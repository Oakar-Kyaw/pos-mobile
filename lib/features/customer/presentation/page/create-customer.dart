import 'package:flutter/material.dart';
import 'package:flutter_localization/flutter_localization.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:pos/localization/customer-local.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

import 'package:pos/features/customer/presentation/provider/customer-provider.dart';
import 'package:pos/utils/app-theme.dart';
import 'package:pos/utils/button.dart';
import 'package:pos/utils/route-constant.dart';
import 'package:pos/utils/shad-toaster.dart';

class CreateCustomerPage extends ConsumerStatefulWidget {
  const CreateCustomerPage({super.key});

  @override
  ConsumerState<CreateCustomerPage> createState() => _CreateCustomerPageState();
}

class _CreateCustomerPageState extends ConsumerState<CreateCustomerPage> {
  final _formKey = GlobalKey<ShadFormState>();

  final nameController = TextEditingController();
  final emailController = TextEditingController();
  final phoneController = TextEditingController();
  final addressController = TextEditingController();

  @override
  void dispose() {
    nameController.dispose();
    emailController.dispose();
    phoneController.dispose();
    addressController.dispose();

    super.dispose();
  }

  // ============================================================
  // CREATE CUSTOMER
  // ============================================================

  Future<void> createCustomer() async {
    if (nameController.text.trim().isEmpty) {
      ShowToast(
        context,
        description: Text(
          CustomerLocale.customerNameRequired.getString(context),
          style: const TextStyle(color: Colors.red),
        ),
        borderColor: Colors.red,
        isError: true,
      );

      return;
    }

    final payload = {
      'name': nameController.text.trim(),
      'email': emailController.text.trim().isEmpty
          ? null
          : emailController.text.trim(),
      'phone': phoneController.text.trim().isEmpty
          ? null
          : phoneController.text.trim(),
      'address': addressController.text.trim().isEmpty
          ? null
          : addressController.text.trim(),
    };

    try {
      final success = await ref
          .read(customerProvider.notifier)
          .createCustomer(payload);

      if (!mounted) return;

      if (success) {
        ShowToast(
          context,
          description: Text(
            CustomerLocale.customerCreateSuccess.getString(context),
            style: const TextStyle(color: Colors.green),
          ),
          borderColor: Colors.green,
        );

        context.pushNamed(AppRoute.customer);
      }
    } catch (e) {
      debugPrint('Create customer error: $e');

      if (!mounted) return;

      ShowToast(
        context,
        description: Text(
          e.toString(),
          style: const TextStyle(color: Colors.red),
        ),
        borderColor: Colors.red,
        isError: true,
      );
    }
  }

  // ============================================================
  // BUILD
  // ============================================================

  @override
  Widget build(BuildContext context) {
    final isDark = ref.watch(themeModeProvider) == ThemeMode.dark;

    final bgColor = isDark ? kBgDark : kBgLight;
    final surfaceColor = isDark ? kSurfaceDark : kSurfaceLight;
    final textColor = isDark ? kTextDark : kTextLight;
    final subColor = isDark ? kTextSubDark : kTextSubLight;

    return Scaffold(
      backgroundColor: bgColor,

      // ============================================================
      // APP BAR
      // ============================================================
      appBar: AppBar(
        backgroundColor: bgColor,
        foregroundColor: textColor,
        title: Text(
          CustomerLocale.customerCreate.getString(context),
          style: TextStyle(color: textColor),
        ),
      ),

      // ============================================================
      // BODY
      // ============================================================
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),

        child: ShadForm(
          key: _formKey,

          child: Column(
            children: [
              // ======================================================
              // CUSTOMER FORM
              // ======================================================
              ShadCard(
                backgroundColor: surfaceColor,

                child: Column(
                  children: [
                    // ==================================================
                    // NAME
                    // ==================================================
                    ShadInputFormField(
                      id: 'name',
                      controller: nameController,
                      label: Text(
                        CustomerLocale.customerName.getString(context),
                        style: TextStyle(color: subColor),
                      ),
                      placeholder: Text(
                        CustomerLocale.customerName.getString(context),
                      ),
                    ),

                    const SizedBox(height: 16),

                    // ==================================================
                    // EMAIL
                    // ==================================================
                    ShadInputFormField(
                      id: 'email',
                      controller: emailController,
                      keyboardType: TextInputType.emailAddress,
                      label: Text(
                        CustomerLocale.customerEmail.getString(context),
                        style: TextStyle(color: subColor),
                      ),
                      placeholder: Text(
                        CustomerLocale.customerEmail.getString(context),
                      ),
                    ),

                    const SizedBox(height: 16),

                    // ==================================================
                    // PHONE
                    // ==================================================
                    ShadInputFormField(
                      id: 'phone',
                      controller: phoneController,
                      keyboardType: TextInputType.phone,
                      label: Text(
                        CustomerLocale.customerPhone.getString(context),
                        style: TextStyle(color: subColor),
                      ),
                      placeholder: Text(
                        CustomerLocale.customerPhone.getString(context),
                      ),
                    ),

                    const SizedBox(height: 16),

                    // ==================================================
                    // ADDRESS
                    // ==================================================
                    ShadInputFormField(
                      id: 'address',
                      controller: addressController,
                      maxLines: 3,
                      label: Text(
                        CustomerLocale.customerAddress.getString(context),
                        style: TextStyle(color: subColor),
                      ),
                      placeholder: Text(
                        CustomerLocale.customerAddress.getString(context),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // ======================================================
              // CREATE BUTTON
              // ======================================================
              GradientSubmitButton(
                onPressed: createCustomer,
                text: CustomerLocale.customerCreate.getString(context),
                width: double.infinity,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
