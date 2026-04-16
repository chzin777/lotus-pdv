import 'dart:io';
import 'package:path_provider/path_provider.dart';

class StorageService {
  static Future<String> get appDataPath async {
    final directory = await getApplicationDocumentsDirectory();
    final pdvPath = Directory('${directory.path}/PDV_System');
    
    if (!await pdvPath.exists()) {
      await pdvPath.create(recursive: true);
    }
    
    return pdvPath.path;
  }

  static Future<String> get productsDataPath async {
    final basePath = await appDataPath;
    final path = Directory('$basePath/data/products');
    
    if (!await path.exists()) {
      await path.create(recursive: true);
    }
    
    return path.path;
  }

  static Future<String> get usersDataPath async {
    final basePath = await appDataPath;
    final path = Directory('$basePath/data/users');
    
    if (!await path.exists()) {
      await path.create(recursive: true);
    }
    
    return path.path;
  }

  static Future<String> get salesDataPath async {
    final basePath = await appDataPath;
    final path = Directory('$basePath/data/sales');
    
    if (!await path.exists()) {
      await path.create(recursive: true);
    }
    
    return path.path;
  }

  static Future<String> get imagesPath async {
    final basePath = await appDataPath;
    final path = Directory('$basePath/images/products');
    
    if (!await path.exists()) {
      await path.create(recursive: true);
    }
    
    return path.path;
  }

  static Future<void> writeFile(String fileName, String content, {required String directory}) async {
    final path = '$directory/$fileName';
    final file = File(path);
    await file.writeAsString(content);
  }

  static Future<String> readFile(String filePath) async {
    final file = File(filePath);
    if (await file.exists()) {
      return await file.readAsString();
    }
    return '';
  }

  static Future<List<FileSystemEntity>> listFiles(String directory) async {
    final dir = Directory(directory);
    if (await dir.exists()) {
      return await dir.list().toList();
    }
    return [];
  }

  static Future<File> saveImage(File imageFile, String fileName) async {
    final imagesDir = await imagesPath;
    final newPath = '$imagesDir/$fileName';
    return await imageFile.copy(newPath);
  }

  static Future<bool> deleteFile(String filePath) async {
    final file = File(filePath);
    if (await file.exists()) {
      await file.delete();
      return true;
    }
    return false;
  }

  static Future<bool> fileExists(String filePath) async {
    final file = File(filePath);
    return await file.exists();
  }

  static String getImagePath(String fileName) {
    return fileName; // Will be constructed with full path when needed
  }
}
