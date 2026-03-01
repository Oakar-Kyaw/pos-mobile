String formatAmount(double value) =>
    value % 1 == 0 ? value.toInt().toString() : value.toStringAsFixed(2);
