import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../providers/account_provider.dart';
import '../models/account.dart';

class AccountsScreen extends StatefulWidget {
  const AccountsScreen({Key? key}) : super(key: key);

  @override
  State<AccountsScreen> createState() => _AccountsScreenState();
}

class _AccountsScreenState extends State<AccountsScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    Future.microtask(() => context.read<AccountProvider>().load());
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  String _formatCurrency(double v) => NumberFormat.simpleCurrency(locale: 'pt_BR').format(v);
  String _formatDate(DateTime dt) => DateFormat("dd/MM/yyyy 'às' HH:mm", 'pt_BR').format(dt);

  void _showNewAccountDialog() {
    final nameCtrl = TextEditingController();
    final phoneCtrl = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            Container(
              width: 36, height: 36,
              decoration: BoxDecoration(
                color: const Color(0xFF7C3AED).withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(Icons.person_add_rounded, size: 18, color: Color(0xFF7C3AED)),
            ),
            const SizedBox(width: 12),
            const Text('Nova Conta', style: TextStyle(fontWeight: FontWeight.w800, color: Color(0xFF0F172A))),
          ],
        ),
        content: SizedBox(
          width: 380,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _Field(controller: nameCtrl, label: 'Nome do cliente', autofocus: true),
              const SizedBox(height: 12),
              _Field(controller: phoneCtrl, label: 'Telefone (opcional)', keyboard: TextInputType.phone),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancelar')),
          ElevatedButton(
            onPressed: () {
              if (nameCtrl.text.trim().isEmpty) return;
              context.read<AccountProvider>().createAccount(nameCtrl.text, phone: phoneCtrl.text);
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF7C3AED),
              foregroundColor: Colors.white,
              elevation: 0,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            ),
            child: const Text('Criar'),
          ),
        ],
      ),
    );
  }

  void _showPaymentDialog(Account account) {
    final amountCtrl = TextEditingController();
    final descCtrl = TextEditingController(text: 'Pagamento');
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            Container(
              width: 36, height: 36,
              decoration: BoxDecoration(
                color: const Color(0xFF10B981).withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(Icons.payments_rounded, size: 18, color: Color(0xFF10B981)),
            ),
            const SizedBox(width: 12),
            const Text('Registrar Pagamento', style: TextStyle(fontWeight: FontWeight.w800, color: Color(0xFF0F172A))),
          ],
        ),
        content: SizedBox(
          width: 380,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Saldo devedor: ${_formatCurrency(account.balance)}',
                style: const TextStyle(fontSize: 14, color: Color(0xFF64748B)),
              ),
              const SizedBox(height: 16),
              _Field(controller: amountCtrl, label: 'Valor (R\$)', keyboard: TextInputType.number, autofocus: true),
              const SizedBox(height: 12),
              _Field(controller: descCtrl, label: 'Descrição'),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancelar')),
          ElevatedButton(
            onPressed: () {
              final amount = double.tryParse(amountCtrl.text.replaceAll(',', '.')) ?? 0;
              if (amount <= 0) return;
              context.read<AccountProvider>().addPayment(account.id, amount, descCtrl.text);
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF10B981),
              foregroundColor: Colors.white,
              elevation: 0,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            ),
            child: const Text('Confirmar'),
          ),
        ],
      ),
    );
  }

  void _showSettleConfirm(Account account) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Quitar conta', style: TextStyle(fontWeight: FontWeight.w800, color: Color(0xFF0F172A))),
        content: Text(
          account.balance > 0.01
              ? 'Esta conta ainda tem saldo de ${_formatCurrency(account.balance)}. Deseja quitar mesmo assim?'
              : 'Confirma a quitação da conta de ${account.customerName}?',
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancelar')),
          ElevatedButton(
            onPressed: () {
              context.read<AccountProvider>().settleAccount(account.id);
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF10B981),
              foregroundColor: Colors.white,
              elevation: 0,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            child: const Text('Quitar'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AccountProvider>();

    if (provider.isLoading) {
      return const Center(child: CircularProgressIndicator(color: Color(0xFF7C3AED)));
    }

    final open = provider.openAccounts..sort((a, b) => b.createdAt.compareTo(a.createdAt));
    final settled = provider.settledAccounts..sort((a, b) => (b.settledAt ?? b.createdAt).compareTo(a.settledAt ?? a.createdAt));

    return Container(
      color: const Color(0xFFF8FAFC),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Padding(
            padding: const EdgeInsets.fromLTRB(28, 24, 28, 0),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Contas (Fiado)',
                        style: TextStyle(fontSize: 26, fontWeight: FontWeight.w800, letterSpacing: -0.5, color: Color(0xFF0F172A)),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${open.length} abertas \u2022 ${settled.length} quitadas',
                        style: const TextStyle(fontSize: 14, color: Color(0xFF64748B)),
                      ),
                    ],
                  ),
                ),
                ElevatedButton.icon(
                  onPressed: _showNewAccountDialog,
                  icon: const Icon(Icons.person_add_rounded, size: 20),
                  label: const Text('Nova Conta', style: TextStyle(fontWeight: FontWeight.w700)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF7C3AED),
                    foregroundColor: Colors.white,
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  ),
                ),
              ],
            ),
          ).animate().fadeIn(duration: 400.ms).slideY(begin: -0.06, end: 0),

          // Tabs
          Padding(
            padding: const EdgeInsets.fromLTRB(28, 18, 28, 0),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: const Color(0xFFE2E8F0)),
              ),
              child: TabBar(
                controller: _tabController,
                indicatorSize: TabBarIndicatorSize.tab,
                indicator: BoxDecoration(
                  color: const Color(0xFF7C3AED),
                  borderRadius: BorderRadius.circular(12),
                ),
                labelColor: Colors.white,
                unselectedLabelColor: const Color(0xFF64748B),
                labelStyle: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14),
                unselectedLabelStyle: const TextStyle(fontWeight: FontWeight.w500, fontSize: 14),
                dividerHeight: 0,
                padding: const EdgeInsets.all(4),
                tabs: [
                  Tab(text: 'Abertas (${open.length})'),
                  Tab(text: 'Quitadas (${settled.length})'),
                ],
              ),
            ),
          ).animate().fadeIn(duration: 400.ms, delay: 100.ms),

          const SizedBox(height: 14),

          // List
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildList(open, isOpen: true),
                _buildList(settled, isOpen: false),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildList(List<Account> accounts, {required bool isOpen}) {
    if (accounts.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 56, height: 56,
              decoration: BoxDecoration(
                color: const Color(0xFF94A3B8).withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Icon(
                isOpen ? Icons.person_outline_rounded : Icons.check_circle_outline_rounded,
                color: const Color(0xFF94A3B8), size: 28,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              isOpen ? 'Nenhuma conta aberta' : 'Nenhuma conta quitada',
              style: const TextStyle(fontWeight: FontWeight.w700, color: Color(0xFF334155)),
            ),
            const SizedBox(height: 4),
            Text(
              isOpen ? 'Crie uma conta ou adicione fiado no PDV' : 'Contas quitadas aparecem aqui',
              style: const TextStyle(fontSize: 13, color: Color(0xFF94A3B8)),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(28, 0, 28, 24),
      itemCount: accounts.length,
      itemBuilder: (context, index) {
        final account = accounts[index];
        return _AccountCard(
          account: account,
          formatCurrency: _formatCurrency,
          formatDate: _formatDate,
          onPay: () => _showPaymentDialog(account),
          onSettle: () => _showSettleConfirm(account),
          onReopen: () => context.read<AccountProvider>().reopenAccount(account.id),
          onDelete: () => context.read<AccountProvider>().deleteAccount(account.id),
        );
      },
    ).animate().fadeIn(duration: 500.ms, delay: 200.ms);
  }
}

// ── Account Card ──

class _AccountCard extends StatefulWidget {
  final Account account;
  final String Function(double) formatCurrency;
  final String Function(DateTime) formatDate;
  final VoidCallback onPay;
  final VoidCallback onSettle;
  final VoidCallback onReopen;
  final VoidCallback onDelete;

  const _AccountCard({
    required this.account,
    required this.formatCurrency,
    required this.formatDate,
    required this.onPay,
    required this.onSettle,
    required this.onReopen,
    required this.onDelete,
  });

  @override
  State<_AccountCard> createState() => _AccountCardState();
}

class _AccountCardState extends State<_AccountCard> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    final a = widget.account;
    final isOpen = a.status == 'open';
    final balance = a.balance;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: const [BoxShadow(color: Color(0x06000000), blurRadius: 8, offset: Offset(0, 2))],
      ),
      child: Column(
        children: [
          // Header
          InkWell(
            borderRadius: BorderRadius.circular(18),
            onTap: () => setState(() => _expanded = !_expanded),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  // Avatar
                  CircleAvatar(
                    radius: 22,
                    backgroundColor: isOpen
                        ? const Color(0xFF7C3AED).withValues(alpha: 0.1)
                        : const Color(0xFF10B981).withValues(alpha: 0.1),
                    child: Text(
                      a.customerName.isNotEmpty ? a.customerName[0].toUpperCase() : '?',
                      style: TextStyle(
                        fontWeight: FontWeight.w800,
                        color: isOpen ? const Color(0xFF7C3AED) : const Color(0xFF10B981),
                      ),
                    ),
                  ),
                  const SizedBox(width: 14),

                  // Name & info
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          a.customerName,
                          style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15, color: Color(0xFF0F172A)),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          [
                            if (a.phone.isNotEmpty) a.phone,
                            '${a.entries.length} lançamentos',
                            if (!isOpen && a.settledAt != null)
                              'Quitada em ${widget.formatDate(a.settledAt!)}',
                          ].join(' \u2022 '),
                          style: const TextStyle(fontSize: 12, color: Color(0xFF94A3B8)),
                        ),
                      ],
                    ),
                  ),

                  // Balance
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        widget.formatCurrency(balance),
                        style: TextStyle(
                          fontWeight: FontWeight.w800,
                          fontSize: 16,
                          color: balance <= 0.01
                              ? const Color(0xFF10B981)
                              : const Color(0xFFEF4444),
                        ),
                      ),
                      Text(
                        balance <= 0.01 ? 'Quitado' : 'Em aberto',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: balance <= 0.01
                              ? const Color(0xFF10B981)
                              : const Color(0xFFF59E0B),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(width: 8),

                  AnimatedRotation(
                    turns: _expanded ? 0.5 : 0,
                    duration: const Duration(milliseconds: 200),
                    child: const Icon(Icons.keyboard_arrow_down_rounded, color: Color(0xFF94A3B8)),
                  ),
                ],
              ),
            ),
          ),

          // Expanded
          if (_expanded)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Divider(color: Color(0xFFF1F5F9)),
                  const SizedBox(height: 4),

                  // Summary
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF8FAFC),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: const Color(0xFFF1F5F9)),
                    ),
                    child: Column(
                      children: [
                        _InfoRow(label: 'Total em compras', value: widget.formatCurrency(a.totalOwed)),
                        const SizedBox(height: 6),
                        _InfoRow(label: 'Total pago', value: widget.formatCurrency(a.totalPaid)),
                        const Divider(height: 18, color: Color(0xFFE2E8F0)),
                        _InfoRow(
                          label: 'Saldo devedor',
                          value: widget.formatCurrency(balance),
                          bold: true,
                          valueColor: balance <= 0.01 ? const Color(0xFF10B981) : const Color(0xFFEF4444),
                        ),
                      ],
                    ),
                  ),

                  if (a.entries.isNotEmpty) ...[
                    const SizedBox(height: 14),
                    const Text('Lançamentos', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13, color: Color(0xFF334155))),
                    const SizedBox(height: 8),
                    ...a.entries.reversed.map((e) => _EntryRow(
                      entry: e,
                      formatCurrency: widget.formatCurrency,
                      formatDate: widget.formatDate,
                    )),
                  ],

                  const SizedBox(height: 14),

                  // Actions
                  if (isOpen)
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: widget.onPay,
                            icon: const Icon(Icons.payments_rounded, size: 18),
                            label: const Text('Pagamento'),
                            style: OutlinedButton.styleFrom(
                              foregroundColor: const Color(0xFF10B981),
                              side: const BorderSide(color: Color(0xFF10B981)),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                              padding: const EdgeInsets.symmetric(vertical: 12),
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: widget.onSettle,
                            icon: const Icon(Icons.check_circle_rounded, size: 18),
                            label: const Text('Quitar'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF10B981),
                              foregroundColor: Colors.white,
                              elevation: 0,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                              padding: const EdgeInsets.symmetric(vertical: 12),
                            ),
                          ),
                        ),
                      ],
                    )
                  else
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: widget.onReopen,
                            icon: const Icon(Icons.replay_rounded, size: 18),
                            label: const Text('Reabrir'),
                            style: OutlinedButton.styleFrom(
                              foregroundColor: const Color(0xFFF59E0B),
                              side: const BorderSide(color: Color(0xFFF59E0B)),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                              padding: const EdgeInsets.symmetric(vertical: 12),
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: widget.onDelete,
                            icon: const Icon(Icons.delete_outline_rounded, size: 18),
                            label: const Text('Excluir'),
                            style: OutlinedButton.styleFrom(
                              foregroundColor: const Color(0xFFEF4444),
                              side: const BorderSide(color: Color(0xFFEF4444)),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                              padding: const EdgeInsets.symmetric(vertical: 12),
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
    );
  }
}

// ── Entry Row ──

class _EntryRow extends StatelessWidget {
  final AccountEntry entry;
  final String Function(double) formatCurrency;
  final String Function(DateTime) formatDate;

  const _EntryRow({required this.entry, required this.formatCurrency, required this.formatDate});

  @override
  Widget build(BuildContext context) {
    final isSale = entry.type == 'sale';
    return Container(
      margin: const EdgeInsets.only(bottom: 6),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: isSale
            ? const Color(0xFFFEF2F2)
            : const Color(0xFFF0FDF4),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isSale
              ? const Color(0xFFEF4444).withValues(alpha: 0.12)
              : const Color(0xFF10B981).withValues(alpha: 0.12),
        ),
      ),
      child: Row(
        children: [
          Icon(
            isSale ? Icons.shopping_bag_rounded : Icons.payments_rounded,
            size: 16,
            color: isSale ? const Color(0xFFEF4444) : const Color(0xFF10B981),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  entry.description,
                  style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Color(0xFF0F172A)),
                ),
                Text(
                  formatDate(entry.createdAt),
                  style: const TextStyle(fontSize: 11, color: Color(0xFF94A3B8)),
                ),
              ],
            ),
          ),
          Text(
            '${isSale ? '+' : '-'} ${formatCurrency(entry.amount)}',
            style: TextStyle(
              fontWeight: FontWeight.w800,
              fontSize: 13,
              color: isSale ? const Color(0xFFEF4444) : const Color(0xFF10B981),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Info Row ──

class _InfoRow extends StatelessWidget {
  final String label;
  final String value;
  final bool bold;
  final Color? valueColor;

  const _InfoRow({required this.label, required this.value, this.bold = false, this.valueColor});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: const TextStyle(fontSize: 13, color: Color(0xFF64748B))),
        Text(
          value,
          style: TextStyle(
            fontSize: bold ? 14 : 13,
            fontWeight: bold ? FontWeight.w800 : FontWeight.w600,
            color: valueColor ?? const Color(0xFF0F172A),
          ),
        ),
      ],
    );
  }
}

// ── Field ──

class _Field extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final TextInputType? keyboard;
  final bool autofocus;

  const _Field({required this.controller, required this.label, this.keyboard, this.autofocus = false});

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      keyboardType: keyboard,
      autofocus: autofocus,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(fontSize: 13, color: Color(0xFF94A3B8)),
        filled: true,
        fillColor: const Color(0xFFF8FAFC),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFFE2E8F0))),
        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFFE2E8F0))),
        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFF7C3AED), width: 2)),
        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      ),
    );
  }
}
