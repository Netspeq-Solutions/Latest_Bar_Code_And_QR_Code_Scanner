import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

import 'LocalStorageScanned_Data.dart';

// Database helper class
class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();

  factory DatabaseHelper() => _instance;

  DatabaseHelper._internal();

  Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    String path = join(await getDatabasesPath(), 'InventoryManagement_DB.db');
    return await openDatabase(
      path,
      version: 1,
      onCreate: LocalStorageScannedData.onCreate,
    );
  }

  Future<String> insertDataList(String tableName, List<Map<String, dynamic>> dataList,) async
  {
    try {
      if (dataList.isEmpty) {
        return "Error: Failed to insert due to empty list";
      }

      final db = await database; // your instance getter

      // Using a batch for efficiency
      final batch = db.batch();

      for (final data in dataList) {
        if (data.isNotEmpty) {
          batch.insert(tableName, data);
        }
      }

      await batch.commit(noResult: true); // executes all inserts
      return "Success: ${dataList.length} records inserted in SQLite DB";
    } catch (e) {
      return "Error: Failed to insert -> $e";
    }
  }


  Future<String> updateData(
      String tableName, Map<String, dynamic> updateData, int updateID) async {
    try {
      if (updateData.isEmpty) {
        return "Error: New Update Data is Empty";
      }
      final db = await database;
      await db.update(tableName, updateData,
          where: "id = ?", whereArgs: [updateID]);
      return "Success: Update Successfully with the ID $updateID";
    } catch (e) {
      return "Error: Failed to update $e";
    }
  }

  Future<List<Map<String, dynamic>>> readData(
    String tableName, {
    String? where,
    List<Object?>? whereArgs,
    String? orderBy,
  }) async {
    try {
      final db = await database;

      final result = await db.query(
        tableName,
        where: where,
        whereArgs: whereArgs,
        orderBy: orderBy,
      );
      return result;
    } catch (e) {
      throw Exception("Error: Failed to read data $e");
    }
  }

  Future<String> deleteData(String tableName, String serialNumber) async {
    try {
      final db = await database;

      final rows = await db.delete(
        tableName,
        where: "serialNumber = ?",
        whereArgs: [serialNumber],
      );

      if (rows > 0) {
        return "Success: Deleted $rows row(s) with ID $serialNumber";
      } else {
        return "Error: No record found with ID $serialNumber";
      }
    } catch (e) {
      return "Error: Delete failed due to $e";
    }
  }

  Future<String> clearTable(String tableName) async {
    try {
      final db = await database;
      final rows = await db.delete(tableName);
      return "Success: Cleared $rows row(s) from $tableName";
    } catch (e) {
      return "Error: Failed to clear table $e";
    }
  }
}
