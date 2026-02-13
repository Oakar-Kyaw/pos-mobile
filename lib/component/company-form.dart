import 'package:flutter/material.dart';
import 'package:flutter_localization/flutter_localization.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:pos/api/company.api.dart';
import 'package:pos/localization/company-local.dart';
import 'package:pos/models/company.dart';
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
  final TextEditingController name = TextEditingController();
  final TextEditingController password = TextEditingController();
  final TextEditingController email = TextEditingController();
  final TextEditingController address = TextEditingController();
  final TextEditingController phone = TextEditingController();
  final TextEditingController code = TextEditingController();

  Future<void> submit() async {
    final notifier = ref.read(companyProvider.notifier);

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
      final Company result = await notifier.postCompany(json.toJson());
      print("Company created: ${result.name}");
      if (mounted) {
        context.go(
          AppRoute.login,
          extra: CompanyRegisterScreenLocal.createdSuccess.getString(context),
        );
      }
    } catch (e) {
      print("Failed to create company: $e");
      ShowToast(
        context,
        borderColor: Colors.red,
        action: Icon(
          LucideIcons.x,
          color: Colors.red,
          size: FontSizeConfig.iconSize(context),
        ),
        description: Text(
          CompanyRegisterScreenLocal.createFailed.getString(context),
          style: TextStyle(color: Colors.red),
        ),
      );
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
    // Email regex (simple & safe)
    final emailRegex = RegExp(r'^[\w\.-]+@([\w-]+\.)+[\w-]{2,4}$');

    if (!emailRegex.hasMatch(value!.trim())) {
      return CompanyRegisterScreenLocal.emailInvalidError.getString(context);
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return ShadForm(
      key: _formKey,
      child: Column(
        children: [
          // ShadButton(
          //   onPressed: () {
          //     ShowToast(
          //       context,
          //       color: Colors.red,
          //       action: Icon(
          //         LucideIcons.x,
          //         color: Colors.red,
          //         size: FontSizeConfig.iconSize(context),
          //       ),
          //       description: Text(
          //         CompanyRegisterScreenLocal.createFailed.getString(context),
          //         style: TextStyle(color: Colors.red),
          //       ),
          //     );
          //   },
          //   child: Text("test"),
          // ),
          // // Company Name
          ShadInputFormField(
            controller: name,
            validator: (value) => requiredValidator(value, context),
            label: Padding(
              padding: const EdgeInsets.only(bottom: 5),
              child: Text(
                CompanyRegisterScreenLocal.companyName.getString(context),
                style: TextStyle(
                  fontSize: FontSizeConfig.body(context),
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            placeholder: Text(
              CompanyRegisterScreenLocal.companyNamePlaceholder.getString(
                context,
              ),
              style: TextStyle(fontSize: FontSizeConfig.body(context)),
            ),
          ),
          const SizedBox(height: 15),
          // Company Code
          ShadInputFormField(
            controller: code,
            validator: (value) => requiredValidator(value, context),
            label: Padding(
              padding: const EdgeInsets.only(bottom: 5),
              child: Text(
                CompanyRegisterScreenLocal.companyCode.getString(context),
                style: TextStyle(
                  fontSize: FontSizeConfig.body(context),
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            placeholder: Text(
              CompanyRegisterScreenLocal.companyCodePlaceholder.getString(
                context,
              ),
              style: TextStyle(fontSize: FontSizeConfig.body(context)),
            ),
          ),
          const SizedBox(height: 15),

          // Company Email
          ShadInputFormField(
            controller: email,
            validator: (value) => emailValidator(value, context),
            label: Padding(
              padding: const EdgeInsets.only(bottom: 5),
              child: Text(
                CompanyRegisterScreenLocal.companyEmail.getString(context),
                style: TextStyle(
                  fontSize: FontSizeConfig.body(context),
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            placeholder: Text(
              CompanyRegisterScreenLocal.companyEmailPlaceholder.getString(
                context,
              ),
              style: TextStyle(fontSize: FontSizeConfig.body(context)),
            ),
          ),
          const SizedBox(height: 15),

          // Company Password
          ShadInputFormField(
            controller: password,
            validator: (value) => requiredValidator(value, context),
            obscureText: true,
            label: Padding(
              padding: const EdgeInsets.only(bottom: 5),
              child: Text(
                CompanyRegisterScreenLocal.companyPassword.getString(context),
                style: TextStyle(
                  fontSize: FontSizeConfig.body(context),
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            placeholder: Text(
              CompanyRegisterScreenLocal.companyPasswordPlaceholder.getString(
                context,
              ),
              style: TextStyle(fontSize: FontSizeConfig.body(context)),
            ),
          ),
          const SizedBox(height: 15),

          // Company Phone
          ShadInputFormField(
            controller: phone,
            validator: (value) => requiredValidator(value, context),
            label: Padding(
              padding: const EdgeInsets.only(bottom: 5),
              child: Text(
                CompanyRegisterScreenLocal.companyPhone.getString(context),
                style: TextStyle(
                  fontSize: FontSizeConfig.body(context),
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            placeholder: Text(
              CompanyRegisterScreenLocal.companyPhonePlaceholder.getString(
                context,
              ),
              style: TextStyle(fontSize: FontSizeConfig.body(context)),
            ),
          ),
          const SizedBox(height: 20),
          // Company Address
          ShadInputFormField(
            controller: address,
            validator: (value) => requiredValidator(value, context),
            label: Padding(
              padding: const EdgeInsets.only(bottom: 5),
              child: Text(
                CompanyRegisterScreenLocal.companyAddress.getString(context),
                style: TextStyle(
                  fontSize: FontSizeConfig.body(context),
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            placeholder: Text(
              CompanyRegisterScreenLocal.companyAddressPlaceholder.getString(
                context,
              ),
              style: TextStyle(fontSize: FontSizeConfig.body(context)),
            ),
          ),
          const SizedBox(height: 20),
          // Add Company Button
          ShadButton(
            width: double.infinity,
            onPressed: () {
              print("what is ");
              if (_formKey.currentState!.validate()) {
                submit();
              }
            },
            child: Text(
              CompanyRegisterScreenLocal.companyButton.getString(context),
            ),
          ),
        ],
      ),
    );
  }
}
