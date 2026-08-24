import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localization/flutter_localization.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_thermal_printer/flutter_thermal_printer.dart';
import 'package:go_router/go_router.dart';
import 'package:pos/component/app-bar.dart';
import 'package:pos/component/loading-component.dart';
import 'package:pos/core/database/printer-table-schema.dart';
import 'package:pos/core/widgets/custom-button.dart';
import 'package:pos/core/widgets/input.dart';
import 'package:pos/features/printer/data/datasource/printer-local-datasource.dart';
import 'package:pos/features/printer/domain/entites/printer-device.dart';
import 'package:pos/features/printer/domain/entites/printer-state.dart';
import 'package:pos/features/printer/domain/enums/printer-type.dart';
import 'package:pos/features/printer/presentation/printer-helper.dart';
import 'package:pos/features/printer/presentation/provider/printer-provider.dart';
import 'package:pos/features/printer/presentation/widget/printer-list.dart';
import 'package:pos/localization/printer-local.dart';
import 'package:pos/utils/app-theme.dart';
import 'package:pos/utils/shad-toaster.dart';
import 'package:shadcn_ui/shadcn_ui.dart';
import 'package:thermal_unicode_print/thermal_unicode_print.dart';

class PrinterPage extends ConsumerStatefulWidget {
  const PrinterPage({super.key});

  @override
  ConsumerState<PrinterPage> createState() => _PrinterPageState();
}

class _PrinterPageState extends ConsumerState<PrinterPage> {
  final _printerNameController = TextEditingController();
  PrinterTableItem? initialPrinter;
  String printerType = "";
  String printerPaperSize = "";
  bool setDefault = false;
  final datasource = PrinterLocalDatabaseSource();
  List<PrinterTableItem> listOfPrinters = [];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _getSavedPrinters();
    });
  }

  Future<List<int>> testTicket() async {
    final profile = await CapabilityProfile.load();
    final paperSize = printerPaperSize.isEmpty
        ? PaperSize.mm58
        : printerPaperSize == "58mm"
        ? PaperSize.mm58
        : printerPaperSize == "72mm"
        ? PaperSize.mm72
        : printerPaperSize == "80mm"
        ? PaperSize.mm80
        : PaperSize.mm58;
    final generator = Generator(paperSize, profile);

    // Initialize the renderer: 384 dots for 58mm paper size
    const renderer = ThermalUnicodeRenderer(dotsWidth: 384);
    const TextStyle titleStyle = TextStyle(
      fontFamily: 'NotoSerif',
      fontSize: 30,
      fontWeight: FontWeight.bold,
    );
    List<int> bytes = [];
    const EdgeInsets cellPadding = EdgeInsets.symmetric(vertical: 1.0);

    // Reset printer
    bytes += generator.reset();
    bytes += await renderer.textLine(
      generator,
      "Hello Customer, Nice to meet you",
      align: TextAlign.center,
      style: titleStyle,
      padding: cellPadding,
    );
    bytes += await renderer.divider(
      generator,
      thickness: 1.0,
      verticalPadding: 2.0,
    );

    bytes += await renderer.textLine(
      generator,
      "တွေ့ရတာ ဝမ်းသာပါတယ်",
      align: TextAlign.center,
      style: titleStyle,
      padding: cellPadding,
    );

    return bytes;
  }

  Future<void> savePrinter(
    BuildContext context,
    PrinterState printerState,
  ) async {
    final valid = checkValidation(context, printerState);

    if (!valid) return;

    await _savePrinter(context, printerState);
  }

  bool checkValidation(BuildContext context, PrinterState printerState) {
    if (_printerNameController.text.isEmpty) {
      ShowToast(
        context,
        isError: true,
        description: Text(
          PrinterScreenLocale.printerNameRequired.getString(context),
          style: TextStyle(color: kRed),
        ),
      );
      return false;
    }

    if (printerType.isEmpty) {
      ShowToast(
        context,
        isError: true,
        description: Text(
          PrinterScreenLocale.printerTypeRequired.getString(context),
          style: TextStyle(color: kRed),
        ),
      );
      return false;
    }

    if (printerState.connectedPrinter == null) {
      ShowToast(
        context,
        isError: true,
        description: Text(
          PrinterScreenLocale.printerConnectRequired.getString(context),
          style: TextStyle(color: kRed),
        ),
      );
      return false;
    }

    if (printerPaperSize.isEmpty) {
      ShowToast(
        context,
        isError: true,
        description: Text(
          PrinterScreenLocale.paperSizeRequired.getString(context),
          style: TextStyle(color: kRed),
        ),
      );
      return false;
    }

    return true;
  }

  Future<void> _savePrinter(BuildContext context, PrinterState printer) async {
    try {
      final connectedPrinter = printer.connectedPrinter!;
      final newPrinter = PrinterTableItem(
        id: 0,
        name: _printerNameController.text,
        address: connectedPrinter.address,
        isConnected: connectedPrinter.isConnected,
        type: PrinterTypeByTable.fromValue(printerType),
        setDefault: setDefault,
        paperSize: printerPaperSize,
        deviceName: connectedPrinter.name,
      );
      await datasource.insert(newPrinter);
      if (!context.mounted) return;
      ShowToast(
        context,
        isError: false,
        description: Text(
          PrinterScreenLocale.printerSaveSuccess.getString(context),
          style: TextStyle(color: kGreen),
        ),
      );
      ref.read(printerProvider.notifier).clearPrinters();
      Navigator.pop(context);
    } catch (e) {
      if (!context.mounted) return;
      ShowToast(
        context,
        isError: true,
        description: Text(
          PrinterScreenLocale.printerSaveFailed.getString(context),
          style: TextStyle(color: kRed),
        ),
      );
    }
  }

  Future<void> _getSavedPrinters() async {
    try {
      final printers = await datasource.getAll();
      final initialPrinter = printers.firstWhereOrNull((e) => e.setDefault);

      print("printers are: ${initialPrinter} ");
      setState(() {
        listOfPrinters = printers;
      });
      if (initialPrinter == null) return;
      ref
          .read(printerProvider.notifier)
          .connect(
            initialPrinter.type.toDomain(),
            PrinterDevice(
              id: initialPrinter.id.toString(),
              name: initialPrinter.name,
              type: initialPrinter.type.toDomain(),
              paperSize: initialPrinter.paperSize,
              address: initialPrinter.address,
              setDefault: initialPrinter.setDefault,
              isConnected: initialPrinter.isConnected,
            ),
          );
    } catch (e) {}
  }

  Future<void> _deletePrinter(BuildContext context, int id) async {
    try {
      await datasource.delete(id);
      await _getSavedPrinters(); // list ကို refresh
    } catch (e) {
      if (!context.mounted) return;
      ShowToast(
        context,
        isError: true,
        description: Text(
          PrinterScreenLocale.printerDeleteFailed.getString(context),
          style: TextStyle(color: kRed),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = ref.watch(themeModeProvider) == ThemeMode.dark;
    final bgColor = isDark ? kBgDark : kBgLight;
    //final subColor = isDark ? kTextSubDark : kTextSubLight;
    final labelColor = isDark ? kTextDark : kTextLight;
    final printerState = ref.watch(printerProvider);
    //print("🖨️ ${printerState.printers}");
    return Scaffold(
      backgroundColor: bgColor,
      appBar: CustomAppBar(
        leading: IconButton(
          onPressed: () => context.pop(),
          icon: const Icon(LucideIcons.arrowLeft),
        ),
        title: PrinterScreenLocale.printerTitle.getString(context),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              customInput(
                context,
                label: PrinterScreenLocale.printerName,
                placeholder: PrinterScreenLocale.printerNamePlaceholder,
                controller: _printerNameController,
                labelColor: labelColor,
              ),
              customGap(),

              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10.0),
                child: customLabel(
                  context,
                  PrinterScreenLocale.printerType,
                  labelColor,
                ),
              ),

              ///printer type
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 5,
                ),
                child: Row(
                  children: [
                    Expanded(
                      flex: 2,
                      child: ShadSelect<String>(
                        placeholder: Text(
                          PrinterScreenLocale.printerTypePlaceholder.getString(
                            context,
                          ),
                        ),
                        options:
                            [
                                  {"key": "Bluetooth", "value": "bluetooth"},
                                  {"key": "USB", "value": "usb"},
                                  {"key": "Ethernet", "value": "ethernet"},
                                ]
                                .map(
                                  (item) => ShadOption(
                                    value: item["value"]!,
                                    child: Text(item["key"]!),
                                  ),
                                )
                                .toList(),
                        selectedOptionBuilder: (context, value) => Text(value),
                        onChanged: (value) {
                          print("value of printer is $value");
                          setState(() {
                            printerType = value ?? "";
                          });
                        },
                      ),
                    ),
                    const SizedBox(width: 10),

                    printerState.isLoading
                        ? Expanded(
                            flex: 1,
                            child: SizedBox(
                              height: 22,
                              width: 1,
                              child: LoadingWidget(),
                            ),
                          )
                        :
                          //if printer type is bluetooth . show bluetooth search
                          printerType == "bluetooth"
                        ? Expanded(
                            flex: 1,
                            child: customButton(
                              horizontal: 15,
                              vertical: 10,
                              label: PrinterScreenLocale.printerSearchButton
                                  .getString(context),
                              isDark: isDark,
                              gradient: true,
                              onTap: () {
                                ref
                                    .read(printerProvider.notifier)
                                    .search(PrinterType.bluetooth);
                                showDialog(
                                  context: context,
                                  builder: (context) => PrinterListDialog(),
                                );
                              },
                            ),
                          )
                        : Container(),
                  ],
                ),
              ),
              customGap(height: 10),
              //device name
              printerState.isConnected && printerState.showDeviceNameAndAddress
                  ? Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 10.0),
                      child: Row(
                        children: [
                          Text(
                            "${PrinterScreenLocale.deviceName.getString(context)}: ",
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          Expanded(
                            child: Text(
                              printerState.connectedPrinter?.name ?? "",
                              overflow: TextOverflow.ellipsis,
                              maxLines: 1,
                            ),
                          ),
                        ],
                      ),
                    )
                  : const SizedBox(),
              printerState.isConnected && printerState.showDeviceNameAndAddress
                  ? customGap(height: 10)
                  : const SizedBox(),
              //device address
              printerState.isConnected && printerState.showDeviceNameAndAddress
                  ? Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 10.0),
                      child: Row(
                        children: [
                          Text(
                            "${PrinterScreenLocale.deviceAddress.getString(context)}: ",
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          Expanded(
                            child: Text(
                              printerState.connectedPrinter?.address ?? "",
                              overflow: TextOverflow.ellipsis,
                              maxLines: 1,
                            ),
                          ),
                        ],
                      ),
                    )
                  : const SizedBox(),
              printerState.isConnected && printerState.showDeviceNameAndAddress
                  ? customGap(height: 10)
                  : const SizedBox(),
              //for papersize (only printerState is connected)
              printerState.isConnected && printerState.showDeviceNameAndAddress
                  ? Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 5,
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            flex: 2,
                            child: ShadSelect<String>(
                              placeholder: Text(
                                PrinterScreenLocale.paperSizePlaceholder
                                    .getString(context),
                              ),
                              options:
                                  [
                                        {"key": "58mm", "value": "58mm"},
                                        {"key": "72mm", "value": "72mm"},
                                        {"key": "80mm", "value": "80mm"},
                                      ]
                                      .map(
                                        (item) => ShadOption(
                                          value: item["value"]!,
                                          child: Text(item["key"]!),
                                        ),
                                      )
                                      .toList(),
                              selectedOptionBuilder: (context, value) =>
                                  Text(value),
                              onChanged: (value) {
                                print("size of printer is $value");
                                if (value == null) return;
                                setState(() {
                                  printerPaperSize = value;
                                });
                                ref
                                    .read(printerProvider.notifier)
                                    .changePrinterDevicePaperSize(value);
                              },
                            ),
                          ),
                        ],
                      ),
                    )
                  : const SizedBox(),
              printerState.isConnected && printerState.showDeviceNameAndAddress
                  ? customGap(height: 10)
                  : const SizedBox(),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10),
                child: ShadCheckbox(
                  value: setDefault,
                  onChanged: (value) => setState(() {
                    setDefault = value;
                  }),
                  label: Text(
                    PrinterScreenLocale.setAsDefault.getString(context),
                  ),
                ),
              ),
              customGap(height: 10),
              customButton(
                label: PrinterScreenLocale.savePrinter.getString(context),
                isDark: isDark,
                gradient: true,
                onTap: () async => savePrinter(context, printerState),
              ),
              customGap(height: 10),
              customButton(
                label: PrinterScreenLocale.printerTest.getString(context),
                isDark: isDark,
                gradient: true,
                onTap: () async {
                  if (printerState.connectedPrinter == null) return;
                  print(
                    " Testing Printer ${printerState.connectedPrinterType}",
                  );
                  final type = printerState.connectedPrinterType!;
                  final bytes = await testTicket();
                  final success = await ref
                      .read(printerProvider.notifier)
                      .printTest(type, bytes);
                  print("test print is : $success");
                },
              ),
              customGap(height: 15),
              // ─── Saved Printers List ───
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10.0),
                child: customLabel(
                  context,
                  PrinterScreenLocale.savedPrinters,
                  labelColor,
                ),
              ),
              customGap(height: 5),
              listOfPrinters.isEmpty
                  ? Padding(
                      padding: const EdgeInsets.all(10),
                      child: Text(
                        PrinterScreenLocale.noPrinterFound.getString(context),
                        style: TextStyle(color: labelColor.withOpacity(0.6)),
                      ),
                    )
                  : ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: listOfPrinters.length,
                      itemBuilder: (context, index) {
                        final printer = listOfPrinters[index];
                        bool isConnected =
                            printerState.connectedPrinter?.address ==
                            printer.address;

                        return Card(
                          margin: const EdgeInsets.symmetric(vertical: 6),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(vertical: 4),
                            child: ListTile(
                              leading: Icon(
                                printer.type == PrinterTypeByTable.bluetooth
                                    ? LucideIcons.bluetooth
                                    : LucideIcons.usb,
                                color: isConnected ? kGreen : labelColor,
                              ),

                              title: Text(
                                printer.name,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  fontWeight: FontWeight.w600,
                                ),
                              ),

                              subtitle: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    printer.deviceName,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),

                                  Text(
                                    printer.address ?? "-",
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),

                                  const SizedBox(height: 6),

                                  isConnected
                                      ? Wrap(
                                          spacing: 8,
                                          runSpacing: 4,
                                          crossAxisAlignment:
                                              WrapCrossAlignment.center,
                                          children: [
                                            GestureDetector(
                                              onTap: () {
                                                PrinterUiHelper.disconnectPrinter(
                                                  context: context,
                                                  ref: ref,
                                                );
                                              },
                                              child: Text(
                                                PrinterScreenLocale.disconnected
                                                    .getString(context),
                                                style: TextStyle(
                                                  color: Colors.red,
                                                ),
                                              ),
                                            ),
                                          ],
                                        )
                                      : InkWell(
                                          onTap: () =>
                                              PrinterUiHelper.connectPrinter(
                                                context: context,
                                                ref: ref,
                                                printerType: printer.type
                                                    .toDomain(),
                                                printer: PrinterDevice(
                                                  id: printer.id.toString(),
                                                  name: printer.deviceName,
                                                  isConnected:
                                                      printer.isConnected,
                                                  address: printer.address,
                                                  paperSize: printer.paperSize,
                                                  setDefault:
                                                      printer.setDefault,
                                                ),
                                              ),
                                          child: Text(
                                            PrinterScreenLocale.connect
                                                .getString(context),
                                            style: TextStyle(
                                              color: Colors.blue,
                                            ),
                                          ),
                                        ),
                                ],
                              ),

                              trailing: IconButton(
                                icon: const Icon(
                                  LucideIcons.trash2,
                                  color: kRed,
                                ),
                                onPressed: () =>
                                    _deletePrinter(context, printer.id),
                              ),
                            ),
                          ),
                        );
                      },
                    ),
            ],
          ),
        ),
      ),
    );
  }
}
