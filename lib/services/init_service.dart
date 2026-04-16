import 'dart:io';
import 'package:flutter/services.dart' show rootBundle;
import 'storage_service.dart';

class InitService {
  static Future<void> initializeAppData() async {
    try {
      await _copyAssetIfNotExists('users.csv', 'data');
      await _copyAssetIfNotExists('products.csv', 'data');
    } catch (e) {
      print('Error initializing app data: $e');
    }
  }

  static Future<void> _copyAssetIfNotExists(String fileName, String subdirectory) async {
    try {
      String directory;
      if (fileName.contains('users')) {
        directory = await StorageService.usersDataPath;
      } else if (fileName.contains('products')) {
        directory = await StorageService.productsDataPath;
      } else {
        return;
      }

      final file = File('$directory/$fileName');
      
      // Only copy if file doesn't exist
      if (!await file.exists()) {
        final data = await rootBundle.loadString('assets/$subdirectory/$fileName');
        await file.writeAsString(data);
        print('Initialized $fileName in $directory');
      }
    } catch (e) {
      print('Error copying $fileName: $e');
    }
  }
}
