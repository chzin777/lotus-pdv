import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
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

  @override
  Widget build(BuildContext context) {
    final saleProvider = context.read<SaleProvider>();

    return FutureBuilder<Map<String, dynamic>>(
      future: saleProvider.getSalesReport(_startDate, _endDate),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (!snapshot.hasData) {
          return const Center(child: Text('Erro ao carregar relatório'));
        }

        final report = snapshot.data!;

        return SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Relatórios',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: ListTile(
                        title: const Text('Data Início'),
                        subtitle: Text(_startDate.toString().split(' ')[0]),
                        onTap: () async {
                          final date = await showDatePicker(
                            context: context,
                            initialDate: _startDate,
                            firstDate: DateTime(2020),
                            lastDate: DateTime.now(),
                          );
                          if (date != null) {
                            setState(() => _startDate = date);
                          }
                        },
                      ),
                    ),
                    Expanded(
                      child: ListTile(
                        title: const Text('Data Fim'),
                        subtitle: Text(_endDate.toString().split(' ')[0]),
                        onTap: () async {
                          final date = await showDatePicker(
                            context: context,
                            initialDate: _endDate,
                            firstDate: DateTime(2020),
                            lastDate: DateTime.now(),
                          );
                          if (date != null) {
                            setState(() => _endDate = date);
                          }
                        },
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                GridView.count(
                  crossAxisCount: 2,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  mainAxisSpacing: 16,
                  crossAxisSpacing: 16,
                  children: [
                    _buildReportCard(
                      title: 'Receita Total',
                      value: 'R\$ ${report['totalRevenue'].toStringAsFixed(2)}',
                      icon: Icons.money,
                      color: const Color(0xFF10B981),
                    ),
                    _buildReportCard(
                      title: 'Desconto Total',
                      value: 'R\$ ${report['totalDiscount'].toStringAsFixed(2)}',
                      icon: Icons.discount,
                      color: const Color(0xFFF59E0B),
                    ),
                    _buildReportCard(
                      title: 'Total de Itens',
                      value: report['totalItems'].toString(),
                      icon: Icons.shopping_cart,
                      color: const Color(0xFF7C3AED),
                    ),
                    _buildReportCard(
                      title: 'Ticket Médio',
                      value: 'R\$ ${report['averageTicket'].toStringAsFixed(2)}',
                      icon: Icons.trending_up,
                      color: const Color(0xFFA78BFA),
                    ),
                    _buildReportCard(
                      title: 'Vendas Concluídas',
                      value: report['completedSales'].toString(),
                      icon: Icons.check_circle,
                      color: const Color(0xFF10B981),
                    ),
                    _buildReportCard(
                      title: 'Vendas Canceladas',
                      value: report['cancelledSales'].toString(),
                      icon: Icons.cancel,
                      color: const Color(0xFFEF4444),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildReportCard({
    required String title,
    required String value,
    required IconData icon,
    required Color color,
  }) {
    return Card(
      elevation: 2,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          gradient: LinearGradient(
            colors: [color.withOpacity(0.1), color.withOpacity(0.05)],
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 40, color: color),
              const SizedBox(height: 12),
              Text(
                title,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                value,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
