import 'package:flutter/material.dart';
import 'package:flutter_localization/flutter_localization.dart';
import 'package:pos/localization/inventory-management-local.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

class InventoryActionConfig {
  final String type;
  final BuildContext context;

  InventoryActionConfig(this.type, this.context);

  String get title {
    switch (type) {
      case 'Damage':
        return InventoryManagementLocale.inventoryExpiredDamaged.getString(
          context,
        );

      case 'Request':
        return InventoryManagementLocale.inventoryRequested.getString(context);

      default:
        return '';
    }
  }

  String get description {
    switch (type) {
      case 'Damage':
        return InventoryManagementLocale.inventoryExpiredDamagedDescription
            .getString(context);

      case 'Request':
        return InventoryManagementLocale.inventoryRequestedDescription
            .getString(context);

      default:
        return '';
    }
  }

  IconData get icon {
    switch (type) {
      case 'Damage':
        return LucideIcons.triangle;

      case 'Request':
        return LucideIcons.clipboardList;

      default:
        return LucideIcons.box;
    }
  }

  static String getTypeValue(String val) {
    if (val == 'Damage') {
      return 'DAMAGED';
    } else if (val == 'Expire') {
      return 'EXPIRED';
    } else {
      return 'REQUESTED';
    }
  }
}
