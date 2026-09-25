import 'package:flutter/material.dart';
import 'package:flutter_localization/flutter_localization.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:pos/component/app-bar.dart';
import 'package:pos/features/brand/data/model/brand.dart';
import 'package:pos/features/brand/presentation/widget/brand-card.dart';
import 'package:pos/features/brand/presentation/widget/brand-form.dart';
import 'package:pos/localization/brand-local.dart';
import 'package:pos/utils/app-theme.dart';
import 'package:pos/utils/responsive.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

class BrandPage extends ConsumerStatefulWidget {
  const BrandPage({super.key});

  @override
  ConsumerState<BrandPage> createState() => _BrandPageState();
}

class _BrandPageState extends ConsumerState<BrandPage> {
  Brand? brandData;

  Future<void> _onRefresh() async {
    if (!mounted) return;

    setState(() {
      brandData = null;
    });

    await Future.delayed(const Duration(milliseconds: 300));
  }

  @override
  Widget build(BuildContext context) {
    final themeMode = ref.watch(themeModeProvider);
    final isDark = themeMode == ThemeMode.dark;

    final bgColor = isDark ? kBgDark : kBgLight;
    final textColor = isDark ? kTextDark : kTextLight;

    final brandFormBoxDecoration = BoxDecoration(
      color: isDark ? kSurfaceDark : kSurfaceLight,
      borderRadius: BorderRadius.circular(16),
      boxShadow: [
        BoxShadow(
          color: isDark
              ? kPrimary.withOpacity(0.06)
              : Colors.black.withOpacity(0.03),
          blurRadius: 8,
          offset: const Offset(0, 2),
        ),
      ],
    );

    return Scaffold(
      backgroundColor: bgColor,
      appBar: CustomAppBar(
        leading: IconButton(
          onPressed: () => context.pop(),
          icon: const Icon(LucideIcons.arrowLeft),
        ),
        title: BrandScreenLocale.brandTitle.getString(context),
      ),
      body: RefreshIndicator(
        onRefresh: _onRefresh,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: Column(
            children: [
              BrandFormTitle(textColor: textColor),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: brandFormBoxDecoration,
                child: BrandForm(
                  brand: brandData,
                  onClear: () => setState(() {
                    brandData = null;
                  }),
                ),
              ),
              const SizedBox(height: 20),
              BrandNameTitle(textColor: textColor),
              const SizedBox(height: 12),
              SizedBox(
                height: MediaQuery.of(context).size.height * 0.55,
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  clipBehavior: Clip.antiAlias,
                  child: BrandCard(
                    crossAxisCount: Responsive.isDesktop(context)
                        ? 4
                        : Responsive.isTablet(context)
                        ? 2
                        : 1,
                    onEdit: (Brand value) {
                      setState(() {
                        brandData = value;
                      });
                    },
                  ),
                ),
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }
}

class BrandNameTitle extends StatelessWidget {
  const BrandNameTitle({super.key, required this.textColor});

  final Color textColor;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 4,
          height: 18,
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [kPrimary, kSecondary],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 10),
        Text(
          BrandScreenLocale.brandTitle.getString(context),
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w700,
            color: textColor,
            letterSpacing: -0.2,
          ),
        ),
        const Spacer(),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          decoration: BoxDecoration(
            color: kPrimary.withOpacity(0.1),
            borderRadius: BorderRadius.circular(20),
          ),
          child: const Text(
            'List',
            style: TextStyle(
              color: kPrimary,
              fontSize: 11,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }
}

class BrandFormTitle extends StatelessWidget {
  const BrandFormTitle({super.key, required this.textColor});

  final Color textColor;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 4,
          height: 18,
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [kPrimary, kSecondary],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 10),
        Text(
          BrandScreenLocale.brandTitle.getString(context),
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w700,
            color: textColor,
            letterSpacing: -0.2,
          ),
        ),
      ],
    );
  }
}
