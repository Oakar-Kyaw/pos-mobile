import 'package:flutter_thermal_printer/utils/printer.dart';
import 'package:pos/features/printer/domain/entites/printer-device.dart';
import 'package:pos/features/printer/domain/enums/printer-type.dart';
import 'package:pos/features/printer/domain/repository/printer-repository.dart';

class ConnectPrinter {
  final PrinterRepository repository;
  const ConnectPrinter({required this.repository});
  Future<bool> connect(
    PrinterType type,
    String deviceAddress, {
    required Printer device,
  }) async {
    switch (type) {
      case PrinterType.bluetooth:
        return await repository.connectBluetoothPrinter(deviceAddress);

      //repository.searchBluetoothPrinter();

      case PrinterType.usb:
        return await repository.connectUsbPrinter(device);

      default:
        return false;
    }
  }
}
