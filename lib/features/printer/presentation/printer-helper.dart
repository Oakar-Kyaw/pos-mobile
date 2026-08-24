import 'package:flutter/widgets.dart';
import 'package:flutter_localization/flutter_localization.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pos/features/printer/domain/entites/printer-device.dart';
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
    required PrinterDevice printer,
    bool? showDeviceNameAndAddress,
  }) async {
    final connected = await ref
        .read(printerProvider.notifier)
        .connect(
          printerType,
          printer,
          showDeviceNameAndAddress: showDeviceNameAndAddress ?? false,
        );

    if (!context.mounted) return;

    if (connected) {
      // context.pop();
      ShowToast(
        context,
        description: Text(
          PrinterScreenLocale.connected.getString(context),
          style: TextStyle(color: kGreen),
        ),
      );
    } else {
      ShowToast(
        context,
        description: Text(
          PrinterScreenLocale.connectionFailed.getString(context),
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
          PrinterScreenLocale.disconnectedSuccess.getString(context),
          style: TextStyle(color: kGreen),
        ),
      );
    } else {
      ShowToast(
        context,
        description: Text(
          PrinterScreenLocale.disconnectedFailed.getString(context),
          style: TextStyle(color: kRed),
        ),
      );
    }
  }
}
