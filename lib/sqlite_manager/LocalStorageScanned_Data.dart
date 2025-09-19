import 'package:sqflite/sqflite.dart';

mixin LocalStorageScannedData {
  static Future<void> onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE SerialNumberStoreTable (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        serialNumber TEXT NOT NULL,
        scanned_type TEXT NOT NULL,
        scannedAt TEXT NOT NULL
      )
    ''');
  }
}


