import 'package:flutter_thermal_printer/utils/printer.dart';
import 'package:pos/features/printer/domain/enums/printer-type.dart';
import 'package:pos/features/printer/domain/repository/printer-repository.dart';

class PrinterUsecase {
  PrinterRepository _repository;
  PrinterUsecase(this._repository);

  Future<bool> testPrint(
    PrinterType type,
    Printer printerDevice,
    List<int> bytes,
  ) async {
    print("type of bluetooth is $type");
    switch (type) {
      case PrinterType.bluetooth:
        print("bluetooth type");
        return await _repository.testPrintByBluetoothPrinter(
          printerDevice,
          bytes,
        );

      //repository.searchBluetoothPrinter();

      case PrinterType.usb:
        return await _repository.testPrintByUsbPrinter(printerDevice, bytes);

      default:
        return false;
    }
  }
}
