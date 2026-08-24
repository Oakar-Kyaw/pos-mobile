import 'package:pos/core/database/app-database.dart';
import 'package:pos/core/database/printer-table-schema.dart';

class PrinterLocalDatabaseSource {
  Future<int> insert(PrinterTableItem item) async {
    final db = await AppDatabase.instance.database;
    return db.insert(PrinterTableSchema.printerTableName, item.toJson());
  }

  Future<List<PrinterTableItem>> getAll() async {
    final db = await AppDatabase.instance.database;
    final rows = await db.query(PrinterTableSchema.printerTableName);
    return rows.map((row) => PrinterTableItem.fromJson(row)).toList();
  }

  Future<int> delete(int id) async {
    final db = await AppDatabase.instance.database;
    return db.delete(
      PrinterTableSchema.printerTableName,
      where: '${PrinterTableSchema.id} = ?',
      whereArgs: [id],
    );
  }
}
