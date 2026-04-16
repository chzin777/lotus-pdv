import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
import 'dart:io';
import '../providers/sale_provider.dart';
import '../providers/product_provider.dart';
import '../providers/auth_provider.dart';
import '../providers/account_provider.dart';
import '../models/sale.dart';

class POSScreen extends StatefulWidget {
  const POSScreen({Key? key}) : super(key: key);

  @override
  State<POSScreen> createState() => _POSScreenState();
}

class _POSScreenState extends State<POSScreen> {
  late TextEditingController _searchController;
  late TextEditingController _discountController;

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController();
    _discountController = TextEditingController();
  }

  @override
  void dispose() {
    _searchController.dispose();
    _discountController.dispose();
    super.dispose();
  }

  void _showAddQuantityDialog(BuildContext context, String productId, String productName, double price) {
    final controller = TextEditingController(text: '1');
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(productName, style: const TextStyle(fontWeight: FontWeight.w800, color: Color(0xFF0F172A))),
        content: TextField(
          controller: controller,
          keyboardType: TextInputType.number,
          autofocus: true,
          decoration: InputDecoration(
            labelText: 'Quantidade',
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () {
              final quantity = int.tryParse(controller.text) ?? 1;
              final product = context.read<ProductProvider>().getProductById(productId);
              if (product != null) {
                context.read<SaleProvider>().addToCart(product, quantity);
              }
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF7C3AED),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            child: const Text('Adicionar'),
          ),
        ],
      ),
    );
  }

  double _parseMoney(String raw) {
    final value = raw.trim().replaceAll('.', '').replaceAll(',', '.');
    return double.tryParse(value) ?? 0.0;
  }

  Future<List<PaymentEntry>?> _showPaymentDialog(BuildContext context, double total) async {
    final methods = const ['Dinheiro', 'Pix', 'Crédito', 'Débito'];
    final entries = <PaymentEntry>[PaymentEntry(method: 'Dinheiro', amount: 0)];
    final controllers = <TextEditingController>[TextEditingController()];

    void disposeControllers() {
      for (final c in controllers) {
        c.dispose();
      }
    }

    double paidTotal() {
      double sum = 0;
      for (int i = 0; i < entries.length; i++) {
        sum += entries[i].amount;
      }
      return sum;
    }

    bool hasCash() => entries.any((e) => e.method == 'Dinheiro' && e.amount > 0);

    return showDialog<List<PaymentEntry>>(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            final paid = paidTotal();
            final diff = paid - total;
            final remaining = diff < 0 ? -diff : 0.0;
            final change = diff > 0 ? diff : 0.0;
            final canConfirm = paid > 0 &&
                remaining <= 1e-9 &&
                (change <= 1e-9 || hasCash());

            Widget summaryRow(String label, String value, {Color? color, FontWeight? weight}) {
              return Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(label, style: const TextStyle(color: Color(0xFF64748B), fontSize: 14)),
                  Text(
                    value,
                    style: TextStyle(
                      color: color ?? const Color(0xFF0F172A),
                      fontWeight: weight ?? FontWeight.w700,
                      fontSize: 14,
                    ),
                  ),
                ],
              );
            }

            return AlertDialog(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              title: Row(
                children: [
                  Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: const Color(0xFF7C3AED).withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(Icons.payments_rounded, size: 18, color: Color(0xFF7C3AED)),
                  ),
                  const SizedBox(width: 12),
                  const Text('Pagamento', style: TextStyle(fontWeight: FontWeight.w800, color: Color(0xFF0F172A))),
                ],
              ),
              content: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 560),
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Informe quanto o cliente está pagando e combine formas de pagamento se necessário.',
                        style: TextStyle(color: Color(0xFF94A3B8), fontSize: 13),
                      ),
                      const SizedBox(height: 20),
                      ...List.generate(entries.length, (i) {
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 10),
                          child: Row(
                            children: [
                              Expanded(
                                flex: 2,
                                child: DropdownButtonFormField<String>(
                                  initialValue: entries[i].method,
                                  decoration: InputDecoration(
                                    labelText: 'Forma',
                                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                                    contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                                  ),
                                  items: methods
                                      .map((m) => DropdownMenuItem(value: m, child: Text(m)))
                                      .toList(),
                                  onChanged: (v) {
                                    if (v == null) return;
                                    setState(() => entries[i].method = v);
                                  },
                                ),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                flex: 2,
                                child: TextField(
                                  controller: controllers[i],
                                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                                  decoration: InputDecoration(
                                    labelText: 'Valor',
                                    prefixText: 'R\$ ',
                                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                                    contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                                  ),
                                  onChanged: (v) {
                                    setState(() => entries[i].amount = _parseMoney(v));
                                  },
                                ),
                              ),
                              const SizedBox(width: 8),
                              IconButton(
                                tooltip: 'Remover',
                                onPressed: entries.length == 1
                                    ? null
                                    : () {
                                        setState(() {
                                          entries.removeAt(i);
                                          controllers.removeAt(i).dispose();
                                        });
                                      },
                                icon: const Icon(Icons.close_rounded, size: 20),
                              ),
                            ],
                          ),
                        );
                      }),
                      TextButton.icon(
                        onPressed: () {
                          setState(() {
                            entries.add(PaymentEntry(method: 'Pix', amount: 0));
                            controllers.add(TextEditingController());
                          });
                        },
                        icon: const Icon(Icons.add_rounded, size: 18),
                        label: const Text('Adicionar forma', style: TextStyle(fontSize: 13)),
                      ),
                      const SizedBox(height: 16),
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(16),
                          color: const Color(0xFFF8FAFC),
                          border: Border.all(color: const Color(0xFFE2E8F0)),
                        ),
                        child: Column(
                          children: [
                            summaryRow('Total da venda', 'R\$ ${total.toStringAsFixed(2)}'),
                            const SizedBox(height: 6),
                            summaryRow('Total pago', 'R\$ ${paid.toStringAsFixed(2)}'),
                            const Divider(height: 20),
                            if (remaining > 0)
                              summaryRow(
                                'Falta pagar',
                                'R\$ ${remaining.toStringAsFixed(2)}',
                                color: const Color(0xFFEF4444),
                                weight: FontWeight.w900,
                              )
                            else
                              summaryRow(
                                'Troco',
                                'R\$ ${change.toStringAsFixed(2)}',
                                color: const Color(0xFF10B981),
                                weight: FontWeight.w900,
                              ),
                            if (change > 0 && !hasCash()) ...[
                              const SizedBox(height: 10),
                              Container(
                                padding: const EdgeInsets.all(10),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFEF4444).withValues(alpha: 0.08),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: const Row(
                                  children: [
                                    Icon(Icons.info_outline_rounded, size: 16, color: Color(0xFFEF4444)),
                                    SizedBox(width: 8),
                                    Expanded(
                                      child: Text(
                                        'Para haver troco, inclua uma linha de Dinheiro.',
                                        style: TextStyle(color: Color(0xFFEF4444), fontSize: 12),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    disposeControllers();
                    Navigator.pop(context);
                  },
                  child: const Text('Cancelar'),
                ),
                ElevatedButton.icon(
                  onPressed: canConfirm
                      ? () {
                          final cleaned = entries
                              .where((e) => e.amount.isFinite && e.amount > 0)
                              .map((e) => PaymentEntry(method: e.method, amount: e.amount))
                              .toList();
                          disposeControllers();
                          Navigator.pop(context, cleaned);
                        }
                      : null,
                  icon: const Icon(Icons.check_rounded, size: 18),
                  label: const Text('Finalizar'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF10B981),
                    foregroundColor: Colors.white,
                    disabledBackgroundColor: const Color(0xFFCBD5E1),
                    disabledForegroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Future<String?> _askSaleLabel(BuildContext context, {required String title, String? initialValue}) async {
    final controller = TextEditingController(text: initialValue ?? '');
    final result = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.w800, color: Color(0xFF0F172A))),
        content: TextField(
          controller: controller,
          autofocus: true,
          decoration: InputDecoration(
            labelText: 'Nome da venda',
            hintText: 'Ex: João, Mesa 3, Maria...',
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          ),
          onSubmitted: (_) => Navigator.pop(context, controller.text),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, controller.text),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF7C3AED),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            child: const Text('Confirmar'),
          ),
        ],
      ),
    );
    controller.dispose();
    final cleaned = result?.trim();
    if (cleaned == null || cleaned.isEmpty) return null;
    return cleaned;
  }

  Future<void> _handleFiado(BuildContext context) async {
    final saleProvider = context.read<SaleProvider>();
    final authProvider = context.read<AuthProvider>();
    final accountProvider = context.read<AccountProvider>();

    if (saleProvider.cartItems.isEmpty) return;

    // Load accounts if needed
    if (accountProvider.accounts.isEmpty) {
      await accountProvider.load();
    }

    final openAccounts = accountProvider.openAccounts;
    String? selectedAccountId;
    final nameCtrl = TextEditingController();
    final phoneCtrl = TextEditingController();
    bool creatingNew = openAccounts.isEmpty;

    final result = await showDialog<String>(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setState) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: Row(
            children: [
              Container(
                width: 36, height: 36,
                decoration: BoxDecoration(
                  color: const Color(0xFFF59E0B).withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.account_balance_wallet_rounded, size: 18, color: Color(0xFFF59E0B)),
              ),
              const SizedBox(width: 12),
              const Text('Vender no Fiado', style: TextStyle(fontWeight: FontWeight.w800, color: Color(0xFF0F172A))),
            ],
          ),
          content: SizedBox(
            width: 420,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Total: R\$ ${saleProvider.finalAmount.toStringAsFixed(2)}',
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: Color(0xFF0F172A)),
                  ),
                  const SizedBox(height: 16),

                  if (!creatingNew && openAccounts.isNotEmpty) ...[
                    const Text('Selecione a conta:', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Color(0xFF334155))),
                    const SizedBox(height: 8),
                    ...openAccounts.map((a) {
                      final isSelected = selectedAccountId == a.id;
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 6),
                        child: MouseRegion(
                          cursor: SystemMouseCursors.click,
                          child: GestureDetector(
                            onTap: () => setState(() => selectedAccountId = a.id),
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 150),
                              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                              decoration: BoxDecoration(
                                color: isSelected ? const Color(0xFF7C3AED).withValues(alpha: 0.06) : const Color(0xFFF8FAFC),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: isSelected ? const Color(0xFF7C3AED) : const Color(0xFFE2E8F0),
                                  width: isSelected ? 2 : 1,
                                ),
                              ),
                              child: Row(
                                children: [
                                  CircleAvatar(
                                    radius: 16,
                                    backgroundColor: const Color(0xFF7C3AED).withValues(alpha: 0.1),
                                    child: Text(
                                      a.customerName[0].toUpperCase(),
                                      style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 12, color: Color(0xFF7C3AED)),
                                    ),
                                  ),
                                  const SizedBox(width: 10),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(a.customerName, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14, color: Color(0xFF0F172A))),
                                        if (a.balance > 0)
                                          Text(
                                            'Saldo: R\$ ${a.balance.toStringAsFixed(2)}',
                                            style: const TextStyle(fontSize: 11, color: Color(0xFF94A3B8)),
                                          ),
                                      ],
                                    ),
                                  ),
                                  if (isSelected)
                                    const Icon(Icons.check_circle_rounded, color: Color(0xFF7C3AED), size: 20),
                                ],
                              ),
                            ),
                          ),
                        ),
                      );
                    }),
                    const SizedBox(height: 8),
                    TextButton.icon(
                      onPressed: () => setState(() => creatingNew = true),
                      icon: const Icon(Icons.add_rounded, size: 18),
                      label: const Text('Nova conta', style: TextStyle(fontSize: 13)),
                    ),
                  ],

                  if (creatingNew) ...[
                    if (openAccounts.isNotEmpty) ...[
                      Row(
                        children: [
                          const Text('Nova conta', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Color(0xFF334155))),
                          const Spacer(),
                          TextButton(
                            onPressed: () => setState(() { creatingNew = false; }),
                            child: const Text('Selecionar existente', style: TextStyle(fontSize: 12)),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                    ] else
                      const Text('Criar conta para o cliente:', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Color(0xFF334155))),
                    const SizedBox(height: 8),
                    TextField(
                      controller: nameCtrl,
                      autofocus: true,
                      decoration: InputDecoration(
                        labelText: 'Nome do cliente',
                        labelStyle: const TextStyle(fontSize: 13, color: Color(0xFF94A3B8)),
                        filled: true,
                        fillColor: const Color(0xFFF8FAFC),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFFE2E8F0))),
                        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFFE2E8F0))),
                        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFF7C3AED), width: 2)),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                      ),
                    ),
                    const SizedBox(height: 10),
                    TextField(
                      controller: phoneCtrl,
                      keyboardType: TextInputType.phone,
                      decoration: InputDecoration(
                        labelText: 'Telefone (opcional)',
                        labelStyle: const TextStyle(fontSize: 13, color: Color(0xFF94A3B8)),
                        filled: true,
                        fillColor: const Color(0xFFF8FAFC),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFFE2E8F0))),
                        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFFE2E8F0))),
                        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFF7C3AED), width: 2)),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancelar')),
            ElevatedButton.icon(
              onPressed: () {
                if (creatingNew) {
                  if (nameCtrl.text.trim().isEmpty) return;
                  Navigator.pop(ctx, 'new:${nameCtrl.text.trim()}|${phoneCtrl.text.trim()}');
                } else {
                  if (selectedAccountId == null) return;
                  Navigator.pop(ctx, 'existing:$selectedAccountId');
                }
              },
              icon: const Icon(Icons.check_rounded, size: 18),
              label: const Text('Confirmar Fiado'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFF59E0B),
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              ),
            ),
          ],
        ),
      ),
    );

    if (result == null || !mounted) return;

    // Create sale as "fiado"
    final sale = await _completeSaleAsFiado(saleProvider, authProvider.currentUser!.id);
    if (sale == null) return;

    // Link to account
    String accountId;
    if (result.startsWith('new:')) {
      final data = result.substring(4);
      final parts = data.split('|');
      final account = await accountProvider.createAccount(parts[0], phone: parts.length > 1 ? parts[1] : '');
      accountId = account.id;
    } else {
      accountId = result.substring(9); // 'existing:'.length
    }

    await accountProvider.addSaleToAccount(accountId, sale);
    _discountController.clear();

    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Row(
          children: [
            Icon(Icons.account_balance_wallet_rounded, color: Colors.white, size: 18),
            SizedBox(width: 8),
            Text('Venda adicionada ao fiado!'),
          ],
        ),
        backgroundColor: const Color(0xFFF59E0B),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  Future<Sale?> _completeSaleAsFiado(SaleProvider saleProvider, String userId) async {
    final draft = saleProvider.activeDraft;
    if (draft.items.isEmpty) return null;

    // Use completeSale with "Fiado" payment method
    final success = await saleProvider.completeSale(
      userId,
      payments: [PaymentEntry(method: 'Fiado', amount: saleProvider.finalAmount)],
    );
    if (!success) return null;

    // Return the last added sale
    return saleProvider.sales.isNotEmpty ? saleProvider.sales.last : null;
  }

  @override
  Widget build(BuildContext context) {
    final products = context.watch<ProductProvider>().filteredProducts;
    final saleProvider = context.watch<SaleProvider>();
    final authProvider = context.watch<AuthProvider>();

    final searchText = _searchController.text.toLowerCase();
    final filtered = searchText.isEmpty
        ? products
        : products.where((p) => p.name.toLowerCase().contains(searchText)).toList();

    return Row(
      children: [
        // ─── Product Grid ───
        Expanded(
          flex: 2,
          child: Container(
            color: const Color(0xFFF8FAFC),
            child: Column(
              children: [
                // Search bar
                Padding(
                  padding: const EdgeInsets.fromLTRB(24, 20, 24, 12),
                  child: TextField(
                    controller: _searchController,
                    decoration: InputDecoration(
                      hintText: 'Buscar produtos...',
                      hintStyle: const TextStyle(color: Color(0xFF94A3B8)),
                      prefixIcon: const Icon(Icons.search_rounded, color: Color(0xFF94A3B8)),
                      filled: true,
                      fillColor: Colors.white,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                        borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                        borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                        borderSide: const BorderSide(color: Color(0xFF7C3AED), width: 2),
                      ),
                      contentPadding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                    onChanged: (_) => setState(() {}),
                  ),
                ).animate().fadeIn(duration: 300.ms),

                // Grid
                Expanded(
                  child: filtered.isEmpty
                      ? Center(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Container(
                                width: 56,
                                height: 56,
                                decoration: BoxDecoration(
                                  color: const Color(0xFF94A3B8).withValues(alpha: 0.1),
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                child: const Icon(Icons.search_off_rounded, color: Color(0xFF94A3B8), size: 28),
                              ),
                              const SizedBox(height: 12),
                              const Text(
                                'Nenhum produto encontrado',
                                style: TextStyle(color: Color(0xFF94A3B8), fontWeight: FontWeight.w600),
                              ),
                            ],
                          ),
                        )
                      : LayoutBuilder(
                          builder: (context, box) {
                            final cols = box.maxWidth >= 900 ? 4 : box.maxWidth >= 600 ? 3 : 2;
                            return GridView.builder(
                              padding: const EdgeInsets.fromLTRB(20, 4, 20, 24),
                              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: cols,
                                childAspectRatio: 0.78,
                                crossAxisSpacing: 12,
                                mainAxisSpacing: 12,
                              ),
                              itemCount: filtered.length,
                              itemBuilder: (context, index) {
                                final product = filtered[index];
                                return _ProductCard(
                                  name: product.name,
                                  price: product.sellingPrice,
                                  stock: product.quantity,
                                  imagePath: product.imagePath,
                                  onTap: () => _showAddQuantityDialog(
                                    context, product.id, product.name, product.sellingPrice,
                                  ),
                                );
                              },
                            );
                          },
                        ),
                ),
              ],
            ),
          ),
        ),

        // ─── Cart Sidebar ───
        Container(
          width: 400,
          decoration: const BoxDecoration(
            color: Colors.white,
            border: Border(left: BorderSide(color: Color(0xFFE2E8F0))),
            boxShadow: [
              BoxShadow(color: Color(0x08000000), blurRadius: 24, offset: Offset(-4, 0)),
            ],
          ),
          child: Column(
            children: [
              // Draft selector
              Container(
                padding: const EdgeInsets.fromLTRB(18, 18, 10, 14),
                decoration: const BoxDecoration(
                  border: Border(bottom: BorderSide(color: Color(0xFFF1F5F9))),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: DropdownButtonFormField<String>(
                        key: ValueKey('${saleProvider.activeDraftId}_${saleProvider.cartItems.length}'),
                        initialValue: saleProvider.activeDraftId,
                        decoration: InputDecoration(
                          labelText: 'Venda aberta',
                          labelStyle: const TextStyle(color: Color(0xFF94A3B8), fontSize: 13),
                          filled: true,
                          fillColor: const Color(0xFFF8FAFC),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFFE2E8F0))),
                          enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFFE2E8F0))),
                          contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                        ),
                        items: saleProvider.drafts.map((d) {
                          final summary = d.shortSummary();
                          return DropdownMenuItem(
                            value: d.id,
                            child: Text(
                              '${d.label} \u2022 $summary',
                              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
                            ),
                          );
                        }).toList(),
                        onChanged: (id) {
                          if (id == null) return;
                          saleProvider.selectDraft(id);
                          _discountController.text = saleProvider.discountAmount == 0
                              ? ''
                              : saleProvider.discountAmount.toStringAsFixed(2);
                        },
                      ),
                    ),
                    const SizedBox(width: 4),
                    _CartIconBtn(
                      icon: Icons.add_rounded,
                      tooltip: 'Nova venda',
                      onTap: () async {
                        final label = await _askSaleLabel(context, title: 'Nova venda');
                        saleProvider.createDraft(label: label);
                        _discountController.clear();
                      },
                    ),
                    _CartIconBtn(
                      icon: Icons.edit_rounded,
                      tooltip: 'Renomear',
                      onTap: () async {
                        final active = saleProvider.activeDraft;
                        final label = await _askSaleLabel(
                          context, title: 'Renomear venda', initialValue: active.label,
                        );
                        if (label == null) return;
                        saleProvider.renameDraft(active.id, label);
                      },
                    ),
                    _CartIconBtn(
                      icon: Icons.delete_outline_rounded,
                      tooltip: 'Excluir venda',
                      color: const Color(0xFFEF4444),
                      onTap: saleProvider.drafts.length <= 1
                          ? null
                          : () {
                              saleProvider.removeDraft(saleProvider.activeDraftId);
                              _discountController.text = saleProvider.discountAmount == 0
                                  ? ''
                                  : saleProvider.discountAmount.toStringAsFixed(2);
                            },
                    ),
                  ],
                ),
              ),

              // Cart items
              Expanded(
                child: saleProvider.cartItems.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              width: 52,
                              height: 52,
                              decoration: BoxDecoration(
                                color: const Color(0xFF94A3B8).withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(14),
                              ),
                              child: const Icon(Icons.shopping_cart_outlined, color: Color(0xFF94A3B8), size: 24),
                            ),
                            const SizedBox(height: 12),
                            const Text('Carrinho vazio', style: TextStyle(fontWeight: FontWeight.w700, color: Color(0xFF334155))),
                            const SizedBox(height: 4),
                            const Text('Clique em um produto para adicionar', style: TextStyle(fontSize: 12, color: Color(0xFF94A3B8))),
                          ],
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        itemCount: saleProvider.cartItems.length,
                        itemBuilder: (context, index) {
                          final item = saleProvider.cartItems[index];
                          return _CartItemTile(
                            name: item.productName,
                            unitPrice: item.unitPrice,
                            quantity: item.quantity,
                            total: item.totalPrice,
                            onRemove: () => saleProvider.removeFromCart(item.productId),
                          );
                        },
                      ),
              ),

              // Checkout footer
              Container(
                padding: const EdgeInsets.all(18),
                decoration: const BoxDecoration(
                  color: Colors.white,
                  border: Border(top: BorderSide(color: Color(0xFFE2E8F0))),
                  boxShadow: [
                    BoxShadow(color: Color(0x08000000), blurRadius: 12, offset: Offset(0, -4)),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      saleProvider.activeDraft.label,
                      style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 16, color: Color(0xFF0F172A)),
                    ),
                    const SizedBox(height: 14),
                    _CheckoutRow(label: 'Subtotal', value: 'R\$ ${saleProvider.subtotal.toStringAsFixed(2)}'),
                    const SizedBox(height: 10),
                    TextField(
                      controller: _discountController,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        labelText: 'Desconto (R\$)',
                        labelStyle: const TextStyle(fontSize: 13, color: Color(0xFF94A3B8)),
                        filled: true,
                        fillColor: const Color(0xFFF8FAFC),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFFE2E8F0))),
                        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFFE2E8F0))),
                        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFF7C3AED), width: 2)),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                      ),
                      onChanged: (value) {
                        final discount = double.tryParse(value) ?? 0;
                        saleProvider.setDiscount(discount);
                      },
                    ),
                    const SizedBox(height: 14),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFF7C3AED), Color(0xFF4F46E5)],
                        ),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('Total', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 16)),
                          Text(
                            'R\$ ${saleProvider.finalAmount.toStringAsFixed(2)}',
                            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 22, letterSpacing: -0.5),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 14),
                    Row(
                      children: [
                        Expanded(
                          flex: 2,
                          child: SizedBox(
                            height: 48,
                            child: OutlinedButton.icon(
                              onPressed: saleProvider.cartItems.isNotEmpty
                                  ? () => _handleFiado(context)
                                  : null,
                              icon: const Icon(Icons.account_balance_wallet_rounded, size: 18),
                              label: const Text('Fiado', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 14)),
                              style: OutlinedButton.styleFrom(
                                foregroundColor: const Color(0xFFF59E0B),
                                side: BorderSide(
                                  color: saleProvider.cartItems.isNotEmpty
                                      ? const Color(0xFFF59E0B)
                                      : const Color(0xFFCBD5E1),
                                ),
                                disabledForegroundColor: const Color(0xFFCBD5E1),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          flex: 3,
                          child: SizedBox(
                            height: 48,
                            child: ElevatedButton.icon(
                              onPressed: saleProvider.cartItems.isNotEmpty
                                  ? () async {
                                      final payments = await _showPaymentDialog(context, saleProvider.finalAmount);
                                      if (payments == null) return;

                                      final success = await saleProvider.completeSale(
                                        authProvider.currentUser!.id,
                                        payments: payments,
                                      );
                                      if (!mounted) return;

                                      if (success) {
                                        _discountController.clear();
                                        ScaffoldMessenger.of(context).showSnackBar(
                                          SnackBar(
                                            content: const Row(
                                              children: [
                                                Icon(Icons.check_circle_rounded, color: Colors.white, size: 18),
                                                SizedBox(width: 8),
                                                Text('Venda realizada com sucesso!'),
                                              ],
                                            ),
                                            backgroundColor: const Color(0xFF10B981),
                                            behavior: SnackBarBehavior.floating,
                                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                          ),
                                        );
                                      } else {
                                        ScaffoldMessenger.of(context).showSnackBar(
                                          SnackBar(
                                            content: Text(saleProvider.errorMessage),
                                            backgroundColor: const Color(0xFFEF4444),
                                            behavior: SnackBarBehavior.floating,
                                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                          ),
                                        );
                                      }
                                    }
                                  : null,
                              icon: const Icon(Icons.check_rounded, size: 20),
                              label: const Text('Confirmar Venda', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 15)),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF10B981),
                                foregroundColor: Colors.white,
                                disabledBackgroundColor: const Color(0xFFCBD5E1),
                                disabledForegroundColor: Colors.white,
                                elevation: 0,
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

// ── Product Card ──

class _ProductCard extends StatefulWidget {
  final String name;
  final double price;
  final int stock;
  final String? imagePath;
  final VoidCallback onTap;

  const _ProductCard({
    required this.name,
    required this.price,
    required this.stock,
    required this.imagePath,
    required this.onTap,
  });

  @override
  State<_ProductCard> createState() => _ProductCardState();
}

class _ProductCardState extends State<_ProductCard> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
              color: _hovered ? const Color(0xFF7C3AED).withValues(alpha: 0.3) : const Color(0xFFE2E8F0),
            ),
            boxShadow: _hovered
                ? [BoxShadow(color: const Color(0xFF7C3AED).withValues(alpha: 0.08), blurRadius: 16, offset: const Offset(0, 6))]
                : [const BoxShadow(color: Color(0x06000000), blurRadius: 8, offset: Offset(0, 2))],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: const Color(0xFFF1F5F9),
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(18)),
                  ),
                  child: widget.imagePath != null
                      ? ClipRRect(
                          borderRadius: const BorderRadius.vertical(top: Radius.circular(18)),
                          child: Image.file(File(widget.imagePath!), fit: BoxFit.cover),
                        )
                      : const Center(
                          child: Icon(Icons.image_outlined, size: 36, color: Color(0xFFCBD5E1)),
                        ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(12, 10, 12, 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.name,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13, color: Color(0xFF0F172A)),
                    ),
                    const SizedBox(height: 6),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'R\$ ${widget.price.toStringAsFixed(2)}',
                          style: const TextStyle(
                            color: Color(0xFF10B981),
                            fontWeight: FontWeight.w800,
                            fontSize: 14,
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: widget.stock > 0
                                ? const Color(0xFF10B981).withValues(alpha: 0.1)
                                : const Color(0xFFEF4444).withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(100),
                          ),
                          child: Text(
                            '${widget.stock} un',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              color: widget.stock > 0 ? const Color(0xFF10B981) : const Color(0xFFEF4444),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Cart Item Tile ──

class _CartItemTile extends StatefulWidget {
  final String name;
  final double unitPrice;
  final int quantity;
  final double total;
  final VoidCallback onRemove;

  const _CartItemTile({
    required this.name,
    required this.unitPrice,
    required this.quantity,
    required this.total,
    required this.onRemove,
  });

  @override
  State<_CartItemTile> createState() => _CartItemTileState();
}

class _CartItemTileState extends State<_CartItemTile> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        margin: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: _hovered ? const Color(0xFFF8FAFC) : Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: _hovered ? const Color(0xFFCBD5E1) : const Color(0xFFF1F5F9)),
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14, color: Color(0xFF0F172A)),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'R\$ ${widget.unitPrice.toStringAsFixed(2)} x ${widget.quantity}',
                    style: const TextStyle(fontSize: 12, color: Color(0xFF94A3B8)),
                  ),
                ],
              ),
            ),
            Text(
              'R\$ ${widget.total.toStringAsFixed(2)}',
              style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 14, color: Color(0xFF0F172A)),
            ),
            const SizedBox(width: 6),
            IconButton(
              onPressed: widget.onRemove,
              icon: const Icon(Icons.close_rounded, size: 18, color: Color(0xFFEF4444)),
              tooltip: 'Remover',
              visualDensity: VisualDensity.compact,
            ),
          ],
        ),
      ),
    );
  }
}

// ── Checkout Row ──

class _CheckoutRow extends StatelessWidget {
  final String label;
  final String value;

  const _CheckoutRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: const TextStyle(color: Color(0xFF64748B), fontSize: 14)),
        Text(value, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14, color: Color(0xFF0F172A))),
      ],
    );
  }
}

// ── Cart Icon Button ──

class _CartIconBtn extends StatelessWidget {
  final IconData icon;
  final String tooltip;
  final VoidCallback? onTap;
  final Color? color;

  const _CartIconBtn({required this.icon, required this.tooltip, this.onTap, this.color});

  @override
  Widget build(BuildContext context) {
    return IconButton(
      tooltip: tooltip,
      onPressed: onTap,
      icon: Icon(icon, size: 20, color: onTap == null ? const Color(0xFFCBD5E1) : (color ?? const Color(0xFF64748B))),
      visualDensity: VisualDensity.compact,
    );
  }
}
