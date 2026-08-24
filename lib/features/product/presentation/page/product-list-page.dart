import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_localization/flutter_localization.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:pos/component/app-bar.dart';
import 'package:pos/core/utils/user-select.dart';
import 'package:pos/localization/drawer-local.dart';
import 'package:pos/localization/product-local.dart';
import 'package:pos/riverpod/selected-user.riverpod.dart';
import 'package:pos/riverpod/user.riverpod.dart';
import 'package:pos/features/product/presentation/page/product-lists.dart';
import 'package:pos/utils/app-theme.dart';
import 'package:pos/utils/check-role.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

class ProductListsPage extends ConsumerStatefulWidget {
  const ProductListsPage({super.key});

  @override
  ConsumerState<ProductListsPage> createState() => _ProductListsPageState();
}

class _ProductListsPageState extends ConsumerState<ProductListsPage> {
  final TextEditingController _searchController = TextEditingController();
  Timer? _debounce;
  String searchQuery = "";
  final int limit = 20;

  @override
  void dispose() {
    super.dispose();
    _searchController.dispose();
  }

  void _onSearchChanged(String value) {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 400), () {
      setState(() {
        searchQuery = value;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = ref.watch(themeModeProvider) == ThemeMode.dark;
    final bgColor = isDark ? kBgDark : kBgLight;
    //print("user dAta🤬: ${selectedData?.userId}");
    return PopScope(
      canPop: true,
      onPopInvokedWithResult: (pop, result) =>
          ref.read(selectedDataStateProvider.notifier).clear(),

      child: Scaffold(
        resizeToAvoidBottomInset: true,
        backgroundColor: bgColor,
        appBar: CustomAppBar(
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => context.pop(),
          ),
          title: DrawerScreenLocale.drawerProduct.getString(context),
        ),
        body: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.all(20),
              child: ConstrainedBox(
                constraints: const BoxConstraints(minHeight: 40),
                child: ShadInput(
                  controller: _searchController,
                  placeholder: Text(
                    ProductScreenLocale.search.getString(context),
                  ),
                  onChanged: _onSearchChanged,
                ),
              ),
            ),
            Expanded(child: ProductLists(searchQuery: searchQuery)),

            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}

// Fixed ProductLabel
class ProductLabel extends ConsumerWidget {
  const ProductLabel({super.key, required this.textColor});

  final Color textColor;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(userStateProvider);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        children: [
          // Container(
          //   width: 4,
          //   height: 18,
          //   decoration: BoxDecoration(
          //     gradient: const LinearGradient(
          //       colors: [kPrimary, kSecondary],
          //       begin: Alignment.topCenter,
          //       end: Alignment.bottomCenter,
          //     ),
          //     borderRadius: BorderRadius.circular(2),
          //   ),
          // ),
          // const SizedBox(width: 10),
          // Text(
          //   DrawerScreenLocale.drawerVoucher.getString(context),
          //   style: TextStyle(
          //     fontSize: 14,
          //     fontWeight: FontWeight.w700,
          //     color: textColor,
          //     letterSpacing: -0.2,
          //   ),
          // ),
          if (isAdmin(user!.role) || isManager(user.role)) ...[
            //Spacer(),
            UserSelect(),
          ],
        ],
      ),
    );
  }
}
