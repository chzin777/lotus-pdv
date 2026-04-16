import 'package:csv/csv.dart';
import 'storage_service.dart';
import '../models/sale.dart';
import 'product_service.dart';

class SaleService {
  static const String _fileName = 'sales.csv';
  static const String _itemsFileName = 'sales_items.csv';

  static Map<String, int> _headerIndex(List<dynamic> headerRow) {
    final map = <String, int>{};
    for (int i = 0; i < headerRow.length; i++) {
      map[headerRow[i].toString()] = i;
    }
    return map;
  }

  static String _cell(List<dynamic> row, int index, {String fallback = ''}) {
    if (index < 0 || index >= row.length) return fallback;
    return row[index].toString();
  }

  static Future<bool> saveSales(List<Sale> sales) async {
    try {
      final salesPath = await StorageService.salesDataPath;
      
      List<List<dynamic>> rows = [
        ['id', 'label', 'totalAmount', 'discountAmount', 'finalAmount', 'paymentMethod', 'status', 'userId', 'createdAt', 'cancelledAt', 'cancellationReason', 'itemCount'],
      ];

      for (var sale in sales) {
        rows.add([
          sale.id,
          sale.label ?? '',
          sale.totalAmount,
          sale.discountAmount,
          sale.finalAmount,
          sale.paymentMethod,
          sale.status,
          sale.userId,
          sale.createdAt.toIso8601String(),
          sale.cancelledAt?.toIso8601String() ?? '',
          sale.cancellationReason ?? '',
          sale.items.length,
        ]);
      }

      String csv = const ListToCsvConverter().convert(rows);
      await StorageService.writeFile(_fileName, csv, directory: salesPath);
      
      // Save items
      return await _saveSaleItems(sales, salesPath);
    } catch (e) {
      print('Error saving sales: $e');
      return false;
    }
  }

  static Future<bool> _saveSaleItems(List<Sale> sales, String salesPath) async {
    try {
      List<List<dynamic>> rows = [
        ['saleId', 'productId', 'productName', 'quantity', 'unitPrice', 'totalPrice'],
      ];

      for (var sale in sales) {
        for (var item in sale.items) {
          rows.add([
            sale.id,
            item.productId,
            item.productName,
            item.quantity,
            item.unitPrice,
            item.totalPrice,
          ]);
        }
      }

      String csv = const ListToCsvConverter().convert(rows);
      await StorageService.writeFile(_itemsFileName, csv, directory: salesPath);
      return true;
    } catch (e) {
      print('Error saving sale items: $e');
      return false;
    }
  }

  static Future<List<Sale>> getSales() async {
    try {
      final salesPath = await StorageService.salesDataPath;
      final filePath = '$salesPath/$_fileName';
      final itemsFilePath = '$salesPath/$_itemsFileName';
      
      final content = await StorageService.readFile(filePath);
      if (content.isEmpty) {
        return [];
      }

      final itemsContent = await StorageService.readFile(itemsFilePath);
      Map<String, List<SaleItem>> itemsMap = {};

      if (itemsContent.isNotEmpty) {
        List<List<dynamic>> itemRows = const CsvToListConverter().convert(itemsContent);
        for (int i = 1; i < itemRows.length; i++) {
          if (itemRows[i].isEmpty) continue;
          
          final saleId = itemRows[i][0].toString();
          if (!itemsMap.containsKey(saleId)) {
            itemsMap[saleId] = [];
          }

          itemsMap[saleId]!.add(SaleItem(
            productId: itemRows[i][1].toString(),
            productName: itemRows[i][2].toString(),
            quantity: int.tryParse(itemRows[i][3].toString()) ?? 0,
            unitPrice: double.tryParse(itemRows[i][4].toString()) ?? 0.0,
            totalPrice: double.tryParse(itemRows[i][5].toString()) ?? 0.0,
          ));
        }
      }

      List<List<dynamic>> rows = const CsvToListConverter().convert(content);
      List<Sale> sales = [];

      if (rows.isEmpty) return [];
      final header = _headerIndex(rows.first);
      final idxId = header['id'] ?? 0;
      final idxLabel = header['label'] ?? -1;
      final idxTotalAmount = header['totalAmount'] ?? 1;
      final idxDiscountAmount = header['discountAmount'] ?? 2;
      final idxFinalAmount = header['finalAmount'] ?? 3;
      final idxPaymentMethod = header['paymentMethod'] ?? 4;
      final idxStatus = header['status'] ?? 5;
      final idxUserId = header['userId'] ?? 6;
      final idxCreatedAt = header['createdAt'] ?? 7;
      final idxCancelledAt = header['cancelledAt'] ?? 8;
      final idxCancellationReason = header['cancellationReason'] ?? 9;

      for (int i = 1; i < rows.length; i++) {
        if (rows[i].isEmpty) continue;
        
        try {
          final saleId = _cell(rows[i], idxId);
          final items = itemsMap[saleId] ?? [];

          sales.add(Sale(
            id: saleId,
            label: idxLabel >= 0 ? _cell(rows[i], idxLabel) : null,
            items: items,
            totalAmount: double.tryParse(_cell(rows[i], idxTotalAmount)) ?? 0.0,
            discountAmount: double.tryParse(_cell(rows[i], idxDiscountAmount)) ?? 0.0,
            finalAmount: double.tryParse(_cell(rows[i], idxFinalAmount)) ?? 0.0,
            paymentMethod: _cell(rows[i], idxPaymentMethod),
            status: _cell(rows[i], idxStatus),
            userId: _cell(rows[i], idxUserId),
            createdAt: DateTime.parse(_cell(rows[i], idxCreatedAt)),
            cancelledAt: _cell(rows[i], idxCancelledAt).isEmpty
                ? null
                : DateTime.parse(_cell(rows[i], idxCancelledAt)),
            cancellationReason: _cell(rows[i], idxCancellationReason).isEmpty
                ? null
                : _cell(rows[i], idxCancellationReason),
          ));
        } catch (e) {
          print('Error parsing sale row: $e');
        }
      }

      return sales;
    } catch (e) {
      print('Error reading sales: $e');
      return [];
    }
  }

  static Future<Sale?> getSaleById(String id) async {
    final sales = await getSales();
    try {
      return sales.firstWhere((sale) => sale.id == id);
    } catch (e) {
      return null;
    }
  }

  static Future<bool> addSale(Sale sale) async {
    final sales = await getSales();
    sales.add(sale);
    return await saveSales(sales);
  }

  static Future<bool> updateSale(Sale sale) async {
    final sales = await getSales();
    final index = sales.indexWhere((s) => s.id == sale.id);
    if (index != -1) {
      sales[index] = sale;
      return await saveSales(sales);
    }
    return false;
  }

  static Future<bool> cancelSale(String saleId, String reason) async {
    final sale = await getSaleById(saleId);
    if (sale != null && sale.status != 'cancelled') {
      final cancelledSale = sale.copyWith(
        status: 'cancelled',
        cancelledAt: DateTime.now(),
        cancellationReason: reason,
      );
      return await updateSale(cancelledSale);
    }
    return false;
  }

  static Future<List<Sale>> getSalesByDateRange(DateTime startDate, DateTime endDate) async {
    final sales = await getSales();
    return sales
        .where((sale) => sale.createdAt.isAfter(startDate) && sale.createdAt.isBefore(endDate))
        .toList();
  }

  static Future<double> getDailySalesAmount(DateTime date) async {
    final startOfDay = DateTime(date.year, date.month, date.day);
    final endOfDay = startOfDay.add(const Duration(days: 1));
    
    final sales = await getSalesByDateRange(startOfDay, endOfDay);
    double total = 0;
    for (var sale in sales) {
      if (sale.status == 'completed') {
        total += sale.finalAmount;
      }
    }
    return total;
  }

  static Future<Map<String, dynamic>> getSalesReport(DateTime startDate, DateTime endDate) async {
    final sales = await getSalesByDateRange(startDate, endDate);
    final products = await ProductService.getProducts();
    final costMap = <String, double>{};
    for (var p in products) {
      costMap[p.id] = p.costPrice;
    }

    double grossRevenue = 0;
    double netRevenue = 0;
    double totalDiscount = 0;
    double productCost = 0;
    int totalItems = 0;
    int completedSales = 0;
    int cancelledSales = 0;

    for (var sale in sales) {
      if (sale.status == 'completed') {
        grossRevenue += sale.totalAmount;
        netRevenue += sale.finalAmount;
        completedSales++;
        for (var item in sale.items) {
          final cost = costMap[item.productId] ?? 0.0;
          productCost += cost * item.quantity;
        }
      } else if (sale.status == 'cancelled') {
        cancelledSales++;
      }
      totalDiscount += sale.discountAmount;
      totalItems += sale.items.fold(0, (sum, item) => sum + item.quantity);
    }

    return {
      'grossRevenue': grossRevenue,
      'netRevenue': netRevenue,
      'totalRevenue': netRevenue,
      'totalDiscount': totalDiscount,
      'productCost': productCost,
      'totalItems': totalItems,
      'completedSales': completedSales,
      'cancelledSales': cancelledSales,
      'averageTicket': completedSales > 0 ? netRevenue / completedSales : 0,
    };
  }
}
