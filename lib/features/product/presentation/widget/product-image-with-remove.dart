import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

class ProductImageWithRemove extends StatefulWidget {
  const ProductImageWithRemove({
    super.key,
    required this.photoUrl,
    required this.onRemove,
    required this.imageFile,
    required this.onUpload,
  });

  final String? photoUrl;
  final File? imageFile;
  final VoidCallback onRemove;
  final VoidCallback onUpload;
  @override
  State<ProductImageWithRemove> createState() => _ProductImageWithRemoveState();
}

class _ProductImageWithRemoveState extends State<ProductImageWithRemove> {
  @override
  Widget build(BuildContext context) {
    print(
      "product image photo url is 😘 ${widget.photoUrl} ${widget.imageFile}",
    );
    if (widget.imageFile != null) {
      return Image.file(
        widget.imageFile!,
        width: 65,
        height: 70,
        fit: BoxFit.cover,
      );
    }
    return widget.photoUrl != null
        ? Stack(
            clipBehavior: Clip.none,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(6),
                child: CachedNetworkImage(
                  imageUrl: widget.photoUrl ?? "",
                  width: 65,
                  height: 70,
                  fit: BoxFit.cover,
                  placeholder: (context, url) => Container(
                    width: 65,
                    height: 70,
                    color: Colors.grey.shade200,
                  ),
                  errorWidget: (context, url, error) => Container(
                    width: 65,
                    height: 70,
                    color: Colors.grey.shade200,
                    child: const Icon(
                      Icons.image_not_supported_outlined,
                      size: 20,
                    ),
                  ),
                ),
              ),

              Positioned(
                top: -12,
                right: -12,
                child: GestureDetector(
                  onTap: widget.onRemove,
                  child: Icon(LucideIcons.x, size: 28, color: Colors.red),
                ),
              ),
            ],
          )
        : InkWell(
            onTap: widget.onUpload,
            borderRadius: BorderRadius.circular(6),
            child: Container(
              width: 65,
              height: 70,
              decoration: BoxDecoration(
                color: Colors.grey.shade200,
                borderRadius: BorderRadius.circular(6),
                border: Border.all(color: Colors.grey.shade400),
              ),
              child: const Center(
                child: Icon(LucideIcons.upload, size: 22, color: Colors.grey),
              ),
            ),
          );
  }
}
