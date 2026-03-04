import 'package:flutter/material.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

IconData paymentIcon(String type) {
  switch (type) {
    case 'CASH':
      return LucideIcons.banknote;
    case 'BANK':
      return LucideIcons.landmark;
    case 'CARD':
      return LucideIcons.creditCard;
    case 'EWALLET':
      return LucideIcons.wallet;
    default:
      return LucideIcons.circleDollarSign;
  }
}
