import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:oauth2/oauth2.dart' as oauth2;
import 'package:http/http.dart' as http;
import 'package:logging/logging.dart';
import 'dart:convert';

import '../constants/app_constants.dart';

// User model
class User {
  final String id;
  final String email;
  final String? name;
  final String? patientId;
  final Map<String, dynamic> metadata;

  User({
    required this.id,
    required this.email,
    this.name,
    this.patientId,
    this.metadata = const {},
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] as String,
      email: json['email'] as String,
      name: json['name'] as String?,
      patientId: json['patientId'] as String?,
      metadata: json['metadata'] as Map<String, dynamic>? ?? {},
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'name': name,
      'patientId': patientId,
      'metadata': metadata,
    };
  }
}

class AuthService extends ChangeNotifier {
  static final AuthService _instance = AuthService._internal();
  factory AuthService() => _instance;
  static AuthService get instance => _instance;
  AuthService._internal();

  final _logger = Logger('AuthService');
  final _secureStorage = const FlutterSecureStorage(
    aOptions: AndroidOptions(
      encryptedSharedPreferences: true,
    ),
    iOptions: IOSOptions(
      accessibility: IOSAccessibility.first_unlock_this_device,
    ),
  );

  User? _currentUser;
  oauth2.Client? _oauthClient;

  User? get currentUser => _currentUser;
  bool get isAuthenticated => _currentUser != null;

  static const String _userKey = 'current_user';
  static const String _tokenKey = 'auth_token';
  static const String _refreshTokenKey = 'refresh_token';

  Future<void> initialize() async {
    try {
      await _loadPersistedUser();
      _logger.info('AuthService initialized');
    } catch (e) {
      _logger.severe('Failed to initialize AuthService: $e');
    }
  }

  Future<void> _loadPersistedUser() async {
    try {
      final userJson = await _secureStorage.read(key: _userKey);
      final token = await _secureStorage.read(key: _tokenKey);

      if (userJson != null && token != null) {
        _currentUser = User.fromJson(jsonDecode(userJson));
        
        // Try to restore OAuth client if we have tokens
        await _restoreOAuthClient();
        
        notifyListeners();
        _logger.info('User session restored: ${_currentUser!.email}');
      }
    } catch (e) {
      _logger.warning('Failed to restore user session: $e');
      await _clearStoredAuth();
    }
  }

  Future<void> _restoreOAuthClient() async {
    try {
      final token = await _secureStorage.read(key: _tokenKey);
      final refreshToken = await _secureStorage.read(key: _refreshTokenKey);

      if (token != null) {
        final credentials = oauth2.Credentials(
          token,
          refreshToken: refreshToken,
          scopes: AppConstants.requiredScopes,
        );

        _oauthClient = oauth2.Client(
          credentials,
          identifier: 'hypertension_app',
          secret: null, // For PKCE flow
        );
      }
    } catch (e) {
      _logger.warning('Failed to restore OAuth client: $e');
    }
  }

  Future<User> signInWithEmailPassword(String email, String password) async {
    try {
      _logger.info('Attempting email/password sign in for: $email');
      
      // For demo purposes, we'll simulate authentication
      // In a real app, this would call your authentication API
      if (email == 'demo@hypertension-app.com' && password == 'demo123') {
        final user = User(
          id: 'demo-user-123',
          email: email,
          name: 'Demo Patient',
          patientId: 'patient-demo-123',
          metadata: {
            'authMethod': 'email_password',
            'createdAt': DateTime.now().toIso8601String(),
          },
        );

        await _setCurrentUser(user);
        return user;
      } else {
        throw Exception('Invalid email or password');
      }
    } catch (e) {
      _logger.severe('Email/password sign in failed: $e');
      rethrow;
    }
  }

  Future<User> signInWithSmartOnFhir() async {
    try {
      _logger.info('Attempting SMART on FHIR authentication');
      
      // SMART on FHIR OAuth2 flow
      final authorizationEndpoint = Uri.parse('${AppConstants.baseUrl}${AppConstants.smartAuthEndpoint}/authorize');
      final tokenEndpoint = Uri.parse('${AppConstants.baseUrl}${AppConstants.smartAuthEndpoint}/token');
      
      final grant = oauth2.AuthorizationCodeGrant(
        'hypertension_app',
        authorizationEndpoint,
        tokenEndpoint,
        httpClient: http.Client(),
      );

      final authorizationUrl = grant.getAuthorizationUrl(
        Uri.parse('com.isys90069.hypertension://callback'),
        scopes: AppConstants.requiredScopes,
      );

      // In a real app, this would open a web browser or webview
      // For demo purposes, simulate successful authentication
      _logger.info('Authorization URL: $authorizationUrl');
      
      // Simulate OAuth callback with authorization code
      // In practice, this would be handled by the app's deep link handling
      final simulatedCode = 'demo_auth_code_123';
      
      // Exchange code for tokens (simulated)
      final user = User(
        id: 'fhir-user-456',
        email: 'patient@example.com',
        name: 'John Doe',
        patientId: 'patient-fhir-456',
        metadata: {
          'authMethod': 'smart_on_fhir',
          'ehr': 'Epic',
          'createdAt': DateTime.now().toIso8601String(),
        },
      );

      await _setCurrentUser(user);
      return user;
    } catch (e) {
      _logger.severe('SMART on FHIR authentication failed: $e');
      rethrow;
    }
  }

  Future<void> _setCurrentUser(User user) async {
    _currentUser = user;
    
    // Persist user data
    await _secureStorage.write(key: _userKey, value: jsonEncode(user.toJson()));
    
    // Generate demo token for API calls
    final demoToken = 'demo_token_${DateTime.now().millisecondsSinceEpoch}';
    await _secureStorage.write(key: _tokenKey, value: demoToken);
    
    notifyListeners();
    _logger.info('User signed in: ${user.email}');
  }

  Future<void> signOut() async {
    try {
      _logger.info('Signing out user: ${_currentUser?.email}');
      
      _currentUser = null;
      _oauthClient?.close();
      _oauthClient = null;
      
      await _clearStoredAuth();
      
      notifyListeners();
      _logger.info('User signed out successfully');
    } catch (e) {
      _logger.severe('Sign out failed: $e');
      rethrow;
    }
  }

  Future<void> _clearStoredAuth() async {
    await Future.wait([
      _secureStorage.delete(key: _userKey),
      _secureStorage.delete(key: _tokenKey),
      _secureStorage.delete(key: _refreshTokenKey),
    ]);
  }

  Future<String?> getAuthToken() async {
    try {
      return await _secureStorage.read(key: _tokenKey);
    } catch (e) {
      _logger.warning('Failed to get auth token: $e');
      return null;
    }
  }

  Future<Map<String, String>> getAuthHeaders() async {
    final token = await getAuthToken();
    if (token != null) {
      return {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/fhir+json',
        'Accept': 'application/fhir+json',
      };
    }
    return {
      'Content-Type': 'application/fhir+json',
      'Accept': 'application/fhir+json',
    };
  }

  Future<bool> refreshToken() async {
    try {
      if (_oauthClient?.credentials.refreshToken != null) {
        _oauthClient = await _oauthClient!.refreshCredentials();
        
        // Update stored tokens
        await _secureStorage.write(
          key: _tokenKey,
          value: _oauthClient!.credentials.accessToken,
        );
        
        if (_oauthClient!.credentials.refreshToken != null) {
          await _secureStorage.write(
            key: _refreshTokenKey,
            value: _oauthClient!.credentials.refreshToken!,
          );
        }
        
        _logger.info('Token refreshed successfully');
        return true;
      }
      return false;
    } catch (e) {
      _logger.warning('Token refresh failed: $e');
      return false;
    }
  }
}

// Riverpod providers
final authServiceProvider = Provider<AuthService>((ref) => AuthService.instance);

final authStateProvider = StreamProvider<User?>((ref) {
  final authService = ref.watch(authServiceProvider);
  
  // Create a stream that emits the current user when it changes
  return Stream.value(authService.currentUser).asyncExpand((user) async* {
    yield user;
    
    // Listen for changes
    authService.addListener(() {
      // This will be called when notifyListeners() is called
    });
  });
});

final currentUserProvider = Provider<User?>((ref) {
  final authState = ref.watch(authStateProvider);
  return authState.value;
});