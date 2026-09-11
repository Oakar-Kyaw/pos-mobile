import 'package:flutter/material.dart';

class DeleteIcon extends StatelessWidget {
  const DeleteIcon({super.key, required this.onDelete});

  final VoidCallback? onDelete;

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.delete_outline, color: Colors.red, size: 25),
      tooltip: 'Delete',
      onPressed: onDelete,
    );
  }
}
