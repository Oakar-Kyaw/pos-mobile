import 'package:flutter/material.dart';
import 'package:pos/utils/app-theme.dart';

class LoadingWidget extends StatelessWidget {
  final Color color;
  const LoadingWidget({super.key, this.color = kPrimary});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 80,
      width: 80,
      child: Center(child: CircularProgressIndicator(color: color)),
    );
  }
}
