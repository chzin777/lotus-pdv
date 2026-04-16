import 'package:csv/csv.dart';
import 'storage_service.dart';
import '../models/user.dart';

class UserService {
  static const String _fileName = 'users.csv';

  static Future<bool> saveUsers(List<User> users) async {
    try {
      final usersPath = await StorageService.usersDataPath;
      
      List<List<dynamic>> rows = [
        ['id', 'username', 'password', 'fullName', 'role', 'isActive', 'createdAt', 'profileImage'],
      ];

      for (var user in users) {
        rows.add([
          user.id,
          user.username,
          user.password,
          user.fullName,
          user.role.toString().split('.').last,
          user.isActive,
          user.createdAt.toIso8601String(),
          user.profileImage ?? '',
        ]);
      }

      String csv = const ListToCsvConverter().convert(rows);
      await StorageService.writeFile(_fileName, csv, directory: usersPath);
      return true;
    } catch (e) {
      print('Error saving users: $e');
      return false;
    }
  }

  static Future<List<User>> getUsers() async {
    try {
      final usersPath = await StorageService.usersDataPath;
      final filePath = '$usersPath/$_fileName';
      
      final content = await StorageService.readFile(filePath);
      if (content.isEmpty) {
        return [];
      }

      List<List<dynamic>> rows = const CsvToListConverter().convert(content);
      List<User> users = [];

      for (int i = 1; i < rows.length; i++) {
        if (rows[i].isEmpty) continue;
        
        try {
          users.add(User(
            id: rows[i][0].toString(),
            username: rows[i][1].toString(),
            password: rows[i][2].toString(),
            fullName: rows[i][3].toString(),
            role: UserRole.values.firstWhere(
              (e) => e.toString().split('.').last == rows[i][4].toString(),
              orElse: () => UserRole.seller,
            ),
            isActive: rows[i][5].toString().toLowerCase() == 'true',
            createdAt: DateTime.parse(rows[i][6].toString()),
            profileImage: rows[i][7].toString().isEmpty ? null : rows[i][7].toString(),
          ));
        } catch (e) {
          print('Error parsing user row: $e');
        }
      }

      return users;
    } catch (e) {
      print('Error reading users: $e');
      return [];
    }
  }

  static Future<User?> getUserByUsername(String username) async {
    final users = await getUsers();
    try {
      return users.firstWhere((user) => user.username == username);
    } catch (e) {
      return null;
    }
  }

  static Future<bool> addUser(User user) async {
    final users = await getUsers();
    users.add(user);
    return await saveUsers(users);
  }

  static Future<bool> updateUser(User user) async {
    final users = await getUsers();
    final index = users.indexWhere((u) => u.id == user.id);
    if (index != -1) {
      users[index] = user;
      return await saveUsers(users);
    }
    return false;
  }

  static Future<bool> deleteUser(String userId) async {
    final users = await getUsers();
    users.removeWhere((u) => u.id == userId);
    return await saveUsers(users);
  }
}
