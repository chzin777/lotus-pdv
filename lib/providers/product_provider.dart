import 'package:flutter/material.dart';
import '../models/product.dart';
import '../services/product_service.dart';

class ProductProvider extends ChangeNotifier {
  List<Product> _products = [];
  List<String> _categories = [];
  bool _isLoading = false;
  String _errorMessage = '';
  String _selectedCategory = 'Todos';

  List<Product> get products => _products;
  List<String> get categories => _categories;
  bool get isLoading => _isLoading;
  String get errorMessage => _errorMessage;
  String get selectedCategory => _selectedCategory;

  List<Product> get filteredProducts {
    if (_selectedCategory == 'Todos') {
      return _products;
    }
    return _products.where((p) => p.category == _selectedCategory).toList();
  }

  Future<void> loadProducts() async {
    _isLoading = true;
    _errorMessage = '';
    notifyListeners();

    try {
      _products = await ProductService.getProducts();
      _categories = await ProductService.getCategories();
      _categories.insert(0, 'Todos');
      _isLoading = false;
    } catch (e) {
      _errorMessage = 'Erro ao carregar produtos: $e';
      _isLoading = false;
    }
    notifyListeners();
  }

  Future<bool> addProduct(Product product) async {
    try {
      final success = await ProductService.addProduct(product);
      if (success) {
        _products.add(product);
        if (!_categories.contains(product.category)) {
          _categories.add(product.category);
        }
        notifyListeners();
      }
      return success;
    } catch (e) {
      _errorMessage = 'Erro ao adicionar produto: $e';
      notifyListeners();
      return false;
    }
  }

  Future<bool> updateProduct(Product product) async {
    try {
      final success = await ProductService.updateProduct(product);
      if (success) {
        final index = _products.indexWhere((p) => p.id == product.id);
        if (index != -1) {
          _products[index] = product;
        }
        notifyListeners();
      }
      return success;
    } catch (e) {
      _errorMessage = 'Erro ao atualizar produto: $e';
      notifyListeners();
      return false;
    }
  }

  Future<bool> deleteProduct(String productId) async {
    try {
      final success = await ProductService.deleteProduct(productId);
      if (success) {
        _products.removeWhere((p) => p.id == productId);
        notifyListeners();
      }
      return success;
    } catch (e) {
      _errorMessage = 'Erro ao deletar produto: $e';
      notifyListeners();
      return false;
    }
  }

  void setSelectedCategory(String category) {
    _selectedCategory = category;
    notifyListeners();
  }

  Product? getProductById(String id) {
    try {
      return _products.firstWhere((p) => p.id == id);
    } catch (e) {
      return null;
    }
  }

  Future<bool> updateProductQuantity(String productId, int newQuantity) async {
    try {
      final success = await ProductService.updateProductQuantity(productId, newQuantity);
      if (success) {
        final product = getProductById(productId);
        if (product != null) {
          final index = _products.indexWhere((p) => p.id == productId);
          _products[index] = product.copyWith(quantity: newQuantity);
          notifyListeners();
        }
      }
      return success;
    } catch (e) {
      _errorMessage = 'Erro ao atualizar quantidade: $e';
      notifyListeners();
      return false;
    }
  }
}
