import 'dart:math';

import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localization/flutter_localization.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_thermal_printer/flutter_thermal_printer.dart';
import 'package:flutter_thermal_printer/utils/printer.dart';
import 'package:go_router/go_router.dart';
import 'package:pos/component/app-bar.dart';
import 'package:pos/component/loading-component.dart';
import 'package:pos/core/database/printer-table-schema.dart';
import 'package:pos/core/widgets/custom-button.dart';
import 'package:pos/core/widgets/input.dart';
import 'package:pos/features/printer/data/datasource/printer-local-datasource.dart';
import 'package:pos/features/printer/domain/entites/printer-state.dart';
import 'package:pos/features/printer/domain/enums/printer-type.dart';
import 'package:pos/features/printer/presentation/printer-helper.dart';
import 'package:pos/features/printer/presentation/provider/printer-provider.dart';
import 'package:pos/features/printer/presentation/widget/printer-list.dart';
import 'package:pos/localization/printer-local.dart';
import 'package:pos/utils/app-theme.dart';
import 'package:pos/utils/button.dart';
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
  final datasource = PrinterLocalDatabaseSource();

  String printerType = "";
  String printerPaperSize = "";
  bool setDefault = false;
  List<PrinterTableItem> listOfPrinters = [];

  /// ချိတ်နေတဲ့ printer ရဲ့ key (loading ပြဖို့)
  String? _connectingKey;

  /// Pull-to-refresh လုပ်နေတုန်း
  bool _isRefreshing = false;

  /// Saved printer ကနေ ချိတ်ထားတာလား (auto connect / saved list)
  bool _connectedFromSaved = false;

  /// Refresh လုပ်တိုင်း တိုးပြီး ShadSelect တွေကို reset ချဖို့
  int _resetCount = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _getSavedPrinters());
  }

  @override
  void dispose() {
    _printerNameController.dispose();
    super.dispose();
  }

  // ---------------------------------------------------------------------------
  // Helpers
  // ---------------------------------------------------------------------------

  void _toast(String text, {required bool error}) {
    ShowToast(
      context,
      isError: error,
      description: Text(text, style: TextStyle(color: error ? kRed : kGreen)),
    );
  }

  /// Connect + loading + paper size ကို တစ်နေရာတည်းမှာ ကိုင်တွယ်မယ်
  Future<void> _connect({
    required String key,
    required PrinterType type,
    required Printer printer,
    String? paperSize,
  }) async {
    if (_connectingKey != null) return;
    setState(() {
      _connectingKey = key;
      _connectedFromSaved = key.startsWith('saved_');
    });
    try {
      await PrinterUiHelper.connectPrinter(
        context: context,
        ref: ref,
        printerType: type,
        printer: printer,
      );

      final connected = ref.read(printerProvider).isConnected;
      if (connected && paperSize != null && paperSize.isNotEmpty) {
        ref
            .read(printerProvider.notifier)
            .changePrinterDevicePaperSize(paperSize);
        if (mounted) setState(() => printerPaperSize = paperSize);
      }
    } finally {
      if (mounted) setState(() => _connectingKey = null);
    }
  }

  Printer _toPlugin(PrinterTableItem p) => Printer(
    address: p.address,
    name: p.deviceName,
    vendorId: p.vendorId,
    productId: p.productId,
    isConnected: p.isConnected,
    connectionType: p.type == PrinterTypeByTable.usb
        ? ConnectionType.USB
        : ConnectionType.BLE,
  );

  bool _isSameConnected(
    PrinterState s, {
    String? address,
    String? vendorId,
    String? productId,
  }) {
    final c = s.connectedPrinter;
    if (!s.isConnected || c == null) return false;
    if (vendorId != null && productId != null) {
      return c.vendorId == vendorId && c.productId == productId;
    }
    return c.address == address;
  }

  // ---------------------------------------------------------------------------
  // Data
  // ---------------------------------------------------------------------------

  Future<List<int>> testTicket() async {
    final profile = await CapabilityProfile.load();
    final paperSize = printerPaperSize == "72mm"
        ? PaperSize.mm72
        : printerPaperSize == "80mm"
        ? PaperSize.mm80
        : PaperSize.mm58;
    final generator = Generator(paperSize, profile);

    const renderer = ThermalUnicodeRenderer(dotsWidth: 384);
    const titleStyle = TextStyle(
      fontFamily: 'NotoSerif',
      fontSize: 30,
      fontWeight: FontWeight.bold,
    );
    const cellPadding = EdgeInsets.symmetric(vertical: 1.0);

    List<int> bytes = [];
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

  bool _validate(PrinterState s) {
    if (_printerNameController.text.trim().isEmpty) {
      _toast(
        PrinterScreenLocale.printerNameRequired.getString(context),
        error: true,
      );
      return false;
    }
    if (printerType.isEmpty) {
      _toast(
        PrinterScreenLocale.printerTypeRequired.getString(context),
        error: true,
      );
      return false;
    }
    if (s.connectedPrinter == null) {
      _toast(
        PrinterScreenLocale.printerConnectRequired.getString(context),
        error: true,
      );
      return false;
    }
    if (printerPaperSize.isEmpty) {
      _toast(
        PrinterScreenLocale.printerPaperSizeRequired.getString(context),
        error: true,
      );
      return false;
    }
    return true;
  }

  Future<void> _savePrinter(PrinterState s) async {
    if (!_validate(s)) return;
    try {
      final c = s.connectedPrinter!;
      await datasource.insert(
        PrinterTableItem(
          id: Random().nextInt(1 << 31),
          name: _printerNameController.text.trim(),
          address: c.address,
          isConnected: c.isConnected,
          type: PrinterTypeByTable.fromValue(printerType),
          setDefault: setDefault,
          paperSize: printerPaperSize,
          deviceName: c.name,
          vendorId: c.vendorId,
          productId: c.productId,
        ),
      );

      if (!mounted) return;
      _toast(
        PrinterScreenLocale.printerSaveSuccess.getString(context),
        error: false,
      );
      ref.read(printerProvider.notifier).clearPrinters();
      Navigator.pop(context);
    } catch (_) {
      if (!mounted) return;
      _toast(
        PrinterScreenLocale.printerSaveFailed.getString(context),
        error: true,
      );
    }
  }

  /// Pull-to-refresh: ရွေးထားတာ/ရှာထားတာ အားလုံးရှင်းပြီး saved list ပြန်ဖတ်မယ်
  Future<void> _onRefresh() async {
    if (_isRefreshing) return;
    setState(() => _isRefreshing = true);

    try {
      // 1. ရှာတွေ့ထားတဲ့ printer list ကို ရှင်းမယ်
      ref.read(printerProvider.notifier).clearPrinters();

      // 3. ရွေးထားတာ အားလုံး ရှင်းမယ်
      _printerNameController.clear();
      if (mounted) {
        setState(() {
          printerType = "";
          printerPaperSize = "";
          setDefault = false;
          _connectingKey = null;
          _connectedFromSaved = false;
          _resetCount++;
        });
      }

      // 4. Saved printers ကို database ကနေ ပြန်ဖတ်မယ် (auto connect မလုပ်)
      await _getSavedPrinters(autoConnect: false);
    } catch (e) {
      debugPrint('Refresh error: $e');
    } finally {
      if (mounted) setState(() => _isRefreshing = false);
    }
  }

  Future<void> _getSavedPrinters({bool autoConnect = true}) async {
    try {
      final printers = await datasource.getAll();
      if (!mounted) return;
      setState(() => listOfPrinters = printers);

      final initial = printers.firstWhereOrNull((e) => e.setDefault);
      if (!autoConnect || initial == null) return;
      if (ref.read(printerProvider).isConnected) return;

      await _connect(
        key: 'saved_${initial.id}',
        type: initial.type.toDomain(),
        printer: _toPlugin(initial),
        paperSize: initial.paperSize,
      );
    } catch (e) {
      debugPrint("Error fetching saved printers: $e");
    }
  }

  Future<void> _deletePrinter(int id) async {
    try {
      await datasource.delete(id);
      await _getSavedPrinters(autoConnect: false);
    } catch (_) {
      if (!mounted) return;
      _toast(
        PrinterScreenLocale.printerDeleteFailed.getString(context),
        error: true,
      );
    }
  }

  // ---------------------------------------------------------------------------
  // UI pieces
  // ---------------------------------------------------------------------------

  Widget _connectedBadge() => Row(
    mainAxisSize: MainAxisSize.min,
    children: [
      Icon(LucideIcons.circleCheck, size: 16, color: kGreen),
      SizedBox(width: 4),
      Text(
        PrinterScreenLocale.printerConnected.getString(context),
        style: TextStyle(color: kGreen, fontWeight: FontWeight.w600),
      ),
    ],
  );

  Widget _loading() =>
      const SizedBox(height: 22, width: 22, child: LoadingWidget());

  Widget _row(String label, String value) => Padding(
    padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 4),
    child: Row(
      children: [
        Text("$label: ", style: const TextStyle(fontWeight: FontWeight.bold)),
        Expanded(
          child: Text(value, overflow: TextOverflow.ellipsis, maxLines: 1),
        ),
      ],
    ),
  );

  @override
  Widget build(BuildContext context) {
    final isDark = ref.watch(themeModeProvider) == ThemeMode.dark;
    final bgColor = isDark ? kBgDark : kBgLight;
    final labelColor = isDark ? kTextDark : kTextLight;
    final printerState = ref.watch(printerProvider);

    const printerTypeOptions = [
      {"key": "Bluetooth", "value": "bluetooth"},
      {"key": "USB", "value": "usb"},
    ];

    return Scaffold(
      backgroundColor: bgColor,
      appBar: CustomAppBar(
        leading: IconButton(
          onPressed: () => context.pop(),
          icon: const Icon(LucideIcons.arrowLeft),
        ),
        title: PrinterScreenLocale.printerTitle.getString(context),
      ),
      body: RefreshIndicator(
        onRefresh: _onRefresh,
        child: SingleChildScrollView(
          // content တိုရင်လည်း pull လို့ရအောင်
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (_isRefreshing) ...[
                const LinearProgressIndicator(minHeight: 2),
                const SizedBox(height: 8),
              ],

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

              // ---- Printer type + search ----
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
                        key: ValueKey('type_$_resetCount'),
                        placeholder: Text(
                          PrinterScreenLocale.printerTypePlaceholder.getString(
                            context,
                          ),
                        ),
                        options: printerTypeOptions
                            .map(
                              (item) => ShadOption(
                                value: item["value"]!,
                                child: Text(item["key"]!),
                              ),
                            )
                            .toList(),
                        selectedOptionBuilder: (context, value) {
                          final item = printerTypeOptions.firstWhereOrNull(
                            (e) => e["value"] == value,
                          );
                          return Text(item?["key"] ?? value);
                        },
                        onChanged: (value) {
                          setState(() => printerType = value ?? "");
                          if (value == "usb") {
                            ref
                                .read(printerProvider.notifier)
                                .search(PrinterType.usb);
                          }
                        },
                      ),
                    ),
                    const SizedBox(width: 10),
                    if (printerState.isLoading)
                      Expanded(flex: 1, child: _loading())
                    else if (printerType == "bluetooth")
                      Expanded(
                        flex: 1,
                        child: customButton(
                          horizontal: 15,
                          vertical: 10,
                          label: PrinterScreenLocale.printerSearchButton
                              .getString(context),
                          isDark: isDark,
                          gradient: true,
                          onTap: () {
                            setState(() => _connectedFromSaved = false);
                            ref
                                .read(printerProvider.notifier)
                                .search(PrinterType.bluetooth);
                            showDialog(
                              context: context,
                              builder: (_) => const PrinterListDialog(),
                            );
                          },
                        ),
                      ),
                  ],
                ),
              ),

              // ---- Found USB printers ----
              if (printerType == "usb" &&
                  printerState.printers != null &&
                  printerState.printers!.isNotEmpty) ...[
                customGap(height: 10),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 10.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        PrinterScreenLocale.printerFoundUsbPrinters.getString(
                          context,
                        ),
                        style: TextStyle(
                          color: labelColor,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 5),
                      ...printerState.printers!.map((printer) {
                        final key =
                            'usb_${printer.vendorId}_${printer.productId}';
                        final connecting = _connectingKey == key;
                        final connected = _isSameConnected(
                          printerState,
                          vendorId: printer.vendorId,
                          productId: printer.productId,
                        );

                        return ListTile(
                          dense: true,
                          contentPadding: EdgeInsets.zero,
                          title: Text(printer.name),
                          subtitle: Text(printer.vendorId ?? ""),
                          trailing: connecting
                              ? _loading()
                              : connected
                              ? _connectedBadge()
                              : GradientSubmitButton(
                                  width: 140,
                                  text: PrinterScreenLocale.printerConnect
                                      .getString(context),
                                  onPressed: () => _connect(
                                    key: key,
                                    type: PrinterType.usb,
                                    printer: Printer(
                                      address: printer.id.toString(),
                                      isConnected: printer.isConnected,
                                      connectionType: ConnectionType.USB,
                                      name: printer.name,
                                      productId: printer.productId,
                                      vendorId: printer.vendorId,
                                    ),
                                  ),
                                ),
                        );
                      }),
                    ],
                  ),
                ),
              ],

              customGap(height: 10),

              // ---- Connected device info + paper size ----
              // Type ရွေးပြီး search ကနေ ချိတ်ထားမှပဲ ပြမယ်
              if (printerState.isConnected &&
                  printerType.isNotEmpty &&
                  !_connectedFromSaved) ...[
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 10.0),
                  child: _connectedBadge(),
                ),
                customGap(height: 6),
                _row(
                  PrinterScreenLocale.printerDeviceName.getString(context),
                  printerState.connectedPrinter?.name ?? "",
                ),
                _row(
                  PrinterScreenLocale.printerDeviceAddress.getString(context),
                  printerState.connectedPrinter?.address ?? "",
                ),
                _row("Paper size", printerPaperSize),
                customGap(height: 6),
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
                          key: ValueKey('paper_$_resetCount'),
                          initialValue: printerPaperSize.isEmpty
                              ? null
                              : printerPaperSize,
                          placeholder: Text(
                            PrinterScreenLocale.printerPaperSizePlaceholder
                                .getString(context),
                          ),
                          options: const [
                            ShadOption(value: "58mm", child: Text("58mm")),
                            ShadOption(value: "72mm", child: Text("72mm")),
                            ShadOption(value: "80mm", child: Text("80mm")),
                          ],
                          selectedOptionBuilder: (context, value) =>
                              Text(value),
                          onChanged: (value) {
                            if (value == null) return;
                            setState(() => printerPaperSize = value);
                            ref
                                .read(printerProvider.notifier)
                                .changePrinterDevicePaperSize(value);
                          },
                        ),
                      ),
                    ],
                  ),
                ),
                customGap(height: 10),
              ],

              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10),
                child: ShadCheckbox(
                  value: setDefault,
                  onChanged: (value) => setState(() => setDefault = value),
                  label: Text(
                    PrinterScreenLocale.printerSetAsDefault.getString(context),
                  ),
                ),
              ),

              customGap(height: 10),

              customButton(
                label: PrinterScreenLocale.printerTest.getString(context),
                isDark: isDark,
                gradient: true,
                onTap: () async {
                  final type = printerState.connectedPrinterType;
                  if (printerState.connectedPrinter == null || type == null) {
                    return;
                  }
                  final bytes = await testTicket();
                  ref.read(printerProvider.notifier).printTest(type, bytes);
                },
              ),

              customGap(height: 15),

              customButton(
                label: PrinterScreenLocale.printerSave.getString(context),
                isDark: isDark,
                gradient: true,
                onTap: () => _savePrinter(printerState),
              ),

              customGap(height: 20),

              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10.0),
                child: customLabel(
                  context,
                  PrinterScreenLocale.printerSavedPrinters,
                  labelColor,
                ),
              ),

              customGap(height: 5),

              // ---- Saved printers ----
              if (_isRefreshing)
                Padding(
                  padding: const EdgeInsets.all(20),
                  child: Center(child: _loading()),
                )
              else if (listOfPrinters.isEmpty)
                Padding(
                  padding: const EdgeInsets.all(10),
                  child: Text(
                    PrinterScreenLocale.printerNoPrinterFound.getString(
                      context,
                    ),
                    style: TextStyle(color: labelColor.withOpacity(0.6)),
                  ),
                )
              else
                ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: listOfPrinters.length,
                  itemBuilder: (context, index) {
                    final printer = listOfPrinters[index];
                    final key = 'saved_${printer.id}';
                    final connecting = _connectingKey == key;
                    final connected = _isSameConnected(
                      printerState,
                      address: printer.address,
                      vendorId: printer.vendorId,
                      productId: printer.productId,
                    );

                    return Card(
                      margin: const EdgeInsets.symmetric(vertical: 6),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 4),
                        child: ListTile(
                          leading: Icon(
                            printer.type == PrinterTypeByTable.bluetooth
                                ? LucideIcons.bluetooth
                                : LucideIcons.usb,
                            color: connected ? kGreen : labelColor,
                          ),
                          title: Text(
                            printer.name,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(fontWeight: FontWeight.w600),
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
                                "${printer.address ?? "-"}  •  ${printer.paperSize}",
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 6),
                              if (connecting)
                                _loading()
                              else if (connected)
                                Row(
                                  children: [
                                    _connectedBadge(),
                                    const SizedBox(width: 12),
                                    GestureDetector(
                                      onTap: () =>
                                          PrinterUiHelper.disconnectPrinter(
                                            context: context,
                                            ref: ref,
                                          ),
                                      child: Text(
                                        PrinterScreenLocale.printerDisconnected
                                            .getString(context),
                                        style: const TextStyle(
                                          color: Colors.red,
                                        ),
                                      ),
                                    ),
                                  ],
                                )
                              else
                                InkWell(
                                  onTap: () => _connect(
                                    key: key,
                                    type: printer.type.toDomain(),
                                    printer: _toPlugin(printer),
                                    paperSize: printer.paperSize,
                                  ),
                                  child: Text(
                                    PrinterScreenLocale.printerConnect
                                        .getString(context),
                                    style: const TextStyle(color: Colors.blue),
                                  ),
                                ),
                            ],
                          ),
                          trailing: IconButton(
                            icon: const Icon(LucideIcons.trash2, color: kRed),
                            onPressed: () => _deletePrinter(printer.id),
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
