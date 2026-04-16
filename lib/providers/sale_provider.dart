import 'package:flutter/material.dart';
import '../models/sale.dart';
import '../models/product.dart';
import '../services/sale_service.dart';
import '../services/product_service.dart';

class SaleProvider extends ChangeNotifier {
  List<SaleItem> _cartItems = [];
  double _discountAmount = 0;
  String _paymentMethod = 'Dinheiro';
  List<Sale> _sales = [];
  bool _isLoading = false;
  String _errorMessage = '';

  List<SaleItem> get cartItems => _cartItems;
  double get discountAmount => _discountAmount;
  String get paymentMethod => _paymentMethod;
  List<Sale> get sales => _sales;
  bool get isLoading => _isLoading;
  String get errorMessage => _errorMessage;

  double get subtotal => _cartItems.fold(0, (sum, item) => sum + item.totalPrice);
  double get finalAmount => (subtotal - _discountAmount).clamp(0, double.infinity);
  int get itemCount => _cartItems.fold(0, (sum, item) => sum + item.quantity);

  void addToCart(Product product, int quantity) {
    final existingItem = _cartItems.firstWhere(
      (item) => item.productId == product.id,
      orElse: () => SaleItem(
        productId: product.id,
        productName: product.name,
        quantity: 0,
        unitPrice: product.sellingPrice,
        totalPrice: 0,
      ),
    );

    if (existingItem.quantity > 0) {
      final newQuantity = existingItem.quantity + quantity;
      final newTotalPrice = product.sellingPrice * newQuantity;
      
      final index = _cartItems.indexOf(existingItem);
      _cartItems[index] = SaleItem(
        productId: product.id,
        productName: product.name,
        quantity: newQuantity,
        unitPrice: product.sellingPrice,
        totalPrice: newTotalPrice,
      );
    } else {
      _cartItems.add(SaleItem(
        productId: product.id,
        productName: product.name,
        quantity: quantity,
        unitPrice: product.sellingPrice,
        totalPrice: product.sellingPrice * quantity,
      ));
    }
    notifyListeners();
  }

  void removeFromCart(String productId) {
    _cartItems.removeWhere((item) => item.productId == productId);
    notifyListeners();
  }

  void updateCartItemQuantity(String productId, int quantity) {
    final index = _cartItems.indexWhere((item) => item.productId == productId);
    if (index != -1) {
      if (quantity <= 0) {
        _cartItems.removeAt(index);
      } else {
        final item = _cartItems[index];
        _cartItems[index] = SaleItem(
          productId: item.productId,
          productName: item.productName,
          quantity: quantity,
          unitPrice: item.unitPrice,
          totalPrice: item.unitPrice * quantity,
        );
      }
      notifyListeners();
    }
  }

  void setDiscount(double amount) {
    _discountAmount = amount.clamp(0, subtotal);
    notifyListeners();
  }

  void setPaymentMethod(String method) {
    _paymentMethod = method;
    notifyListeners();
  }

  void clearCart() {
    _cartItems.clear();
    _discountAmount = 0;
    _paymentMethod = 'Dinheiro';
    notifyListeners();
  }

  Future<bool> completeSale(String userId) async {
    if (_cartItems.isEmpty) {
      _errorMessage = 'Carrinho vazio';
      notifyListeners();
      return false;
    }

    try {
      final sale = Sale(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        items: List.from(_cartItems),
        totalAmount: subtotal,
        discountAmount: _discountAmount,
        finalAmount: finalAmount,
        paymentMethod: _paymentMethod,
        status: 'completed',
        userId: userId,
      );

      final success = await SaleService.addSale(sale);
      if (success) {
        // Update product quantities
        for (var item in _cartItems) {
          final product = await ProductService.getProductById(item.productId);
          if (product != null) {
            await ProductService.updateProductQuantity(
              item.productId,
              product.quantity - item.quantity,
            );
          }
        }
        
        _sales.add(sale);
        clearCart();
      }
      return success;
    } catch (e) {
      _errorMessage = 'Erro ao completar venda: $e';
      notifyListeners();
      return false;
    }
  }

  Future<void> loadSales() async {
    _isLoading = true;
    _errorMessage = '';
    notifyListeners();

    try {
      _sales = await SaleService.getSales();
      _isLoading = false;
    } catch (e) {
      _errorMessage = 'Erro ao carregar vendas: $e';
      _isLoading = false;
    }
    notifyListeners();
  }

  Future<bool> cancelSale(String saleId, String reason) async {
    try {
      final success = await SaleService.cancelSale(saleId, reason);
      if (success) {
        final sale = await SaleService.getSaleById(saleId);
        if (sale != null) {
          // Restore product quantities
          for (var item in sale.items) {
            final product = await ProductService.getProductById(item.productId);
            if (product != null) {
              await ProductService.updateProductQuantity(
                item.productId,
                product.quantity + item.quantity,
              );
            }
          }
        }
        await loadSales();
      }
      return success;
    } catch (e) {
      _errorMessage = 'Erro ao cancelar venda: $e';
      notifyListeners();
      return false;
    }
  }

  Future<Map<String, dynamic>> getSalesReport(DateTime startDate, DateTime endDate) async {
    return await SaleService.getSalesReport(startDate, endDate);
  }
}
