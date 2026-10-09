import 'package:pos/features/printer/domain/enums/printer-brand-type.dart';
import 'package:pos/features/printer/domain/enums/printer-type.dart';

enum PrinterTypeByTable {
  bluetooth,
  usb,
  ethernet;

  // to save string in db
  String toValue() => name; // "bluetooth" or "usb"

  // create enum from db value
  static PrinterTypeByTable fromValue(String value) {
    return PrinterTypeByTable.values.firstWhere(
      (e) => e.name == value,
      orElse: () => throw ArgumentError('Unknown printer type: $value'),
    );
  }
}

enum PrinterBrandTypeByTable {
  labelPinter,
  ecs;

  // to save string in db
  String toValue() => name;

  // create enum from db value
  static PrinterBrandTypeByTable fromValue(String value) {
    return PrinterBrandTypeByTable.values.firstWhere(
      (e) => e.name == value,
      orElse: () => throw ArgumentError('Unknown printer type: $value'),
    );
  }
}

extension PrinterTypeMapper on PrinterTypeByTable {
  PrinterType toDomain() {
    switch (this) {
      case PrinterTypeByTable.bluetooth:
        return PrinterType.bluetooth;
      case PrinterTypeByTable.usb:
        return PrinterType.usb;
      case PrinterTypeByTable.ethernet:
        return PrinterType.ethernet;
    }
  }
}

extension PrinterBrandTypeMapper on PrinterBrandTypeByTable {
  PrinterBrandType toDomain() {
    switch (this) {
      case PrinterBrandTypeByTable.ecs:
        return PrinterBrandType.ecs;
      case PrinterBrandTypeByTable.labelPinter:
        return PrinterBrandType.labelPrinter;
    }
  }
}

class PrinterTableItem {
  final int id;
  final String name;
  final String? address;
  final bool isConnected;
  final PrinterTypeByTable type;
  final String? vendorId;
  final String? productId;
  final PrinterBrandTypeByTable? brandType;
  final String paperSize;
  final String deviceName;
  final bool setDefault;

  const PrinterTableItem({
    required this.id,
    required this.name,
    required this.isConnected,
    required this.deviceName,
    required this.paperSize,
    required this.type,
    required this.setDefault,
    this.brandType,
    this.productId,
    this.vendorId,
    this.address,
  });

  factory PrinterTableItem.fromJson(Map<String, dynamic> json) {
    final brand = json[PrinterTableSchema.brandType] as String?;
    return PrinterTableItem(
      id: json[PrinterTableSchema.id] as int,
      name: json[PrinterTableSchema.name] as String,
      address: json[PrinterTableSchema.address] as String?,
      isConnected: (json[PrinterTableSchema.isConnected] as int) == 1,
      deviceName: (json[PrinterTableSchema.deviceName] as String?) ?? '',
      paperSize: json[PrinterTableSchema.paperSize] as String,
      setDefault: (json[PrinterTableSchema.setDefault] as int) == 1,
      type: PrinterTypeByTable.fromValue(
        json[PrinterTableSchema.type] as String,
      ),
      brandType: brand == null
          ? null
          : PrinterBrandTypeByTable.fromValue(brand),
      vendorId: json[PrinterTableSchema.vendorId] as String?,
      productId: json[PrinterTableSchema.productId] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      PrinterTableSchema.id: id,
      PrinterTableSchema.name: name,
      PrinterTableSchema.deviceName: deviceName,
      PrinterTableSchema.address: address,
      PrinterTableSchema.isConnected: isConnected ? 1 : 0,
      PrinterTableSchema.type: type.toValue(),
      PrinterTableSchema.brandType: brandType?.toValue(),
      PrinterTableSchema.vendorId: vendorId,
      PrinterTableSchema.productId: productId,
      PrinterTableSchema.paperSize: paperSize,
      PrinterTableSchema.setDefault: setDefault ? 1 : 0,
    };
  }

  PrinterTableItem copyWith({
    int? id,
    String? name,
    String? address,
    bool? isConnected,
    PrinterTypeByTable? type,
    PrinterBrandTypeByTable? brandType,
    String? vendorId,
    String? productId,
    String? paperSize,
    String? deviceName,
    bool? setDefault,
  }) {
    return PrinterTableItem(
      id: id ?? this.id,
      name: name ?? this.name,
      address: address ?? this.address,
      isConnected: isConnected ?? this.isConnected,
      type: type ?? this.type,
      brandType: brandType ?? this.brandType,
      vendorId: vendorId ?? this.vendorId,
      productId: productId ?? this.productId,
      paperSize: paperSize ?? this.paperSize,
      deviceName: deviceName ?? this.deviceName,
      setDefault: setDefault ?? this.setDefault,
    );
  }
}

class PrinterTableSchema {
  static const String printerTableName = 'printer';

  static const String id = "_id";
  static const String name = "printerName";
  static const String address = "printerAddress";
  static const String isConnected = "printerIsConnected";
  static const String type = "printerType";
  static const String deviceName = "printerDeviceName";
  static const String setDefault = "printerSetDefault";
  static const String paperSize = "printerPaperSize";
  static const String brandType = "printerBrandType";
  static const String vendorId = "printerVendorId";
  static const String productId = "printerProductId";

  static const String printerTable =
      '''
    CREATE TABLE $printerTableName (
      $id INTEGER PRIMARY KEY AUTOINCREMENT,
      $name TEXT NOT NULL,
      $address TEXT,
      $isConnected INTEGER NOT NULL DEFAULT 1,
      $type TEXT NOT NULL,
      $deviceName TEXT,
      $setDefault INTEGER NOT NULL DEFAULT 0,
      $paperSize TEXT NOT NULL DEFAULT '58mm',
      $brandType TEXT,
      $vendorId TEXT,
      $productId TEXT
    )
  ''';
}
