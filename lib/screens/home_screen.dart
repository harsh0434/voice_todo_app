import 'package:flutter/material.dart';
import '../widgets/todo_list.dart';
import '../widgets/voice_input.dart';
import '../providers/todo_provider.dart';
import '../models/voice_command.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Voice Todo'), centerTitle: true),
      body: Column(
        children: [
          Expanded(child: const TodoList()),
          const ConversationHistoryWidget(),
          ClarificationPromptBanner(),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Theme.of(context).cardColor,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 8,
                  offset: const Offset(0, -2),
                ),
              ],
            ),
            child: const VoiceInput(),
          ),
          const SizedBox(height: 16),
          QueuedCommandsWidget(),
        ],
      ),
    );
  }
}

class ClarificationPromptBanner extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final prompt = ref.watch(clarificationPromptProvider);
    if (prompt == null) return const SizedBox();
    return Dismissible(
      key: ValueKey(prompt),
      direction: DismissDirection.up,
      onDismissed:
          (_) => ref.read(clarificationPromptProvider.notifier).state = null,
      child: Container(
        width: double.infinity,
        color: Colors.amber.shade200,
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
        child: Row(
          children: [
            const Icon(Icons.info_outline, color: Colors.black87),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                prompt,
                style: const TextStyle(color: Colors.black87),
              ),
            ),
            IconButton(
              icon: const Icon(Icons.close),
              onPressed:
                  () =>
                      ref.read(clarificationPromptProvider.notifier).state =
                          null,
            ),
          ],
        ),
      ),
    );
  }
}

class QueuedCommandsWidget extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final queuedAsync = ref.watch(queuedVoiceCommandsProvider);
    return queuedAsync.when(
      data: (commands) {
        if (commands.isEmpty) {
          return const SizedBox();
        }
        return Card(
          margin: const EdgeInsets.all(16),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Queued Voice Commands:',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                ...commands.map(
                  (cmd) => ListTile(
                    title: Text(cmd.command),
                    subtitle: Text(
                      'Status: ${cmd.status.name} | Queued: ${cmd.timestamp}',
                    ),
                    leading: Icon(
                      cmd.status == VoiceCommandStatus.pending
                          ? Icons.schedule
                          : cmd.status == VoiceCommandStatus.synced
                          ? Icons.check_circle
                          : Icons.error,
                      color:
                          cmd.status == VoiceCommandStatus.pending
                              ? Colors.orange
                              : cmd.status == VoiceCommandStatus.synced
                              ? Colors.green
                              : Colors.red,
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
      loading: () => const CircularProgressIndicator(),
      error: (e, _) => Text('Error loading queued commands: $e'),
    );
  }
}

class ConversationHistoryWidget extends ConsumerWidget {
  const ConversationHistoryWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final queuedAsync = ref.watch(queuedVoiceCommandsProvider);
    return queuedAsync.when(
      data: (commands) {
        if (commands.isEmpty) return const SizedBox();
        return Container(
          height: 200,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: ListView.builder(
            reverse: true,
            itemCount: commands.length,
            itemBuilder: (context, index) {
              final cmd = commands[commands.length - 1 - index];
              return Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Align(
                    alignment: Alignment.centerRight,
                    child: Container(
                      margin: const EdgeInsets.only(bottom: 4),
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: Colors.blue.shade100,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        cmd.command,
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                  if (cmd.appResponse != null)
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Container(
                        margin: const EdgeInsets.only(bottom: 12),
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: Colors.grey.shade200,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(cmd.appResponse!),
                      ),
                    ),
                ],
              );
            },
          ),
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Text('Error loading conversation: $e'),
    );
  }
}
