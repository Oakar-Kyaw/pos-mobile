import 'dart:ui' as ui;
import 'dart:typed_data';
import 'package:flutter/material.dart';

Future<Uint8List> myanmarTextToImage(
  String text, {
  double fontSize = 20,
  Color color = Colors.black,
  FontWeight fontWeight = FontWeight.normal,
}) async {
  final textPainter = TextPainter(
    text: TextSpan(
      text: text,
      style: TextStyle(
        fontSize: fontSize * 2,
        color: color,
        fontWeight: fontWeight,
        fontFamily: 'Pyidaungsu',
      ),
    ),
    textDirection: TextDirection.ltr,
  )..layout();

  final recorder = ui.PictureRecorder();
  final canvas = Canvas(recorder);
  textPainter.paint(canvas, Offset.zero);
  final picture = recorder.endRecording();
  final image = await picture.toImage(
    textPainter.width.ceil(),
    textPainter.height.ceil(),
  );
  final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
  return byteData!.buffer.asUint8List();
}
