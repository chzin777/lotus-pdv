import 'package:csv/csv.dart';
import 'storage_service.dart';
import '../models/account.dart';

class AccountService {
  static const String _fileName = 'accounts.csv';
  static const String _entriesFileName = 'account_entries.csv';

  static Future<String> get _dataPath async {
    final basePath = await StorageService.appDataPath;
    final path = '$basePath/data/accounts';
    await StorageService.ensureDirectory(path);
    return path;
  }

  static Future<bool> saveAll(List<Account> accounts) async {
    try {
      final dir = await _dataPath;

      // Save accounts
      final rows = <List<dynamic>>[
        ['id', 'customerName', 'phone', 'status', 'createdAt', 'settledAt'],
      ];
      for (final a in accounts) {
        rows.add([
          a.id,
          a.customerName,
          a.phone,
          a.status,
          a.createdAt.toIso8601String(),
          a.settledAt?.toIso8601String() ?? '',
        ]);
      }
      await StorageService.writeFile(_fileName, const ListToCsvConverter().convert(rows), directory: dir);

      // Save entries
      final eRows = <List<dynamic>>[
        ['accountId', 'id', 'type', 'amount', 'description', 'saleId', 'createdAt'],
      ];
      for (final a in accounts) {
        for (final e in a.entries) {
          eRows.add([
            a.id,
            e.id,
            e.type,
            e.amount,
            e.description,
            e.saleId ?? '',
            e.createdAt.toIso8601String(),
          ]);
        }
      }
      await StorageService.writeFile(_entriesFileName, const ListToCsvConverter().convert(eRows), directory: dir);

      return true;
    } catch (e) {
      print('Error saving accounts: $e');
      return false;
    }
  }

  static Future<List<Account>> getAll() async {
    try {
      final dir = await _dataPath;
      final content = await StorageService.readFile('$dir/$_fileName');
      if (content.isEmpty) return [];

      final rows = const CsvToListConverter().convert(content);
      if (rows.length <= 1) return [];

      // Load entries
      final entriesContent = await StorageService.readFile('$dir/$_entriesFileName');
      final entriesMap = <String, List<AccountEntry>>{};

      if (entriesContent.isNotEmpty) {
        final eRows = const CsvToListConverter().convert(entriesContent);
        for (int i = 1; i < eRows.length; i++) {
          if (eRows[i].isEmpty) continue;
          final accountId = eRows[i][0].toString();
          entriesMap.putIfAbsent(accountId, () => []);
          entriesMap[accountId]!.add(AccountEntry(
            id: eRows[i][1].toString(),
            type: eRows[i][2].toString(),
            amount: double.tryParse(eRows[i][3].toString()) ?? 0,
            description: eRows[i][4].toString(),
            saleId: eRows[i][5].toString().isEmpty ? null : eRows[i][5].toString(),
            createdAt: DateTime.tryParse(eRows[i][6].toString()) ?? DateTime.now(),
          ));
        }
      }

      final accounts = <Account>[];
      for (int i = 1; i < rows.length; i++) {
        if (rows[i].isEmpty) continue;
        final id = rows[i][0].toString();
        accounts.add(Account(
          id: id,
          customerName: rows[i][1].toString(),
          phone: rows[i][2].toString(),
          status: rows[i][3].toString(),
          createdAt: DateTime.tryParse(rows[i][4].toString()) ?? DateTime.now(),
          settledAt: rows[i][5].toString().isEmpty ? null : DateTime.tryParse(rows[i][5].toString()),
          entries: entriesMap[id] ?? [],
        ));
      }

      return accounts;
    } catch (e) {
      print('Error loading accounts: $e');
      return [];
    }
  }
}
