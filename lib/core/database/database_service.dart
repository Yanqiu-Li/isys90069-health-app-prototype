import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:sqflite_sqlcipher/sqflite.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:crypto/crypto.dart';
import 'package:logging/logging.dart';
import 'package:uuid/uuid.dart';

import '../constants/app_constants.dart';
import '../models/fhir_models.dart';

class DatabaseService {
  static final DatabaseService _instance = DatabaseService._internal();
  factory DatabaseService() => _instance;
  static DatabaseService get instance => _instance;
  DatabaseService._internal();

  Database? _database;
  final _logger = Logger('DatabaseService');
  final _secureStorage = const FlutterSecureStorage(
    aOptions: AndroidOptions(
      encryptedSharedPreferences: true,
    ),
    iOptions: IOSOptions(
      accessibility: IOSAccessibility.first_unlock_this_device,
    ),
  );

  static const String _databaseKeyKey = 'database_encryption_key';

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<void> initialize() async {
    await database;
    _logger.info('Database initialized successfully');
  }

  Future<Database> _initDatabase() async {
    try {
      final documentsDirectory = await getApplicationDocumentsDirectory();
      final path = p.join(documentsDirectory.path, AppConstants.databaseName);
      
      // Get or generate encryption key
      final encryptionKey = await _getOrGenerateEncryptionKey();
      
      return await openDatabase(
        path,
        version: AppConstants.databaseVersion,
        onCreate: _onCreate,
        onUpgrade: _onUpgrade,
        password: encryptionKey,
        singleInstance: true,
        readOnly: false,
      );
    } catch (e) {
      _logger.severe('Failed to initialize database: $e');
      rethrow;
    }
  }

  Future<String> _getOrGenerateEncryptionKey() async {
    try {
      // Try to get existing key
      String? existingKey = await _secureStorage.read(key: _databaseKeyKey);
      
      if (existingKey != null && existingKey.isNotEmpty) {
        return existingKey;
      }

      // Generate new key if none exists
      final bytes = List<int>.generate(32, (i) => 
        DateTime.now().millisecondsSinceEpoch + i);
      final key = sha256.convert(bytes).toString();
      
      // Store the key securely
      await _secureStorage.write(key: _databaseKeyKey, value: key);
      
      _logger.info('Generated new database encryption key');
      return key;
    } catch (e) {
      _logger.severe('Failed to get/generate encryption key: $e');
      rethrow;
    }
  }

  Future<void> _onCreate(Database db, int version) async {
    await _createTables(db);
    _logger.info('Database tables created');
  }

  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    _logger.info('Upgrading database from $oldVersion to $newVersion');
    // Add migration logic here when needed
  }

  Future<void> _createTables(Database db) async {
    // FHIR Resources table - stores all FHIR resources as JSON
    await db.execute('''
      CREATE TABLE fhir_resources (
        id TEXT PRIMARY KEY,
        resource_type TEXT NOT NULL,
        subject_id TEXT,
        effective_date_time TEXT,
        created_at TEXT NOT NULL,
        updated_at TEXT NOT NULL,
        data TEXT NOT NULL,
        sync_status INTEGER DEFAULT 0,
        version_id TEXT,
        INDEX(resource_type),
        INDEX(subject_id),
        INDEX(effective_date_time),
        INDEX(sync_status)
      )
    ''');

    // Blood Pressure readings table - optimized for queries
    await db.execute('''
      CREATE TABLE blood_pressure_readings (
        id TEXT PRIMARY KEY,
        patient_id TEXT NOT NULL,
        systolic REAL NOT NULL,
        diastolic REAL NOT NULL,
        timestamp TEXT NOT NULL,
        device_id TEXT,
        position TEXT,
        cuff_size INTEGER,
        session_id TEXT,
        reading_number INTEGER,
        created_at TEXT NOT NULL,
        fhir_resource_id TEXT,
        INDEX(patient_id),
        INDEX(timestamp),
        INDEX(session_id),
        FOREIGN KEY(fhir_resource_id) REFERENCES fhir_resources(id)
      )
    ''');

    // Medications table
    await db.execute('''
      CREATE TABLE medications (
        id TEXT PRIMARY KEY,
        patient_id TEXT NOT NULL,
        medication_code TEXT NOT NULL,
        medication_name TEXT NOT NULL,
        dosage TEXT,
        frequency TEXT,
        status TEXT DEFAULT 'active',
        start_date TEXT,
        end_date TEXT,
        prescriber_id TEXT,
        created_at TEXT NOT NULL,
        updated_at TEXT NOT NULL,
        fhir_resource_id TEXT,
        INDEX(patient_id),
        INDEX(status),
        FOREIGN KEY(fhir_resource_id) REFERENCES fhir_resources(id)
      )
    ''');

    // Medication adherence events
    await db.execute('''
      CREATE TABLE medication_events (
        id TEXT PRIMARY KEY,
        medication_id TEXT NOT NULL,
        scheduled_time TEXT NOT NULL,
        actual_time TEXT,
        status TEXT NOT NULL, -- 'taken', 'missed', 'late'
        reason TEXT,
        notes TEXT,
        created_at TEXT NOT NULL,
        INDEX(medication_id),
        INDEX(scheduled_time),
        INDEX(status),
        FOREIGN KEY(medication_id) REFERENCES medications(id)
      )
    ''');

    // Care plans and activities
    await db.execute('''
      CREATE TABLE care_plans (
        id TEXT PRIMARY KEY,
        patient_id TEXT NOT NULL,
        title TEXT,
        description TEXT,
        status TEXT DEFAULT 'active',
        start_date TEXT,
        end_date TEXT,
        created_at TEXT NOT NULL,
        updated_at TEXT NOT NULL,
        fhir_resource_id TEXT,
        INDEX(patient_id),
        INDEX(status),
        FOREIGN KEY(fhir_resource_id) REFERENCES fhir_resources(id)
      )
    ''');

    // Lifestyle questionnaire responses
    await db.execute('''
      CREATE TABLE questionnaire_responses (
        id TEXT PRIMARY KEY,
        patient_id TEXT NOT NULL,
        questionnaire_type TEXT NOT NULL,
        response_data TEXT NOT NULL,
        completed_at TEXT NOT NULL,
        score REAL,
        created_at TEXT NOT NULL,
        fhir_resource_id TEXT,
        INDEX(patient_id),
        INDEX(questionnaire_type),
        INDEX(completed_at),
        FOREIGN KEY(fhir_resource_id) REFERENCES fhir_resources(id)
      )
    ''');

    // Device information
    await db.execute('''
      CREATE TABLE devices (
        id TEXT PRIMARY KEY,
        device_type TEXT NOT NULL,
        manufacturer TEXT,
        model TEXT,
        serial_number TEXT,
        firmware_version TEXT,
        calibration_date TEXT,
        last_connected TEXT,
        bluetooth_address TEXT,
        is_validated BOOLEAN DEFAULT 0,
        created_at TEXT NOT NULL,
        updated_at TEXT NOT NULL,
        INDEX(device_type),
        INDEX(bluetooth_address)
      )
    ''');

    // Sync queue for offline operations
    await db.execute('''
      CREATE TABLE sync_queue (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        operation TEXT NOT NULL, -- 'CREATE', 'UPDATE', 'DELETE'
        resource_type TEXT NOT NULL,
        resource_id TEXT NOT NULL,
        data TEXT,
        created_at TEXT NOT NULL,
        retry_count INTEGER DEFAULT 0,
        last_error TEXT,
        INDEX(operation),
        INDEX(resource_type),
        INDEX(created_at)
      )
    ''');

    // Audit log
    await db.execute('''
      CREATE TABLE audit_log (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        user_id TEXT,
        action TEXT NOT NULL,
        resource_type TEXT,
        resource_id TEXT,
        details TEXT,
        ip_address TEXT,
        user_agent TEXT,
        timestamp TEXT NOT NULL,
        INDEX(user_id),
        INDEX(action),
        INDEX(timestamp)
      )
    ''');
  }

  // Generic FHIR resource operations
  Future<String> insertFhirResource(FhirResource resource) async {
    final db = await database;
    final now = DateTime.now().toIso8601String();
    
    try {
      await db.insert('fhir_resources', {
        'id': resource.id,
        'resource_type': resource.resourceType,
        'subject_id': _extractSubjectId(resource),
        'effective_date_time': _extractEffectiveDateTime(resource),
        'created_at': now,
        'updated_at': now,
        'data': jsonEncode(resource.toJson()),
        'sync_status': 0, // 0 = not synced, 1 = synced
        'version_id': resource.meta?.versionId,
      });

      await _logAudit('CREATE', resource.resourceType, resource.id);
      _logger.info('Inserted FHIR resource: ${resource.resourceType}/${resource.id}');
      return resource.id;
    } catch (e) {
      _logger.severe('Failed to insert FHIR resource: $e');
      rethrow;
    }
  }

  Future<void> updateFhirResource(FhirResource resource) async {
    final db = await database;
    final now = DateTime.now().toIso8601String();
    
    try {
      await db.update(
        'fhir_resources',
        {
          'subject_id': _extractSubjectId(resource),
          'effective_date_time': _extractEffectiveDateTime(resource),
          'updated_at': now,
          'data': jsonEncode(resource.toJson()),
          'sync_status': 0, // Mark as needing sync
          'version_id': resource.meta?.versionId,
        },
        where: 'id = ?',
        whereArgs: [resource.id],
      );

      await _logAudit('UPDATE', resource.resourceType, resource.id);
      _logger.info('Updated FHIR resource: ${resource.resourceType}/${resource.id}');
    } catch (e) {
      _logger.severe('Failed to update FHIR resource: $e');
      rethrow;
    }
  }

  Future<Map<String, dynamic>?> getFhirResource(String resourceType, String id) async {
    final db = await database;
    
    try {
      final results = await db.query(
        'fhir_resources',
        where: 'resource_type = ? AND id = ?',
        whereArgs: [resourceType, id],
        limit: 1,
      );

      if (results.isEmpty) return null;

      await _logAudit('READ', resourceType, id);
      return jsonDecode(results.first['data'] as String);
    } catch (e) {
      _logger.severe('Failed to get FHIR resource: $e');
      rethrow;
    }
  }

  Future<List<Map<String, dynamic>>> queryFhirResources(
    String resourceType, {
    String? subjectId,
    DateTime? startDate,
    DateTime? endDate,
    int? limit,
    int? offset,
  }) async {
    final db = await database;
    
    try {
      final whereClause = <String>['resource_type = ?'];
      final whereArgs = <dynamic>[resourceType];

      if (subjectId != null) {
        whereClause.add('subject_id = ?');
        whereArgs.add(subjectId);
      }

      if (startDate != null) {
        whereClause.add('effective_date_time >= ?');
        whereArgs.add(startDate.toIso8601String());
      }

      if (endDate != null) {
        whereClause.add('effective_date_time <= ?');
        whereArgs.add(endDate.toIso8601String());
      }

      final results = await db.query(
        'fhir_resources',
        where: whereClause.join(' AND '),
        whereArgs: whereArgs,
        orderBy: 'effective_date_time DESC',
        limit: limit,
        offset: offset,
      );

      await _logAudit('QUERY', resourceType, null, details: {
        'count': results.length,
        'subjectId': subjectId,
      });

      return results.map((row) => jsonDecode(row['data'] as String)).toList();
    } catch (e) {
      _logger.severe('Failed to query FHIR resources: $e');
      rethrow;
    }
  }

  // Blood pressure specific operations
  Future<void> insertBloodPressureReading({
    required String patientId,
    required double systolic,
    required double diastolic,
    required DateTime timestamp,
    String? deviceId,
    String? position,
    int? cuffSize,
    String? sessionId,
    int? readingNumber,
  }) async {
    final db = await database;
    final id = const Uuid().v4();
    final now = DateTime.now().toIso8601String();
    
    try {
      await db.insert('blood_pressure_readings', {
        'id': id,
        'patient_id': patientId,
        'systolic': systolic,
        'diastolic': diastolic,
        'timestamp': timestamp.toIso8601String(),
        'device_id': deviceId,
        'position': position,
        'cuff_size': cuffSize,
        'session_id': sessionId,
        'reading_number': readingNumber,
        'created_at': now,
      });

      await _logAudit('CREATE', 'BloodPressureReading', id);
      _logger.info('Inserted blood pressure reading: $systolic/$diastolic mmHg');
    } catch (e) {
      _logger.severe('Failed to insert blood pressure reading: $e');
      rethrow;
    }
  }

  Future<List<Map<String, dynamic>>> getBloodPressureReadings({
    required String patientId,
    DateTime? startDate,
    DateTime? endDate,
    int? limit,
  }) async {
    final db = await database;
    
    try {
      final whereClause = <String>['patient_id = ?'];
      final whereArgs = <dynamic>[patientId];

      if (startDate != null) {
        whereClause.add('timestamp >= ?');
        whereArgs.add(startDate.toIso8601String());
      }

      if (endDate != null) {
        whereClause.add('timestamp <= ?');
        whereArgs.add(endDate.toIso8601String());
      }

      final results = await db.query(
        'blood_pressure_readings',
        where: whereClause.join(' AND '),
        whereArgs: whereArgs,
        orderBy: 'timestamp DESC',
        limit: limit,
      );

      await _logAudit('QUERY', 'BloodPressureReading', null, details: {
        'count': results.length,
        'patientId': patientId,
      });

      return results;
    } catch (e) {
      _logger.severe('Failed to get blood pressure readings: $e');
      rethrow;
    }
  }

  // Sync operations
  Future<void> addToSyncQueue(
    String operation,
    String resourceType,
    String resourceId, {
    Map<String, dynamic>? data,
  }) async {
    final db = await database;
    
    try {
      await db.insert('sync_queue', {
        'operation': operation,
        'resource_type': resourceType,
        'resource_id': resourceId,
        'data': data != null ? jsonEncode(data) : null,
        'created_at': DateTime.now().toIso8601String(),
        'retry_count': 0,
      });

      _logger.info('Added to sync queue: $operation $resourceType/$resourceId');
    } catch (e) {
      _logger.severe('Failed to add to sync queue: $e');
      rethrow;
    }
  }

  Future<List<Map<String, dynamic>>> getPendingSyncItems() async {
    final db = await database;
    
    try {
      return await db.query(
        'sync_queue',
        orderBy: 'created_at ASC',
        limit: 100, // Process in batches
      );
    } catch (e) {
      _logger.severe('Failed to get pending sync items: $e');
      rethrow;
    }
  }

  Future<void> removeSyncItem(int id) async {
    final db = await database;
    
    try {
      await db.delete('sync_queue', where: 'id = ?', whereArgs: [id]);
    } catch (e) {
      _logger.severe('Failed to remove sync item: $e');
      rethrow;
    }
  }

  // Helper methods
  String? _extractSubjectId(FhirResource resource) {
    if (resource is BloodPressureObservation) {
      return resource.subject.reference?.split('/').last;
    }
    if (resource is MedicationRequest) {
      return resource.subject.reference?.split('/').last;
    }
    if (resource is CarePlan) {
      return resource.subject.reference?.split('/').last;
    }
    return null;
  }

  String? _extractEffectiveDateTime(FhirResource resource) {
    if (resource is BloodPressureObservation) {
      return resource.effectiveDateTime.toIso8601String();
    }
    if (resource is MedicationRequest) {
      return resource.authoredOn?.toIso8601String();
    }
    return null;
  }

  Future<void> _logAudit(
    String action,
    String resourceType,
    String? resourceId, {
    Map<String, dynamic>? details,
  }) async {
    final db = await database;
    
    try {
      await db.insert('audit_log', {
        'action': action,
        'resource_type': resourceType,
        'resource_id': resourceId,
        'details': details != null ? jsonEncode(details) : null,
        'timestamp': DateTime.now().toIso8601String(),
      });
    } catch (e) {
      _logger.warning('Failed to log audit: $e');
    }
  }

  Future<void> close() async {
    final db = _database;
    if (db != null) {
      await db.close();
      _database = null;
      _logger.info('Database connection closed');
    }
  }
}