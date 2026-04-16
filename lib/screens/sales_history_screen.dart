import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/sale_provider.dart';

class SalesHistoryScreen extends StatefulWidget {
  const SalesHistoryScreen({Key? key}) : super(key: key);

  @override
  State<SalesHistoryScreen> createState() => _SalesHistoryScreenState();
}

class _SalesHistoryScreenState extends State<SalesHistoryScreen> {
  late TextEditingController _reasonController;

  @override
  void initState() {
    super.initState();
    _reasonController = TextEditingController();
    Future.microtask(() {
      context.read<SaleProvider>().loadSales();
    });
  }

  @override
  void dispose() {
    _reasonController.dispose();
    super.dispose();
  }

  void _showCancelDialog(BuildContext context, String saleId) {
    _reasonController.clear();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Cancelar Venda'),
        content: TextField(
          controller: _reasonController,
          maxLines: 3,
          decoration: const InputDecoration(
            labelText: 'Motivo do cancelamento',
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () async {
              final reason = _reasonController.text;
              if (reason.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Por favor, informe o motivo')),
                );
                return;
              }

              final success = await context.read<SaleProvider>().cancelSale(saleId, reason);
              if (mounted) {
                Navigator.pop(context);
                if (success) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Venda cancelada com sucesso')),
                  );
                }
              }
            },
            child: const Text('Confirmar Cancelamento'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final saleProvider = context.watch<SaleProvider>();
    final sales = saleProvider.sales;

    if (saleProvider.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Text(
            'Histórico de Vendas',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        Expanded(
          child: sales.isEmpty
              ? const Center(child: Text('Nenhuma venda registrada'))
              : ListView.builder(
                  itemCount: sales.length,
                  itemBuilder: (context, index) {
                    final sale = sales[index];
                    return Card(
                      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      child: ExpansionTile(
                        title: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text('#${sale.id.substring(0, 8)}'),
                            Text('R\$ ${sale.finalAmount.toStringAsFixed(2)}'),
                          ],
                        ),
                        subtitle: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(sale.createdAt.toString()),
                            Chip(
                              label: Text(sale.status),
                              backgroundColor: sale.status == 'completed' ? const Color(0xFF10B981) : const Color(0xFFEF4444),
                              labelStyle: const TextStyle(color: Colors.white),
                            ),
                          ],
                        ),
                        children: [
                          Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('Itens: ${sale.itemCount}'),
                                const SizedBox(height: 8),
                                ...sale.items.map((item) => Text(
                                  '${item.productName} x${item.quantity} - R\$ ${item.totalPrice.toStringAsFixed(2)}',
                                )),
                                const SizedBox(height: 16),
                                Text('Método: ${sale.paymentMethod}'),
                                Text('Subtotal: R\$ ${sale.totalAmount.toStringAsFixed(2)}'),
                                Text('Desconto: R\$ ${sale.discountAmount.toStringAsFixed(2)}'),
                                Text(
                                  'Total: R\$ ${sale.finalAmount.toStringAsFixed(2)}',
                                  style: const TextStyle(fontWeight: FontWeight.bold),
                                ),
                                if (sale.status == 'completed')
                                  ...[
                                    const SizedBox(height: 16),
                                    SizedBox(
                                      width: double.infinity,
                                      child: ElevatedButton.icon(
                                        onPressed: () => _showCancelDialog(context, sale.id),
                                        icon: const Icon(Icons.clear),
                                        label: const Text('Cancelar Venda'),
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: const Color(0xFFEF4444),
                                          foregroundColor: Colors.white,
                                        ),
                                      ),
                                    ),
                                  ] else if (sale.cancelledAt != null)
                                    ...[
                                      const SizedBox(height: 16),
                                      Text(
                                        'Motivo: ${sale.cancellationReason}',
                                        style: const TextStyle(fontStyle: FontStyle.italic),
                                      ),
                                    ],
                              ],
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
        ),
      ],
    );
  }
}
