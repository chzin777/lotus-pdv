import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../providers/sale_provider.dart';
import '../models/sale.dart';

enum _HistoryFilter { day, month, period }

class SalesHistoryScreen extends StatefulWidget {
  const SalesHistoryScreen({Key? key}) : super(key: key);

  @override
  State<SalesHistoryScreen> createState() => _SalesHistoryScreenState();
}

class _SalesHistoryScreenState extends State<SalesHistoryScreen> {
  late TextEditingController _reasonController;
  _HistoryFilter _activeFilter = _HistoryFilter.day;
  late DateTime _selectedDay;
  late int _selectedMonthIndex;
  late DateTime _periodStart;
  late DateTime _periodEnd;

  static const _monthNames = [
    'Jan', 'Fev', 'Mar', 'Abr', 'Mai', 'Jun',
    'Jul', 'Ago', 'Set', 'Out', 'Nov', 'Dez',
  ];

  @override
  void initState() {
    super.initState();
    _reasonController = TextEditingController();
    final now = DateTime.now();
    _selectedDay = DateTime(now.year, now.month, now.day);
    _selectedMonthIndex = now.month - 1;
    _periodStart = now.subtract(const Duration(days: 30));
    _periodEnd = now;
    Future.microtask(() {
      context.read<SaleProvider>().loadSales();
    });
  }

  @override
  void dispose() {
    _reasonController.dispose();
    super.dispose();
  }

  List<Sale> _applyFilter(List<Sale> sales) {
    final now = DateTime.now();
    switch (_activeFilter) {
      case _HistoryFilter.day:
        return sales.where((s) {
          return s.createdAt.year == _selectedDay.year &&
              s.createdAt.month == _selectedDay.month &&
              s.createdAt.day == _selectedDay.day;
        }).toList();
      case _HistoryFilter.month:
        final month = _selectedMonthIndex + 1;
        final year = now.year;
        return sales.where((s) {
          return s.createdAt.year == year && s.createdAt.month == month;
        }).toList();
      case _HistoryFilter.period:
        final start = DateTime(_periodStart.year, _periodStart.month, _periodStart.day);
        final end = DateTime(_periodEnd.year, _periodEnd.month, _periodEnd.day, 23, 59, 59);
        return sales.where((s) {
          return s.createdAt.isAfter(start.subtract(const Duration(seconds: 1))) &&
              s.createdAt.isBefore(end.add(const Duration(seconds: 1)));
        }).toList();
    }
  }

  String _filterLabel() {
    switch (_activeFilter) {
      case _HistoryFilter.day:
        final now = DateTime.now();
        final today = DateTime(now.year, now.month, now.day);
        if (_selectedDay == today) return 'Hoje';
        return DateFormat('dd/MM/yyyy').format(_selectedDay);
      case _HistoryFilter.month:
        return _monthNames[_selectedMonthIndex];
      case _HistoryFilter.period:
        return '${DateFormat('dd/MM').format(_periodStart)} - ${DateFormat('dd/MM').format(_periodEnd)}';
    }
  }

  Future<void> _pickDay() async {
    final date = await showDatePicker(
      context: context,
      initialDate: _selectedDay,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: Color(0xFF7C3AED),
              onPrimary: Colors.white,
              surface: Colors.white,
            ),
          ),
          child: child!,
        );
      },
    );
    if (date != null) {
      setState(() => _selectedDay = date);
    }
  }

  Future<void> _pickPeriodDate(bool isStart) async {
    final date = await showDatePicker(
      context: context,
      initialDate: isStart ? _periodStart : _periodEnd,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: Color(0xFF7C3AED),
              onPrimary: Colors.white,
              surface: Colors.white,
            ),
          ),
          child: child!,
        );
      },
    );
    if (date != null) {
      setState(() {
        if (isStart) {
          _periodStart = date;
        } else {
          _periodEnd = date;
        }
      });
    }
  }

  void _showCancelDialog(BuildContext context, String saleId) {
    _reasonController.clear();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: const Color(0xFFEF4444).withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(Icons.cancel_outlined, size: 18, color: Color(0xFFEF4444)),
            ),
            const SizedBox(width: 12),
            const Text('Cancelar Venda', style: TextStyle(fontWeight: FontWeight.w800, color: Color(0xFF0F172A))),
          ],
        ),
        content: SizedBox(
          width: 400,
          child: TextField(
            controller: _reasonController,
            maxLines: 3,
            decoration: InputDecoration(
              labelText: 'Motivo do cancelamento',
              labelStyle: const TextStyle(color: Color(0xFF94A3B8), fontSize: 13),
              hintText: 'Descreva o motivo...',
              filled: true,
              fillColor: const Color(0xFFF8FAFC),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFFE2E8F0))),
              enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFFE2E8F0))),
              focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFFEF4444), width: 2)),
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Voltar'),
          ),
          ElevatedButton.icon(
            onPressed: () async {
              final reason = _reasonController.text;
              if (reason.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: const Text('Informe o motivo do cancelamento'),
                    backgroundColor: const Color(0xFFF59E0B),
                    behavior: SnackBarBehavior.floating,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                );
                return;
              }

              final success = await context.read<SaleProvider>().cancelSale(saleId, reason);
              if (mounted) {
                Navigator.pop(context);
                if (success) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: const Row(
                        children: [
                          Icon(Icons.check_circle_rounded, color: Colors.white, size: 18),
                          SizedBox(width: 8),
                          Text('Venda cancelada com sucesso'),
                        ],
                      ),
                      backgroundColor: const Color(0xFF10B981),
                      behavior: SnackBarBehavior.floating,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                  );
                }
              }
            },
            icon: const Icon(Icons.cancel_outlined, size: 18),
            label: const Text('Confirmar Cancelamento'),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFEF4444),
              foregroundColor: Colors.white,
              elevation: 0,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime dt) => DateFormat("dd/MM/yyyy 'às' HH:mm", 'pt_BR').format(dt);

  @override
  Widget build(BuildContext context) {
    final saleProvider = context.watch<SaleProvider>();
    final allSales = [...saleProvider.sales]..sort((a, b) => b.createdAt.compareTo(a.createdAt));
    final sales = _applyFilter(allSales);
    final now = DateTime.now();
    final currentMonth = now.month - 1;

    if (saleProvider.isLoading) {
      return const Center(child: CircularProgressIndicator(color: Color(0xFF7C3AED)));
    }

    return Container(
      color: const Color(0xFFF8FAFC),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Padding(
            padding: const EdgeInsets.fromLTRB(28, 24, 28, 0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Histórico de Vendas',
                  style: TextStyle(fontSize: 26, fontWeight: FontWeight.w800, letterSpacing: -0.5, color: Color(0xFF0F172A)),
                ),
                const SizedBox(height: 4),
                Text(
                  '${sales.length} vendas encontradas  ·  ${_filterLabel()}',
                  style: const TextStyle(fontSize: 14, color: Color(0xFF64748B)),
                ),
              ],
            ),
          ).animate().fadeIn(duration: 400.ms).slideY(begin: -0.06, end: 0),

          const SizedBox(height: 16),

          // Filter bar
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 28),
            child: Column(
              children: [
                // Filter type chips
                Row(
                  children: [
                    _HistoryFilterChip(
                      label: 'Dia',
                      icon: Icons.today_rounded,
                      isActive: _activeFilter == _HistoryFilter.day,
                      onTap: () => setState(() => _activeFilter = _HistoryFilter.day),
                    ),
                    const SizedBox(width: 8),
                    _HistoryFilterChip(
                      label: 'Mês',
                      icon: Icons.calendar_month_rounded,
                      isActive: _activeFilter == _HistoryFilter.month,
                      onTap: () => setState(() => _activeFilter = _HistoryFilter.month),
                    ),
                    const SizedBox(width: 8),
                    _HistoryFilterChip(
                      label: 'Período',
                      icon: Icons.date_range_rounded,
                      isActive: _activeFilter == _HistoryFilter.period,
                      onTap: () => setState(() => _activeFilter = _HistoryFilter.period),
                    ),
                  ],
                ),

                const SizedBox(height: 12),

                // Filter controls
                if (_activeFilter == _HistoryFilter.day)
                  _DayFilterRow(
                    selectedDay: _selectedDay,
                    onPickDay: _pickDay,
                    onPreviousDay: () {
                      setState(() {
                        _selectedDay = _selectedDay.subtract(const Duration(days: 1));
                      });
                    },
                    onNextDay: () {
                      final tomorrow = _selectedDay.add(const Duration(days: 1));
                      if (!tomorrow.isAfter(DateTime.now())) {
                        setState(() => _selectedDay = tomorrow);
                      }
                    },
                    onToday: () {
                      final today = DateTime(now.year, now.month, now.day);
                      setState(() => _selectedDay = today);
                    },
                  ),

                if (_activeFilter == _HistoryFilter.month)
                  SizedBox(
                    height: 38,
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      itemCount: currentMonth + 1,
                      separatorBuilder: (_, __) => const SizedBox(width: 8),
                      itemBuilder: (context, index) {
                        final isActive = _selectedMonthIndex == index;
                        return _MonthChip(
                          label: _monthNames[index],
                          isActive: isActive,
                          onTap: () => setState(() => _selectedMonthIndex = index),
                        );
                      },
                    ),
                  ),

                if (_activeFilter == _HistoryFilter.period)
                  Row(
                    children: [
                      _PeriodDateChip(
                        label: 'Início',
                        date: DateFormat('dd/MM/yyyy').format(_periodStart),
                        onTap: () => _pickPeriodDate(true),
                      ),
                      const SizedBox(width: 10),
                      const Icon(Icons.arrow_forward_rounded, size: 18, color: Color(0xFF94A3B8)),
                      const SizedBox(width: 10),
                      _PeriodDateChip(
                        label: 'Fim',
                        date: DateFormat('dd/MM/yyyy').format(_periodEnd),
                        onTap: () => _pickPeriodDate(false),
                      ),
                    ],
                  ),
              ],
            ),
          ).animate().fadeIn(duration: 400.ms, delay: 80.ms),

          const SizedBox(height: 18),

          // List
          Expanded(
            child: sales.isEmpty
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
                          child: const Icon(Icons.receipt_long_outlined, color: Color(0xFF94A3B8), size: 28),
                        ),
                        const SizedBox(height: 12),
                        const Text('Nenhuma venda encontrada', style: TextStyle(fontWeight: FontWeight.w700, color: Color(0xFF334155))),
                        const SizedBox(height: 4),
                        Text(
                          'Sem vendas para ${_filterLabel().toLowerCase()}',
                          style: const TextStyle(fontSize: 13, color: Color(0xFF94A3B8)),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.fromLTRB(28, 0, 28, 24),
                    itemCount: sales.length,
                    itemBuilder: (context, index) {
                      final sale = sales[index];
                      return _SaleCard(
                        sale: sale,
                        formatDate: _formatDate,
                        onCancel: () => _showCancelDialog(context, sale.id),
                      );
                    },
                  ).animate().fadeIn(duration: 500.ms, delay: 100.ms),
          ),
        ],
      ),
    );
  }
}

// ── History Filter Chip ──

class _HistoryFilterChip extends StatefulWidget {
  final String label;
  final IconData icon;
  final bool isActive;
  final VoidCallback onTap;

  const _HistoryFilterChip({required this.label, required this.icon, required this.isActive, required this.onTap});

  @override
  State<_HistoryFilterChip> createState() => _HistoryFilterChipState();
}

class _HistoryFilterChipState extends State<_HistoryFilterChip> {
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
          duration: const Duration(milliseconds: 180),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 9),
          decoration: BoxDecoration(
            color: widget.isActive
                ? const Color(0xFF7C3AED)
                : _hovered
                    ? const Color(0xFF7C3AED).withValues(alpha: 0.08)
                    : Colors.white,
            borderRadius: BorderRadius.circular(100),
            border: Border.all(
              color: widget.isActive
                  ? const Color(0xFF7C3AED)
                  : _hovered
                      ? const Color(0xFF7C3AED).withValues(alpha: 0.3)
                      : const Color(0xFFE2E8F0),
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(widget.icon, size: 16, color: widget.isActive ? Colors.white : const Color(0xFF7C3AED)),
              const SizedBox(width: 6),
              Text(
                widget.label,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: widget.isActive ? Colors.white : const Color(0xFF334155),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Day Filter Row ──

class _DayFilterRow extends StatelessWidget {
  final DateTime selectedDay;
  final VoidCallback onPickDay;
  final VoidCallback onPreviousDay;
  final VoidCallback onNextDay;
  final VoidCallback onToday;

  const _DayFilterRow({
    required this.selectedDay,
    required this.onPickDay,
    required this.onPreviousDay,
    required this.onNextDay,
    required this.onToday,
  });

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final isToday = selectedDay == today;

    return Row(
      children: [
        _SmallIconButton(icon: Icons.chevron_left_rounded, onTap: onPreviousDay),
        const SizedBox(width: 6),
        GestureDetector(
          onTap: onPickDay,
          child: MouseRegion(
            cursor: SystemMouseCursors.click,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: const Color(0xFFE2E8F0)),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.calendar_today_rounded, size: 14, color: Color(0xFF7C3AED)),
                  const SizedBox(width: 8),
                  Text(
                    isToday ? 'Hoje' : DateFormat('dd/MM/yyyy').format(selectedDay),
                    style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: Color(0xFF0F172A)),
                  ),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(width: 6),
        _SmallIconButton(icon: Icons.chevron_right_rounded, onTap: onNextDay),
        const SizedBox(width: 10),
        if (!isToday)
          GestureDetector(
            onTap: onToday,
            child: MouseRegion(
              cursor: SystemMouseCursors.click,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: const Color(0xFF7C3AED).withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Text('Hoje', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: Color(0xFF7C3AED))),
              ),
            ),
          ),
      ],
    );
  }
}

class _SmallIconButton extends StatefulWidget {
  final IconData icon;
  final VoidCallback onTap;

  const _SmallIconButton({required this.icon, required this.onTap});

  @override
  State<_SmallIconButton> createState() => _SmallIconButtonState();
}

class _SmallIconButtonState extends State<_SmallIconButton> {
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
          duration: const Duration(milliseconds: 150),
          width: 34,
          height: 34,
          decoration: BoxDecoration(
            color: _hovered ? const Color(0xFF7C3AED).withValues(alpha: 0.08) : Colors.white,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: const Color(0xFFE2E8F0)),
          ),
          child: Icon(widget.icon, size: 20, color: const Color(0xFF64748B)),
        ),
      ),
    );
  }
}

// ── Month Chip ──

class _MonthChip extends StatefulWidget {
  final String label;
  final bool isActive;
  final VoidCallback onTap;

  const _MonthChip({required this.label, required this.isActive, required this.onTap});

  @override
  State<_MonthChip> createState() => _MonthChipState();
}

class _MonthChipState extends State<_MonthChip> {
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
          duration: const Duration(milliseconds: 180),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: widget.isActive
                ? const Color(0xFF7C3AED)
                : _hovered
                    ? const Color(0xFF7C3AED).withValues(alpha: 0.08)
                    : Colors.white,
            borderRadius: BorderRadius.circular(100),
            border: Border.all(
              color: widget.isActive
                  ? const Color(0xFF7C3AED)
                  : const Color(0xFFE2E8F0),
            ),
          ),
          child: Text(
            widget.label,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: widget.isActive ? Colors.white : const Color(0xFF334155),
            ),
          ),
        ),
      ),
    );
  }
}

// ── Period Date Chip ──

class _PeriodDateChip extends StatefulWidget {
  final String label;
  final String date;
  final VoidCallback onTap;

  const _PeriodDateChip({required this.label, required this.date, required this.onTap});

  @override
  State<_PeriodDateChip> createState() => _PeriodDateChipState();
}

class _PeriodDateChipState extends State<_PeriodDateChip> {
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
          duration: const Duration(milliseconds: 180),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          decoration: BoxDecoration(
            color: _hovered ? const Color(0xFF7C3AED).withValues(alpha: 0.06) : Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: _hovered ? const Color(0xFF7C3AED).withValues(alpha: 0.25) : const Color(0xFFE2E8F0),
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.calendar_today_rounded, size: 14, color: Color(0xFF7C3AED)),
              const SizedBox(width: 8),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(widget.label, style: const TextStyle(fontSize: 10, color: Color(0xFF94A3B8), fontWeight: FontWeight.w600)),
                  Text(widget.date, style: const TextStyle(fontSize: 13, color: Color(0xFF0F172A), fontWeight: FontWeight.w700)),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Sale Card ──

class _SaleCard extends StatefulWidget {
  final Sale sale;
  final String Function(DateTime) formatDate;
  final VoidCallback onCancel;

  const _SaleCard({required this.sale, required this.formatDate, required this.onCancel});

  @override
  State<_SaleCard> createState() => _SaleCardState();
}

class _SaleCardState extends State<_SaleCard> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    final sale = widget.sale;
    final isCompleted = sale.status == 'completed';
    final titleLabel = (sale.label != null && sale.label!.trim().isNotEmpty)
        ? sale.label!.trim()
        : '#${sale.id.length > 8 ? sale.id.substring(0, 8) : sale.id}';

    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: const [
          BoxShadow(color: Color(0x06000000), blurRadius: 8, offset: Offset(0, 2)),
        ],
      ),
      child: Column(
        children: [
          // Header row
          InkWell(
            borderRadius: BorderRadius.circular(18),
            onTap: () => setState(() => _expanded = !_expanded),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  // Status icon
                  Container(
                    width: 42,
                    height: 42,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: isCompleted
                            ? [const Color(0xFF10B981), const Color(0xFF059669)]
                            : [const Color(0xFFEF4444), const Color(0xFFDC2626)],
                      ),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      isCompleted ? Icons.check_rounded : Icons.close_rounded,
                      color: Colors.white,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 14),

                  // Title & date
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          titleLabel,
                          style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15, color: Color(0xFF0F172A)),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          widget.formatDate(sale.createdAt),
                          style: const TextStyle(fontSize: 12, color: Color(0xFF94A3B8)),
                        ),
                      ],
                    ),
                  ),

                  // Status badge
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(
                      color: isCompleted
                          ? const Color(0xFF10B981).withValues(alpha: 0.1)
                          : const Color(0xFFEF4444).withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(100),
                    ),
                    child: Text(
                      isCompleted ? 'Concluída' : 'Cancelada',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: isCompleted ? const Color(0xFF10B981) : const Color(0xFFEF4444),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),

                  // Amount
                  Text(
                    'R\$ ${sale.finalAmount.toStringAsFixed(2)}',
                    style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 16, color: Color(0xFF0F172A)),
                  ),
                  const SizedBox(width: 8),

                  // Expand arrow
                  AnimatedRotation(
                    turns: _expanded ? 0.5 : 0,
                    duration: const Duration(milliseconds: 200),
                    child: const Icon(Icons.keyboard_arrow_down_rounded, color: Color(0xFF94A3B8)),
                  ),
                ],
              ),
            ),
          ),

          // Expanded detail
          if (_expanded)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Divider(color: Color(0xFFF1F5F9)),
                  const SizedBox(height: 8),

                  // Items
                  ...sale.items.map<Widget>((item) => Padding(
                        padding: const EdgeInsets.only(bottom: 6),
                        child: Row(
                          children: [
                            Container(
                              width: 6,
                              height: 6,
                              decoration: const BoxDecoration(
                                color: Color(0xFF7C3AED),
                                shape: BoxShape.circle,
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Text(
                                '${item.productName} x${item.quantity}',
                                style: const TextStyle(fontSize: 13, color: Color(0xFF334155)),
                              ),
                            ),
                            Text(
                              'R\$ ${item.totalPrice.toStringAsFixed(2)}',
                              style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Color(0xFF0F172A)),
                            ),
                          ],
                        ),
                      )),

                  const SizedBox(height: 12),

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
                        _PaymentDetail(raw: sale.paymentMethod),
                        const SizedBox(height: 6),
                        _DetailRow(label: 'Subtotal', value: 'R\$ ${sale.totalAmount.toStringAsFixed(2)}'),
                        const SizedBox(height: 6),
                        _DetailRow(label: 'Desconto', value: 'R\$ ${sale.discountAmount.toStringAsFixed(2)}'),
                        const Divider(height: 18, color: Color(0xFFE2E8F0)),
                        _DetailRow(
                          label: 'Total',
                          value: 'R\$ ${sale.finalAmount.toStringAsFixed(2)}',
                          bold: true,
                        ),
                      ],
                    ),
                  ),

                  // Cancel reason or cancel button
                  if (isCompleted) ...[
                    const SizedBox(height: 14),
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton.icon(
                        onPressed: widget.onCancel,
                        icon: const Icon(Icons.cancel_outlined, size: 18),
                        label: const Text('Cancelar Venda'),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: const Color(0xFFEF4444),
                          side: const BorderSide(color: Color(0xFFEF4444)),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                      ),
                    ),
                  ] else if (sale.cancellationReason != null) ...[
                    const SizedBox(height: 12),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: const Color(0xFFEF4444).withValues(alpha: 0.06),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: const Color(0xFFEF4444).withValues(alpha: 0.12)),
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Icon(Icons.info_outline_rounded, size: 16, color: Color(0xFFEF4444)),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              'Motivo: ${sale.cancellationReason}',
                              style: const TextStyle(fontSize: 13, color: Color(0xFFEF4444), fontStyle: FontStyle.italic),
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
    );
  }
}

// ── Payment Detail ──

class _PaymentDetail extends StatelessWidget {
  final String raw;

  const _PaymentDetail({required this.raw});

  @override
  Widget build(BuildContext context) {
    final parts = raw.split(';').where((s) => s.trim().isNotEmpty).toList();

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const Text('Pagamento', style: TextStyle(fontSize: 13, color: Color(0xFF64748B))),
        Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: parts.map((part) {
            final sep = part.indexOf(':');
            if (sep == -1) {
              return Text(part.trim(), style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Color(0xFF0F172A)));
            }
            final method = part.substring(0, sep).trim();
            final amount = part.substring(sep + 1).trim();
            return Padding(
              padding: const EdgeInsets.only(bottom: 2),
              child: Text(
                '$method: R\$ $amount',
                style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Color(0xFF0F172A)),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }
}

// ── Detail Row ──

class _DetailRow extends StatelessWidget {
  final String label;
  final String value;
  final bool bold;

  const _DetailRow({required this.label, required this.value, this.bold = false});

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
            color: const Color(0xFF0F172A),
          ),
        ),
      ],
    );
  }
}
