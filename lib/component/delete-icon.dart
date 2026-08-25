import 'package:flutter/material.dart';

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
      child: IconButton(
        icon: Icon(Icons.delete_outline, color: Colors.red, size: 25),
        tooltip: 'Delete',
        onPressed: onDelete,
      ),
    );
  }
}
