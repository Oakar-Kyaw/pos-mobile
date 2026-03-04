import 'package:flutter/material.dart';
import 'package:flutter_localization/flutter_localization.dart';
import 'package:pos/localization/inventory-management-local.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

enum InventoryActionType { damaged, requested }

class InventoryActionConfig {
  final InventoryActionType type;
  BuildContext context;

  InventoryActionConfig(this.type, this.context);

  String get title {
    switch (type) {
      case InventoryActionType.damaged:
        return InventoryManagementLocale.inventoryExpiredDamaged.getString(
          context,
        );
      case InventoryActionType.requested:
        return InventoryManagementLocale.inventoryRequested.getString(context);
        ;
    }
  }

  String get description {
    switch (type) {
      case InventoryActionType.damaged:
        return InventoryManagementLocale.inventoryExpiredDamagedDescription
            .getString(context);

      case InventoryActionType.requested:
        return InventoryManagementLocale.inventoryRequestedDescription
            .getString(context);
    }
  }

  IconData get icon {
    switch (type) {
      case InventoryActionType.damaged:
        return LucideIcons.triangle;
      case InventoryActionType.requested:
        return LucideIcons.clipboardList;
    }
  }
}
