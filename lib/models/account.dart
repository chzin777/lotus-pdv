class Account {
  final String id;
  final String customerName;
  final String phone;
  final List<AccountEntry> entries;
  final String status; // 'open' | 'settled'
  final DateTime createdAt;
  final DateTime? settledAt;

  Account({
    required this.id,
    required this.customerName,
    this.phone = '',
    List<AccountEntry>? entries,
    this.status = 'open',
    DateTime? createdAt,
    this.settledAt,
  })  : entries = entries ?? [],
        createdAt = createdAt ?? DateTime.now();

  double get totalOwed =>
      entries.where((e) => e.type == 'sale').fold(0.0, (s, e) => s + e.amount);

  double get totalPaid =>
      entries.where((e) => e.type == 'payment').fold(0.0, (s, e) => s + e.amount);

  double get balance => totalOwed - totalPaid;

  bool get isSettled => status == 'settled';

  Account copyWith({
    String? id,
    String? customerName,
    String? phone,
    List<AccountEntry>? entries,
    String? status,
    DateTime? createdAt,
    DateTime? settledAt,
  }) {
    return Account(
      id: id ?? this.id,
      customerName: customerName ?? this.customerName,
      phone: phone ?? this.phone,
      entries: entries ?? this.entries,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      settledAt: settledAt ?? this.settledAt,
    );
  }
}

class AccountEntry {
  final String id;
  final String type; // 'sale' | 'payment'
  final double amount;
  final String description;
  final String? saleId;
  final DateTime createdAt;

  AccountEntry({
    required this.id,
    required this.type,
    required this.amount,
    required this.description,
    this.saleId,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();
}
