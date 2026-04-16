import 'package:flutter/material.dart';
import '../models/account.dart';
import '../models/sale.dart';
import '../services/account_service.dart';

class AccountProvider extends ChangeNotifier {
  List<Account> _accounts = [];
  bool _isLoading = false;

  List<Account> get accounts => _accounts;
  List<Account> get openAccounts => _accounts.where((a) => a.status == 'open').toList();
  List<Account> get settledAccounts => _accounts.where((a) => a.status == 'settled').toList();
  bool get isLoading => _isLoading;

  Future<void> load() async {
    _isLoading = true;
    notifyListeners();
    _accounts = await AccountService.getAll();
    _isLoading = false;
    notifyListeners();
  }

  Future<Account> createAccount(String customerName, {String phone = ''}) async {
    final account = Account(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      customerName: customerName.trim(),
      phone: phone.trim(),
    );
    _accounts.add(account);
    await AccountService.saveAll(_accounts);
    notifyListeners();
    return account;
  }

  Future<bool> addSaleToAccount(String accountId, Sale sale) async {
    final idx = _accounts.indexWhere((a) => a.id == accountId);
    if (idx == -1) return false;

    final account = _accounts[idx];
    final entry = AccountEntry(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      type: 'sale',
      amount: sale.finalAmount,
      description: '${sale.label ?? 'Venda'} \u2022 ${sale.itemCount} itens',
      saleId: sale.id,
    );

    final updated = account.copyWith(
      entries: [...account.entries, entry],
    );
    _accounts[idx] = updated;
    await AccountService.saveAll(_accounts);
    notifyListeners();
    return true;
  }

  Future<bool> addPayment(String accountId, double amount, String description) async {
    final idx = _accounts.indexWhere((a) => a.id == accountId);
    if (idx == -1) return false;

    final account = _accounts[idx];
    final entry = AccountEntry(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      type: 'payment',
      amount: amount,
      description: description.isEmpty ? 'Pagamento' : description,
    );

    final updated = account.copyWith(
      entries: [...account.entries, entry],
    );
    _accounts[idx] = updated;
    await AccountService.saveAll(_accounts);
    notifyListeners();
    return true;
  }

  Future<bool> settleAccount(String accountId) async {
    final idx = _accounts.indexWhere((a) => a.id == accountId);
    if (idx == -1) return false;

    final account = _accounts[idx];
    final updated = account.copyWith(
      status: 'settled',
      settledAt: DateTime.now(),
    );
    _accounts[idx] = updated;
    await AccountService.saveAll(_accounts);
    notifyListeners();
    return true;
  }

  Future<bool> reopenAccount(String accountId) async {
    final idx = _accounts.indexWhere((a) => a.id == accountId);
    if (idx == -1) return false;

    final account = _accounts[idx];
    final updated = account.copyWith(status: 'open', settledAt: null);
    _accounts[idx] = updated;
    await AccountService.saveAll(_accounts);
    notifyListeners();
    return true;
  }

  Future<bool> deleteAccount(String accountId) async {
    _accounts.removeWhere((a) => a.id == accountId);
    await AccountService.saveAll(_accounts);
    notifyListeners();
    return true;
  }
}
