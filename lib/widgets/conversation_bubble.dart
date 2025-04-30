import 'package:flutter/material.dart';
import '../models/voice_command.dart';

class ConversationBubble extends StatelessWidget {
  final VoiceCommand command;
  final bool isUser;

  const ConversationBubble({
    super.key,
    required this.command,
    required this.isUser,
  });

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isUser ? Colors.blue.shade100 : Colors.grey.shade200,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              command.command,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: isUser ? Colors.blue.shade900 : Colors.black87,
              ),
            ),
            if (command.appResponse != null) ...[
              const SizedBox(height: 4),
              Text(
                command.appResponse!,
                style: TextStyle(
                  color: isUser ? Colors.blue.shade700 : Colors.black54,
                  fontSize: 12,
                ),
              ),
            ],
            const SizedBox(height: 4),
            Text(
              _formatTimestamp(command.timestamp),
              style: TextStyle(color: Colors.grey.shade600, fontSize: 10),
            ),
          ],
        ),
      ),
    );
  }

  String _formatTimestamp(DateTime timestamp) {
    return '${timestamp.hour.toString().padLeft(2, '0')}:${timestamp.minute.toString().padLeft(2, '0')}';
  }
}
