import 'package:flutter/material.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

class DeleteIcon extends StatelessWidget {
  const DeleteIcon({
    super.key,
    required this.onDelete,
    this.top = 7,
    this.right = 2,
  });

  final VoidCallback? onDelete;
  final double top;
  final double right;

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: top,
      right: right,
      child: InkWell(
        onTap: onDelete,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 6),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              //colors: [Colors.grey, Colors.blueGrey],
              colors: [Color(0xFFEF4444), Color(0xFFF97316)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(50),
          ),
          child: const Icon(LucideIcons.x, color: Colors.white, size: 18),
        ),
      ),
    );
  }
}
