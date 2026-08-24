import 'package:pos/features/printer/domain/enums/printer-type.dart';

class PrinterDevice {
  final String id;
  final String name;
  final String? address;
  final bool isConnected;
  final String paperSize;
  final bool setDefault;
  final PrinterType? type;

  const PrinterDevice({
    required this.id,
    required this.name,
    this.type,
    this.paperSize = "58mm",
    this.address,
    this.setDefault = false,
    this.isConnected = false,
  });

  PrinterDevice copyWith({
    String? id,
    String? name,
    String? address,
    bool? isConnected,
    String? paperSize,
    bool? setDefault,
    PrinterType? type,
  }) {
    return PrinterDevice(
      id: id ?? this.id,
      name: name ?? this.name,
      address: address ?? this.address,
      isConnected: isConnected ?? this.isConnected,
      paperSize: paperSize ?? this.paperSize,
      setDefault: setDefault ?? this.setDefault,
      type: type ?? this.type,
    );
  }
}
