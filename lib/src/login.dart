import 'package:flutter/material.dart';
import 'package:flutter_localization/flutter_localization.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:pos/api/login.dart';
import 'package:pos/utils/font-size.dart';
import 'package:pos/utils/route-constant.dart';
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
      WidgetsBinding.instance.addPostFrameCallback((_) {
        showToastWidget();
      });
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
    final email = emailController.text;
    final password = passwordController.text;

    final loginApi = await ref
        .read(loginProvider.notifier)
        .login(email: email, password: password)
        .catchError((error) {
          String message;
          if (error.message == LoginScreenLocale.emailNotFound) {
            message = LoginScreenLocale.emailNotFound.getString(context);
          } else if (error.message == LoginScreenLocale.passwordWrong) {
            message = LoginScreenLocale.passwordWrong.getString(context);
          } else {
            message = error.toString();
          }

          ShowToast(
            context,
            action: Icon(LucideIcons.x, color: Colors.red),
            borderColor: Colors.red,
            description: Text(message, style: TextStyle(color: Colors.red)),
          );
        });
    print("login api is ${loginApi}");
    if (loginApi["success"]) {
      context.pushReplacement(AppRoute.home);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = ShadTheme.of(context);

    return Scaffold(
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 420),
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: ShadForm(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // ===== TITLE =====
                    Text(
                      LoginScreenLocale.loginTitle.getString(context),
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: FontSizeConfig.title(context),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      LoginScreenLocale.loginDescription.getString(context),
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: FontSizeConfig.body(context)),
                    ),

                    const SizedBox(height: 32),

                    // ===== EMAIL =====
                    ShadInputFormField(
                      controller: emailController,
                      label: Text(
                        LoginScreenLocale.email.getString(context),
                        style: TextStyle(
                          fontSize: FontSizeConfig.body(context),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      placeholder: Text(
                        LoginScreenLocale.emailPlaceholder.getString(context),
                        style: TextStyle(
                          fontSize: FontSizeConfig.body(context),
                        ),
                      ),
                      validator: (v) => (v == null || v.isEmpty)
                          ? LoginScreenLocale.emailError.getString(context)
                          : null,
                      keyboardType: TextInputType.emailAddress,
                    ),

                    const SizedBox(height: 16),

                    // ===== PASSWORD =====
                    ShadInputFormField(
                      controller: passwordController,
                      label: Text(
                        LoginScreenLocale.password.getString(context),
                        style: TextStyle(
                          fontSize: FontSizeConfig.body(context),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      placeholder: Text(
                        LoginScreenLocale.passwordPlaceholder.getString(
                          context,
                        ),
                      ),
                      obscureText: _obscurePassword,
                      validator: (v) => (v == null || v.isEmpty)
                          ? LoginScreenLocale.passwordError.getString(context)
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
                        ),
                      ),
                      padding: const EdgeInsets.symmetric(
                        vertical: 12,
                        horizontal: 10,
                      ),
                    ),

                    const SizedBox(height: 32),

                    // ===== SIGN IN BUTTON =====
                    ShadButton(
                      size: ShadButtonSize.lg,
                      onPressed: () {
                        if (_formKey.currentState!.saveAndValidate()) {
                          final data = _formKey.currentState!.value;
                          debugPrint('Login Form Data 👉 $data');
                          submit();
                        }
                      },
                      child: Text(LoginScreenLocale.signIn.getString(context)),
                    ),

                    SizedBox(height: 25),
                    Center(
                      child: GestureDetector(
                        onTap: () => context.pushNamed(AppRoute.companyProfile),
                        child: RichText(
                          text: TextSpan(
                            style: TextStyle(
                              color:
                                  theme.colorScheme.foreground, // 👈 IMPORTANT
                              fontSize: FontSizeConfig.body(context),
                            ),
                            children: [
                              TextSpan(
                                text: LoginScreenLocale.newToPos.getString(
                                  context,
                                ),
                              ),
                              TextSpan(text: "? "),
                              TextSpan(
                                text: LoginScreenLocale.register.getString(
                                  context,
                                ),
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: theme.colorScheme.primary,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
