// lib/screens/inventory_check_screen.dart (ĐÃ SỬA LỖI TÌM KIẾM GỢI Ý)
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../models/product.dart';
import '../services/db_service.dart';

class InventoryCheckScreen extends StatefulWidget {
  const InventoryCheckScreen({super.key});

  @override
  State<InventoryCheckScreen> createState() => _InventoryCheckScreenState();
}

class _InventoryCheckScreenState extends State<InventoryCheckScreen> {
  final _productSearchController = TextEditingController();
  final _actualQuantityController = TextEditingController();
  final _noteController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  Product? _selectedProduct;
  int _systemStock = 0;
  int _difference = 0;

  // Biến mới để lưu trữ kết quả tìm kiếm (danh sách gợi ý)
  List<Product> _searchResults = [];

  @override
  void initState() {
    super.initState();
    // Thay đổi: Listener gọi hàm tìm kiếm để đổ dữ liệu vào _searchResults
    _productSearchController.addListener(_searchProduct);
    _actualQuantityController.addListener(_calculateDifference);
  }

  @override
  void dispose() {
    _productSearchController.removeListener(_searchProduct);
    _actualQuantityController.removeListener(_calculateDifference);
    _productSearchController.dispose();
    _actualQuantityController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  // HÀM TÌM KIẾM VÀ HIỂN THỊ DANH SÁCH GỢI Ý
  void _searchProduct() {
    final query = _productSearchController.text.trim();
    if (query.isEmpty) {
      setState(() {
        _searchResults = []; // Xóa danh sách gợi ý
        _selectedProduct = null; // Bỏ chọn sản phẩm
        _systemStock = 0;
        _actualQuantityController.clear();
        _difference = 0;
      });
      return;
    }

    // Chỉ tìm kiếm nếu chưa có sản phẩm nào được chọn (để tránh làm mất dữ liệu)
    if (_selectedProduct == null || _selectedProduct!.name.toLowerCase() != query.toLowerCase()) {
      final allProducts = DBService.products().values.toList();
      final results = DBService.searchProducts(query, allProducts);

      setState(() {
        _searchResults = results;
      });
    }
  }

  // HÀM CHỌN SẢN PHẨM TỪ DANH SÁCH GỢI Ý
  void _selectProduct(Product product) {
    setState(() {
      _selectedProduct = product;
      _systemStock = product.stockQuantity;
      _searchResults = []; // Xóa danh sách gợi ý sau khi chọn

      // Điền tên sản phẩm chính xác vào ô tìm kiếm
      _productSearchController.text = product.name;

      // Đặt con trỏ ở cuối để người dùng có thể thấy tên đầy đủ
      _productSearchController.selection = TextSelection.collapsed(offset: product.name.length);

      // Reset số lượng thực tế và chênh lệch
      _actualQuantityController.clear();
      _difference = 0;
    });
  }

  // HÀM TÍNH TOÁN CHÊNH LỆCH
  void _calculateDifference() {
    if (_selectedProduct == null) {
      setState(() => _difference = 0);
      return;
    }

    final int actualQuantity = int.tryParse(_actualQuantityController.text) ?? 0;
    setState(() {
      // Chênh lệch = Số lượng thực tế - Số lượng hệ thống
      _difference = actualQuantity - _systemStock;
    });
  }

  // HÀM XÁC NHẬN ĐIỀU CHỈNH KHO
  void _onConfirmCheck() async {
    if (!_formKey.currentState!.validate() || _selectedProduct == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Vui lòng chọn sản phẩm và nhập đủ thông tin.')));
      return;
    }

    final int actualQuantity = int.tryParse(_actualQuantityController.text) ?? 0;

    // 1. Chỉ cập nhật nếu có chênh lệch
    if (_difference == 0) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Không có chênh lệch, không cần điều chỉnh.')));
      Navigator.pop(context);
      return;
    }

    try {
      // 2. Cập nhật tồn kho hệ thống bằng số lượng thực tế
      _selectedProduct!.stockQuantity = actualQuantity;
      await _selectedProduct!.save();

      // 3. Thông báo
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text('Điều chỉnh tồn kho thành công! Chênh lệch: ${_difference} ${_selectedProduct!.unit}'),
            backgroundColor: _difference > 0 ? Colors.green : Colors.red
        ),
      );
      Navigator.pop(context);

    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Lỗi khi điều chỉnh kho: ${e.toString()}'), backgroundColor: Colors.red),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    Color differenceColor = _difference == 0 ? Colors.black54 : (_difference > 0 ? Colors.green : Colors.red);
    String differenceText = _difference == 0 ? '0' : (_difference > 0 ? '+${_difference}' : '${_difference}');


    return Scaffold(
      appBar: AppBar(
        title: const Text('Kiểm kê', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.amber,
        foregroundColor: Colors.black87,
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Trường Tìm kiếm sản phẩm
              const Text('Tìm kiếm sản phẩm', style: TextStyle(fontWeight: FontWeight.w600)),
              const SizedBox(height: 8),
              // Đổi từ TextFormField sang Column để chứa danh sách gợi ý
              Column(
                children: [
                  TextFormField(
                    controller: _productSearchController,
                    decoration: InputDecoration(
                      hintText: 'Nhập tên hoặc mã sản phẩm...',
                      fillColor: Colors.grey.shade100,
                      filled: true,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide.none,
                      ),
                      suffixIcon: _selectedProduct != null ? const Icon(Icons.check_circle, color: Colors.green) : null,
                    ),
                  ),

                  // Hiển thị danh sách gợi ý
                  if (_searchResults.isNotEmpty)
                    Container(
                      constraints: const BoxConstraints(maxHeight: 200), // Giới hạn chiều cao
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: Colors.grey.shade300),
                      ),
                      margin: const EdgeInsets.only(top: 4),
                      child: ListView.builder(
                        shrinkWrap: true,
                        itemCount: _searchResults.length,
                        itemBuilder: (context, index) {
                          final product = _searchResults[index];
                          return ListTile(
                            title: Text(product.name),
                            subtitle: Text('Mã: ${product.id}'),
                            onTap: () => _selectProduct(product), // Khi người dùng CHỌN
                          );
                        },
                      ),
                    ),
                ],
              ), // Kết thúc phần tìm kiếm

              if (_selectedProduct != null)
                Padding(
                  padding: const EdgeInsets.only(top: 10.0),
                  child: Text('Đơn vị: ${_selectedProduct!.unit}', style: const TextStyle(fontWeight: FontWeight.w500)),
                ),
              // Bỏ phần thông báo "Không tìm thấy sản phẩm" để tránh gây rối khi đang gõ
              // else if (_productSearchController.text.isNotEmpty && _searchResults.isEmpty)
              //   const Padding(
              //     padding: EdgeInsets.only(top: 8.0),
              //     child: Text('Không tìm thấy sản phẩm.', style: TextStyle(color: Colors.red)),
              //   ),

              const SizedBox(height: 20),

              // Trường Tồn kho hệ thống
              const Text('Tồn kho hệ thống', style: TextStyle(fontWeight: FontWeight.w600)),
              const SizedBox(height: 8),
              Container(
                height: 50,
                width: double.infinity,
                padding: const EdgeInsets.symmetric(horizontal: 12),
                alignment: Alignment.centerLeft,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: Colors.grey.shade300),
                ),
                child: Text(
                  _selectedProduct != null ? '$_systemStock ${_selectedProduct!.unit}' : '...',
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.blue),
                ),
              ),

              const SizedBox(height: 20),

              // Trường Số lượng thực tế
              const Text('Số lượng thực tế', style: TextStyle(fontWeight: FontWeight.w600)),
              const SizedBox(height: 8),
              TextFormField(
                controller: _actualQuantityController,
                keyboardType: TextInputType.number,
                enabled: _selectedProduct != null, // Chỉ cho phép nhập khi đã chọn sản phẩm
                decoration: InputDecoration(
                  fillColor: Colors.grey.shade100,
                  filled: true,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide.none,
                  ),
                ),
                validator: (val) {
                  final int? quantity = int.tryParse(val ?? '');
                  if (_selectedProduct != null && (quantity == null || quantity < 0)) {
                    return 'Vui lòng nhập Số lượng thực tế hợp lệ.';
                  }
                  return null;
                },
              ),

              const SizedBox(height: 20),

              // Trường Chênh lệch
              const Text('Chênh lệch (Thực tế - Hệ thống)', style: TextStyle(fontWeight: FontWeight.w600)),
              const SizedBox(height: 8),
              Container(
                height: 50,
                width: double.infinity,
                padding: const EdgeInsets.symmetric(horizontal: 12),
                alignment: Alignment.centerLeft,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: Colors.grey.shade300),
                ),
                child: Text(
                  differenceText,
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: differenceColor),
                ),
              ),

              const SizedBox(height: 20),

              // Trường Ghi chú/Lý do chênh lệch
              const Text('Ghi chú/Lý do chênh lệch', style: TextStyle(fontWeight: FontWeight.w600)),
              const SizedBox(height: 8),
              TextFormField(
                controller: _noteController,
                maxLines: 4,
                decoration: InputDecoration(
                  hintText: 'Ghi chú về lý do chênh lệch...',
                  fillColor: Colors.grey.shade100,
                  filled: true,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),

              const SizedBox(height: 40),

              // Nút Xác nhận điều chỉnh
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: _selectedProduct != null ? _onConfirmCheck : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.amber,
                    foregroundColor: Colors.black,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: const Text('Xác nhận điều chỉnh', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}