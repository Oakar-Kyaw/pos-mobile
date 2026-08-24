import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pos/component/loading-component.dart';
import 'package:pos/features/printer/domain/enums/printer-type.dart';
import 'package:pos/features/printer/presentation/printer-helper.dart';
import 'package:pos/features/printer/presentation/provider/printer-provider.dart';
import 'package:pos/utils/app-theme.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

class PrinterListDialog extends ConsumerStatefulWidget {
  const PrinterListDialog({super.key});

  @override
  ConsumerState<PrinterListDialog> createState() => _PrinterListDialogState();
}

class _PrinterListDialogState extends ConsumerState<PrinterListDialog> {
  @override
  Widget build(BuildContext context) {
    final isDark = ref.watch(themeModeProvider) == ThemeMode.dark;
    final printerState = ref.watch(printerProvider);
    final surfaceColor = isDark ? kSurfaceDark : kSurfaceLight;
    final textColor = isDark ? kTextDark : kTextLight;
    final dividerColor = isDark
        ? Colors.white.withOpacity(0.08)
        : const Color(0xFFE5E7EB);
    final printerArr = printerState.printers ?? [];
    return AlertDialog(
      insetPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 24),
      backgroundColor: surfaceColor,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      content: SizedBox(
        width: double.maxFinite,
        child: SingleChildScrollView(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom + 20,
          ),
          child: printerState.isLoading
              ? LoadingWidget()
              : ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: printerArr.length,
                  separatorBuilder: (_, __) =>
                      Divider(height: 1, color: dividerColor),
                  itemBuilder: (context, index) {
                    final printer = printerState.printers![index];
                    return ListTile(
                      leading: Icon(LucideIcons.printer, color: kPrimary),
                      title: Text(
                        printer.name,
                        style: TextStyle(color: textColor),
                      ),
                      trailing:
                          printerState.isConnecting &&
                              printerState.address == printer.address
                          ? SizedBox(
                              height: 20,
                              width: 20,
                              child: LoadingWidget(),
                            )
                          : const SizedBox(),
                      onTap: () => PrinterUiHelper.connectPrinter(
                        context: context,
                        ref: ref,
                        printer: printer,
                        printerType: PrinterType.bluetooth,
                        showDeviceNameAndAddress: true,
                      ),
                    );
                  },
                ),
        ),
      ),
    );
  }
}
