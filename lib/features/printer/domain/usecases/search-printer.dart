// domain/usecases/search-printer.dart
import 'package:flutter_thermal_printer/utils/printer.dart';
import 'package:pos/features/printer/domain/entites/printer-device.dart';
import 'package:pos/features/printer/domain/enums/printer-type.dart';
import 'package:pos/features/printer/domain/repository/printer-repository.dart';

class SearchPrinter {
  final PrinterRepository repository;

  SearchPrinter(this.repository);

  Future<List<PrinterDevice>?> call(PrinterType type) async {
    switch (type) {
      case PrinterType.bluetooth:
        return await repository.checkAndScanBluetooth();

      //repository.searchBluetoothPrinter();

      case PrinterType.usb:
        return repository.searchUsbPrinter();

      default:
        return [];
    }
  }
}
