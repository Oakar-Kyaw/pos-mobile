import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter_thermal_printer/flutter_thermal_printer.dart';
import 'package:flutter_thermal_printer/flutter_thermal_printer_platform_interface.dart';
import 'package:flutter_thermal_printer/utils/printer.dart';
import 'package:pos/features/printer/domain/entites/printer-device.dart';
import 'package:pos/features/printer/domain/enums/printer-type.dart';

class UsbDataSource {
  final _printerPlugin = FlutterThermalPrinter.instance;

  // scan ပြီးလည်း မပိတ်ဘဲ ဆက်ထားမယ့် listener (EventChannel sink မ null ဖြစ်အောင်)
  StreamSubscription<List<Printer>>? _devicesSub;

  // scan စောင့်နေတုန်း ရလဒ်ပို့ဖို့
  Completer<List<PrinterDevice>>? _scanCompleter;

  List<Printer> _discoveredUsbPrinters = [];
  Printer? _connectedPrinter;

  UsbDataSource();

  String _idOf(Printer d) =>
      '${d.vendorId ?? ''}:${d.productId ?? ''}:${d.name ?? 'usb'}';

  PrinterDevice _toDevice(Printer d) {
    return PrinterDevice(
      id: _idOf(d),
      name: (d.name != null && d.name!.isNotEmpty)
          ? d.name!
          : 'Unknown USB Printer',
      address: d.address ?? d.name ?? 'USB_PORT',
      vendorId: d.vendorId?.toString(),
      productId: d.productId?.toString(),
      isConnected: false,
      type: PrinterType.usb,
    );
  }

  /// listener တစ်ခုကို တစ်ခါပဲ စတင်မယ်
  void _ensureListening() {
    _devicesSub ??= _printerPlugin.devicesStream.listen(
      (List<Printer> devices) {
        final usb = devices
            .where((d) => d.connectionType == ConnectionType.USB)
            .toList();
        if (usb.isEmpty) return;

        _discoveredUsbPrinters = usb;

        final c = _scanCompleter;
        if (c != null && !c.isCompleted) {
          c.complete(usb.map(_toDevice).toList());
        }
      },
      onError: (error) {
        debugPrint('devicesStream error: $error');
        final c = _scanCompleter;
        if (c != null && !c.isCompleted) c.completeError(error);
      },
    );
  }

  /// 1. SCAN
  Future<List<PrinterDevice>> scanUsbPrinters() async {
    _ensureListening();
    _discoveredUsbPrinters = [];

    final completer = Completer<List<PrinterDevice>>();
    _scanCompleter = completer;

    try {
      await _printerPlugin.getPrinters(connectionTypes: [ConnectionType.USB]);

      return await completer.future.timeout(
        const Duration(seconds: 4),
        onTimeout: () => <PrinterDevice>[],
      );
    } catch (e) {
      debugPrint('USB Scan failed: $e');
      return <PrinterDevice>[];
    } finally {
      _scanCompleter = null;
      // ⚠️ subscription ကို မ cancel ပါနဲ့ (connect မှာ လိုနေသေးလို့)
      try {
        await _printerPlugin.stopScan();
      } catch (_) {}
    }
  }

  Future<bool> connectUsbPrinter(Printer device) async {
    debugPrint('Attempting to connect to USB printer: ${device.name}');
    try {
      await _printerPlugin.getPrinters(connectionTypes: [ConnectionType.USB]);
      await Future.delayed(const Duration(milliseconds: 500));

      await _printerPlugin.connect(device);

      // permission dialog ပေါ်ရင် user ခွင့်ပြုဖို့ အချိန်ပေးမယ်
      for (var i = 0; i < 10; i++) {
        await Future.delayed(const Duration(milliseconds: 500));
        final ok = await FlutterThermalPrinterPlatform.instance.isConnected(
          device,
        );
        if (ok) {
          _connectedPrinter = device;
          debugPrint('USB connected (verified)');
          return true;
        }
      }
      debugPrint('USB connect timeout (permission မရ ဖြစ်နိုင်)');
      return false;
    } catch (e) {
      debugPrint('Connect failed over USB: $e');
      return false;
    }
  }

  /// 3. PRINT
  Future<bool> printData(List<int> bytes) async {
    if (_connectedPrinter == null) {
      debugPrint('Print failed: No USB printer connected.');
      return false;
    }
    try {
      debugPrint(
        'Writing ${bytes.length} bytes to USB printer ${_connectedPrinter}',
      );
      await _printerPlugin.printData(_connectedPrinter!, bytes);
      return true;
    } catch (e) {
      debugPrint('USB Print execution failed: $e');
      return false;
    }
  }

  /// 4. DISCONNECT
  Future<bool> disconnectUsbPrinter() async {
    if (_connectedPrinter == null) return true;
    try {
      await _printerPlugin.disconnect(_connectedPrinter!);
      _connectedPrinter = null;
      return true;
    } catch (e) {
      debugPrint('USB Disconnect failed: $e');
      return false;
    }
  }

  /// 5. CONNECTION STATUS
  Future<bool> isConnectedToPrinter(String deviceIdOrName) async {
    final p = _connectedPrinter;
    if (p == null) return false;
    return _idOf(p) == deviceIdOrName || p.name == deviceIdOrName;
  }

  void dispose() {
    _scanCompleter = null;
    _devicesSub?.cancel();
    _devicesSub = null;
  }
}
