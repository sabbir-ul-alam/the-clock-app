// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'alarm.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class RingToneAdapter extends TypeAdapter<RingTone> {
  @override
  final int typeId = 1;

  @override
  RingTone read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return RingTone(
      fields[1] as String,
      fields[0] as String,
    );
  }

  @override
  void write(BinaryWriter writer, RingTone obj) {
    writer
      ..writeByte(2)
      ..writeByte(0)
      ..write(obj.tonePath)
      ..writeByte(1)
      ..write(obj.toneName);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is RingToneAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class AlarmAdapter extends TypeAdapter<Alarm> {
  @override
  final int typeId = 2;

  @override
  Alarm read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Alarm(
      id: fields[0] as int,
      alarmName: fields[1] as String?,
      alarmTime: fields[2] as DateTime,
      ringTonePath: fields[3] as RingTone?,
      snoozeDuration: fields[4] as int,
      listOfDays: (fields[5] as List?)?.cast<Day>(),
      isAlarm: fields[6] as bool,
      vibration: fields[7] as bool,
      isEnabled: fields[8] as bool,
    );
  }

  @override
  void write(BinaryWriter writer, Alarm obj) {
    writer
      ..writeByte(9)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.alarmName)
      ..writeByte(2)
      ..write(obj.alarmTime)
      ..writeByte(3)
      ..write(obj.ringTonePath)
      ..writeByte(4)
      ..write(obj.snoozeDuration)
      ..writeByte(5)
      ..write(obj.listOfDays)
      ..writeByte(6)
      ..write(obj.isAlarm)
      ..writeByte(7)
      ..write(obj.vibration)
      ..writeByte(8)
      ..write(obj.isEnabled);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AlarmAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class DayAdapter extends TypeAdapter<Day> {
  @override
  final int typeId = 0;

  @override
  Day read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return Day.sunday;
      case 1:
        return Day.monday;
      case 2:
        return Day.tuesday;
      case 3:
        return Day.wednesday;
      case 4:
        return Day.thursday;
      case 5:
        return Day.friday;
      case 6:
        return Day.saturday;
      default:
        return Day.sunday;
    }
  }

  @override
  void write(BinaryWriter writer, Day obj) {
    switch (obj) {
      case Day.sunday:
        writer.writeByte(0);
        break;
      case Day.monday:
        writer.writeByte(1);
        break;
      case Day.tuesday:
        writer.writeByte(2);
        break;
      case Day.wednesday:
        writer.writeByte(3);
        break;
      case Day.thursday:
        writer.writeByte(4);
        break;
      case Day.friday:
        writer.writeByte(5);
        break;
      case Day.saturday:
        writer.writeByte(6);
        break;
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is DayAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
