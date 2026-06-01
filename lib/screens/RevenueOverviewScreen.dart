// lib/screens/RevenueOverviewScreen.dart (ĐÃ SỬA LỖI CUỐI CÙNG)

import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'order_list_screen.dart';
import '../services/db_service.dart';
import '../models/order.dart';
import '../models/product.dart';
import 'new_products_screen.dart';
import '../models/order_line.dart'; // <-- Import OrderLine

class RevenueOverviewScreen extends StatefulWidget {
  const RevenueOverviewScreen({super.key});

  @override
  State<RevenueOverviewScreen> createState() => _RevenueOverviewScreenState();
}

class _RevenueOverviewScreenState extends State<RevenueOverviewScreen> {
  // Tách Widget Card số liệu (Giữ nguyên)
  Widget _buildMetricCard(
      String title, String value, IconData icon, Color color,
      {VoidCallback? onTap}) {
    return Expanded(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Card(
          elevation: 1,
          shape:
          RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title,
                    style:
                    const TextStyle(fontSize: 14, color: Colors.black54)),
                const SizedBox(height: 8),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.baseline,
                  textBaseline: TextBaseline.alphabetic,
                  children: [
                    Text(
                      value,
                      style: const TextStyle(
                          fontSize: 24, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(width: 4),
                    Icon(icon, size: 16, color: color),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // Hàm định dạng tiền tệ (Giữ nguyên)
  String _formatCurrency(double amount) {
    return '${amount.round().toString().replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
          (Match m) => '${m[1]},',
    )} ₫';
  }

  // Widget hiển thị Hiệu suất sản phẩm (Giữ nguyên)
  Widget _buildProductPerformanceTile(
      String name, String quantity, String imagePath) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 3,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Image.asset(
              imagePath,
              width: 50,
              height: 50,
              fit: BoxFit.cover,
              errorBuilder: (c, e, s) => Container(
                width: 50,
                height: 50,
                color: Colors.grey.shade200,
                child: const Icon(Icons.image_not_supported, size: 20),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: const TextStyle(
                      fontSize: 16, fontWeight: FontWeight.bold),
                ),
                Text(
                  quantity,
                  style: const TextStyle(fontSize: 14, color: Colors.black54),
                ),
              ],
            ),
          ),
          const Icon(Icons.trending_up, color: Colors.green),
        ],
      ),
    );
  }

  // Widget hỗ trợ lấy ảnh (Giữ nguyên)
  String _getImagePathForProduct(String productId) {
    String id = productId.toLowerCase();
    if (id.contains('táo') || id.contains('anh1')) {
      return 'assets/images/anh1.png';
    }
    if (id.contains('sprite') || id.contains('coke')) {
      return 'assets/images/coke.png';
    }
    if (id.contains('chuối')) {
      return 'assets/images/chuoi.png';
    }
    // Bạn nên tạo 1 ảnh mặc định trong assets/images/
    return 'assets/images/default_product.png';
  }

  @override
  Widget build(BuildContext context) {
    // ValueListenableBuilder này cho Orders
    return ValueListenableBuilder<Box<Order>>(
      valueListenable: DBService.orders().listenable(),
      builder: (context, orderBox, _) {
        final totalOrders = orderBox.length;
        final totalRevenue = DBService.getTotalRevenue();

        // --- BẮT ĐẦU LOGIC HIỆU SUẤT SẢN PHẨM (ĐÃ SỬA LỖI) ---
        final productsBox = DBService.products();

        // SỬA LỖI 2: Đổi <String, int> thành <String, double>
        final Map<String, double> productSaleCounts = {};

        // 1. Tổng hợp số lượng bán ra từ tất cả đơn hàng
        for (final order in orderBox.values) {

          // SỬA LỖI 1: Đổi 'order.orderLines' thành 'order.items'
          for (final line in order.items) {

            // SỬA LỖI 2: Đổi '?? 0' thành '?? 0.0' để giữ kiểu double
            productSaleCounts[line.productId] =
                (productSaleCounts[line.productId] ?? 0.0) + line.quantity;
          }
        }

        // 2. Chuyển đổi thành danh sách và sắp xếp giảm dần
        // SỬA LỖI 2: Đổi <String, int> thành <String, double>
        final List<MapEntry<String, double>> sortedSales =
        productSaleCounts.entries.toList();
        sortedSales.sort((a, b) => b.value.compareTo(a.value)); // Sắp xếp giảm dần

        // 3. Lấy 3 sản phẩm bán chạy nhất
        final topSales = sortedSales.take(3).toList();
        // --- KẾT THÚC LOGIC HIỆU SUẤT SẢN PHẨM ---

        return Scaffold(
          appBar: AppBar(
            title: const Text('Tổng quan Doanh thu'),
            backgroundColor: Colors.blue.shade600,
            foregroundColor: Colors.white,
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 1. Header (Tổng quan) - Giữ nguyên
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Colors.blue.shade600, Colors.blue.shade400],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.blue.withOpacity(0.2),
                        spreadRadius: 2,
                        blurRadius: 8,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Doanh thu (Tổng cộng)',
                        style: TextStyle(color: Colors.white70, fontSize: 14),
                      ),
                      Text(
                        _formatCurrency(totalRevenue),
                        style: const TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                            color: Colors.white),
                      ),
                      const SizedBox(height: 10),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('Cập nhật theo thời gian thực',
                              style: TextStyle(
                                  color: Colors.white60, fontSize: 12)),
                          const Icon(Icons.show_chart,
                              color: Colors.white70, size: 20),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // 2. Các chỉ số quan trọng - Giữ nguyên
                Row(
                  children: [
                    // Thẻ 1: Số đơn hàng
                    _buildMetricCard(
                      'Số đơn hàng',
                      '$totalOrders',
                      Icons.receipt_long,
                      Colors.green,
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (_) => const OrderListScreen()),
                        );
                      },
                    ),
                    const SizedBox(width: 8),
                    // Thẻ 2: Sản phẩm mới
                    ValueListenableBuilder(
                      valueListenable: DBService.products().listenable(),
                      builder: (context, Box<Product> productBox, _) {
                        final allProducts = productBox.values.toList();
                        final now = DateTime.now();
                        final List<Product> newProductsList =
                        allProducts.where((product) {
                          if (product.createdAt == null) return false;
                          return now.difference(product.createdAt!).inHours <
                              24;
                        }).toList();
                        final int newProductCount = newProductsList.length;

                        return _buildMetricCard(
                          'Sản phẩm mới',
                          newProductCount.toString(),
                          Icons.new_releases,
                          Colors.green,
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => NewProductsScreen(
                                  newProducts: newProductsList,
                                ),
                              ),
                            );
                          },
                        );
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                // 3. Hiệu suất sản phẩm (ĐÃ CẬP NHẬT)
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Hiệu suất sản phẩm',
                      style:
                      TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                    TextButton(
                      onPressed: () {
                        // TODO: Tạo một trang mới
                        // hiển thị *tất cả* sản phẩm đã sắp xếp
                      },
                      child: const Text('Xem thêm',
                          style: TextStyle(color: Color(0xFF3B82F6))),
                    ),
                  ],
                ),
                const SizedBox(height: 12),

                // --- DANH SÁCH SẢN PHẨM BÁN CHẠY (ĐỘNG) ---
                if (topSales.isEmpty)
                  Container(
                    padding: const EdgeInsets.all(20),
                    alignment: Alignment.center,
                    child: const Text(
                      'Chưa có dữ liệu bán hàng.',
                      style: TextStyle(color: Colors.grey, fontSize: 16),
                    ),
                  )
                else
                  ListView.builder(
                    itemCount: topSales.length,
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemBuilder: (context, index) {
                      final saleData = topSales[index];
                      final productId = saleData.key;
                      final quantitySold = saleData.value; // Đây là kiểu double

                      final Product? product = productsBox.get(productId);

                      if (product == null) {
                        return ListTile(
                          title: Text('Không tìm thấy SP ID: $productId'),
                        );
                      }

                      // SỬA LỖI 2: Thêm logic định dạng số double
                      String quantityText;
                      // Nếu số lượng là số nguyên (ví dụ: 50.0), chỉ hiển thị 50
                      if (quantitySold == quantitySold.roundToDouble()) {
                        quantityText = quantitySold.toInt().toString();
                      } else {
                        // Nếu là số lẻ (ví dụ: 50.5), hiển thị 50.5
                        quantityText = quantitySold.toString();
                      }

                      // Sử dụng lại widget build của bạn
                      return _buildProductPerformanceTile(
                        product.name,
                        '$quantityText ${product.unit}', // Ví dụ: "50.5 kg"
                        _getImagePathForProduct(product.id), // Lấy ảnh động
                      );
                    },
                  ),
              ],
            ),
          ),
        );
      },
    );
  }
}