import 'package:flutter/material.dart';

class EditIcon extends StatelessWidget {
  const EditIcon({
    super.key,
    required this.onEdit,
    this.top = 7,
    this.right = 2,
    this.centerVertical = false,
  });

  final VoidCallback? onEdit;

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
          icon: const Icon(Icons.edit_outlined, color: Colors.blue, size: 25),
          tooltip: 'Edit',
          onPressed: onEdit,
        ),
      ),
    );
  }
}
