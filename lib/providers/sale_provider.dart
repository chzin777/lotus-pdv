import 'package:flutter/material.dart';
import '../models/sale.dart';
import '../models/product.dart';
import '../services/sale_service.dart';
import '../services/product_service.dart';

class PaymentEntry {
  String method;
  double amount;

  PaymentEntry({required this.method, required this.amount});
}

class DraftSale {
  final String id;
  String label;
  List<SaleItem> items;
  double discountAmount;

  DraftSale({
    required this.id,
    required this.label,
    List<SaleItem>? items,
    this.discountAmount = 0,
  }) : items = items ?? [];

  int get itemCount => items.fold(0, (sum, item) => sum + item.quantity);
  double get subtotal => items.fold(0, (sum, item) => sum + item.totalPrice);
  double get finalAmount => (subtotal - discountAmount).clamp(0, double.infinity);

  String shortSummary() {
    if (items.isEmpty) return '(vazia)';
    return '($itemCount itens)';
  }
}

class SaleProvider extends ChangeNotifier {
  final List<DraftSale> _drafts = [];
  String? _activeDraftId;

  List<Sale> _sales = [];
  bool _isLoading = false;
  String _errorMessage = '';

  SaleProvider() {
    // Evita mutações durante o build (ex.: criar draft dentro de getter),
    // que podem causar asserts internos do Flutter.
    final first = DraftSale(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      label: 'Venda 1',
    );
    _drafts.add(first);
    _activeDraftId = first.id;
  }

  List<DraftSale> get drafts => List.unmodifiable(_drafts);
  DraftSale get activeDraft {
    final id = _activeDraftId ?? _drafts.first.id;
    return _drafts.firstWhere((d) => d.id == id, orElse: () => _drafts.first);
  }

  String get activeDraftId => activeDraft.id;
  List<SaleItem> get cartItems => activeDraft.items;
  double get discountAmount => activeDraft.discountAmount;
  List<Sale> get sales => _sales;
  bool get isLoading => _isLoading;
  String get errorMessage => _errorMessage;

  double get subtotal => activeDraft.subtotal;
  double get finalAmount => activeDraft.finalAmount;
  int get itemCount => activeDraft.itemCount;

  DraftSale createDraft({String? label}) {
    final newDraft = DraftSale(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      label: (label == null || label.trim().isEmpty)
          ? 'Venda ${_drafts.length + 1}'
          : label.trim(),
    );
    _drafts.add(newDraft);
    _activeDraftId = newDraft.id;
    notifyListeners();
    return newDraft;
  }

  void selectDraft(String id) {
    if (_drafts.any((d) => d.id == id)) {
      _activeDraftId = id;
      notifyListeners();
    }
  }

  void renameDraft(String id, String label) {
    final draft = _drafts.firstWhere((d) => d.id == id, orElse: () => activeDraft);
    final cleaned = label.trim();
    if (cleaned.isEmpty) return;
    draft.label = cleaned;
    notifyListeners();
  }

  void removeDraft(String id) {
    if (_drafts.length <= 1) return;
    _drafts.removeWhere((d) => d.id == id);
    if (_activeDraftId == id) {
      _activeDraftId = _drafts.isNotEmpty ? _drafts.first.id : null;
    }
    notifyListeners();
  }

  void addToCart(Product product, int quantity) {
    final draft = activeDraft;
    final existingItem = draft.items.firstWhere(
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
      
      final index = draft.items.indexOf(existingItem);
      draft.items[index] = SaleItem(
        productId: product.id,
        productName: product.name,
        quantity: newQuantity,
        unitPrice: product.sellingPrice,
        totalPrice: newTotalPrice,
      );
    } else {
      draft.items.add(SaleItem(
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
    activeDraft.items.removeWhere((item) => item.productId == productId);
    notifyListeners();
  }

  void updateCartItemQuantity(String productId, int quantity) {
    final draft = activeDraft;
    final index = draft.items.indexWhere((item) => item.productId == productId);
    if (index != -1) {
      if (quantity <= 0) {
        draft.items.removeAt(index);
      } else {
        final item = draft.items[index];
        draft.items[index] = SaleItem(
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
    activeDraft.discountAmount = amount.clamp(0, subtotal);
    notifyListeners();
  }

  void clearCart() {
    activeDraft.items.clear();
    activeDraft.discountAmount = 0;
    notifyListeners();
  }

  Future<bool> completeSale(String userId, {required List<PaymentEntry> payments}) async {
    final draft = activeDraft;
    if (draft.items.isEmpty) {
      _errorMessage = 'Carrinho vazio';
      notifyListeners();
      return false;
    }

    try {
      final cleanedPayments = payments
          .where((p) => p.amount.isFinite && p.amount > 0)
          .toList(growable: false);
      if (cleanedPayments.isEmpty) {
        _errorMessage = 'Informe o valor do pagamento';
        notifyListeners();
        return false;
      }

      final totalPaid =
          cleanedPayments.fold<double>(0, (sum, p) => sum + p.amount);
      final total = finalAmount;
      final hasCash = cleanedPayments.any((p) => p.method == 'Dinheiro');

      if (totalPaid + 1e-9 < total) {
        _errorMessage = 'Pagamento insuficiente';
        notifyListeners();
        return false;
      }
      if (totalPaid - total > 1e-9 && !hasCash) {
        _errorMessage =
            'Troco só é permitido quando parte do pagamento é em dinheiro';
        notifyListeners();
        return false;
      }

      final paymentBreakdown = cleanedPayments
          .map((p) => '${p.method}:${p.amount.toStringAsFixed(2)}')
          .join(';');

      final sale = Sale(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        label: draft.label,
        items: List.from(draft.items),
        totalAmount: draft.subtotal,
        discountAmount: draft.discountAmount,
        finalAmount: draft.finalAmount,
        paymentMethod: paymentBreakdown,
        status: 'completed',
        userId: userId,
      );

      final success = await SaleService.addSale(sale);
      if (success) {
        // Update product quantities
        for (var item in draft.items) {
          final product = await ProductService.getProductById(item.productId);
          if (product != null) {
            await ProductService.updateProductQuantity(
              item.productId,
              product.quantity - item.quantity,
            );
          }
        }
        
        _sales.add(sale);

        // Remove the completed draft and switch to another open one,
        // or reset it as empty if it's the only draft.
        if (_drafts.length > 1) {
          _drafts.remove(draft);
          _activeDraftId = _drafts.last.id;
        } else {
          draft.items = [];
          draft.discountAmount = 0;
        }
        Future.microtask(() => notifyListeners());
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
