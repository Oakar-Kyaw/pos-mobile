// presentation/provider/printer-provider.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_thermal_printer/utils/printer.dart';
import 'package:pos/features/printer/data/datasource/bluetooth-data-source.dart';
import 'package:pos/features/printer/domain/entites/printer-device.dart';
import 'package:pos/features/printer/domain/entites/printer-state.dart';
import 'package:pos/features/printer/domain/enums/printer-type.dart';
import 'package:pos/features/printer/domain/repository/printer-repository-implementation.dart';
import 'package:pos/features/printer/domain/repository/printer-repository.dart';
import 'package:pos/features/printer/domain/usecases/connect-printer.dart';
import 'package:pos/features/printer/domain/usecases/printer-usecase.dart';
import 'package:pos/features/printer/domain/usecases/search-printer.dart';

// 2. BluetoothDataSource Provider
final bluetoothDataSourceProvider = Provider<BluetoothDataSource>((ref) {
  return BluetoothDataSource();
});

final printerRepositoryProvider = Provider<PrinterRepository>((ref) {
  return PrinterRepositoryImpl(
    bluetooth: ref.watch(bluetoothDataSourceProvider),
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
          .call(type); // await ထည့်ပြီးပြီ
      state = state.copyWith(isLoading: false, printers: printers);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<bool> connect(
    PrinterType type,
    PrinterDevice device, {
    bool showDeviceNameAndAddress = false,
  }) async {
    state = state.copyWith(
      isConnecting: true,
      address: device.address,
      error: null,
    );
    try {
      final success = await ref
          .read(connectPrinterUsecaseProvider)
          .connect(type, device.address!);
      print("success connection is $success");

      state = state.copyWith(
        isConnecting: false,
        isConnected: true,
        connectedPrinterType: type,
        connectedPrinter: success ? device : state.connectedPrinter,
        showDeviceNameAndAddress: showDeviceNameAndAddress,
      );
      return success;
    } catch (e) {
      state = state.copyWith(
        isConnecting: false,
        isConnected: false,
        address: null,
        connectedPrinter: null,
        connectedPrinterType: null,
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
    Printer printerDevice = Printer(
      address: existPrinter.address,
      name: existPrinter.name,
      connectionType: switch (type) {
        "bluetooth" => ConnectionType.BLE,
        "usb" => ConnectionType.USB,
        "network" => ConnectionType.NETWORK,
        _ => ConnectionType.BLE,
      },
      isConnected: existPrinter.isConnected,
    );
    final writeData = await ref
        .read(printerUsecaseProvider)
        .testPrint(type, printerDevice, bytes);
    return writeData;
  }

  void clearPrinters() {
    state = state.copyWith(printers: [], showDeviceNameAndAddress: false);
  }
}
