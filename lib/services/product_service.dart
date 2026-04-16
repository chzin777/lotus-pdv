import 'package:csv/csv.dart';
import 'storage_service.dart';
import '../models/product.dart';

class ProductService {
  static const String _fileName = 'products.csv';

  static Future<bool> saveProducts(List<Product> products) async {
    try {
      final productsPath = await StorageService.productsDataPath;
      
      List<List<dynamic>> rows = [
        ['id', 'name', 'description', 'costPrice', 'sellingPrice', 'quantity', 'category', 'imagePath', 'sku', 'isActive', 'createdAt', 'updatedAt'],
      ];

      for (var product in products) {
        rows.add([
          product.id,
          product.name,
          product.description,
          product.costPrice,
          product.sellingPrice,
          product.quantity,
          product.category,
          product.imagePath ?? '',
          product.sku,
          product.isActive,
          product.createdAt.toIso8601String(),
          product.updatedAt?.toIso8601String() ?? '',
        ]);
      }

      String csv = const ListToCsvConverter().convert(rows);
      await StorageService.writeFile(_fileName, csv, directory: productsPath);
      return true;
    } catch (e) {
      print('Error saving products: $e');
      return false;
    }
  }

  static Future<List<Product>> getProducts() async {
    try {
      final productsPath = await StorageService.productsDataPath;
      final filePath = '$productsPath/$_fileName';
      
      final content = await StorageService.readFile(filePath);
      if (content.isEmpty) {
        return [];
      }

      List<List<dynamic>> rows = const CsvToListConverter().convert(content);
      List<Product> products = [];

      for (int i = 1; i < rows.length; i++) {
        if (rows[i].isEmpty) continue;
        
        try {
          products.add(Product(
            id: rows[i][0].toString(),
            name: rows[i][1].toString(),
            description: rows[i][2].toString(),
            costPrice: double.tryParse(rows[i][3].toString()) ?? 0.0,
            sellingPrice: double.tryParse(rows[i][4].toString()) ?? 0.0,
            quantity: int.tryParse(rows[i][5].toString()) ?? 0,
            category: rows[i][6].toString(),
            imagePath: rows[i][7].toString().isEmpty ? null : rows[i][7].toString(),
            sku: rows[i][8].toString(),
            isActive: rows[i][9].toString().toLowerCase() == 'true',
            createdAt: DateTime.parse(rows[i][10].toString()),
            updatedAt: rows[i][11].toString().isEmpty ? null : DateTime.parse(rows[i][11].toString()),
          ));
        } catch (e) {
          print('Error parsing product row: $e');
        }
      }

      return products;
    } catch (e) {
      print('Error reading products: $e');
      return [];
    }
  }

  static Future<Product?> getProductById(String id) async {
    final products = await getProducts();
    try {
      return products.firstWhere((product) => product.id == id);
    } catch (e) {
      return null;
    }
  }

  static Future<List<Product>> getProductsByCategory(String category) async {
    final products = await getProducts();
    return products.where((p) => p.category == category).toList();
  }

  static Future<bool> addProduct(Product product) async {
    final products = await getProducts();
    products.add(product);
    return await saveProducts(products);
  }

  static Future<bool> updateProduct(Product product) async {
    final products = await getProducts();
    final index = products.indexWhere((p) => p.id == product.id);
    if (index != -1) {
      products[index] = product;
      return await saveProducts(products);
    }
    return false;
  }

  static Future<bool> deleteProduct(String productId) async {
    final products = await getProducts();
    products.removeWhere((p) => p.id == productId);
    return await saveProducts(products);
  }

  static Future<bool> updateProductQuantity(String productId, int newQuantity) async {
    final product = await getProductById(productId);
    if (product != null) {
      return await updateProduct(product.copyWith(quantity: newQuantity));
    }
    return false;
  }

  static Future<List<String>> getCategories() async {
    final products = await getProducts();
    final categories = <String>{};
    for (var product in products) {
      categories.add(product.category);
    }
    return categories.toList();
  }
}
