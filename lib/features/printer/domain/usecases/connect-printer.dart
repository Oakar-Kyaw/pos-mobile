import 'package:pos/features/printer/domain/enums/printer-type.dart';
import 'package:pos/features/printer/domain/repository/printer-repository.dart';

class ConnectPrinter {
  final PrinterRepository repository;
  const ConnectPrinter({required this.repository});
  Future<bool> connect(PrinterType type, String deviceAddress) async {
    switch (type) {
      case PrinterType.bluetooth:
        return await repository.connectBluetoothPrinter(deviceAddress);

      //repository.searchBluetoothPrinter();

      case PrinterType.usb:
        return await repository.connectUsbPrinter(deviceAddress);

      default:
        return false;
    }
  }
}
