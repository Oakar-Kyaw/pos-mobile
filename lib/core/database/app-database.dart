import 'package:path/path.dart';
import 'package:pos/core/database/database-constant.dart';
import 'package:pos/core/database/printer-table-schema.dart';
import 'package:sqflite/sqflite.dart';

class AppDatabase {
  AppDatabase._instance();

  static final AppDatabase instance = AppDatabase._instance();

  Database? _database;

  Future<Database> get database async {
    _database ??= await _init();
    return _database!;
  }

  Future<Database> _init() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, DatabaseConstant.dbName);

    return openDatabase(
      path,
      version: DatabaseConstant.dbVersion,
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    // Create all tables here
    await db.execute(PrinterTableSchema.printerTable);

    // Example:
    // await db.execute(ProductTableSchema.productTable);
    // await db.execute(CustomerTableSchema.customerTable);
    // await db.execute(OrderTableSchema.orderTable);
  }

  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    // ===========================
    // Version 2
    // ===========================
    if (oldVersion < 2) {
      await db.execute(
        'ALTER TABLE ${PrinterTableSchema.printerTableName} '
        'ADD COLUMN ${PrinterTableSchema.deviceName} TEXT',
      );

      await db.execute(
        "ALTER TABLE ${PrinterTableSchema.printerTableName} "
        "ADD COLUMN ${PrinterTableSchema.paperSize} TEXT NOT NULL DEFAULT '58mm'",
      );

      await db.execute(
        'ALTER TABLE ${PrinterTableSchema.printerTableName} '
        'ADD COLUMN ${PrinterTableSchema.setDefault} INTEGER NOT NULL DEFAULT 0',
      );
    }

    // ===========================
    // Version 3
    // ===========================
    if (oldVersion < 3) {
      // Future migrations
    }

    // ===========================
    // Version 4
    // ===========================
    if (oldVersion < 4) {
      // Future migrations
    }
  }
}
