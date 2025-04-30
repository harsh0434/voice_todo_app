// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'voice_command.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class VoiceCommandAdapter extends TypeAdapter<VoiceCommand> {
  @override
  final int typeId = 2;

  @override
  VoiceCommand read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return VoiceCommand(
      command: fields[0] as String,
      timestamp: fields[1] as DateTime,
      status: fields[2] as VoiceCommandStatus,
    );
  }

  @override
  void write(BinaryWriter writer, VoiceCommand obj) {
    writer
      ..writeByte(3)
      ..writeByte(0)
      ..write(obj.command)
      ..writeByte(1)
      ..write(obj.timestamp)
      ..writeByte(2)
      ..write(obj.status);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is VoiceCommandAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class VoiceCommandStatusAdapter extends TypeAdapter<VoiceCommandStatus> {
  @override
  final int typeId = 1;

  @override
  VoiceCommandStatus read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return VoiceCommandStatus.pending;
      case 1:
        return VoiceCommandStatus.synced;
      case 2:
        return VoiceCommandStatus.error;
      default:
        return VoiceCommandStatus.pending;
    }
  }

  @override
  void write(BinaryWriter writer, VoiceCommandStatus obj) {
    switch (obj) {
      case VoiceCommandStatus.pending:
        writer.writeByte(0);
        break;
      case VoiceCommandStatus.synced:
        writer.writeByte(1);
        break;
      case VoiceCommandStatus.error:
        writer.writeByte(2);
        break;
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is VoiceCommandStatusAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
