import 'package:flutter/material.dart';
import 'package:pos/utils/app-theme.dart';

class LoadingWidget extends StatelessWidget {
  final Color color;
  final double size;

  const LoadingWidget({super.key, this.color = kPrimary, this.size = 15});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SizedBox(
        height: size,
        width: size,
        child: CircularProgressIndicator(color: color, strokeWidth: 2.5),
      ),
    );
  }
}
