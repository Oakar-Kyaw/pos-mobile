// lib/features/printer_scanner/data/datasources/bluetooth_data_source.dart
import 'dart:async';
import 'package:flutter_blue_classic/flutter_blue_classic.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:pos/features/printer/domain/entites/printer-device.dart';
import 'package:print_bluetooth_thermal/print_bluetooth_thermal.dart';

class BluetoothDataSource {
  final _blueClassic = FlutterBlueClassic();
  //final List<BluetoothDevice>
  List<BluetoothInfo> foundDevices = [];
  String? _connectedAddress;

  // Constructor မှတစ်ဆင့် Dependency Injection (DI) သွင်းခြင်း
  BluetoothDataSource();

  // Bluetooth Support ဖြစ်၊ မဖြစ် စစ်ဆေးခြင်း
  Future<List<PrinterDevice>> scanPrinters() async {
    Duration scanDuration = const Duration(seconds: 10);
    final bool result =
        await PrintBluetoothThermal.isPermissionBluetoothGranted;
    print("resulit bluetooth is: $result");

    // 1. Bluetooth support ရှိလား
    final supported = await _blueClassic.isSupported;
    if (!supported) {
      print('ဒီစက်မှာ Bluetooth support မရှိပါ');
      return [];
    }

    // 2. Runtime permission တောင်း (Android 12+ အတွက် မဖြစ်မနေလိုအပ်ပါတယ်)
    final statuses = await [
      Permission.bluetoothScan,
      Permission.bluetoothConnect,
      Permission
          .locationWhenInUse, // usesFineLocation: true သုံးထားရင် ဒါပါ လိုပါတယ်
    ].request();

    final allGranted = statuses.values.every((s) => s.isGranted);
    if (!allGranted) {
      print('Bluetooth/Location permission ကို user က ခွင့်မပြုပါ');
      throw Exception(
        "User doesn't permit bluetooth",
      ); // permission မရရင် scan စလို့ရမှာမဟုတ်ပါ
    }

    // 3. Enabled ဖြစ်အောင်လုပ် (ဖွင့်ပြီးသားလည်း ဖြစ်နိုင်၊ ပိတ်နေရင် ဖွင့်ခိုင်း)
    final enabled = await _blueClassic.isEnabled;
    if (!enabled) {
      await _blueClassic.turnOn();
      // turnOn ပြီးလို့ device ဆီက confirm ပြန်လာအောင် ခဏစောင့်
      await Future.delayed(const Duration(seconds: 1));
    }

    // 4. Enabled ဖြစ်ရင် (မူလကတည်းက on ဖြစ်နေပါစေ၊ အခုမှ on ဖြစ်ပါစေ) scan စ
    //    <- ဒါက အရေးကြီးဆုံး fix: enabled-check ရဲ့ "if" ထဲက scan logic ကို ထုတ်ထားလိုက်ပါတယ်
    foundDevices.clear();
    foundDevices = await PrintBluetoothThermal.pairedBluetooths;

    print("ရလဒ်: ${foundDevices} ခု တွေ့ပါတယ်");

    return foundDevices.map((d) {
      print("🤖 d ${d.name}");
      return PrinterDevice(
        id: d.macAdress,
        name: d.name.isNotEmpty == true ? d.name : '(no name)',
        address: d.macAdress,
      );
    }).toList();
  }

  // Bluetooth ပွင့်၊ မပွင့် စစ်ဆေးခြင်း
  Future<bool> isBluetoothEnabled() async {
    return await _blueClassic.isEnabled;
  }

  Future<bool> connectBluetoothPrinter(String deviceAddress) async {
    print("bluetooth device $deviceAddress");
    try {
      final result = await PrintBluetoothThermal.connect(
        macPrinterAddress: deviceAddress,
      );

      print("printer connection result $result");

      final isConnected = await PrintBluetoothThermal.connectionStatus;
      print("connection state 🤩 $isConnected");

      if (isConnected) {
        _connectedAddress = deviceAddress;
      }
      return await PrintBluetoothThermal.connectionStatus;
      //_connection != null;
    } catch (e) {
      print("Connect faile $e");
      return false;
    }
  }

  Future<bool> disconnectBluetoothPrinter() async {
    try {
      final result = await PrintBluetoothThermal.disconnect;

      print("printer connection result $result");

      final isConnected = await PrintBluetoothThermal.connectionStatus;
      print("connection state 🤩 $isConnected");

      return await PrintBluetoothThermal.connectionStatus == false;
      //_connection != null;
    } catch (e) {
      print("Connect faile $e");
      return false;
    }
  }

  Future<bool> isConnectedToPrinter(String address) async {
    final isConnected = await PrintBluetoothThermal.connectionStatus;
    return isConnected && _connectedAddress == address;
  }

  Future<bool> printData(List<int> bytes) async {
    print("printer data is ");
    try {
      print("Writing ${bytes.length} bytes to Bluetooth printer");
      final result = await PrintBluetoothThermal.writeBytes(bytes);
      // _connection!.output.add(Uint8List.fromList(bytes));
      // await _connection!.output.allSent;
      return true;
    } catch (e) {
      print('Print failed: $e');
      return false;
    }
  }
}
