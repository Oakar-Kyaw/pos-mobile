import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localization/flutter_localization.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:pos/api/company.api.dart';
import 'package:pos/api/user.api.dart';
import 'package:pos/component/loading-component.dart';
import 'package:pos/features/profile/presentation/widget/edit-company-dialog.dart';
import 'package:pos/localization/company-local.dart';
import 'package:pos/riverpod/user.riverpod.dart';
import 'package:pos/utils/app-theme.dart';
import 'package:pos/utils/font-size.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

class CompanyProfileTab extends ConsumerWidget {
  const CompanyProfileTab({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = ref.watch(themeModeProvider) == ThemeMode.dark;
    final user = ref.watch(userStateProvider);
    final textColor = isDark ? kTextDark : kTextLight;
    final subColor = isDark ? kTextSubDark : kTextSubLight;
    final surfaceColor = isDark ? kSurfaceDark : kSurfaceLight;

    final companyAsync = ref.watch(companyByIdProvider(user!.companyId));

    return companyAsync.when(
      loading: () => const Center(child: LoadingWidget()),
      error: (err, _) => Center(
        child: Text(
          "${CompanyRegisterScreenLocal.error.getString(context)}: $err",
          style: TextStyle(color: subColor),
        ),
      ),
      data: (company) {
        final hasLogo =
            company.photoUrl != null && company.photoUrl!.isNotEmpty;

        return SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: hasLogo
                    ? CachedNetworkImage(
                        imageUrl: company.photoUrl!,
                        width: 96,
                        height: 96,
                        fit: BoxFit.cover,
                        placeholder: (context, url) => Container(
                          width: 96,
                          height: 96,
                          color: kPrimary.withOpacity(0.1),
                          child: const Center(
                            child: CircularProgressIndicator(strokeWidth: 2),
                          ),
                        ),
                        errorWidget: (context, url, error) => Container(
                          width: 96,
                          height: 96,
                          color: kPrimary.withOpacity(0.1),
                          child: const Icon(
                            LucideIcons.building2,
                            size: 40,
                            color: kPrimary,
                          ),
                        ),
                      )
                    : Container(
                        width: 96,
                        height: 96,
                        color: kPrimary.withOpacity(0.1),
                        child: const Icon(
                          LucideIcons.building2,
                          size: 40,
                          color: kPrimary,
                        ),
                      ),
              ),

              const SizedBox(height: 16),

              Text(
                company.name,
                style: TextStyle(
                  color: textColor,
                  fontSize: FontSizeConfig.title(context),
                  fontWeight: FontWeight.w700,
                ),
              ),

              const SizedBox(height: 4),

              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: kPrimary.withOpacity(0.12),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      company.type,
                      style: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: kPrimary,
                      ),
                    ),
                  ),

                  if (company.isTrial) ...[
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: kAmber.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        CompanyRegisterScreenLocal.trial.getString(context),
                        style: const TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: kAmber,
                        ),
                      ),
                    ),
                  ],
                ],
              ),

              const SizedBox(height: 24),

              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: surfaceColor,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: isDark
                          ? kPrimary.withOpacity(0.08)
                          : Colors.black.withOpacity(0.05),
                      blurRadius: 10,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    _InfoRow(
                      icon: LucideIcons.mail,
                      label: CompanyRegisterScreenLocal.companyEmail.getString(
                        context,
                      ),
                      value: company.email,
                      textColor: textColor,
                      subColor: subColor,
                    ),

                    const Divider(height: 24),

                    _InfoRow(
                      icon: LucideIcons.hash,
                      label: CompanyRegisterScreenLocal.companyCode.getString(
                        context,
                      ),
                      value:
                          company.code ??
                          CompanyRegisterScreenLocal.notAvailable.getString(
                            context,
                          ),
                      textColor: textColor,
                      subColor: subColor,
                    ),

                    const Divider(height: 24),

                    _InfoRow(
                      icon: LucideIcons.phone,
                      label: CompanyRegisterScreenLocal.companyPhone.getString(
                        context,
                      ),
                      value:
                          company.phone ??
                          CompanyRegisterScreenLocal.notAvailable.getString(
                            context,
                          ),
                      textColor: textColor,
                      subColor: subColor,
                    ),

                    const Divider(height: 24),

                    _InfoRow(
                      icon: LucideIcons.globe,
                      label: CompanyRegisterScreenLocal.country.getString(
                        context,
                      ),
                      value: company.country,
                      textColor: textColor,
                      subColor: subColor,
                    ),

                    const Divider(height: 24),

                    _InfoRow(
                      icon: LucideIcons.mapPin,
                      label: CompanyRegisterScreenLocal.companyAddress
                          .getString(context),
                      value:
                          company.address ??
                          CompanyRegisterScreenLocal.notAvailable.getString(
                            context,
                          ),
                      textColor: textColor,
                      subColor: subColor,
                    ),

                    const Divider(height: 24),

                    _InfoRow(
                      icon: LucideIcons.calendar,
                      label: CompanyRegisterScreenLocal.subscriptionEndDate
                          .getString(context),
                      value: company.subscriptionEndDate != null
                          ? DateFormat(
                              "EEE, dd MMM yyyy",
                            ).format(company.subscriptionEndDate!)
                          : CompanyRegisterScreenLocal.notAvailable.getString(
                              context,
                            ),
                      textColor: textColor,
                      subColor: subColor,
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              SizedBox(
                width: double.infinity,
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [kPrimary, kSecondary],
                    ),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: ShadButton(
                    backgroundColor: Colors.transparent,
                    onPressed: () async {
                      final updated = await showDialog<bool>(
                        context: context,
                        builder: (_) => EditCompanyDialog(company: company),
                      );

                      if (updated == true) {
                        ref.invalidate(companyByIdProvider(user.id));
                      }
                    },
                    child: Text(
                      CompanyRegisterScreenLocal.editCompany.getString(context),
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({
    required this.icon,
    required this.label,
    required this.value,
    required this.textColor,
    required this.subColor,
  });

  final IconData icon;
  final String label;
  final String value;
  final Color textColor;
  final Color subColor;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Icon(icon, size: 16, color: subColor),
        const SizedBox(width: 10),

        Expanded(
          child: Text(
            label,
            maxLines: 3,
            style: TextStyle(color: subColor, fontSize: 12),
            overflow: TextOverflow.ellipsis,
          ),
        ),

        const SizedBox(width: 8),

        Flexible(
          flex: 2,
          child: Text(
            value,
            textAlign: TextAlign.right,
            overflow: TextOverflow.ellipsis,
            maxLines: 1,
            style: TextStyle(color: textColor, fontWeight: FontWeight.w600),
          ),
        ),
      ],
    );
  }
}
