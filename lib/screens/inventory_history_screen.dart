// lib/screens/inventory_history_screen.dart (ĐÃ CHỈNH SỬA)

import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:intl/intl.dart';
import '../services/db_service.dart';
import '../models/inventory_history.dart';

class InventoryHistoryScreen extends StatelessWidget {
  const InventoryHistoryScreen({super.key});

  String _formatDate(DateTime date) {
    return DateFormat('dd/MM/yyyy HH:mm').format(date);
  }

  // Hàm định dạng tiền tệ (giả sử VNĐ)
  String _formatCurrency(double? amount) {
    if (amount == null) return 'N/A';
    final formatter = NumberFormat('#,###', 'vi_VN');
    return formatter.format(amount) + ' đ';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Lịch sử nhập kho', // Đổi tiêu đề tập trung vào nhập hàng
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.blue.shade600,
        foregroundColor: Colors.white,
        elevation: 1,
      ),
      // SỬ DỤNG VALUELISTENABLEBUILDER ĐỂ ĐỌC DỮ LIỆU TỪ HIVE
      body: ValueListenableBuilder(
        valueListenable: DBService.inventoryHistory().listenable(),
        builder: (context, Box<InventoryHistory> box, _) {
          // Lấy tất cả các bản ghi
          final List<InventoryHistory> history = box.values.toList();

          // Lọc chỉ lấy giao dịch Nhập ("IN")
          final List<InventoryHistory> importHistory = history
              .where((item) => item.transactionType == 'IN')
              .toList();

          // Sắp xếp ngược theo thời gian (mới nhất lên đầu)
          importHistory.sort((a, b) => b.timestamp.compareTo(a.timestamp));

          if (importHistory.isEmpty) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: const [
                  Icon(Icons.history, size: 64, color: Colors.grey),
                  SizedBox(height: 12),
                  Text(
                    'Chưa có lịch sử nhập hàng nào',
                    style: TextStyle(fontSize: 16, color: Colors.grey),
                  ),
                ],
              ),
            );
          }

          return ListView.separated(
            itemCount: importHistory.length,
            separatorBuilder: (context, index) => const Divider(height: 1),
            itemBuilder: (context, index) {
              final item = importHistory[index];
              final color = Colors.green.shade700;

              return ListTile(
                leading: Icon(Icons.call_received, color: color),
                title: Text(
                  '[NHẬP] ${item.productName}',
                  style: TextStyle(fontWeight: FontWeight.bold, color: color),
                ),
                subtitle: Text(
                  'SL: ${item.quantity} - Giá nhập (đơn vị): ${_formatCurrency(item.unitPrice)} • Tổng ước tính: ${_formatCurrency((item.unitPrice ?? 0) * item.quantity)}\n'
                  'Mã: ${item.productId} | Thời gian: ${_formatDate(item.timestamp)}',
                ),
                isThreeLine: true,
              );
            },
          );
        },
      ),
    );
  }
}
