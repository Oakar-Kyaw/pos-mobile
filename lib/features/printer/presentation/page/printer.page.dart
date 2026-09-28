// import 'dart:async';

// import 'package:collection/collection.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_localization/flutter_localization.dart';
// import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'package:flutter_thermal_printer/flutter_thermal_printer.dart';
// import 'package:flutter_thermal_printer/utils/printer.dart';
// import 'package:go_router/go_router.dart';
// import 'package:pos/component/app-bar.dart';
// import 'package:pos/component/loading-component.dart';
// import 'package:pos/core/database/printer-table-schema.dart';
// import 'package:pos/core/widgets/custom-button.dart';
// import 'package:pos/core/widgets/input.dart';
// import 'package:pos/features/printer/data/datasource/printer-local-datasource.dart';
// import 'package:pos/features/printer/domain/entites/printer-device.dart';
// import 'package:pos/features/printer/domain/entites/printer-state.dart';
// import 'package:pos/features/printer/domain/enums/printer-type.dart';
// import 'package:pos/features/printer/presentation/printer-helper.dart';
// import 'package:pos/features/printer/presentation/provider/printer-provider.dart';
// import 'package:pos/features/printer/presentation/widget/printer-list.dart';
// import 'package:pos/localization/printer-local.dart';
// import 'package:pos/utils/app-theme.dart';
// import 'package:pos/utils/shad-toaster.dart';
// import 'package:shadcn_ui/shadcn_ui.dart';
// import 'package:thermal_unicode_print/thermal_unicode_print.dart';

// class PrinterPage extends ConsumerStatefulWidget {
//   const PrinterPage({super.key});

//   @override
//   ConsumerState<PrinterPage> createState() => _PrinterPageState();
// }

// class _PrinterPageState extends ConsumerState<PrinterPage> {
//   final _printerNameController = TextEditingController();
//   PrinterTableItem? initialPrinter;
//   String printerType = "";
//   String printerPaperSize = "";
//   bool setDefault = false;
//   final datasource = PrinterLocalDatabaseSource();
//   List<PrinterTableItem> listOfPrinters = [];
//   // State သို့မဟုတ် Page အပေါ်ဆုံးတွင် ခေတ္တကြေညာပေးရန်
//   StreamSubscription<List<Printer>>? _devicesStreamSubscription;
//   List<Printer> scannedPrinters = [];

//   @override
//   void initState() {
//     super.initState();
//     WidgetsBinding.instance.addPostFrameCallback((_) {
//       _getSavedPrinters();
//     });
//   }

//   @override
//   void dispose() {
//     _devicesStreamSubscription?.cancel();
//     _printerNameController.dispose();
//     super.dispose();
//   }

//   void search() async {
//     try {
//       await _devicesStreamSubscription?.cancel();

//       // Stream ကို စောင့်နားထောင်ရုံသာ လုပ်ပါ (Auto-connect ကို ဖယ်ထုတ်လိုက်ပါ)
//       _devicesStreamSubscription = FlutterThermalPrinter.instance.devicesStream
//           .listen((List<Printer> event) {
//             setState(() {
//               scannedPrinters = event;
//             });
//             debugPrint("USB Printers found: 📱 ${event.length} devices");
//           });

//       // USB စကင်ဖတ်ရန် တောင်းဆိုပါ
//       await FlutterThermalPrinter.instance.getPrinters(
//         connectionTypes: [ConnectionType.USB],
//       );
//     } catch (e) {
//       debugPrint("စကင်ဖတ်ရာတွင် အမှားအယွင်းရှိပါသည်: $e");
//     }
//   }

//   Future<void> connectToDevice(Printer device) async {
//     try {
//       debugPrint("Printer connect $device");
//       // Connect natively through the plugin using the extracted device metadata
//       final isConnected = await FlutterThermalPrinter.instance.connect(device);

//       if (isConnected) {
//         debugPrint(
//           "🎉 Connected successfully to: ${device.name} at ${device.address}",
//         );

//         // Push the active device data into your Riverpod state notifier framework
//         ref
//             .read(printerProvider.notifier)
//             .connect(
//               PrinterType.usb, // Maps to your domain's local configuration type
//               PrinterDevice(
//                 id: device.address ?? device.name ?? 'usb_device',
//                 name: device.name ?? 'NS03 Model Printer',
//                 type: PrinterType.usb,
//                 paperSize: printerPaperSize.isEmpty ? "58mm" : printerPaperSize,
//                 address: device.address ?? '',
//                 setDefault: setDefault,
//                 isConnected: true,
//               ),
//             );

//         if (!mounted) return;
//         ShowToast(
//           context,
//           isError: false,
//           description: const Text(
//             "Printer ချိတ်ဆက်မှု အောင်မြင်ပါသည်",
//             style: TextStyle(color: kGreen),
//           ),
//         );
//       } else {
//         throw Exception("Natively returned connection status: false");
//       }
//     } catch (e) {
//       debugPrint("ချိတ်ဆက်မှု မအောင်မြင်ပါ: $e");
//       if (!mounted) return;
//       ShowToast(
//         context,
//         isError: true,
//         description: Text(
//           "Printer ချိတ်ဆက်မှု မအောင်မြင်ပါ: $e",
//           style: TextStyle(color: kRed),
//         ),
//       );
//     }
//   }

//   Future<List<int>> testTicket() async {
//     final profile = await CapabilityProfile.load();
//     final paperSize = printerPaperSize.isEmpty
//         ? PaperSize.mm58
//         : printerPaperSize == "58mm"
//         ? PaperSize.mm58
//         : printerPaperSize == "72mm"
//         ? PaperSize.mm72
//         : printerPaperSize == "80mm"
//         ? PaperSize.mm80
//         : PaperSize.mm58;
//     final generator = Generator(paperSize, profile);

//     // Initialize the renderer: 384 dots for 58mm paper size
//     const renderer = ThermalUnicodeRenderer(dotsWidth: 384);
//     const TextStyle titleStyle = TextStyle(
//       fontFamily: 'NotoSerif',
//       fontSize: 30,
//       fontWeight: FontWeight.bold,
//     );
//     List<int> bytes = [];
//     const EdgeInsets cellPadding = EdgeInsets.symmetric(vertical: 1.0);

//     // Reset printer
//     bytes += generator.reset();
//     bytes += await renderer.textLine(
//       generator,
//       "Hello Customer, Nice to meet you",
//       align: TextAlign.center,
//       style: titleStyle,
//       padding: cellPadding,
//     );
//     bytes += await renderer.divider(
//       generator,
//       thickness: 1.0,
//       verticalPadding: 2.0,
//     );

//     bytes += await renderer.textLine(
//       generator,
//       "တွေ့ရတာ ဝမ်းသာပါတယ်",
//       align: TextAlign.center,
//       style: titleStyle,
//       padding: cellPadding,
//     );

//     return bytes;
//   }

//   Future<void> savePrinter(
//     BuildContext context,
//     PrinterState printerState,
//   ) async {
//     final valid = checkValidation(context, printerState);

//     if (!valid) return;

//     await _savePrinter(context, printerState);
//   }

//   bool checkValidation(BuildContext context, PrinterState printerState) {
//     if (_printerNameController.text.isEmpty) {
//       ShowToast(
//         context,
//         isError: true,
//         description: Text(
//           PrinterScreenLocale.printerNameRequired.getString(context),
//           style: TextStyle(color: kRed),
//         ),
//       );
//       return false;
//     }

//     if (printerType.isEmpty) {
//       ShowToast(
//         context,
//         isError: true,
//         description: Text(
//           PrinterScreenLocale.printerTypeRequired.getString(context),
//           style: TextStyle(color: kRed),
//         ),
//       );
//       return false;
//     }

//     if (printerState.connectedPrinter == null) {
//       ShowToast(
//         context,
//         isError: true,
//         description: Text(
//           PrinterScreenLocale.printerConnectRequired.getString(context),
//           style: TextStyle(color: kRed),
//         ),
//       );
//       return false;
//     }

//     if (printerPaperSize.isEmpty) {
//       ShowToast(
//         context,
//         isError: true,
//         description: Text(
//           PrinterScreenLocale.printerPaperSizeRequired.getString(context),
//           style: TextStyle(color: kRed),
//         ),
//       );
//       return false;
//     }

//     return true;
//   }

//   Future<void> _savePrinter(BuildContext context, PrinterState printer) async {
//     try {
//       final connectedPrinter = printer.connectedPrinter!;
//       final newPrinter = PrinterTableItem(
//         id: 0,
//         name: _printerNameController.text,
//         address: connectedPrinter.address,
//         isConnected: connectedPrinter.isConnected,
//         type: PrinterTypeByTable.fromValue(printerType),
//         setDefault: setDefault,
//         paperSize: printerPaperSize,
//         deviceName: connectedPrinter.name,
//       );
//       await datasource.insert(newPrinter);
//       if (!context.mounted) return;
//       ShowToast(
//         context,
//         isError: false,
//         description: Text(
//           PrinterScreenLocale.printerSaveSuccess.getString(context),
//           style: TextStyle(color: kGreen),
//         ),
//       );
//       ref.read(printerProvider.notifier).clearPrinters();
//       Navigator.pop(context);
//     } catch (e) {
//       if (!context.mounted) return;
//       ShowToast(
//         context,
//         isError: true,
//         description: Text(
//           PrinterScreenLocale.printerSaveFailed.getString(context),
//           style: TextStyle(color: kRed),
//         ),
//       );
//     }
//   }

//   Future<void> _getSavedPrinters() async {
//     try {
//       final printers = await datasource.getAll();
//       final initialPrinter = printers.firstWhereOrNull((e) => e.setDefault);

//       print("printers are: ${initialPrinter} ");
//       setState(() {
//         listOfPrinters = printers;
//       });
//       if (initialPrinter == null) return;
//       ref
//           .read(printerProvider.notifier)
//           .connect(
//             initialPrinter.type.toDomain(),
//             PrinterDevice(
//               id: initialPrinter.id.toString(),
//               name: initialPrinter.name,
//               type: initialPrinter.type.toDomain(),
//               paperSize: initialPrinter.paperSize,
//               address: initialPrinter.address,
//               setDefault: initialPrinter.setDefault,
//               isConnected: initialPrinter.isConnected,
//             ),
//           );
//     } catch (e) {}
//   }

//   Future<void> _deletePrinter(BuildContext context, int id) async {
//     try {
//       await datasource.delete(id);
//       await _getSavedPrinters(); // list ကို refresh
//     } catch (e) {
//       if (!context.mounted) return;
//       ShowToast(
//         context,
//         isError: true,
//         description: Text(
//           PrinterScreenLocale.printerDeleteFailed.getString(context),
//           style: TextStyle(color: kRed),
//         ),
//       );
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     final isDark = ref.watch(themeModeProvider) == ThemeMode.dark;
//     final bgColor = isDark ? kBgDark : kBgLight;
//     //final subColor = isDark ? kTextSubDark : kTextSubLight;
//     final labelColor = isDark ? kTextDark : kTextLight;
//     final printerState = ref.watch(printerProvider);
//     //print("🖨️ ${printerState.printers}");
//     return Scaffold(
//       backgroundColor: bgColor,
//       appBar: CustomAppBar(
//         leading: IconButton(
//           onPressed: () => context.pop(),
//           icon: const Icon(LucideIcons.arrowLeft),
//         ),
//         title: PrinterScreenLocale.printerTitle.getString(context),
//       ),
//       body: Padding(
//         padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
//         child: SingleChildScrollView(
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               customInput(
//                 context,
//                 label: PrinterScreenLocale.printerName,
//                 placeholder: PrinterScreenLocale.printerNamePlaceholder,
//                 controller: _printerNameController,
//                 labelColor: labelColor,
//               ),
//               customGap(),

//               Padding(
//                 padding: const EdgeInsets.symmetric(horizontal: 10.0),
//                 child: customLabel(
//                   context,
//                   PrinterScreenLocale.printerType,
//                   labelColor,
//                 ),
//               ),

//               ///printer type
//               Padding(
//                 padding: const EdgeInsets.symmetric(
//                   horizontal: 10,
//                   vertical: 5,
//                 ),
//                 child: Row(
//                   children: [
//                     Expanded(
//                       flex: 2,
//                       child: ShadSelect<String>(
//                         placeholder: Text(
//                           PrinterScreenLocale.printerTypePlaceholder.getString(
//                             context,
//                           ),
//                         ),
//                         options:
//                             [
//                                   {"key": "Bluetooth", "value": "bluetooth"},
//                                   // {"key": "USB", "value": "usb"},
//                                   // {"key": "Ethernet", "value": "ethernet"},
//                                 ]
//                                 .map(
//                                   (item) => ShadOption(
//                                     value: item["value"]!,
//                                     child: Text(item["key"]!),
//                                   ),
//                                 )
//                                 .toList(),
//                         selectedOptionBuilder: (context, value) => Text(value),
//                         onChanged: (value) {
//                           print("value of printer is $value");
//                           setState(() {
//                             printerType = value ?? "";
//                           });
//                         },
//                       ),
//                     ),
//                     const SizedBox(width: 10),

//                     printerState.isLoading
//                         ? Expanded(
//                             flex: 1,
//                             child: SizedBox(
//                               height: 22,
//                               width: 1,
//                               child: LoadingWidget(),
//                             ),
//                           )
//                         :
//                           //if printer type is bluetooth . show bluetooth search
//                           printerType == "bluetooth"
//                         ? Expanded(
//                             flex: 1,
//                             child: customButton(
//                               horizontal: 15,
//                               vertical: 10,
//                               label: PrinterScreenLocale.printerSearchButton
//                                   .getString(context),
//                               isDark: isDark,
//                               gradient: true,
//                               onTap: () {
//                                 ref
//                                     .read(printerProvider.notifier)
//                                     .search(PrinterType.bluetooth);
//                                 showDialog(
//                                   context: context,
//                                   builder: (context) => PrinterListDialog(),
//                                 );
//                               },
//                             ),
//                           )
//                         : Container(),
//                   ],
//                 ),
//               ),
//               customGap(height: 10),
//               //device name
//               printerState.isConnected && printerState.showDeviceNameAndAddress
//                   ? Padding(
//                       padding: const EdgeInsets.symmetric(horizontal: 10.0),
//                       child: Row(
//                         children: [
//                           Text(
//                             "${PrinterScreenLocale.printerDeviceName.getString(context)}: ",
//                             style: TextStyle(fontWeight: FontWeight.bold),
//                           ),
//                           Expanded(
//                             child: Text(
//                               printerState.connectedPrinter?.name ?? "",
//                               overflow: TextOverflow.ellipsis,
//                               maxLines: 1,
//                             ),
//                           ),
//                         ],
//                       ),
//                     )
//                   : const SizedBox(),
//               printerState.isConnected && printerState.showDeviceNameAndAddress
//                   ? customGap(height: 10)
//                   : const SizedBox(),
//               //device address
//               printerState.isConnected && printerState.showDeviceNameAndAddress
//                   ? Padding(
//                       padding: const EdgeInsets.symmetric(horizontal: 10.0),
//                       child: Row(
//                         children: [
//                           Text(
//                             "${PrinterScreenLocale.printerDeviceAddress.getString(context)}: ",
//                             style: TextStyle(fontWeight: FontWeight.bold),
//                           ),
//                           Expanded(
//                             child: Text(
//                               printerState.connectedPrinter?.address ?? "",
//                               overflow: TextOverflow.ellipsis,
//                               maxLines: 1,
//                             ),
//                           ),
//                         ],
//                       ),
//                     )
//                   : const SizedBox(),
//               printerState.isConnected && printerState.showDeviceNameAndAddress
//                   ? customGap(height: 10)
//                   : const SizedBox(),
//               //for papersize (only printerState is connected)
//               printerState.isConnected && printerState.showDeviceNameAndAddress
//                   ? Padding(
//                       padding: const EdgeInsets.symmetric(
//                         horizontal: 10,
//                         vertical: 5,
//                       ),
//                       child: Row(
//                         children: [
//                           Expanded(
//                             flex: 2,
//                             child: ShadSelect<String>(
//                               placeholder: Text(
//                                 PrinterScreenLocale.printerPaperSizePlaceholder
//                                     .getString(context),
//                               ),
//                               options:
//                                   [
//                                         {"key": "58mm", "value": "58mm"},
//                                         {"key": "72mm", "value": "72mm"},
//                                         {"key": "80mm", "value": "80mm"},
//                                       ]
//                                       .map(
//                                         (item) => ShadOption(
//                                           value: item["value"]!,
//                                           child: Text(item["key"]!),
//                                         ),
//                                       )
//                                       .toList(),
//                               selectedOptionBuilder: (context, value) =>
//                                   Text(value),
//                               onChanged: (value) {
//                                 print("size of printer is $value");
//                                 if (value == null) return;
//                                 setState(() {
//                                   printerPaperSize = value;
//                                 });
//                                 ref
//                                     .read(printerProvider.notifier)
//                                     .changePrinterDevicePaperSize(value);
//                               },
//                             ),
//                           ),
//                         ],
//                       ),
//                     )
//                   : const SizedBox(),
//               printerState.isConnected && printerState.showDeviceNameAndAddress
//                   ? customGap(height: 10)
//                   : const SizedBox(),
//               Padding(
//                 padding: const EdgeInsets.symmetric(horizontal: 10),
//                 child: ShadCheckbox(
//                   value: setDefault,
//                   onChanged: (value) => setState(() {
//                     setDefault = value;
//                   }),
//                   label: Text(
//                     PrinterScreenLocale.printerSetAsDefault.getString(context),
//                   ),
//                 ),
//               ),
//               customGap(height: 10),
//               customButton(
//                 label: PrinterScreenLocale.printerConnect.getString(context),
//                 isDark: isDark,
//                 gradient: true,
//                 onTap: () async => search(),
//               ),
//               customGap(height: 10),
//               customButton(
//                 label: PrinterScreenLocale.printerSavedPrinters.getString(
//                   context,
//                 ),
//                 isDark: isDark,
//                 gradient: true,
//                 onTap: () async => search(),
//               ),
//               customGap(height: 10),
//               customButton(
//                 label: PrinterScreenLocale.printerSavedPrinters.getString(
//                   context,
//                 ),
//                 isDark: isDark,
//                 gradient: true,
//                 onTap: () async => savePrinter(context, printerState),
//               ),
//               customGap(height: 10),
//               customButton(
//                 label: PrinterScreenLocale.printerTest.getString(context),
//                 isDark: isDark,
//                 gradient: true,
//                 onTap: () async {
//                   if (printerState.connectedPrinter == null) return;
//                   print(
//                     " Testing Printer ${printerState.connectedPrinterType}",
//                   );
//                   final type = printerState.connectedPrinterType!;
//                   final bytes = await testTicket();
//                   final success = await ref
//                       .read(printerProvider.notifier)
//                       .printTest(type, bytes);
//                   print("test print is : $success");
//                 },
//               ),
//               customGap(height: 15),
//               // ─── Saved Printers List ───
//               Padding(
//                 padding: const EdgeInsets.symmetric(horizontal: 10.0),
//                 child: customLabel(
//                   context,
//                   PrinterScreenLocale.printerSavedPrinters,
//                   labelColor,
//                 ),
//               ),
//               customGap(height: 5),
//               listOfPrinters.isEmpty
//                   ? Padding(
//                       padding: const EdgeInsets.all(10),
//                       child: Text(
//                         PrinterScreenLocale.printerNoPrinterFound.getString(
//                           context,
//                         ),
//                         style: TextStyle(color: labelColor.withOpacity(0.6)),
//                       ),
//                     )
//                   : ListView.builder(
//                       shrinkWrap: true,
//                       physics: const NeverScrollableScrollPhysics(),
//                       itemCount: listOfPrinters.length,
//                       itemBuilder: (context, index) {
//                         final printer = listOfPrinters[index];
//                         bool isConnected =
//                             printerState.connectedPrinter?.address ==
//                             printer.address;

//                         return Card(
//                           margin: const EdgeInsets.symmetric(vertical: 6),
//                           child: Padding(
//                             padding: const EdgeInsets.symmetric(vertical: 4),
//                             child: ListTile(
//                               leading: Icon(
//                                 printer.type == PrinterTypeByTable.bluetooth
//                                     ? LucideIcons.bluetooth
//                                     : LucideIcons.usb,
//                                 color: isConnected ? kGreen : labelColor,
//                               ),

//                               title: Text(
//                                 printer.name,
//                                 maxLines: 1,
//                                 overflow: TextOverflow.ellipsis,
//                                 style: const TextStyle(
//                                   fontWeight: FontWeight.w600,
//                                 ),
//                               ),

//                               subtitle: Column(
//                                 crossAxisAlignment: CrossAxisAlignment.start,
//                                 mainAxisSize: MainAxisSize.min,
//                                 children: [
//                                   Text(
//                                     printer.deviceName,
//                                     maxLines: 1,
//                                     overflow: TextOverflow.ellipsis,
//                                   ),

//                                   Text(
//                                     printer.address ?? "-",
//                                     maxLines: 1,
//                                     overflow: TextOverflow.ellipsis,
//                                   ),

//                                   const SizedBox(height: 6),

//                                   isConnected
//                                       ? Wrap(
//                                           spacing: 8,
//                                           runSpacing: 4,
//                                           crossAxisAlignment:
//                                               WrapCrossAlignment.center,
//                                           children: [
//                                             GestureDetector(
//                                               onTap: () {
//                                                 PrinterUiHelper.disconnectPrinter(
//                                                   context: context,
//                                                   ref: ref,
//                                                 );
//                                               },
//                                               child: Text(
//                                                 PrinterScreenLocale
//                                                     .printerDisconnected
//                                                     .getString(context),
//                                                 style: TextStyle(
//                                                   color: Colors.red,
//                                                 ),
//                                               ),
//                                             ),
//                                           ],
//                                         )
//                                       : InkWell(
//                                           onTap: () =>
//                                               PrinterUiHelper.connectPrinter(
//                                                 context: context,
//                                                 ref: ref,
//                                                 printerType: printer.type
//                                                     .toDomain(),
//                                                 printer: PrinterDevice(
//                                                   id: printer.id.toString(),
//                                                   name: printer.deviceName,
//                                                   isConnected:
//                                                       printer.isConnected,
//                                                   address: printer.address,
//                                                   paperSize: printer.paperSize,
//                                                   setDefault:
//                                                       printer.setDefault,
//                                                 ),
//                                               ),
//                                           child: Text(
//                                             PrinterScreenLocale.printerConnect
//                                                 .getString(context),
//                                             style: TextStyle(
//                                               color: Colors.blue,
//                                             ),
//                                           ),
//                                         ),
//                                 ],
//                               ),

//                               trailing: IconButton(
//                                 icon: const Icon(
//                                   LucideIcons.trash2,
//                                   color: kRed,
//                                 ),
//                                 onPressed: () =>
//                                     _deletePrinter(context, printer.id),
//                               ),
//                             ),
//                           ),
//                         );
//                       },
//                     ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }
import 'dart:async';

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
  final _printerPlugin = FlutterThermalPrinter.instance;

  StreamSubscription<List<Printer>>? _devicesStreamSubscription;
  List<Printer> scannedPrinters = [];
  Printer? selectedPrinter;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _getSavedPrinters();
    });
  }

  @override
  void dispose() {
    _devicesStreamSubscription?.cancel();
    _printerNameController.dispose();
    super.dispose();
  }

  void searchUsbPrinters() async {
    try {
      await _devicesStreamSubscription?.cancel();

      _devicesStreamSubscription = FlutterThermalPrinter.instance.devicesStream
          .listen((List<Printer> event) {
            if (!mounted) return;
            setState(() {
              scannedPrinters = event;
            });
            debugPrint("USB Printers found: 📱 ${event.length} devices");
          });

      await FlutterThermalPrinter.instance.getPrinters(
        connectionTypes: [ConnectionType.USB],
      );
    } catch (e) {
      debugPrint("စကင်ဖတ်ရာတွင် အမှားအယွင်းရှိပါသည်: $e");
    }
  }

  Future<void> connectToDevice(Printer device) async {
    try {
      debugPrint(
        "Connecting to USB device: ${device.name} "
        "(Address/VendorID: ${device.address})",
      );

      await _devicesStreamSubscription?.cancel();
      _devicesStreamSubscription = null;

      await Future.delayed(const Duration(milliseconds: 300));

      final isConnected = await FlutterThermalPrinter.instance.connect(device);

      if (isConnected ||
          device.isConnected == true ||
          device.vendorId != null) {
        debugPrint(
          "🎉 USB printer connected: "
          "${device.name}, vendorId=${device.vendorId}, "
          "productId=${device.productId}",
        );
        setState(() {
          selectedPrinter = device;
        });

        if (!mounted) return;
        printReceipt();
        ShowToast(
          context,
          isError: false,
          description: const Text(
            "USB Printer ချိတ်ဆက်မှု အောင်မြင်ပါသည်",
            style: TextStyle(color: kGreen),
          ),
        );

        return;
      }

      throw Exception("USB printer connection failed");
    } catch (e) {
      debugPrint("USB printer connection failed: $e");

      if (!mounted) return;

      ShowToast(
        context,
        isError: true,
        description: Text(
          "USB Printer ချိတ်ဆက်မှု မအောင်မြင်ပါ: $e",
          style: const TextStyle(color: kRed),
        ),
      );
    }
  }

  // STEP 3: Send data to print
  Future<void> printReceipt() async {
    if (selectedPrinter == null) {
      print("No printer connected!");
      return;
    }

    // Replace this list with your actual formatted ESC/POS bytes
    // (e.g. text converted using the esc_pos_utils package)
    List<int> bytesToPrint = [
      0x1B, 0x40, // Initialize printer
      ...'Hello World!\n\n\n'.codeUnits,
      0x1D, 0x56, 0x41, 0x00, // Paper cut command
    ];

    await _printerPlugin.printData(selectedPrinter!, bytesToPrint);
  }

  void stopScan() {
    _devicesStreamSubscription?.cancel();
  }

  Future<List<int>> testTicket() async {
    final profile = await CapabilityProfile.load();
    final paperSize = printerPaperSize == "72mm"
        ? PaperSize.mm72
        : printerPaperSize == "80mm"
        ? PaperSize.mm80
        : PaperSize.mm58;
    final generator = Generator(paperSize, profile);

    const renderer = ThermalUnicodeRenderer(dotsWidth: 384);
    const TextStyle titleStyle = TextStyle(
      fontFamily: 'NotoSerif',
      fontSize: 30,
      fontWeight: FontWeight.bold,
    );
    List<int> bytes = [];
    const EdgeInsets cellPadding = EdgeInsets.symmetric(vertical: 1.0);

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
    if (_printerNameController.text.trim().isEmpty) {
      ShowToast(
        context,
        isError: true,
        description: Text(
          PrinterScreenLocale.printerNameRequired.getString(context),
          style: const TextStyle(color: kRed),
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
          style: const TextStyle(color: kRed),
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
          style: const TextStyle(color: kRed),
        ),
      );
      return false;
    }

    if (printerPaperSize.isEmpty) {
      ShowToast(
        context,
        isError: true,
        description: Text(
          PrinterScreenLocale.printerPaperSizeRequired.getString(context),
          style: const TextStyle(color: kRed),
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
        name: _printerNameController.text.trim(),
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
          style: const TextStyle(color: kGreen),
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
          style: const TextStyle(color: kRed),
        ),
      );
    }
  }

  Future<void> _getSavedPrinters() async {
    try {
      final printers = await datasource.getAll();
      final initial = printers.firstWhereOrNull((e) => e.setDefault);

      if (!mounted) return;
      setState(() {
        listOfPrinters = printers;
      });

      if (initial == null) return;

      ref
          .read(printerProvider.notifier)
          .connect(
            initial.type.toDomain(),
            PrinterDevice(
              id: initial.id.toString(),
              name: initial.name,
              type: initial.type.toDomain(),
              paperSize: initial.paperSize,
              address: initial.address,
              setDefault: initial.setDefault,
              isConnected: initial.isConnected,
            ),
          );
    } catch (e) {
      debugPrint("Error fetching saved printers: $e");
    }
  }

  Future<void> _deletePrinter(BuildContext context, int id) async {
    try {
      await datasource.delete(id);
      await _getSavedPrinters();
    } catch (e) {
      if (!context.mounted) return;
      ShowToast(
        context,
        isError: true,
        description: Text(
          PrinterScreenLocale.printerDeleteFailed.getString(context),
          style: const TextStyle(color: kRed),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = ref.watch(themeModeProvider) == ThemeMode.dark;
    final bgColor = isDark ? kBgDark : kBgLight;
    final labelColor = isDark ? kTextDark : kTextLight;
    final printerState = ref.watch(printerProvider);

    final printerTypeOptions = [
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
                          setState(() {
                            printerType = value ?? "";
                          });

                          if (value == "usb") {
                            searchUsbPrinters();
                          }
                        },
                      ),
                    ),
                    const SizedBox(width: 10),
                    if (printerState.isLoading)
                      const Expanded(
                        flex: 1,
                        child: SizedBox(height: 22, child: LoadingWidget()),
                      )
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
                            ref
                                .read(printerProvider.notifier)
                                .search(PrinterType.bluetooth);

                            showDialog(
                              context: context,
                              builder: (context) => const PrinterListDialog(),
                            );
                          },
                        ),
                      ),
                  ],
                ),
              ),

              if (printerType == "usb" && scannedPrinters.isNotEmpty) ...[
                customGap(height: 10),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 10.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Found USB Printers:",
                        style: TextStyle(
                          color: labelColor,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 5),
                      ...scannedPrinters.map(
                        (device) => ListTile(
                          dense: true,
                          contentPadding: EdgeInsets.zero,
                          title: Text(device.name ?? "USB Device"),
                          subtitle: Text(device.address ?? ""),
                          trailing: ElevatedButton(
                            onPressed: () => connectToDevice(device),
                            child: const Text("Connect"),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],

              customGap(height: 10),

              if (printerState.isConnected &&
                  printerState.showDeviceNameAndAddress) ...[
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 10.0),
                  child: Row(
                    children: [
                      Text(
                        "${PrinterScreenLocale.printerDeviceName.getString(context)}: ",
                        style: const TextStyle(fontWeight: FontWeight.bold),
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
                ),

                customGap(height: 10),

                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 10.0),
                  child: Row(
                    children: [
                      Text(
                        "${PrinterScreenLocale.printerDeviceAddress.getString(context)}: ",
                        style: const TextStyle(fontWeight: FontWeight.bold),
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
                ),

                customGap(height: 10),

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
                ),

                customGap(height: 10),
              ],

              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10),
                child: ShadCheckbox(
                  value: setDefault,
                  onChanged: (value) => setState(() {
                    setDefault = value;
                  }),
                  label: Text(
                    PrinterScreenLocale.printerSetAsDefault.getString(context),
                  ),
                ),
              ),

              customGap(height: 15),

              customButton(
                label: PrinterScreenLocale.printerSaveSuccess.getString(
                  context,
                ),
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

                  final type = printerState.connectedPrinterType!;
                  final bytes = await testTicket();

                  await ref
                      .read(printerProvider.notifier)
                      .printTest(type, bytes);
                },
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

              listOfPrinters.isEmpty
                  ? Padding(
                      padding: const EdgeInsets.all(10),
                      child: Text(
                        PrinterScreenLocale.printerNoPrinterFound.getString(
                          context,
                        ),
                        style: TextStyle(color: labelColor.withOpacity(0.6)),
                      ),
                    )
                  : ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: listOfPrinters.length,
                      itemBuilder: (context, index) {
                        final printer = listOfPrinters[index];

                        final bool isConnected =
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
                                      ? GestureDetector(
                                          onTap: () {
                                            PrinterUiHelper.disconnectPrinter(
                                              context: context,
                                              ref: ref,
                                            );
                                          },
                                          child: Text(
                                            PrinterScreenLocale
                                                .printerDisconnected
                                                .getString(context),
                                            style: const TextStyle(
                                              color: Colors.red,
                                            ),
                                          ),
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
                                            PrinterScreenLocale.printerConnect
                                                .getString(context),
                                            style: const TextStyle(
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
