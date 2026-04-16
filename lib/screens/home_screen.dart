import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../providers/auth_provider.dart';
import '../providers/product_provider.dart';
import '../providers/sale_provider.dart';
import 'pos_screen.dart';
import 'products_screen.dart';
import 'sales_history_screen.dart';
import 'reports_screen.dart';
import 'accounts_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with TickerProviderStateMixin {
  int _selectedIndex = 0;

  static const _surface = Color(0xFFF8FAFC);

  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      context.read<ProductProvider>().loadProducts();
      context.read<SaleProvider>().loadSales();
    });
  }

  String _greeting() {
    final h = DateTime.now().hour;
    if (h < 12) return 'Bom dia';
    if (h < 18) return 'Boa tarde';
    return 'Boa noite';
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();
    final user = authProvider.currentUser;
    final firstName = (user?.fullName ?? 'Usuário').split(' ').first;

    return Scaffold(
      backgroundColor: _surface,
      body: Row(
        children: [
          // ─── Sidebar ───
          _Sidebar(
            selectedIndex: _selectedIndex,
            userName: user?.fullName ?? '',
            userRole: user?.role.name ?? '',
            onItemTap: (i) => setState(() => _selectedIndex = i),
            onLogout: () {
              authProvider.logout();
              Navigator.of(context).pushReplacementNamed('/login');
            },
          ),

          // ─── Content ───
          Expanded(
            child: IndexedStack(
              index: _selectedIndex,
              children: [
                _DashboardContent(
                  greeting: _greeting(),
                  firstName: firstName,
                  onNavigate: (i) => setState(() => _selectedIndex = i),
                ),
                POSScreen(isActive: _selectedIndex == 1),
                const ProductsScreen(),
                const SalesHistoryScreen(),
                const AccountsScreen(),
                const ReportsScreen(),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════
//  SIDEBAR
// ═══════════════════════════════════════════════════════════════

class _Sidebar extends StatelessWidget {
  final int selectedIndex;
  final String userName;
  final String userRole;
  final ValueChanged<int> onItemTap;
  final VoidCallback onLogout;

  const _Sidebar({
    required this.selectedIndex,
    required this.userName,
    required this.userRole,
    required this.onItemTap,
    required this.onLogout,
  });

  static const _bg = Color(0xFF1E1B2E);
  static const _active = Color(0xFF2D2945);
  static const _primary = Color(0xFF7C3AED);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 240,
      decoration: const BoxDecoration(
        color: _bg,
        boxShadow: [
          BoxShadow(
            color: Color(0x1A000000),
            blurRadius: 24,
            offset: Offset(4, 0),
          ),
        ],
      ),
      child: Column(
        children: [
          // ── Brand ──
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 28, 20, 8),
            child: Row(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: Image.asset(
                    'assets/images/logo/logo.png',
                    width: 38,
                    height: 38,
                    fit: BoxFit.contain,
                  ),
                ),
                const SizedBox(width: 12),
                const Text(
                  'Lotus PDV',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    letterSpacing: -0.3,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 20),

          // ── Nav Items ──
          ..._navItems.asMap().entries.map((e) {
            final i = e.key;
            final item = e.value;
            final selected = selectedIndex == i;
            return _SidebarItem(
              icon: item.$1,
              label: item.$2,
              selected: selected,
              onTap: () => onItemTap(i),
            );
          }),

          const Spacer(),

          // ── User Info ──
          Container(
            margin: const EdgeInsets.fromLTRB(14, 0, 14, 8),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: _active,
              borderRadius: BorderRadius.circular(14),
            ),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 18,
                  backgroundColor: _primary.withValues(alpha: 0.3),
                  child: Text(
                    userName.isNotEmpty ? userName[0].toUpperCase() : 'U',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                      fontSize: 14,
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        userName,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                          fontSize: 13,
                        ),
                      ),
                      Text(
                        _roleLabel(userRole),
                        style: TextStyle(
                          color: Colors.white.withValues(alpha:0.5),
                          fontSize: 11,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // ── Logout ──
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 0, 14, 20),
            child: SizedBox(
              width: double.infinity,
              child: TextButton.icon(
                onPressed: onLogout,
                icon: Icon(Icons.logout_rounded, size: 18, color: Colors.white.withValues(alpha:0.5)),
                label: Text(
                  'Sair',
                  style: TextStyle(color: Colors.white.withValues(alpha:0.5), fontSize: 13),
                ),
                style: TextButton.styleFrom(
                  alignment: Alignment.centerLeft,
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _roleLabel(String role) {
    switch (role) {
      case 'admin':
        return 'Administrador';
      case 'manager':
        return 'Gerente';
      case 'seller':
        return 'Vendedor';
      default:
        return role;
    }
  }

  static const _navItems = <(IconData, String)>[
    (Icons.grid_view_rounded, 'Dashboard'),
    (Icons.point_of_sale_rounded, 'PDV'),
    (Icons.inventory_2_rounded, 'Produtos'),
    (Icons.receipt_long_rounded, 'Histórico'),
    (Icons.account_balance_wallet_rounded, 'Contas'),
    (Icons.insights_rounded, 'Relatórios'),
  ];
}

class _SidebarItem extends StatefulWidget {
  final IconData icon;
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _SidebarItem({
    required this.icon,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  State<_SidebarItem> createState() => _SidebarItemState();
}

class _SidebarItemState extends State<_SidebarItem> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    final active = widget.selected;
    final highlight = active || _hovered;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 2),
      child: MouseRegion(
        onEnter: (_) => setState(() => _hovered = true),
        onExit: (_) => setState(() => _hovered = false),
        child: GestureDetector(
          onTap: widget.onTap,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 180),
            curve: Curves.easeOut,
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
            decoration: BoxDecoration(
              color: active
                  ? const Color(0xFF2D2945)
                  : _hovered
                      ? const Color(0xFF252240)
                      : Colors.transparent,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                Icon(
                  widget.icon,
                  size: 20,
                  color: active
                      ? const Color(0xFFA78BFA)
                      : Colors.white.withValues(alpha:highlight ? 0.85 : 0.45),
                ),
                const SizedBox(width: 12),
                Text(
                  widget.label,
                  style: TextStyle(
                    color: active
                        ? Colors.white
                        : Colors.white.withValues(alpha:highlight ? 0.85 : 0.55),
                    fontWeight: active ? FontWeight.w700 : FontWeight.w500,
                    fontSize: 14,
                  ),
                ),
                if (active) ...[
                  const Spacer(),
                  Container(
                    width: 6,
                    height: 6,
                    decoration: const BoxDecoration(
                      color: Color(0xFFA78BFA),
                      shape: BoxShape.circle,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════
//  DASHBOARD CONTENT
// ═══════════════════════════════════════════════════════════════

class _DashboardContent extends StatelessWidget {
  final String greeting;
  final String firstName;
  final ValueChanged<int> onNavigate;

  const _DashboardContent({
    required this.greeting,
    required this.firstName,
    required this.onNavigate,
  });

  String _formatCurrency(double v) =>
      NumberFormat.simpleCurrency(locale: 'pt_BR').format(v);

  bool _isSameDay(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;

  @override
  Widget build(BuildContext context) {
    final products = context.watch<ProductProvider>().products;
    final sales = context.watch<SaleProvider>().sales;
    final now = DateTime.now();

    final completed = sales.where((s) => s.status == 'completed').toList();
    final today = completed.where((s) => _isSameDay(s.createdAt, now)).toList();

    final revenue = today.fold<double>(0, (s, e) => s + e.finalAmount);
    final discount = today.fold<double>(0, (s, e) => s + e.discountAmount);
    final items = today.fold<int>(0, (s, e) => s + e.itemCount);
    final avgTicket = today.isEmpty ? 0.0 : revenue / today.length;

    final lowStock = products.where((p) => p.isActive && p.quantity <= 5).toList()
      ..sort((a, b) => a.quantity.compareTo(b.quantity));

    final recent = [...completed]..sort((a, b) => b.createdAt.compareTo(a.createdAt));

    // yesterday revenue for comparison
    final yesterday = now.subtract(const Duration(days: 1));
    final yesterdaySales =
        completed.where((s) => _isSameDay(s.createdAt, yesterday)).toList();
    final revenueYesterday =
        yesterdaySales.fold<double>(0, (s, e) => s + e.finalAmount);
    final revenueDelta = revenueYesterday > 0
        ? ((revenue - revenueYesterday) / revenueYesterday * 100)
        : (revenue > 0 ? 100.0 : 0.0);

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(32, 28, 32, 36),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Header ──
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '$greeting, $firstName',
                      style: const TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.w800,
                        letterSpacing: -0.5,
                        color: Color(0xFF0F172A),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Resumo do dia \u2022 ${DateFormat("EEEE, dd 'de' MMMM", "pt_BR").format(now)}',
                      style: const TextStyle(
                        fontSize: 14,
                        color: Color(0xFF64748B),
                      ),
                    ),
                  ],
                ),
              ),
              _TimeChip(),
            ],
          ).animate().fadeIn(duration: 400.ms).slideY(begin: -0.08, end: 0),

          const SizedBox(height: 24),

          // ── KPI row ──
          LayoutBuilder(
            builder: (context, box) {
              final cols = box.maxWidth >= 1100
                  ? 4
                  : box.maxWidth >= 750
                      ? 2
                      : 1;
              final gap = 14.0;
              final w = (box.maxWidth - gap * (cols - 1)) / cols;

              return Wrap(
                spacing: gap,
                runSpacing: gap,
                children: [
                  SizedBox(
                    width: w,
                    child: _GradientKpiCard(
                      title: 'Faturamento',
                      value: _formatCurrency(revenue),
                      caption: today.isEmpty
                          ? 'Nenhuma venda hoje'
                          : '${today.length} vendas \u2022 ticket médio ${_formatCurrency(avgTicket)}',
                      icon: Icons.trending_up_rounded,
                      gradient: const [Color(0xFF7C3AED), Color(0xFF4F46E5)],
                      delta: revenueDelta,
                    ),
                  ),
                  SizedBox(
                    width: w,
                    child: _KpiCard(
                      title: 'Itens vendidos',
                      value: items.toString(),
                      caption: 'Descontos: ${_formatCurrency(discount)}',
                      icon: Icons.shopping_basket_rounded,
                      accent: const Color(0xFF10B981),
                    ),
                  ),
                  SizedBox(
                    width: w,
                    child: _KpiCard(
                      title: 'Produtos ativos',
                      value: products.where((p) => p.isActive).length.toString(),
                      caption: '${products.length} cadastrados no total',
                      icon: Icons.inventory_2_rounded,
                      accent: const Color(0xFF3B82F6),
                    ),
                  ),
                  SizedBox(
                    width: w,
                    child: _KpiCard(
                      title: 'Estoque baixo',
                      value: lowStock.length.toString(),
                      caption: lowStock.isEmpty
                          ? 'Tudo certo!'
                          : 'Até 5 unidades restantes',
                      icon: Icons.warning_amber_rounded,
                      accent: lowStock.isEmpty
                          ? const Color(0xFF10B981)
                          : const Color(0xFFF59E0B),
                    ),
                  ),
                ],
              );
            },
          )
              .animate()
              .fadeIn(duration: 500.ms, delay: 100.ms)
              .slideY(begin: 0.06, end: 0),

          const SizedBox(height: 24),

          // ── Quick Actions ──
          _QuickActions(onNavigate: onNavigate)
              .animate()
              .fadeIn(duration: 500.ms, delay: 200.ms)
              .slideY(begin: 0.06, end: 0),

          const SizedBox(height: 24),

          // ── Bottom sections (recent sales + stock alerts) ──
          LayoutBuilder(
            builder: (context, c2) {
              final wide = c2.maxWidth >= 900;
              if (wide) {
                return Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      flex: 3,
                      child: _RecentSalesCard(
                        sales: recent,
                        formatCurrency: _formatCurrency,
                        onViewAll: () => onNavigate(3),
                        onOpenPOS: () => onNavigate(1),
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      flex: 2,
                      child: _StockAlertsCard(
                        items: lowStock,
                        onOpenProducts: () => onNavigate(2),
                      ),
                    ),
                  ],
                );
              }
              return Column(
                children: [
                  _RecentSalesCard(
                    sales: recent,
                    formatCurrency: _formatCurrency,
                    onViewAll: () => onNavigate(3),
                    onOpenPOS: () => onNavigate(1),
                  ),
                  const SizedBox(height: 14),
                  _StockAlertsCard(
                    items: lowStock,
                    onOpenProducts: () => onNavigate(2),
                  ),
                ],
              );
            },
          )
              .animate()
              .fadeIn(duration: 500.ms, delay: 300.ms)
              .slideY(begin: 0.06, end: 0),
        ],
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════
//  TIME CHIP (live clock feel)
// ═══════════════════════════════════════════════════════════════

class _TimeChip extends StatefulWidget {
  @override
  State<_TimeChip> createState() => _TimeChipState();
}

class _TimeChipState extends State<_TimeChip> {
  late String _time;

  @override
  void initState() {
    super.initState();
    _time = DateFormat('HH:mm').format(DateTime.now());
    _tick();
  }

  void _tick() {
    Future.delayed(const Duration(seconds: 30), () {
      if (!mounted) return;
      setState(() => _time = DateFormat('HH:mm').format(DateTime.now()));
      _tick();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xFF7C3AED).withValues(alpha:0.08),
        borderRadius: BorderRadius.circular(100),
        border: Border.all(color: const Color(0xFF7C3AED).withValues(alpha:0.12)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.access_time_rounded, size: 16, color: Color(0xFF7C3AED)),
          const SizedBox(width: 6),
          Text(
            _time,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: Color(0xFF7C3AED),
              letterSpacing: 0.5,
            ),
          ),
        ],
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════
//  GRADIENT KPI CARD  (main revenue card)
// ═══════════════════════════════════════════════════════════════

class _GradientKpiCard extends StatefulWidget {
  final String title;
  final String value;
  final String caption;
  final IconData icon;
  final List<Color> gradient;
  final double delta;

  const _GradientKpiCard({
    required this.title,
    required this.value,
    required this.caption,
    required this.icon,
    required this.gradient,
    required this.delta,
  });

  @override
  State<_GradientKpiCard> createState() => _GradientKpiCardState();
}

class _GradientKpiCardState extends State<_GradientKpiCard> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 220),
        curve: Curves.easeOut,
        transform: _hovered ? (Matrix4.identity()..setEntry(0, 0, 1.015)..setEntry(1, 1, 1.015)) : Matrix4.identity(),
        transformAlignment: Alignment.center,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: widget.gradient,
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: widget.gradient.first.withValues(alpha:_hovered ? 0.35 : 0.2),
              blurRadius: _hovered ? 28 : 16,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        padding: const EdgeInsets.all(22),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 42,
                  height: 42,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha:0.18),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(widget.icon, color: Colors.white, size: 22),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    widget.title,
                    style: TextStyle(
                      color: Colors.white.withValues(alpha:0.85),
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                    ),
                  ),
                ),
                if (widget.delta != 0)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha:0.18),
                      borderRadius: BorderRadius.circular(100),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          widget.delta > 0
                              ? Icons.arrow_upward_rounded
                              : Icons.arrow_downward_rounded,
                          size: 12,
                          color: Colors.white,
                        ),
                        const SizedBox(width: 2),
                        Text(
                          '${widget.delta.abs().toStringAsFixed(0)}%',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 18),
            Text(
              widget.value,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 30,
                fontWeight: FontWeight.w800,
                letterSpacing: -0.8,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              widget.caption,
              style: TextStyle(
                color: Colors.white.withValues(alpha:0.7),
                fontSize: 13,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════
//  STANDARD KPI CARD
// ═══════════════════════════════════════════════════════════════

class _KpiCard extends StatefulWidget {
  final String title;
  final String value;
  final String caption;
  final IconData icon;
  final Color accent;

  const _KpiCard({
    required this.title,
    required this.value,
    required this.caption,
    required this.icon,
    required this.accent,
  });

  @override
  State<_KpiCard> createState() => _KpiCardState();
}

class _KpiCardState extends State<_KpiCard> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 220),
        curve: Curves.easeOut,
        transform: _hovered ? (Matrix4.identity()..setEntry(0, 0, 1.015)..setEntry(1, 1, 1.015)) : Matrix4.identity(),
        transformAlignment: Alignment.center,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: _hovered
                ? widget.accent.withValues(alpha:0.25)
                : const Color(0xFFE2E8F0),
          ),
          boxShadow: [
            BoxShadow(
              color: _hovered
                  ? widget.accent.withValues(alpha:0.08)
                  : const Color(0x08000000),
              blurRadius: _hovered ? 20 : 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        padding: const EdgeInsets.all(22),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 42,
                  height: 42,
                  decoration: BoxDecoration(
                    color: widget.accent.withValues(alpha:0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(widget.icon, color: widget.accent, size: 22),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    widget.title,
                    style: const TextStyle(
                      color: Color(0xFF64748B),
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 18),
            Text(
              widget.value,
              style: const TextStyle(
                color: Color(0xFF0F172A),
                fontSize: 30,
                fontWeight: FontWeight.w800,
                letterSpacing: -0.8,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              widget.caption,
              style: const TextStyle(
                color: Color(0xFF94A3B8),
                fontSize: 13,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════
//  QUICK ACTIONS
// ═══════════════════════════════════════════════════════════════

class _QuickActions extends StatelessWidget {
  final ValueChanged<int> onNavigate;

  const _QuickActions({required this.onNavigate});

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 10,
      runSpacing: 10,
      children: [
        _ActionButton(
          icon: Icons.point_of_sale_rounded,
          label: 'Abrir PDV',
          color: const Color(0xFF7C3AED),
          onTap: () => onNavigate(1),
        ),
        _ActionButton(
          icon: Icons.inventory_2_rounded,
          label: 'Produtos',
          color: const Color(0xFF3B82F6),
          onTap: () => onNavigate(2),
        ),
        _ActionButton(
          icon: Icons.receipt_long_rounded,
          label: 'Histórico',
          color: const Color(0xFF10B981),
          onTap: () => onNavigate(3),
        ),
        _ActionButton(
          icon: Icons.account_balance_wallet_rounded,
          label: 'Contas',
          color: const Color(0xFFF59E0B),
          onTap: () => onNavigate(4),
        ),
        _ActionButton(
          icon: Icons.insights_rounded,
          label: 'Relatórios',
          color: const Color(0xFFEC4899),
          onTap: () => onNavigate(5),
        ),
      ],
    );
  }
}

class _ActionButton extends StatefulWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _ActionButton({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  State<_ActionButton> createState() => _ActionButtonState();
}

class _ActionButtonState extends State<_ActionButton> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
          decoration: BoxDecoration(
            color: _hovered ? widget.color : Colors.white,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: _hovered
                  ? widget.color
                  : widget.color.withValues(alpha:0.2),
            ),
            boxShadow: _hovered
                ? [
                    BoxShadow(
                      color: widget.color.withValues(alpha:0.2),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    )
                  ]
                : [],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                widget.icon,
                size: 18,
                color: _hovered ? Colors.white : widget.color,
              ),
              const SizedBox(width: 10),
              Text(
                widget.label,
                style: TextStyle(
                  fontWeight: FontWeight.w700,
                  fontSize: 14,
                  color: _hovered ? Colors.white : const Color(0xFF0F172A),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════
//  RECENT SALES CARD
// ═══════════════════════════════════════════════════════════════

class _RecentSalesCard extends StatelessWidget {
  final List sales;
  final String Function(double) formatCurrency;
  final VoidCallback onViewAll;
  final VoidCallback onOpenPOS;

  const _RecentSalesCard({
    required this.sales,
    required this.formatCurrency,
    required this.onViewAll,
    required this.onOpenPOS,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: const [
          BoxShadow(color: Color(0x06000000), blurRadius: 12, offset: Offset(0, 4)),
        ],
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: const Color(0xFF7C3AED).withValues(alpha:0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.receipt_long_rounded,
                    size: 18, color: Color(0xFF7C3AED)),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Vendas recentes',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF0F172A),
                      ),
                    ),
                    Text(
                      sales.isEmpty
                          ? 'Nenhuma venda registrada'
                          : 'Últimas ${sales.length >= 8 ? 8 : sales.length} vendas',
                      style: const TextStyle(fontSize: 12, color: Color(0xFF94A3B8)),
                    ),
                  ],
                ),
              ),
              TextButton(
                onPressed: onViewAll,
                style: TextButton.styleFrom(
                  foregroundColor: const Color(0xFF7C3AED),
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text('Ver tudo', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
                    SizedBox(width: 4),
                    Icon(Icons.arrow_forward_rounded, size: 14),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          if (sales.isEmpty)
            _EmptyState(
              icon: Icons.receipt_long_rounded,
              title: 'Sem vendas ainda',
              message: 'Finalize vendas no PDV para vê-las aqui.',
              actionLabel: 'Abrir PDV',
              onAction: onOpenPOS,
            )
          else
            ...sales.take(8).map((s) => _SaleRow(
                  time: DateFormat('HH:mm').format(s.createdAt),
                  amount: formatCurrency(s.finalAmount),
                  items: s.itemCount,
                  payment: s.paymentMethod,
                )),
        ],
      ),
    );
  }
}

class _SaleRow extends StatefulWidget {
  final String time;
  final String amount;
  final int items;
  final String payment;

  const _SaleRow({
    required this.time,
    required this.amount,
    required this.items,
    required this.payment,
  });

  @override
  State<_SaleRow> createState() => _SaleRowState();
}

class _SaleRowState extends State<_SaleRow> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 160),
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(14),
          color: _hovered ? const Color(0xFFF1F5F9) : const Color(0xFFF8FAFC),
          border: Border.all(
            color: _hovered
                ? const Color(0xFFCBD5E1)
                : const Color(0xFFE2E8F0).withValues(alpha:0.6),
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF10B981), Color(0xFF059669)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(Icons.check_rounded, color: Colors.white, size: 18),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.amount,
                    style: const TextStyle(
                      fontWeight: FontWeight.w800,
                      fontSize: 15,
                      color: Color(0xFF0F172A),
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '${widget.items} itens \u2022 ${widget.payment}',
                    style: const TextStyle(fontSize: 12, color: Color(0xFF94A3B8)),
                  ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(
                color: const Color(0xFF0F172A).withValues(alpha:0.05),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                widget.time,
                style: const TextStyle(
                  fontWeight: FontWeight.w700,
                  fontSize: 13,
                  color: Color(0xFF475569),
                  letterSpacing: 0.3,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════
//  STOCK ALERTS CARD
// ═══════════════════════════════════════════════════════════════

class _StockAlertsCard extends StatelessWidget {
  final List items;
  final VoidCallback onOpenProducts;

  const _StockAlertsCard({
    required this.items,
    required this.onOpenProducts,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: const [
          BoxShadow(color: Color(0x06000000), blurRadius: 12, offset: Offset(0, 4)),
        ],
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: const Color(0xFFF59E0B).withValues(alpha:0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.warning_amber_rounded,
                    size: 18, color: Color(0xFFF59E0B)),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Alertas de estoque',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF0F172A),
                      ),
                    ),
                    Text(
                      items.isEmpty ? 'Tudo certo!' : '${items.length} produto(s) com estoque baixo',
                      style: const TextStyle(fontSize: 12, color: Color(0xFF94A3B8)),
                    ),
                  ],
                ),
              ),
              TextButton(
                onPressed: onOpenProducts,
                style: TextButton.styleFrom(
                  foregroundColor: const Color(0xFF7C3AED),
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text('Produtos', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
                    SizedBox(width: 4),
                    Icon(Icons.arrow_forward_rounded, size: 14),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          if (items.isEmpty)
            const _EmptyState(
              icon: Icons.check_circle_rounded,
              title: 'Estoque OK',
              message: 'Nenhum produto com estoque baixo.',
            )
          else
            ...items.take(8).map((p) => _StockRow(
                  name: p.name,
                  sku: p.sku,
                  qty: p.quantity,
                  maxQty: 5,
                )),
        ],
      ),
    );
  }
}

class _StockRow extends StatelessWidget {
  final String name;
  final String sku;
  final int qty;
  final int maxQty;

  const _StockRow({
    required this.name,
    required this.sku,
    required this.qty,
    required this.maxQty,
  });

  Color _color() {
    if (qty <= 1) return const Color(0xFFEF4444);
    if (qty <= 3) return const Color(0xFFF59E0B);
    return const Color(0xFF3B82F6);
  }

  @override
  Widget build(BuildContext context) {
    final c = _color();
    final pct = (qty / maxQty).clamp(0.0, 1.0);

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(14),
        color: const Color(0xFFF8FAFC),
        border: Border.all(color: const Color(0xFFE2E8F0).withValues(alpha:0.6)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 14,
                        color: Color(0xFF0F172A),
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      sku,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(fontSize: 11, color: Color(0xFF94A3B8)),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 10),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(100),
                  color: c.withValues(alpha:0.1),
                  border: Border.all(color: c.withValues(alpha:0.2)),
                ),
                child: Text(
                  '$qty un',
                  style: TextStyle(
                    fontWeight: FontWeight.w800,
                    fontSize: 12,
                    color: c,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          ClipRRect(
            borderRadius: BorderRadius.circular(100),
            child: LinearProgressIndicator(
              value: pct,
              minHeight: 5,
              backgroundColor: c.withValues(alpha:0.1),
              valueColor: AlwaysStoppedAnimation(c),
            ),
          ),
        ],
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════
//  EMPTY STATE
// ═══════════════════════════════════════════════════════════════

class _EmptyState extends StatelessWidget {
  final IconData icon;
  final String title;
  final String message;
  final String? actionLabel;
  final VoidCallback? onAction;

  const _EmptyState({
    required this.icon,
    required this.title,
    required this.message,
    this.actionLabel,
    this.onAction,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 28),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        color: const Color(0xFFF8FAFC),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        children: [
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              color: const Color(0xFF94A3B8).withValues(alpha:0.1),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(icon, size: 24, color: const Color(0xFF94A3B8)),
          ),
          const SizedBox(height: 14),
          Text(
            title,
            style: const TextStyle(
              fontWeight: FontWeight.w800,
              fontSize: 15,
              color: Color(0xFF334155),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            message,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 13, color: Color(0xFF94A3B8)),
          ),
          if (actionLabel != null && onAction != null) ...[
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: onAction,
              icon: const Icon(Icons.arrow_forward_rounded, size: 16),
              label: Text(actionLabel!),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF7C3AED),
                foregroundColor: Colors.white,
                elevation: 0,
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
