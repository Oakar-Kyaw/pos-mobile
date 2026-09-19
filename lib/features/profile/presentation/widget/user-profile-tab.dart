import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localization/flutter_localization.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:pos/features/company/presentation/provider/company.riverpod.dart';
import 'package:pos/features/profile/data/model/user.dart';
import 'package:pos/features/profile/presentation/widget/delete-user-dialog.dart';
import 'package:pos/features/profile/presentation/widget/edit-profile-dialog.dart';
import 'package:pos/localization/profile-local.dart';
import 'package:pos/riverpod/login-check.dart';
import 'package:pos/riverpod/user.riverpod.dart';
import 'package:pos/utils/app-theme.dart';
import 'package:pos/utils/font-size.dart';
import 'package:pos/utils/secure-storage.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

class UserProfileTab extends StatelessWidget {
  const UserProfileTab({super.key, required this.user});

  final User user;

  String get _fullName {
    final first = user.firstName?.trim() ?? '';
    final last = user.lastName?.trim() ?? '';
    final combined = '$first $last'.trim();
    return combined.isNotEmpty ? combined : user.email;
  }

  @override
  Widget build(BuildContext context) {
    return Consumer(
      builder: (context, ref, _) {
        final isDark = ref.watch(themeModeProvider) == ThemeMode.dark;
        final textColor = isDark ? kTextDark : kTextLight;
        final subColor = isDark ? kTextSubDark : kTextSubLight;
        final surfaceColor = isDark ? kSurfaceDark : kSurfaceLight;
        final hasPhoto = user.photoUrl != null && user.photoUrl!.isNotEmpty;

        return SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              // ── Avatar ─────────────────────
              ClipOval(
                child: hasPhoto
                    ? CachedNetworkImage(
                        imageUrl: user.photoUrl!,
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
                            LucideIcons.user,
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
                          LucideIcons.user,
                          size: 40,
                          color: kPrimary,
                        ),
                      ),
              ),
              const SizedBox(height: 16),
              Text(
                _fullName,
                style: TextStyle(
                  color: textColor,
                  fontSize: FontSizeConfig.title(context),
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 4),
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
                  user.role.toUpperCase(),
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: kPrimary,
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // ── Info card ──────────────────
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
                      icon: LucideIcons.user,
                      label: ProfileScreenLocale.firstName.getString(context),
                      value: user.firstName ?? "-",
                      textColor: textColor,
                      subColor: subColor,
                    ),
                    const Divider(height: 24),
                    _InfoRow(
                      icon: LucideIcons.user,
                      label: ProfileScreenLocale.lastName.getString(context),
                      value: user.lastName ?? "-",
                      textColor: textColor,
                      subColor: subColor,
                    ),
                    const Divider(height: 24),
                    _InfoRow(
                      icon: LucideIcons.mail,
                      label: ProfileScreenLocale.email.getString(context),
                      value: user.email,
                      textColor: textColor,
                      subColor: subColor,
                    ),
                    const Divider(height: 24),
                    _InfoRow(
                      icon: LucideIcons.phone,
                      label: ProfileScreenLocale.phone.getString(context),
                      value: user.phone ?? "-",
                      textColor: textColor,
                      subColor: subColor,
                    ),
                    const Divider(height: 24),
                    _InfoRow(
                      icon: LucideIcons.mapPin,
                      label: ProfileScreenLocale.address.getString(context),
                      value: user.address ?? "-",
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
                        builder: (_) => EditProfileDialog(user: user),
                      );
                      if (updated == true) {
                        ref.invalidate(userStateProvider);
                      }
                    },
                    child: Text(
                      ProfileScreenLocale.profileEdit.getString(context),
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 12),

              SizedBox(
                width: double.infinity,
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(colors: [kRed, kRed]),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: ShadButton(
                    backgroundColor: Colors.transparent,
                    onPressed: () async {
                      final deleted = await showDialog<bool>(
                        context: context,
                        builder: (_) => const DeleteAccountDialog(),
                      );

                      if (deleted == true) {
                        final storage = SecureStorage();
                        await storage.deleteLoginData();
                        await storage.saveAcessAndRefreshToken(
                          accessToken: '',
                          refreshToken: '',
                        );
                        ref.read(checkLoginProvider.notifier).logout();
                        ref.read(companyStateProvider.notifier).clear();

                        if (context.mounted) {
                          context.go('/login');
                        }
                      }
                    },
                    child: Text(
                      ProfileScreenLocale.deleteAccount.getString(context),
                      style: TextStyle(
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
      children: [
        Icon(icon, size: 16, color: subColor),
        const SizedBox(width: 10),
        Text(label, style: TextStyle(color: subColor, fontSize: 12)),
        const Spacer(),
        Flexible(
          child: Text(
            value,
            textAlign: TextAlign.right,
            style: TextStyle(color: textColor, fontWeight: FontWeight.w600),
          ),
        ),
      ],
    );
  }
}
