// lib/models/product.dart
import 'package:hive/hive.dart';

part 'product.g.dart';

@HiveType(typeId: 0)
class Product extends HiveObject {
  @HiveField(0)
  String id;

  @HiveField(1)
  String name;

  @HiveField(2)
  double price;

  @HiveField(3)
  String unit;

  @HiveField(4)
  int stockQuantity;

  @HiveField(5) // <-- THÊM DÒNG NÀY (sử dụng index tiếp theo)
  DateTime? createdAt; // <-- THÊM TRƯỜNG NÀY (nullable)

  Product({
    required this.id,
    required this.name,
    required this.price,
    required this.unit,
    this.stockQuantity = 0,
    this.createdAt, // <-- THÊM VÀO CONSTRUCTOR (không 'required')
  });
}