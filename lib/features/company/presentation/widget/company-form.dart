import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localization/flutter_localization.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:pos/api/company.api.dart';
import 'package:pos/features/company/data/model/company.dart';
import 'package:pos/localization/company-local.dart';
import 'package:pos/utils/app-theme.dart';
import 'package:pos/utils/font-size.dart';
import 'package:pos/utils/route-constant.dart';
import 'package:pos/utils/shad-toaster.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

class CompanyForm extends ConsumerStatefulWidget {
  const CompanyForm({super.key});

  @override
  ConsumerState<CompanyForm> createState() => _CompanyFormState();
}

class _CompanyFormState extends ConsumerState<CompanyForm> {
  final _formKey = GlobalKey<ShadFormState>();
  final name = TextEditingController();
  final password = TextEditingController();
  final email = TextEditingController();
  final address = TextEditingController();
  final phone = TextEditingController();
  final code = TextEditingController();

  bool isLoading = false;

  @override
  void dispose() {
    name.dispose();
    password.dispose();
    email.dispose();
    address.dispose();
    phone.dispose();
    code.dispose();
    super.dispose();
  }

  Future<void> submit() async {
    if (isLoading) return;

    setState(() => isLoading = true);

    final json = Company(
      id: 0,
      email: email.text.trim(),
      name: name.text.trim(),
      password: password.text.trim(),
      address: address.text.trim(),
      phone: phone.text.trim(),
      code: code.text.trim(),
    );

    try {
      final Company result = await ref
          .read(companyProvider.notifier)
          .postCompany(json.toJson());

      print("Company created: ${result.name}");

      if (mounted) {
        context.go(
          AppRoute.login,
          extra: CompanyRegisterScreenLocal.createdSuccess.getString(context),
        );
      }
    } catch (e) {
      print("Failed to create company: $e");

      if (!mounted) return;

      if (e.toString().contains(
        'Company with this email, name, or phone already exists',
      )) {
        ShowToast(
          context,
          isError: true,
          action: Icon(
            LucideIcons.x,
            color: Colors.red,
            size: FontSizeConfig.iconSize(context),
          ),
          description: Text(
            CompanyRegisterScreenLocal.alreadyExists.getString(context),
            style: const TextStyle(color: Colors.red),
          ),
        );
      } else {
        ShowToast(
          context,
          isError: true,
          action: Icon(
            LucideIcons.x,
            color: Colors.red,
            size: FontSizeConfig.iconSize(context),
          ),
          description: Text(
            CompanyRegisterScreenLocal.createFailed.getString(context),
            style: const TextStyle(color: Colors.red),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => isLoading = false);
      }
    }
  }

  String? requiredValidator(String? value, BuildContext context) {
    if (value == null || value.trim().isEmpty) {
      return CompanyRegisterScreenLocal.requiredError.getString(context);
    }
    return null;
  }

  String? emailValidator(String? value, BuildContext context) {
    if (requiredValidator(value, context) != null) {
      return requiredValidator(value, context);
    }
    final emailRegex = RegExp(r'^[\w\.-]+@([\w-]+\.)+[\w-]{2,4}$');
    if (!emailRegex.hasMatch(value!.trim())) {
      return CompanyRegisterScreenLocal.emailInvalidError.getString(context);
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final isDark = ref.watch(themeModeProvider) == ThemeMode.dark;
    final textColor = isDark ? kTextDark : kTextLight;

    Widget label(String text) => Padding(
      padding: const EdgeInsets.only(bottom: 5),
      child: Text(
        text,
        style: TextStyle(
          fontSize: FontSizeConfig.body(context),
          fontWeight: FontWeight.w600,
          color: textColor,
        ),
      ),
    );

    Widget placeholder(String text) =>
        Text(text, style: TextStyle(fontSize: FontSizeConfig.body(context)));

    return ShadForm(
      key: _formKey,
      child: Column(
        children: [
          // ── Company Name ─────────────────────────
          ShadInputFormField(
            controller: name,
            enabled: !isLoading,
            validator: (v) => requiredValidator(v, context),
            label: label(
              CompanyRegisterScreenLocal.companyName.getString(context),
            ),
            placeholder: placeholder(
              CompanyRegisterScreenLocal.companyNamePlaceholder.getString(
                context,
              ),
            ),
          ),
          const SizedBox(height: 15),

          // ── Company Code ─────────────────────────
          ShadInputFormField(
            controller: code,
            enabled: !isLoading,
            validator: (v) => requiredValidator(v, context),
            label: label(
              CompanyRegisterScreenLocal.companyCode.getString(context),
            ),
            placeholder: placeholder(
              CompanyRegisterScreenLocal.companyCodePlaceholder.getString(
                context,
              ),
            ),
          ),
          const SizedBox(height: 15),

          // ── Company Email ────────────────────────
          ShadInputFormField(
            controller: email,
            enabled: !isLoading,
            validator: (v) => emailValidator(v, context),
            keyboardType: TextInputType.emailAddress,
            label: label(
              CompanyRegisterScreenLocal.companyEmail.getString(context),
            ),
            placeholder: placeholder(
              CompanyRegisterScreenLocal.companyEmailPlaceholder.getString(
                context,
              ),
            ),
          ),
          const SizedBox(height: 15),

          // ── Company Password ─────────────────────
          ShadInputFormField(
            controller: password,
            enabled: !isLoading,
            validator: (v) => requiredValidator(v, context),
            obscureText: true,
            label: label(
              CompanyRegisterScreenLocal.companyPassword.getString(context),
            ),
            placeholder: placeholder(
              CompanyRegisterScreenLocal.companyPasswordPlaceholder.getString(
                context,
              ),
            ),
          ),
          const SizedBox(height: 15),

          // ── Company Phone ────────────────────────
          ShadInputFormField(
            controller: phone,
            enabled: !isLoading,
            validator: (v) => requiredValidator(v, context),
            keyboardType: TextInputType.phone,
            label: label(
              CompanyRegisterScreenLocal.companyPhone.getString(context),
            ),
            placeholder: placeholder(
              CompanyRegisterScreenLocal.companyPhonePlaceholder.getString(
                context,
              ),
            ),
          ),
          const SizedBox(height: 15),

          // ── Company Address ──────────────────────
          ShadInputFormField(
            controller: address,
            enabled: !isLoading,
            validator: (v) => requiredValidator(v, context),
            maxLines: 2,
            label: label(
              CompanyRegisterScreenLocal.companyAddress.getString(context),
            ),
            placeholder: placeholder(
              CompanyRegisterScreenLocal.companyAddressPlaceholder.getString(
                context,
              ),
            ),
          ),
          const SizedBox(height: 24),

          // ── Submit Button ────────────────────────
          SizedBox(
            width: double.infinity,
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: isLoading
                      ? [kPrimary.withOpacity(0.5), kSecondary.withOpacity(0.5)]
                      : [kPrimary, kSecondary],
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                ),
                borderRadius: BorderRadius.circular(8),
                boxShadow: isLoading
                    ? []
                    : [
                        BoxShadow(
                          color: kPrimary.withOpacity(0.35),
                          blurRadius: 14,
                          offset: const Offset(0, 5),
                        ),
                      ],
              ),
              child: ShadButton(
                backgroundColor: Colors.transparent,
                onPressed: isLoading
                    ? null
                    : () {
                        if (_formKey.currentState!.validate()) submit();
                      },
                child: isLoading
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : Text(
                        CompanyRegisterScreenLocal.companyButton.getString(
                          context,
                        ),
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
  }
}
