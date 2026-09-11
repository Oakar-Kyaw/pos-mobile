import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_localization/flutter_localization.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:pos/component/app-bar.dart';
import 'package:pos/features/low-stock/presentation/provider/low-stock.provider.dart';
import 'package:pos/features/low-stock/presentation/widget/low-stock-list.dart';
import 'package:pos/localization/drawer-local.dart';
import 'package:pos/localization/product-local.dart';
import 'package:pos/utils/app-theme.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

class LowStockPage extends ConsumerStatefulWidget {
  const LowStockPage({super.key});

  @override
  ConsumerState<LowStockPage> createState() => _LowStockPageState();
}

class _LowStockPageState extends ConsumerState<LowStockPage> {
  final TextEditingController _searchController = TextEditingController();

  late LowStockSearchNotifier _lowStockSearchNotifier;

  Timer? _debounce;

  @override
  void initState() {
    super.initState();

    _lowStockSearchNotifier = ref.read(lowStockSearchProvider.notifier);
  }

  @override
  void dispose() {
    _searchController.dispose();
    _debounce?.cancel();

    super.dispose();
  }

  void _onSearchChanged(String value) {
    _debounce?.cancel();

    _debounce = Timer(const Duration(milliseconds: 400), () {
      ref.read(lowStockSearchProvider.notifier).setSearch(value);
    });
  }

  void _goBack() {
    _lowStockSearchNotifier.clear();
    context.pop();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = ref.watch(themeModeProvider) == ThemeMode.dark;

    final bgColor = isDark ? kBgDark : kBgLight;
    final textColor = isDark ? kTextDark : kTextLight;
    final surfaceColor = isDark ? kSurfaceDark : kSurfaceLight;

    return PopScope(
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) {
          Future(() {
            ref.read(lowStockSearchProvider.notifier).clear();
          });
        }
      },
      child: Scaffold(
        backgroundColor: bgColor,
        appBar: CustomAppBar(
          leading: IconButton(
            onPressed: _goBack,
            icon: const Icon(LucideIcons.arrowLeft),
          ),
          title: DrawerScreenLocale.drawerLowStock.getString(context),
        ),
        body: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                width: double.infinity,
                child: Container(
                  decoration: BoxDecoration(
                    color: surfaceColor,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: isDark
                          ? Colors.white.withOpacity(0.08)
                          : const Color(0xFFE5E7EB),
                    ),
                  ),
                  child: ShadInputFormField(
                    controller: _searchController,
                    placeholder: Text(
                      ProductScreenLocale.searchPlaceholder.getString(context),
                    ),
                    onChanged: _onSearchChanged,
                    style: TextStyle(color: textColor),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              const Expanded(child: LowStockList()),
            ],
          ),
        ),
      ),
    );
  }
}
