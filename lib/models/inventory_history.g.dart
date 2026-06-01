// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'inventory_history.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class InventoryHistoryAdapter extends TypeAdapter<InventoryHistory> {
  @override
  final int typeId = 11;

  @override
  InventoryHistory read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return InventoryHistory(
      productId: fields[0] as String,
      productName: fields[1] as String,
      quantity: fields[2] as int,
      timestamp: fields[3] as DateTime,
      transactionType: fields[4] as String,
      unitPrice: fields[5] as double?,
    );
  }

  @override
  void write(BinaryWriter writer, InventoryHistory obj) {
    writer
      ..writeByte(6)
      ..writeByte(0)
      ..write(obj.productId)
      ..writeByte(1)
      ..write(obj.productName)
      ..writeByte(2)
      ..write(obj.quantity)
      ..writeByte(3)
      ..write(obj.timestamp)
      ..writeByte(4)
      ..write(obj.transactionType)
      ..writeByte(5)
      ..write(obj.unitPrice);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is InventoryHistoryAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
