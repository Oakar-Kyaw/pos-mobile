import 'package:pos/features/printer/domain/entites/printer-device.dart';
import 'package:pos/features/printer/domain/enums/printer-type.dart';

class _Unset {
  const _Unset();
}

const _unset = _Unset();

class PrinterState {
  final bool isLoading;
  final List<PrinterDevice>? printers;
  final bool isConnecting;
  final bool isConnected;
  final PrinterDevice? connectedPrinter;
  final PrinterType? connectedPrinterType;
  final String? address;
  final String? error;
  final bool showDeviceNameAndAddress;

  const PrinterState({
    required this.isLoading,
    this.printers,
    required this.isConnecting,
    this.isConnected = false,
    this.connectedPrinter,
    this.connectedPrinterType,
    this.address,
    this.error,
    this.showDeviceNameAndAddress = false,
  });

  PrinterState copyWith({
    bool? isLoading,
    bool? isConnecting,
    bool? isConnected,
    Object? address = _unset,
    List<PrinterDevice>? printers,
    Object? connectedPrinter = _unset,
    Object? connectedPrinterType = _unset,
    Object? error = _unset,
    bool? showDeviceNameAndAddress,
  }) {
    return PrinterState(
      isLoading: isLoading ?? this.isLoading,
      isConnecting: isConnecting ?? this.isConnecting,
      isConnected: isConnected ?? this.isConnected,
      printers: printers ?? this.printers,
      address: identical(address, _unset) ? this.address : address as String?,
      connectedPrinter: identical(connectedPrinter, _unset)
          ? this.connectedPrinter
          : connectedPrinter as PrinterDevice?,
      connectedPrinterType: identical(connectedPrinterType, _unset)
          ? this.connectedPrinterType
          : connectedPrinterType as PrinterType?,
      error: identical(error, _unset) ? this.error : error as String?,
      showDeviceNameAndAddress:
          showDeviceNameAndAddress ?? this.showDeviceNameAndAddress,
    );
  }
}
