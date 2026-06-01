// lib/models/inventory_history.dart

import 'package:hive_flutter/hive_flutter.dart';

part 'inventory_history.g.dart'; // Vẫn cần dòng này và chạy build_runner

@HiveType(typeId: 11) // TypeId mới, chưa được sử dụng
class InventoryHistory extends HiveObject {
  @HiveField(0)
  final String productId;

  @HiveField(1)
  final String productName;

  @HiveField(2)
  final int quantity;

  @HiveField(3)
  final DateTime timestamp;

  @HiveField(4)
  final String transactionType; // "IN" (Nhập) hoặc "OUT" (Xuất)

  @HiveField(5)
  final double? unitPrice;

  InventoryHistory({
    required this.productId,
    required this.productName,
    required this.quantity,
    required this.timestamp,
    required this.transactionType,
    this.unitPrice,
  });
}