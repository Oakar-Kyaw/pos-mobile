// import 'package:flutter_thermal_printer/utils/printer.dart';
// import 'package:pos/features/printer/data/datasource/bluetooth-data-source.dart';
// import 'package:pos/features/printer/domain/entites/printer-device.dart';
// import 'package:pos/features/printer/domain/repository/printer-repository.dart';

// class PrinterRepositoryImpl implements PrinterRepository {
//   final BluetoothDataSource bluetooth;

//   PrinterRepositoryImpl({required this.bluetooth});

//   @override
//   Future<List<PrinterDevice>> checkAndScanBluetooth() =>
//       bluetooth.checkAndScanBluetooth();

//   @override
//   Future<bool> connectBluetoothPrinter(String deviceAddress) =>
//       bluetooth.connectBluetoothPrinter(deviceAddress);

//   @override
//   Future<List<PrinterDevice>> searchUsbPrinter() async => [];

//   @override
//   Future<bool> connectUsbPrinter(String deviceAddress) =>
//       bluetooth.connectBluetoothPrinter(deviceAddress);

//   @override
//   Future<bool> testPrintByBluetoothPrinter(
//     Printer printerDevice,
//     List<int> bytes,
//   ) => bluetooth.printData(printerDevice, bytes);

//   @override
//   Future<bool> testPrintByUsbPrinter(Printer printerDevice, List<int> bytes) =>
//       bluetooth.printData(printerDevice, bytes);
// }

import 'package:flutter_thermal_printer/utils/printer.dart';
import 'package:pos/features/printer/data/datasource/bluetooth-data-source.dart';
import 'package:pos/features/printer/domain/entites/printer-device.dart';
import 'package:pos/features/printer/domain/repository/printer-repository.dart';

class PrinterRepositoryImpl implements PrinterRepository {
  final BluetoothDataSource bluetooth;

  PrinterRepositoryImpl({required this.bluetooth});

  @override
  Future<List<PrinterDevice>> checkAndScanBluetooth() =>
      bluetooth.scanPrinters();

  @override
  Future<bool> connectBluetoothPrinter(String printerAddress) =>
      bluetooth.connectBluetoothPrinter(printerAddress);

  @override
  Future<bool> checkBluetoothConnection(String printerAddress) =>
      bluetooth.isConnectedToPrinter(printerAddress);

  @override
  Future<bool> disconnectBluetoothConnection() =>
      bluetooth.disconnectBluetoothPrinter();

  @override
  Future<List<PrinterDevice>> searchUsbPrinter() async => [];

  @override
  Future<bool> connectUsbPrinter(String deviceAddress) =>
      bluetooth.connectBluetoothPrinter(deviceAddress);

  @override
  Future<bool> testPrintByBluetoothPrinter(
    Printer printerDevice,
    List<int> bytes,
  ) => bluetooth.printData(bytes);

  @override
  Future<bool> testPrintByUsbPrinter(Printer printerDevice, List<int> bytes) =>
      bluetooth.printData(bytes);
}
