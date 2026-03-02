import 'package:flutter/material.dart';
import 'package:flutter_localization/flutter_localization.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pos/api/voucher.api.dart';
import 'package:pos/localization/voucher-local.dart';
import 'package:pos/utils/app-theme.dart';
import 'package:pos/utils/font-size.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

class VoucherSearchField extends ConsumerStatefulWidget {
  final Function(String) onSearchChanged;
  final Function(int) onVoucherSelected;

  const VoucherSearchField({
    super.key,
    required this.onSearchChanged,
    required this.onVoucherSelected,
  });

  @override
  ConsumerState<VoucherSearchField> createState() => _VoucherSearchFieldState();
}

class _VoucherSearchFieldState extends ConsumerState<VoucherSearchField> {
  late final TextEditingController searchController;
  bool showSuggestions = false;

  @override
  void initState() {
    super.initState();
    searchController = TextEditingController();
  }

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = ref.watch(themeModeProvider) == ThemeMode.dark;
    final textColor = isDark ? kTextDark : kTextLight;
    final subColor = isDark ? kTextSubDark : kTextSubLight;
    final progressIndicatorColor = isDark
        ? kPrimary
        : kPrimary.withOpacity(0.8);

    return Column(
      children: [
        ShadInputFormField(
          controller: searchController,
          decoration: const ShadDecoration(
            secondaryFocusedBorder: ShadBorder.none,
          ),
          placeholder: Text(
            VoucherScreenLocale.searchVoucherPlaceholder.getString(context),
            style: TextStyle(color: subColor),
          ),
          onChanged: (value) {
            widget.onSearchChanged.call(value);
            setState(() {
              showSuggestions = value.isNotEmpty;
            });
          },
        ),

        const SizedBox(height: 15),
        !showSuggestions
            ? const SizedBox()
            : ref
                  .watch(voucherProvider)
                  .when(
                    data: (items) {
                      if (items.isEmpty) return const SizedBox();

                      return Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: kPrimary.withOpacity(0.2)),
                        ),
                        child: ListView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: items.length,
                          itemBuilder: (context, index) {
                            final voucher = items[index];

                            return ListTile(
                              title: Text(
                                voucher.voucherCode ?? '',
                                style: TextStyle(
                                  color: textColor,
                                  fontWeight: FontWeight.bold,
                                  fontSize: FontSizeConfig.body(context),
                                ),
                              ),
                              subtitle: Text(
                                voucher.createdAt != null
                                    ? DateFormat(
                                        'yyyy-MM-dd E',
                                      ).format(voucher.createdAt!)
                                    : '-',
                                style: TextStyle(color: subColor),
                              ),
                              onTap: () {
                                searchController.text =
                                    voucher.voucherCode ?? '';
                                widget.onVoucherSelected.call(voucher.id);
                                setState(() {
                                  showSuggestions = false;
                                });
                              },
                            );
                          },
                        ),
                      );
                    },
                    loading: () => Center(
                      child: SizedBox(
                        height: 30,
                        width: 30,
                        child: CircularProgressIndicator(
                          color: progressIndicatorColor,
                        ),
                      ),
                    ),
                    error: (_, __) => const SizedBox(),
                  ),
      ],
    );
  }
}
