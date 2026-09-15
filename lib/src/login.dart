import 'package:flutter/material.dart';
import 'package:flutter_localization/flutter_localization.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:pos/api/login.dart';
import 'package:pos/api/user.api.dart';
import 'package:pos/core/utils/register-button-widget.dart';
import 'package:pos/utils/app-theme.dart';
import 'package:pos/utils/font-size.dart';
import 'package:pos/utils/route-constant.dart';
import 'package:pos/utils/secure-storage.dart';
import 'package:pos/utils/shad-toaster.dart';
import 'package:shadcn_ui/shadcn_ui.dart';
import 'package:pos/localization/login-local.dart';

class LoginScreen extends ConsumerStatefulWidget {
  final bool? showToast;
  final Widget? toastDescription;
  final Widget? toastIcon;

  const LoginScreen({
    super.key,
    this.showToast,
    this.toastDescription,
    this.toastIcon,
  });

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _formKey = GlobalKey<ShadFormState>();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  bool _obscurePassword = true;

  @override
  void initState() {
    super.initState();
    if (widget.showToast == true) {
      WidgetsBinding.instance.addPostFrameCallback((_) => showToastWidget());
    }
  }

  void showToastWidget() {
    ShowToast(
      context,
      action: widget.toastIcon,
      description: widget.toastDescription,
    );
  }

  void submit() async {
    Map<String, dynamic>? loginApi;

    try {
      loginApi = await ref
          .read(loginProvider.notifier)
          .login(
            email: emailController.text,
            password: passwordController.text,
          );
    } catch (error) {
      debugPrint("message of error 👧 $error");

      if (!mounted) return; // 👈 widget unmount ဖြစ်နေရင် ဒီမှာ ရပ်လိုက်တယ်

      String message;
      if (error.toString().contains(LoginScreenLocale.emailNotFound)) {
        message = LoginScreenLocale.emailNotFound.getString(context);
      } else if (error.toString().contains(LoginScreenLocale.passwordWrong)) {
        message = LoginScreenLocale.passwordWrong.getString(context);
      } else {
        message = error.toString();
      }

      ShowToast(
        context,
        action: const Icon(LucideIcons.x, color: Colors.red),
        borderColor: Colors.red,
        description: Text(message, style: const TextStyle(color: Colors.red)),
      );
      return; // 👈 login fail ဖြစ်ရင် ဒီနေရာမှာ ရပ်ပါ
    }

    if (!mounted) return; // 👈 await ကျော်ပြီးတိုင်း mounted check ထပ်လုပ်ပါ

    final secureStorage = SecureStorage();
    final token = await secureStorage.getFirebaseToken();

    if (!mounted) return; // 👈 ထပ် await ဖြတ်လို့ ထပ်စစ်ပါ

    if (token != null) {
      await ref
          .read(userProvider.notifier)
          .createorUpdateNotificationDeviceToken(deviceToken: token);
    }

    if (!mounted) return;

    if (loginApi?["success"] == true) {
      context.pushReplacement(AppRoute.home);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = ref.watch(themeModeProvider) == ThemeMode.dark;
    final bgColor = isDark ? kBgDark : kBgLight;
    final textColor = isDark ? kTextDark : kTextLight;
    final subColor = isDark ? kTextSubDark : kTextSubLight;

    return Scaffold(
      backgroundColor: bgColor,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 420),
              child: Column(
                children: [
                  // ── Logo / Icon ──────────────────────
                  Container(
                    width: 72,
                    height: 72,
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [kPrimary, kSecondary],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: kPrimary.withOpacity(0.35),
                          blurRadius: 20,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                    child: const Icon(
                      LucideIcons.shoppingCart,
                      color: Colors.white,
                      size: 34,
                    ),
                  ),

                  const SizedBox(height: 24),

                  // ── Title ────────────────────────────
                  Text(
                    LoginScreenLocale.loginTitle.getString(context),
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: FontSizeConfig.title(context),
                      fontWeight: FontWeight.w800,
                      color: textColor,
                      letterSpacing: -0.5,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    LoginScreenLocale.loginDescription.getString(context),
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: FontSizeConfig.body(context),
                      color: subColor,
                    ),
                  ),

                  const SizedBox(height: 32),

                  // ── Form Card ────────────────────────
                  Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: isDark ? kSurfaceDark : kSurfaceLight,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: isDark
                              ? kPrimary.withOpacity(0.12)
                              : Colors.black.withOpacity(0.07),
                          blurRadius: 20,
                          offset: const Offset(0, 6),
                        ),
                      ],
                    ),
                    child: ShadForm(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          // ── Email ──────────────────
                          ShadInputFormField(
                            controller: emailController,
                            label: Text(
                              LoginScreenLocale.email.getString(context),
                              style: TextStyle(
                                fontSize: FontSizeConfig.body(context),
                                fontWeight: FontWeight.w600,
                                color: textColor,
                              ),
                            ),
                            placeholder: Text(
                              LoginScreenLocale.emailPlaceholder.getString(
                                context,
                              ),
                              style: TextStyle(
                                fontSize: FontSizeConfig.body(context),
                              ),
                            ),
                            validator: (v) => (v.isEmpty)
                                ? LoginScreenLocale.emailError.getString(
                                    context,
                                  )
                                : null,
                            keyboardType: TextInputType.emailAddress,
                          ),

                          const SizedBox(height: 16),

                          // ── Password ───────────────
                          ShadInputFormField(
                            controller: passwordController,
                            label: Text(
                              LoginScreenLocale.password.getString(context),
                              style: TextStyle(
                                fontSize: FontSizeConfig.body(context),
                                fontWeight: FontWeight.w600,
                                color: textColor,
                              ),
                            ),
                            placeholder: Text(
                              LoginScreenLocale.passwordPlaceholder.getString(
                                context,
                              ),
                            ),
                            obscureText: _obscurePassword,
                            validator: (v) => (v.isEmpty)
                                ? LoginScreenLocale.passwordError.getString(
                                    context,
                                  )
                                : null,
                            trailing: GestureDetector(
                              onTap: () => setState(
                                () => _obscurePassword = !_obscurePassword,
                              ),
                              child: Icon(
                                _obscurePassword
                                    ? Icons.visibility_off
                                    : Icons.visibility,
                                size: FontSizeConfig.iconSize(context),
                                color: subColor,
                              ),
                            ),
                            padding: const EdgeInsets.symmetric(
                              vertical: 12,
                              horizontal: 10,
                            ),
                          ),

                          const SizedBox(height: 28),

                          // ── Sign in button ─────────
                          SizedBox(
                            width: double.infinity,
                            child: DecoratedBox(
                              decoration: BoxDecoration(
                                gradient: const LinearGradient(
                                  colors: [kPrimary, kSecondary],
                                  begin: Alignment.centerLeft,
                                  end: Alignment.centerRight,
                                ),
                                borderRadius: BorderRadius.circular(10),
                                boxShadow: [
                                  BoxShadow(
                                    color: kPrimary.withOpacity(0.35),
                                    blurRadius: 14,
                                    offset: const Offset(0, 5),
                                  ),
                                ],
                              ),
                              child: ShadButton(
                                size: ShadButtonSize.lg,
                                backgroundColor: Colors.transparent,
                                onPressed: () {
                                  if (_formKey.currentState!
                                      .saveAndValidate()) {
                                    submit();
                                  }
                                },
                                child: Text(
                                  LoginScreenLocale.signIn.getString(context),
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
                    ),
                  ),

                  const SizedBox(height: 24),

                  // ── Register link ────────────────────
                  RegisterButton(
                    title: LoginScreenLocale.register.getString(context),
                    onTap: () => context.pushNamed(AppRoute.companyProfile),
                    subColor: subColor,
                    newToPos: true,
                    newToPosString: LoginScreenLocale.newToPos.getString(
                      context,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

Widget invoiceReceiptWidget({
  required double receiptWidth,
  required String shopName,
  required String address,
  required String invoiceNo,
  required DateTime date,
  required double total,
  String? paymentMethod,
  String footerNote = 'Thank you for your purchase!',
}) {
  return SizedBox(
    width: receiptWidth,
    child: Material(
      color: Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisSize: MainAxisSize.min,
          children: [
            Center(
              child: Text(
                shopName,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
    ),
  );
}
