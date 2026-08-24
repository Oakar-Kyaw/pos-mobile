// // domain/repository/printer-repository.dart
// import 'package:flutter_thermal_printer/utils/printer.dart';
// import 'package:pos/features/printer/domain/entites/printer-device.dart';

// abstract class PrinterRepository {
//   Future<List<PrinterDevice>> checkAndScanBluetooth();
//   Future<bool> connectBluetoothPrinter(String deviceAddress);
//   Future<List<PrinterDevice>> searchUsbPrinter();
//   Future<bool> connectUsbPrinter(String deviceAddress);
//   Future<bool> testPrintByBluetoothPrinter(Printer printer, List<int> bytes);
//   Future<bool> testPrintByUsbPrinter(Printer printer, List<int> bytes);
// }
// domain/repository/printer-repository.dart
import 'package:flutter_thermal_printer/utils/printer.dart';
import 'package:pos/features/printer/domain/entites/printer-device.dart';

abstract class PrinterRepository {
  Future<List<PrinterDevice>> checkAndScanBluetooth();
  Future<bool> connectBluetoothPrinter(String deviceAddress);
  Future<bool> checkBluetoothConnection(String deviceAddress);
  Future<bool> disconnectBluetoothConnection();
  Future<List<PrinterDevice>> searchUsbPrinter();
  Future<bool> connectUsbPrinter(String deviceAddress);
  Future<bool> testPrintByBluetoothPrinter(Printer printer, List<int> bytes);
  Future<bool> testPrintByUsbPrinter(Printer printer, List<int> bytes);
}
