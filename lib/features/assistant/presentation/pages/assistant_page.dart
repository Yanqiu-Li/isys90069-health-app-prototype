import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../shared/themes/app_theme.dart';
import '../../../../core/services/auth_service.dart';

class AssistantPage extends ConsumerStatefulWidget {
  const AssistantPage({super.key});

  @override
  ConsumerState<AssistantPage> createState() => _AssistantPageState();
}

class _AssistantPageState extends ConsumerState<AssistantPage> {
  final _messageController = TextEditingController();
  final _scrollController = ScrollController();
  final List<ChatMessage> _messages = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _initializeChat();
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _initializeChat() {
    _messages.add(
      ChatMessage(
        text: 'Hello! I\'m your AI health assistant. I can help you understand your blood pressure readings, provide information about hypertension management, and answer your health-related questions. How can I assist you today?',
        isUser: false,
        timestamp: DateTime.now(),
      ),
    );
  }

  Future<void> _sendMessage() async {
    if (_messageController.text.trim().isEmpty) return;

    final userMessage = _messageController.text.trim();
    _messageController.clear();

    setState(() {
      _messages.add(
        ChatMessage(
          text: userMessage,
          isUser: true,
          timestamp: DateTime.now(),
        ),
      );
      _isLoading = true;
    });

    // Scroll to bottom
    _scrollToBottom();

    // Simulate AI response
    await Future.delayed(const Duration(seconds: 2));

    final response = _generateResponse(userMessage);

    setState(() {
      _messages.add(
        ChatMessage(
          text: response,
          isUser: false,
          timestamp: DateTime.now(),
        ),
      );
      _isLoading = false;
    });

    _scrollToBottom();
  }

  String _generateResponse(String userMessage) {
    final message = userMessage.toLowerCase();

    if (message.contains('blood pressure') || message.contains('bp')) {
      return 'Normal blood pressure is typically below 120/80 mmHg. Readings between 120-129 (systolic) and below 80 (diastolic) are considered elevated. If your readings consistently show 130/80 or higher, you may have high blood pressure.\n\nSource: American Heart Association Guidelines (2017)\n\n⚠️ For medical advice, please consult your healthcare provider.';
    } else if (message.contains('medication') || message.contains('medicine')) {
      return 'Common blood pressure medications include:\n\n• ACE inhibitors (like Lisinopril)\n• Calcium channel blockers (like Amlodipine)\n• Beta-blockers (like Metoprolol)\n• Diuretics (like Hydrochlorothiazide)\n\nIt\'s important to take medications as prescribed and never stop without consulting your doctor.\n\nSource: Mayo Clinic\n\n⚠️ Always follow your doctor\'s instructions regarding medications.';
    } else if (message.contains('diet') || message.contains('food')) {
      return 'A heart-healthy diet can help manage blood pressure:\n\n• Limit sodium to less than 2,300mg daily (ideally 1,500mg)\n• Eat plenty of fruits and vegetables\n• Choose whole grains over refined grains\n• Include lean proteins and low-fat dairy\n• Limit saturated and trans fats\n\nThe DASH diet is specifically designed for blood pressure management.\n\nSource: American Heart Association\n\n💡 Small changes in diet can make a big difference!';
    } else if (message.contains('exercise') || message.contains('activity')) {
      return 'Regular physical activity helps lower blood pressure:\n\n• Aim for 150 minutes of moderate aerobic activity weekly\n• Include muscle-strengthening exercises 2+ days per week\n• Even 10 minutes of activity can help\n• Walking, swimming, and cycling are great options\n\nStart slowly and gradually increase intensity.\n\nSource: Physical Activity Guidelines for Americans\n\n⚠️ Check with your doctor before starting new exercise programs.';
    } else if (message.contains('stress') || message.contains('anxiety')) {
      return 'Stress can temporarily raise blood pressure. Here are some stress management techniques:\n\n• Deep breathing exercises\n• Meditation or mindfulness\n• Regular physical activity\n• Adequate sleep (7-9 hours nightly)\n• Social support and connection\n• Time management\n\nChronic stress may contribute to long-term high blood pressure.\n\nSource: American Psychological Association\n\n🧘‍♀️ Try the 4-7-8 breathing technique for quick stress relief.';
    } else if (message.contains('emergency') || message.contains('urgent')) {
      return '🚨 SEEK IMMEDIATE MEDICAL ATTENTION if you experience:\n\n• Blood pressure ≥180/120 mmHg with symptoms\n• Severe headache\n• Chest pain or difficulty breathing\n• Vision changes\n• Severe anxiety or confusion\n• Nausea or vomiting\n\n📞 Call 911 or go to the nearest emergency room immediately.\n\n⚠️ This is not a substitute for emergency medical care.';
    } else if (message.contains('sleep')) {
      return 'Good sleep is important for blood pressure management:\n\n• Aim for 7-9 hours of quality sleep\n• Maintain a consistent sleep schedule\n• Create a relaxing bedtime routine\n• Keep the bedroom cool and dark\n• Avoid caffeine and screens before bed\n• Sleep apnea can affect blood pressure\n\nPoor sleep may contribute to high blood pressure.\n\nSource: Sleep Foundation\n\n😴 Quality sleep is as important as diet and exercise!';
    } else {
      return 'I understand you\'re asking about ${userMessage}. I can provide information about:\n\n• Blood pressure readings and management\n• Medications and their effects\n• Diet and lifestyle recommendations\n• Exercise guidelines\n• Stress management techniques\n\nCould you please be more specific about what you\'d like to know?\n\n⚠️ Remember, I provide educational information only. Always consult your healthcare provider for medical advice.';
    }
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Health Assistant'),
        actions: [
          IconButton(
            onPressed: () {
              setState(() {
                _messages.clear();
                _initializeChat();
              });
            },
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      body: Column(
        children: [
          // Disclaimer Banner
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12.0),
            color: Colors.orange.withOpacity(0.1),
            child: Row(
              children: [
                Icon(
                  Icons.info_outline,
                  color: Colors.orange,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'For informational purposes only. Not medical advice.',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Colors.orange[800],
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ),
          
          // Quick Actions
          Container(
            padding: const EdgeInsets.all(16.0),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  _QuickActionChip(
                    label: 'Blood Pressure Info',
                    onTap: () => _sendQuickMessage('Tell me about blood pressure readings'),
                  ),
                  const SizedBox(width: 8),
                  _QuickActionChip(
                    label: 'Diet Tips',
                    onTap: () => _sendQuickMessage('What foods help lower blood pressure?'),
                  ),
                  const SizedBox(width: 8),
                  _QuickActionChip(
                    label: 'Exercise Guide',
                    onTap: () => _sendQuickMessage('What exercises are good for hypertension?'),
                  ),
                  const SizedBox(width: 8),
                  _QuickActionChip(
                    label: 'Medications',
                    onTap: () => _sendQuickMessage('Tell me about blood pressure medications'),
                  ),
                ],
              ),
            ),
          ),
          
          // Messages
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                final message = _messages[index];
                return _MessageBubble(message: message);
              },
            ),
          ),
          
          // Loading indicator
          if (_isLoading)
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                children: [
                  const CircleAvatar(
                    backgroundColor: AppTheme.primaryColor,
                    child: Icon(Icons.assistant, color: Colors.white, size: 20),
                  ),
                  const SizedBox(width: 12),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color: Colors.grey[300],
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const SizedBox(
                      width: 40,
                      height: 20,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          _TypingDot(),
                          _TypingDot(delay: 200),
                          _TypingDot(delay: 400),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          
          // Input field
          Container(
            padding: const EdgeInsets.all(16.0),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 4,
                  offset: const Offset(0, -2),
                ),
              ],
            ),
            child: SafeArea(
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _messageController,
                      decoration: InputDecoration(
                        hintText: 'Ask about your health...',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(25),
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                      ),
                      onSubmitted: (_) => _sendMessage(),
                      enabled: !_isLoading,
                    ),
                  ),
                  const SizedBox(width: 8),
                  CircleAvatar(
                    backgroundColor: AppTheme.primaryColor,
                    child: IconButton(
                      onPressed: _isLoading ? null : _sendMessage,
                      icon: const Icon(Icons.send, color: Colors.white),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _sendQuickMessage(String message) {
    _messageController.text = message;
    _sendMessage();
  }
}

class ChatMessage {
  final String text;
  final bool isUser;
  final DateTime timestamp;

  ChatMessage({
    required this.text,
    required this.isUser,
    required this.timestamp,
  });
}

class _MessageBubble extends StatelessWidget {
  final ChatMessage message;

  const _MessageBubble({required this.message});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: message.isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
        children: [
          if (!message.isUser) ...[
            const CircleAvatar(
              backgroundColor: AppTheme.primaryColor,
              child: Icon(Icons.assistant, color: Colors.white, size: 20),
            ),
            const SizedBox(width: 8),
          ],
          Flexible(
            child: Container(
              padding: const EdgeInsets.all(12.0),
              decoration: BoxDecoration(
                color: message.isUser 
                    ? AppTheme.primaryColor 
                    : Colors.grey[200],
                borderRadius: BorderRadius.circular(16).copyWith(
                  bottomLeft: message.isUser 
                      ? const Radius.circular(16) 
                      : const Radius.circular(4),
                  bottomRight: message.isUser 
                      ? const Radius.circular(4) 
                      : const Radius.circular(16),
                ),
              ),
              child: Text(
                message.text,
                style: TextStyle(
                  color: message.isUser ? Colors.white : Colors.black87,
                  fontSize: 14,
                ),
              ),
            ),
          ),
          if (message.isUser) ...[
            const SizedBox(width: 8),
            CircleAvatar(
              backgroundColor: Colors.grey[400],
              child: const Icon(Icons.person, color: Colors.white, size: 20),
            ),
          ],
        ],
      ),
    );
  }
}

class _QuickActionChip extends StatelessWidget {
  final String label;
  final VoidCallback onTap;

  const _QuickActionChip({
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ActionChip(
      label: Text(label),
      onPressed: onTap,
      backgroundColor: AppTheme.primaryColor.withOpacity(0.1),
      labelStyle: const TextStyle(
        color: AppTheme.primaryColor,
        fontWeight: FontWeight.w500,
      ),
    );
  }
}

class _TypingDot extends StatefulWidget {
  final int delay;

  const _TypingDot({this.delay = 0});

  @override
  State<_TypingDot> createState() => _TypingDotState();
}

class _TypingDotState extends State<_TypingDot>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    
    _animation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );

    Future.delayed(Duration(milliseconds: widget.delay), () {
      if (mounted) {
        _controller.repeat(reverse: true);
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return Opacity(
          opacity: _animation.value,
          child: Container(
            width: 4,
            height: 4,
            decoration: const BoxDecoration(
              color: Colors.grey,
              shape: BoxShape.circle,
            ),
          ),
        );
      },
    );
  }
}