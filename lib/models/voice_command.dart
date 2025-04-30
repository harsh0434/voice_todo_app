import 'package:hive/hive.dart';

part 'voice_command.g.dart';

@HiveType(typeId: 1)
enum VoiceCommandStatus {
  @HiveField(0)
  pending,
  @HiveField(1)
  synced,
  @HiveField(2)
  error,
}

@HiveType(typeId: 2)
class VoiceCommand extends HiveObject {
  @HiveField(0)
  String command;
  @HiveField(1)
  DateTime timestamp;
  @HiveField(2)
  VoiceCommandStatus status;
  @HiveField(3)
  String? appResponse;

  VoiceCommand({
    required this.command,
    required this.timestamp,
    this.status = VoiceCommandStatus.pending,
    this.appResponse,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': key, // Use HiveObject's key as the SQLite id
      'command': command,
      'timestamp': timestamp.toIso8601String(),
      'status': status.name,
      'appResponse': appResponse,
    };
  }

  static VoiceCommand fromMap(Map<String, dynamic> map) {
    return VoiceCommand(
      command: map['command'],
      timestamp: DateTime.parse(map['timestamp']),
      status: VoiceCommandStatus.values.firstWhere(
        (e) => e.name == map['status'],
        orElse: () => VoiceCommandStatus.pending,
      ),
      appResponse: map['appResponse'],
    );
  }
}
