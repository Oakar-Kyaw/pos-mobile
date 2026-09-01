import 'package:flutter/material.dart';

class DeleteIcon extends StatelessWidget {
  const DeleteIcon({
    super.key,
    required this.onDelete,
    this.top = 7,
    this.right = 2,
    this.centerVertical = false,
  });

  final VoidCallback? onDelete;

  final double top;
  final double right;
  final bool centerVertical;

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: centerVertical ? 0 : top,
      bottom: centerVertical ? 0 : null,
      right: right,
      child: Align(
        alignment: Alignment.center,
        child: IconButton(
          icon: const Icon(Icons.delete_outline, color: Colors.red, size: 25),
          tooltip: 'Delete',
          onPressed: onDelete,
        ),
      ),
    );
  }
}
