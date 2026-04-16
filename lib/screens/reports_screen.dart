import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../providers/sale_provider.dart';

class ReportsScreen extends StatefulWidget {
  const ReportsScreen({Key? key}) : super(key: key);

  @override
  State<ReportsScreen> createState() => _ReportsScreenState();
}

class _ReportsScreenState extends State<ReportsScreen> {
  late DateTime _startDate;
  late DateTime _endDate;

  @override
  void initState() {
    super.initState();
    _endDate = DateTime.now();
    _startDate = _endDate.subtract(const Duration(days: 30));
  }

  String _fmt(DateTime dt) => DateFormat('dd/MM/yyyy').format(dt);

  Future<void> _pickDate(bool isStart) async {
    final date = await showDatePicker(
      context: context,
      initialDate: isStart ? _startDate : _endDate,
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
          _startDate = date;
        } else {
          _endDate = date;
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final saleProvider = context.read<SaleProvider>();

    return Container(
      color: const Color(0xFFF8FAFC),
      child: FutureBuilder<Map<String, dynamic>>(
        future: saleProvider.getSalesReport(_startDate, _endDate),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator(color: Color(0xFF7C3AED)));
          }

          if (!snapshot.hasData) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 56,
                    height: 56,
                    decoration: BoxDecoration(
                      color: const Color(0xFFEF4444).withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: const Icon(Icons.error_outline_rounded, color: Color(0xFFEF4444), size: 28),
                  ),
                  const SizedBox(height: 12),
                  const Text('Erro ao carregar relatório', style: TextStyle(fontWeight: FontWeight.w700, color: Color(0xFF334155))),
                ],
              ),
            );
          }

          final report = snapshot.data!;

          return SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(32, 28, 32, 36),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                const Text(
                  'Relatórios',
                  style: TextStyle(fontSize: 26, fontWeight: FontWeight.w800, letterSpacing: -0.5, color: Color(0xFF0F172A)),
                ).animate().fadeIn(duration: 400.ms).slideY(begin: -0.06, end: 0),
                const SizedBox(height: 4),
                const Text(
                  'Análise de vendas por período',
                  style: TextStyle(fontSize: 14, color: Color(0xFF64748B)),
                ).animate().fadeIn(duration: 400.ms).slideY(begin: -0.06, end: 0),

                const SizedBox(height: 20),

                // Date picker row
                Row(
                  children: [
                    _DatePickerChip(
                      label: 'Início',
                      date: _fmt(_startDate),
                      onTap: () => _pickDate(true),
                    ),
                    const SizedBox(width: 10),
                    const Icon(Icons.arrow_forward_rounded, size: 18, color: Color(0xFF94A3B8)),
                    const SizedBox(width: 10),
                    _DatePickerChip(
                      label: 'Fim',
                      date: _fmt(_endDate),
                      onTap: () => _pickDate(false),
                    ),
                  ],
                ).animate().fadeIn(duration: 400.ms, delay: 100.ms),

                const SizedBox(height: 24),

                // KPI Grid
                LayoutBuilder(
                  builder: (context, box) {
                    final cols = box.maxWidth >= 1000 ? 3 : 2;
                    final gap = 14.0;
                    final w = (box.maxWidth - gap * (cols - 1)) / cols;

                    return Wrap(
                      spacing: gap,
                      runSpacing: gap,
                      children: [
                        SizedBox(
                          width: w,
                          child: _ReportKpi(
                            title: 'Receita Total',
                            value: 'R\$ ${((report['totalRevenue'] as num).toDouble()).toStringAsFixed(2)}',
                            icon: Icons.trending_up_rounded,
                            gradient: const [Color(0xFF10B981), Color(0xFF059669)],
                          ),
                        ),
                        SizedBox(
                          width: w,
                          child: _ReportKpi(
                            title: 'Descontos',
                            value: 'R\$ ${((report['totalDiscount'] as num).toDouble()).toStringAsFixed(2)}',
                            icon: Icons.discount_rounded,
                            gradient: const [Color(0xFFF59E0B), Color(0xFFD97706)],
                          ),
                        ),
                        SizedBox(
                          width: w,
                          child: _ReportKpi(
                            title: 'Ticket Médio',
                            value: 'R\$ ${((report['averageTicket'] as num).toDouble()).toStringAsFixed(2)}',
                            icon: Icons.receipt_long_rounded,
                            gradient: const [Color(0xFF7C3AED), Color(0xFF4F46E5)],
                          ),
                        ),
                        SizedBox(
                          width: w,
                          child: _ReportCard(
                            title: 'Itens Vendidos',
                            value: report['totalItems'].toString(),
                            icon: Icons.shopping_basket_rounded,
                            accent: const Color(0xFF3B82F6),
                          ),
                        ),
                        SizedBox(
                          width: w,
                          child: _ReportCard(
                            title: 'Vendas Concluídas',
                            value: report['completedSales'].toString(),
                            icon: Icons.check_circle_rounded,
                            accent: const Color(0xFF10B981),
                          ),
                        ),
                        SizedBox(
                          width: w,
                          child: _ReportCard(
                            title: 'Vendas Canceladas',
                            value: report['cancelledSales'].toString(),
                            icon: Icons.cancel_rounded,
                            accent: const Color(0xFFEF4444),
                          ),
                        ),
                      ],
                    );
                  },
                ).animate().fadeIn(duration: 500.ms, delay: 200.ms).slideY(begin: 0.06, end: 0),
              ],
            ),
          );
        },
      ),
    );
  }
}

// ── Date Picker Chip ──

class _DatePickerChip extends StatefulWidget {
  final String label;
  final String date;
  final VoidCallback onTap;

  const _DatePickerChip({required this.label, required this.date, required this.onTap});

  @override
  State<_DatePickerChip> createState() => _DatePickerChipState();
}

class _DatePickerChipState extends State<_DatePickerChip> {
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
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: _hovered ? const Color(0xFF7C3AED).withValues(alpha: 0.06) : Colors.white,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: _hovered ? const Color(0xFF7C3AED).withValues(alpha: 0.25) : const Color(0xFFE2E8F0),
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.calendar_today_rounded, size: 16, color: Color(0xFF7C3AED)),
              const SizedBox(width: 10),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(widget.label, style: const TextStyle(fontSize: 11, color: Color(0xFF94A3B8), fontWeight: FontWeight.w600)),
                  Text(widget.date, style: const TextStyle(fontSize: 14, color: Color(0xFF0F172A), fontWeight: FontWeight.w700)),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Report KPI (gradient) ──

class _ReportKpi extends StatefulWidget {
  final String title;
  final String value;
  final IconData icon;
  final List<Color> gradient;

  const _ReportKpi({required this.title, required this.value, required this.icon, required this.gradient});

  @override
  State<_ReportKpi> createState() => _ReportKpiState();
}

class _ReportKpiState extends State<_ReportKpi> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 220),
        curve: Curves.easeOut,
        transform: _hovered
            ? (Matrix4.identity()..setEntry(0, 0, 1.015)..setEntry(1, 1, 1.015))
            : Matrix4.identity(),
        transformAlignment: Alignment.center,
        padding: const EdgeInsets.all(22),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: widget.gradient,
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: widget.gradient.first.withValues(alpha: _hovered ? 0.3 : 0.15),
              blurRadius: _hovered ? 24 : 14,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 42,
                  height: 42,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.18),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(widget.icon, color: Colors.white, size: 22),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    widget.title,
                    style: TextStyle(color: Colors.white.withValues(alpha: 0.85), fontWeight: FontWeight.w600, fontSize: 14),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 18),
            Text(
              widget.value,
              style: const TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.w800, letterSpacing: -0.8),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Report Card (white) ──

class _ReportCard extends StatefulWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color accent;

  const _ReportCard({required this.title, required this.value, required this.icon, required this.accent});

  @override
  State<_ReportCard> createState() => _ReportCardState();
}

class _ReportCardState extends State<_ReportCard> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 220),
        curve: Curves.easeOut,
        transform: _hovered
            ? (Matrix4.identity()..setEntry(0, 0, 1.015)..setEntry(1, 1, 1.015))
            : Matrix4.identity(),
        transformAlignment: Alignment.center,
        padding: const EdgeInsets.all(22),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: _hovered ? widget.accent.withValues(alpha: 0.25) : const Color(0xFFE2E8F0),
          ),
          boxShadow: [
            BoxShadow(
              color: _hovered ? widget.accent.withValues(alpha: 0.08) : const Color(0x08000000),
              blurRadius: _hovered ? 20 : 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 42,
                  height: 42,
                  decoration: BoxDecoration(
                    color: widget.accent.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(widget.icon, color: widget.accent, size: 22),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    widget.title,
                    style: const TextStyle(color: Color(0xFF64748B), fontWeight: FontWeight.w600, fontSize: 14),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 18),
            Text(
              widget.value,
              style: const TextStyle(color: Color(0xFF0F172A), fontSize: 28, fontWeight: FontWeight.w800, letterSpacing: -0.8),
            ),
          ],
        ),
      ),
    );
  }
}
