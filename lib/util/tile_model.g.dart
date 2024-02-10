// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'tile_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class TileModelAdapter extends TypeAdapter<TileModel> {
  @override
  final int typeId = 0;

  @override
  TileModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return TileModel(
      emoji: fields[0] as String,
      customName: fields[1] as String,
      linkToProduct: fields[2] as String,
      inputNotificationDate: fields[3] as int,
      daysTillNotification: fields[4] as int,
      creationTime: fields[6] as DateTime,
      notificationDate: fields[7] as DateTime,
    );
  }

  @override
  void write(BinaryWriter writer, TileModel obj) {
    writer
      ..writeByte(8)
      ..writeByte(0)
      ..write(obj.emoji)
      ..writeByte(1)
      ..write(obj.customName)
      ..writeByte(2)
      ..write(obj.linkToProduct)
      ..writeByte(3)
      ..write(obj.inputNotificationDate)
      ..writeByte(5)
      ..write(obj.id)
      ..writeByte(6)
      ..write(obj.creationTime)
      ..writeByte(7)
      ..write(obj.notificationDate)
      ..writeByte(4)
      ..write(obj.daysTillNotification);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TileModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
