import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:image/image.dart' as img;
import 'package:esc_pos_utils_plus/esc_pos_utils_plus.dart';

bool needsImageRender(String text) => text.codeUnits.any((c) => c > 255);

int paperWidthPx(PaperSize paperSize) {
  switch (paperSize) {
    case PaperSize.mm58:
      return 384;
    case PaperSize.mm80:
    default:
      return 576;
  }
}

Future<img.Image> textToImage(
  String text, {
  required double maxWidth,
  double fontSize = 22,
  bool bold = false,
  TextAlign textAlign = TextAlign.left,
}) async {
  final painter = TextPainter(
    text: TextSpan(
      text: text,
      style: TextStyle(
        color: Colors.black,
        fontSize: fontSize,
        fontWeight: bold ? FontWeight.bold : FontWeight.normal,
        fontFamily: 'Padauk', // Swapped to Padauk for a naturally tight layout
      ),
    ),
    textAlign: textAlign,
    textDirection: TextDirection.ltr,
  )..layout(maxWidth: maxWidth);

  final recorder = ui.PictureRecorder();
  final canvas = Canvas(
    recorder,
    Rect.fromLTWH(0, 0, maxWidth, painter.height),
  );

  canvas.drawRect(
    Rect.fromLTWH(0, 0, maxWidth, painter.height),
    Paint()..color = Colors.white,
  );
  painter.paint(canvas, Offset.zero);

  final picture = recorder.endRecording();
  final uiImage = await picture.toImage(maxWidth.ceil(), painter.height.ceil());
  final byteData = await uiImage.toByteData(format: ui.ImageByteFormat.png);
  return img.decodeImage(byteData!.buffer.asUint8List())!;
}

Future<List<int>> printLine(
  Generator generator,
  PaperSize paperSize,
  String text, {
  PosStyles styles = const PosStyles(),
}) async {
  if (text.isEmpty) return [];
  if (!needsImageRender(text)) {
    return generator.text(text, styles: styles);
  }
  final totalWidth = paperWidthPx(paperSize).toDouble();
  final image = await textToImage(
    text,
    maxWidth: totalWidth,
    fontSize: styles.height == PosTextSize.size2 ? 40 : 26,
    bold: styles.bold,
    textAlign: styles.align == PosAlign.center
        ? TextAlign.center
        : styles.align == PosAlign.right
        ? TextAlign.right
        : TextAlign.left,
  );
  return generator.image(image, align: styles.align);
}

class RowCol {
  final String text;
  final int width;
  final PosAlign align;
  final bool bold;
  final PosTextSize height;

  const RowCol({
    required this.text,
    required this.width,
    this.align = PosAlign.left,
    this.bold = false,
    this.height = PosTextSize.size1,
  });
}

Future<List<int>> printRow(
  Generator generator,
  PaperSize paperSize,
  List<RowCol> cols,
) async {
  final anyImage = cols.any((c) => needsImageRender(c.text));

  if (!anyImage) {
    return generator.row(
      cols
          .map(
            (c) => PosColumn(
              text: c.text,
              width: c.width,
              styles: PosStyles(
                align: c.align,
                bold: c.bold,
                height: c.height,
                width: c.height,
              ),
            ),
          )
          .toList(),
    );
  }

  final totalWidth = paperWidthPx(paperSize).toDouble();
  final singleGridSegment = totalWidth / 12.0;

  final painters = <TextPainter>[];
  double calculatedMaxRowHeight = 0.0;

  for (final col in cols) {
    final allowedColWidth = singleGridSegment * col.width;
    final double computedFontSize = col.height == PosTextSize.size2 ? 38 : 24;

    final painter = TextPainter(
      text: TextSpan(
        text: col.text,
        style: TextStyle(
          color: Colors.black,
          fontSize: computedFontSize,
          fontWeight: col.bold ? FontWeight.bold : FontWeight.normal,
          fontFamily: 'Padauk', // Swapped to Padauk here as well
        ),
      ),
      textAlign: col.align == PosAlign.right
          ? TextAlign.right
          : col.align == PosAlign.center
          ? TextAlign.center
          : TextAlign.left,
      textDirection: TextDirection.ltr,
    )..layout(maxWidth: allowedColWidth);

    painters.add(painter);

    if (painter.height > calculatedMaxRowHeight) {
      calculatedMaxRowHeight = painter.height;
    }
  }

  final recorder = ui.PictureRecorder();
  final canvas = Canvas(
    recorder,
    Rect.fromLTWH(0, 0, totalWidth, calculatedMaxRowHeight),
  );

  canvas.drawRect(
    Rect.fromLTWH(0, 0, totalWidth, calculatedMaxRowHeight),
    Paint()..color = Colors.white,
  );

  double currentGridXOffset = 0.0;

  for (int i = 0; i < cols.length; i++) {
    final col = cols[i];
    final painter = painters[i];
    final allowedColWidth = singleGridSegment * col.width;

    double paintXPosition;
    if (col.align == PosAlign.right) {
      paintXPosition = currentGridXOffset + (allowedColWidth - painter.width);
    } else if (col.align == PosAlign.center) {
      paintXPosition =
          currentGridXOffset + ((allowedColWidth - painter.width) / 2);
    } else {
      paintXPosition = currentGridXOffset;
    }

    // Vertically center align text lines cleanly inside the compact Padauk row height
    double paintYPosition = (calculatedMaxRowHeight - painter.height) / 2;

    painter.paint(canvas, Offset(paintXPosition, paintYPosition));
    currentGridXOffset += allowedColWidth;
  }

  final picture = recorder.endRecording();
  final uiImage = await picture.toImage(
    totalWidth.ceil(),
    calculatedMaxRowHeight.ceil(),
  );
  final byteData = await uiImage.toByteData(format: ui.ImageByteFormat.png);
  final image = img.decodeImage(byteData!.buffer.asUint8List())!;

  return generator.image(image, align: PosAlign.left);
}

String truncateText(String text, int maxLength) {
  if (text.length <= maxLength) return text;
  return '${text.substring(0, maxLength - 1)}…';
}

String formatAmount(double value) {
  if (value % 1 == 0) {
    return value.toInt().toString();
  } else {
    return value.toStringAsFixed(2);
  }
}
