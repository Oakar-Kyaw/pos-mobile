import 'dart:async';
import 'package:flutter_thermal_printer/flutter_thermal_printer.dart';
import 'package:flutter_thermal_printer/utils/printer.dart';
import 'package:pos/features/printer/domain/entites/printer-device.dart';

class UsbDataSource {
  final _printerPlugin = FlutterThermalPrinter.instance;
  StreamSubscription<List<Printer>>? _usbScanSubscription;

  // Track discovered printers to interact with them by address/ID later
  List<Printer> _discoveredUsbPrinters = [];
  Printer? _connectedPrinter;

  UsbDataSource();

  /// 1. SCAN & SEARCH FOR USB PRINTERS
  Future<List<PrinterDevice>> scanUsbPrinters() async {
    final completer = Completer<List<PrinterDevice>>();
    _discoveredUsbPrinters.clear();

    // Stream the USB connection types
    _usbScanSubscription = _printerPlugin
        .getPrinters(
          connectionTypes: [ConnectionType.USB],
          refreshDuration: const Duration(seconds: 1),
        )
        .listen(
          (List<Printer> devices) {
            _discoveredUsbPrinters = devices;

            // Map to your domain's PrinterDevice entity
            final printerDevices = devices.map((d) {
              return PrinterDevice(
                // USB devices use vendorId/productId combinations or internal names as unique identifiers
                id: d.name ?? 'usb_printer_${devices.indexOf(d)}',
                name: d.name != null && d.name!.isNotEmpty
                    ? d.name!
                    : 'Unknown USB Printer',
                address: d.name ?? 'USB_PORT',
              );
            }).toList();

            // Clean up the stream and complete after getting the initial list
            _usbScanSubscription?.cancel();
            if (!completer.isCompleted) {
              completer.complete(printerDevices);
            }
          },
          onError: (error) {
            print("USB Scan failed: $error");
            if (!completer.isCompleted) completer.completeError(error);
          },
        );

    // Timeout protection if no stream response drops in 4 seconds
    return completer.future.timeout(
      const Duration(seconds: 4),
      onTimeout: () => [],
    );
  }

  /// 2. CONNECT TO USB PRINTER
  Future<bool> connectUsbPrinter(String deviceIdOrName) async {
    print("Attempting to connect to USB printer: $deviceIdOrName");
    try {
      // Find the cached printer reference from our scan list matching the ID/Name
      final targetPrinter = _discoveredUsbPrinters.firstWhere(
        (d) => d.name == deviceIdOrName,
        orElse: () => throw Exception(
          "Printer not found in scanned list. Run scan first.",
        ),
      );

      final bool isConnected = await _printerPlugin.connect(targetPrinter);
      print("USB printer connection result: $isConnected");

      if (isConnected) {
        _connectedPrinter = targetPrinter;
      }
      return isConnected;
    } catch (e) {
      print("Connect failed over USB: $e");
      return false;
    }
  }

  /// 3. PRINT DATA
  Future<bool> printData(List<int> bytes) async {
    if (_connectedPrinter == null) {
      print('Print failed: No USB printer connected.');
      return false;
    }
    try {
      print("Writing ${bytes.length} bytes to USB printer");
      final bool result = await _printerPlugin.printData(
        _connectedPrinter!,
        bytes,
      );
      return result;
    } catch (e) {
      print('USB Print execution failed: $e');
      return false;
    }
  }

  /// 4. DISCONNECT
  Future<bool> disconnectUsbPrinter() async {
    if (_connectedPrinter == null) return true;
    try {
      final bool result = await _printerPlugin.disconnect(_connectedPrinter!);
      if (result) {
        _connectedPrinter = null;
      }
      return result;
    } catch (e) {
      print('USB Disconnect failed: $e');
      return false;
    }
  }

  /// 5. CONNECTION CHECK STATUS
  Future<bool> isConnectedToPrinter(String deviceIdOrName) async {
    if (_connectedPrinter == null) return false;
    // Check if the current connected printer profile matches the query address
    return _connectedPrinter!.name == deviceIdOrName;
  }
}
