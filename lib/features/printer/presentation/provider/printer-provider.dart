// presentation/provider/printer-provider.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_thermal_printer/utils/printer.dart';
import 'package:pos/features/printer/data/datasource/bluetooth-data-source.dart';
import 'package:pos/features/printer/data/datasource/usb-data-source.dart';
import 'package:pos/features/printer/domain/entites/printer-device.dart';
import 'package:pos/features/printer/domain/entites/printer-state.dart';
import 'package:pos/features/printer/domain/enums/printer-type.dart';
import 'package:pos/features/printer/domain/repository/printer-repository-implementation.dart';
import 'package:pos/features/printer/domain/repository/printer-repository.dart';
import 'package:pos/features/printer/domain/usecases/connect-printer.dart';
import 'package:pos/features/printer/domain/usecases/printer-usecase.dart';
import 'package:pos/features/printer/domain/usecases/search-printer.dart';
import 'package:uuid/uuid.dart';

// 1. BluetoothDataSource Provider
final bluetoothDataSourceProvider = Provider<BluetoothDataSource>((ref) {
  return BluetoothDataSource();
});

//2. UsbDataSource Provider
final usbDataSourceProvider = Provider<UsbDataSource>((ref) {
  return UsbDataSource();
});

final printerRepositoryProvider = Provider<PrinterRepository>((ref) {
  return PrinterRepositoryImpl(
    bluetooth: ref.watch(bluetoothDataSourceProvider),
    usb: ref.watch(usbDataSourceProvider),
  );
});

final searchPrinterUsecaseProvider = Provider((ref) {
  return SearchPrinter(ref.watch(printerRepositoryProvider));
});

final connectPrinterUsecaseProvider = Provider((ref) {
  return ConnectPrinter(repository: ref.watch(printerRepositoryProvider));
});

final printerUsecaseProvider = Provider((ref) {
  return PrinterUsecase(ref.watch(printerRepositoryProvider));
});

final printerProvider = NotifierProvider<PrinterNotifier, PrinterState>(
  PrinterNotifier.new,
);

class PrinterNotifier extends Notifier<PrinterState> {
  @override
  PrinterState build() =>
      const PrinterState(isLoading: false, isConnecting: false);

  Future<void> search(PrinterType type) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final printers = await ref
          .read(searchPrinterUsecaseProvider)
          .searchDevice(type);
      debugPrint("😁 Search Device is: $printers");
      state = state.copyWith(isLoading: false, printers: printers);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<bool> connect(
    PrinterType type,
    Printer device, {
    bool showDeviceNameAndAddress = false,
  }) async {
    state = state.copyWith(isConnecting: true, error: null);
    try {
      debugPrint("Connecting $device ${device.vendorId}");
      final success = await ref
          .read(connectPrinterUsecaseProvider)
          .connect(type, device.address!, device: device);

      final domainDevice = PrinterDevice(
        id: device.address ?? '',
        name: device.name ?? '',
        address: device.address,
        vendorId: device.vendorId,
        productId: device.productId,
        type: type,
        isConnected: success,
      );

      state = state.copyWith(
        isConnecting: false,
        isConnected: success,
        connectedPrinterType: success ? type : null,
        connectedPrinter: success ? domainDevice : null,
        address: success ? device.address : null,
        showDeviceNameAndAddress: success && showDeviceNameAndAddress,
      );
      return success;
    } catch (e) {
      state = state.copyWith(
        isConnecting: false,
        isConnected: false,
        connectedPrinter: null,
        connectedPrinterType: null,
        address: null,
        showDeviceNameAndAddress: false,
        error: e.toString(),
      );
      return false;
    }
  }

  PrinterState changePrinterDevicePaperSize(String paperSize) {
    try {
      state = state.copyWith(
        connectedPrinter: state.connectedPrinter == null
            ? state.connectedPrinter
            : state.connectedPrinter!.copyWith(paperSize: paperSize),
      );
      return state;
    } catch (e) {
      state = state.copyWith(
        connectedPrinter: state.connectedPrinter,
        error: e.toString(),
      );
      return state;
    }
  }

  Future<bool> checkBluetoothConnection(String address) async {
    final success = await ref
        .read(printerRepositoryProvider)
        .checkBluetoothConnection(address);

    return success;
  }

  Future<bool> disconnectBluetoothConnection() async {
    final disconnected = await ref
        .read(printerRepositoryProvider)
        .disconnectBluetoothConnection();

    state = state.copyWith(
      isConnecting: false,
      isConnected: false,
      address: null,
      connectedPrinter: null,
      connectedPrinterType: null,
      showDeviceNameAndAddress: false,
    );

    print("After disconnect:");
    print(state.isConnected);
    print(state.connectedPrinter);

    return disconnected;
  }

  Future<bool> printTest(PrinterType type, List<int> bytes) async {
    final existPrinter = state.connectedPrinter;
    if (existPrinter == null) return false;
    debugPrint("printer type for print test 📈 $type");
    final printerDevice = Printer(
      address: existPrinter.address,
      name: existPrinter.name,
      vendorId: existPrinter.vendorId,
      productId: existPrinter.productId,
      connectionType: switch (type) {
        PrinterType.usb => ConnectionType.USB,
        PrinterType.ethernet => ConnectionType.NETWORK,
        _ => ConnectionType.BLE,
      },
      isConnected: existPrinter.isConnected,
    );

    return ref
        .read(printerUsecaseProvider)
        .testPrint(type, printerDevice, bytes, device: existPrinter);
  }

  void clearPrinters() {
    state = state.copyWith(printers: [], showDeviceNameAndAddress: false);
  }
}
