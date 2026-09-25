import 'package:flutter/material.dart';
import 'package:flutter_localization/flutter_localization.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pos/component/loading-component.dart';
import 'package:pos/features/brand/data/model/brand.dart';
import 'package:pos/features/brand/presentation/provider/brand-provider.dart';
import 'package:pos/localization/brand-local.dart';
import 'package:pos/utils/app-theme.dart';
import 'package:pos/utils/font-size.dart';
import 'package:pos/utils/shad-toaster.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

class BrandCard extends ConsumerWidget {
  final ValueChanged<Brand> onEdit;
  final int crossAxisCount;

  const BrandCard({super.key, required this.onEdit, this.crossAxisCount = 1});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = ref.watch(themeModeProvider) == ThemeMode.dark;
    final textColor = isDark ? kTextDark : kTextLight;
    final subColor = isDark ? kTextSubDark : kTextSubLight;

    final brandAsync = ref.watch(brandProvider);
    if (brandAsync.isLoading) {
      return const Center(child: LoadingWidget());
    }

    if (brandAsync.hasError) {
      return const Center(child: Text("Failed to load brands"));
    }

    final data = brandAsync.value ?? [];
    if (data.isEmpty) {
      return Center(
        child: Text(
          BrandScreenLocale.brandListEmpty.getString(context),
          style: TextStyle(color: subColor),
        ),
      );
    }

    void _delete(int id) {
      ref
          .read(brandProvider.notifier)
          .deleteBrand(id)
          .then((data) {
            if (data) {
              ShowToast(
                context,
                description: Text(
                  BrandScreenLocale.brandDeleteSuccess.getString(context),
                ),
              );
              ref.invalidate(brandProvider);
            }
          })
          .catchError((err) {
            ShowToast(
              context,
              description: Text(
                BrandScreenLocale.brandDeleteError.getString(context),
              ),
              isError: true,
            );
          });
    }

    // crossAxisCount == 1 ဆိုရင် ListView အတိုင်း full width ဖြစ်ပါမယ်
    return GridView.builder(
      itemCount: data.length,
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: crossAxisCount,
        crossAxisSpacing: 10,
        mainAxisSpacing: 10,
        mainAxisExtent: 64, // 👈 Card တစ်ခုချင်း အမြင့် — content အလိုက် ညှိပါ
      ),
      itemBuilder: (context, index) {
        final brand = data[index];
        return Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: isDark ? kSurfaceDark : kSurfaceLight,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isDark
                  ? Colors.white.withOpacity(0.06)
                  : Colors.black.withOpacity(0.06),
            ),
            boxShadow: [
              BoxShadow(
                color: isDark
                    ? kPrimary.withOpacity(0.06)
                    : Colors.black.withOpacity(0.04),
                blurRadius: 8,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: kPrimary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(
                  LucideIcons.badgeCheck,
                  color: kPrimary,
                  size: 18,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  brand.name,
                  style: TextStyle(
                    fontSize: FontSizeConfig.title(context),
                    fontWeight: FontWeight.w700,
                    color: textColor,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Row(
                children: [
                  IconButton(
                    icon: Icon(
                      Icons.edit,
                      size: FontSizeConfig.iconSize(context),
                    ),
                    color: Colors.green,
                    onPressed: () => onEdit(brand),
                  ),
                  IconButton(
                    icon: Icon(
                      Icons.delete,
                      size: FontSizeConfig.iconSize(context),
                    ),
                    color: Colors.red,
                    onPressed: () => _delete(brand.id!),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}
