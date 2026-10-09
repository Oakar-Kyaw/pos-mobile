import 'package:flutter/widgets.dart';
import 'package:flutter_localization/flutter_localization.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_thermal_printer/utils/printer.dart';
import 'package:pos/features/printer/domain/enums/printer-type.dart';
import 'package:pos/features/printer/presentation/provider/printer-provider.dart';
import 'package:pos/localization/printer-local.dart';
import 'package:pos/utils/app-theme.dart';
import 'package:pos/utils/shad-toaster.dart';

class PrinterUiHelper {
  static Future<void> connectPrinter({
    required BuildContext context,
    required PrinterType printerType,
    required WidgetRef ref,
    required Printer printer,
    bool? showDeviceNameAndAddress,
  }) async {
    debugPrint("Printer Ui Helper 📊 ${printer.vendorId}");
    final connected = await ref
        .read(printerProvider.notifier)
        .connect(
          printerType,
          printer,
          showDeviceNameAndAddress: showDeviceNameAndAddress ?? false,
        );
    debugPrint("printer ui heloper success 📆 $connected");
    if (!context.mounted) return;

    if (connected) {
      // context.pop();
      ShowToast(
        context,
        description: Text(
          PrinterScreenLocale.printerConnected.getString(context),
          style: TextStyle(color: kGreen),
        ),
      );
    } else {
      ShowToast(
        context,
        isError: true,
        description: Text(
          PrinterScreenLocale.printerConnectionFailed.getString(context),
          style: TextStyle(color: kRed),
        ),
      );
    }
  }

  static Future<void> disconnectPrinter({
    required BuildContext context,
    required WidgetRef ref,
  }) async {
    final connected = await ref
        .read(printerProvider.notifier)
        .disconnectBluetoothConnection();

    if (!context.mounted) return;

    if (connected) {
      // context.pop();
      ShowToast(
        context,
        description: Text(
          PrinterScreenLocale.printerDisconnectedSuccess.getString(context),
          style: TextStyle(color: kGreen),
        ),
      );
    } else {
      ShowToast(
        context,
        description: Text(
          PrinterScreenLocale.printerDisconnectedFailed.getString(context),
          style: TextStyle(color: kRed),
        ),
      );
    }
  }
}
