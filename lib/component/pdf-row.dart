import 'package:pdf/widgets.dart' as pw;

pw.Widget pdfRow(String label, String value, color, {bool bold = false}) {
  return pw.Padding(
    padding: const pw.EdgeInsets.symmetric(vertical: 4),
    child: pw.Row(
      children: [
        pw.Expanded(
          child: pw.Text(
            label,
            style: pw.TextStyle(fontSize: 11, color: color),
          ),
        ),
        pw.Text(
          value,
          style: pw.TextStyle(
            fontSize: 11,
            fontWeight: bold ? pw.FontWeight.bold : pw.FontWeight.normal,
          ),
        ),
      ],
    ),
  );
}
