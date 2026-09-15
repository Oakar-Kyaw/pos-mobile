import 'package:flutter/material.dart';
import 'package:flutter_localization/flutter_localization.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:pos/localization/supplier-local.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

import 'package:pos/features/supplier/presentation/provider/supplier-provider.dart';
import 'package:pos/utils/app-theme.dart';
import 'package:pos/utils/button.dart';
import 'package:pos/utils/route-constant.dart';
import 'package:pos/utils/shad-toaster.dart';

class CreateSupplierPage extends ConsumerStatefulWidget {
  const CreateSupplierPage({super.key});

  @override
  ConsumerState<CreateSupplierPage> createState() => _CreateSupplierPageState();
}

class _CreateSupplierPageState extends ConsumerState<CreateSupplierPage> {
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

  Future<void> createSupplier() async {
    if (nameController.text.trim().isEmpty) {
      ShowToast(
        context,
        description: Text(
          SupplierLocale.supplierNameRequired.getString(context),
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
          .read(supplierProvider.notifier)
          .createSupplier(payload);

      if (!mounted) return;

      if (success) {
        ShowToast(
          context,
          description: Text(
            SupplierLocale.supplierCreateSuccess.getString(context),
            style: const TextStyle(color: Colors.green),
          ),
          borderColor: Colors.green,
        );

        context.pushNamed(AppRoute.supplier);
      }
    } catch (e) {
      debugPrint('Create supplier error: $e');

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

  @override
  Widget build(BuildContext context) {
    final isDark = ref.watch(themeModeProvider) == ThemeMode.dark;

    final bgColor = isDark ? kBgDark : kBgLight;
    final surfaceColor = isDark ? kSurfaceDark : kSurfaceLight;
    final textColor = isDark ? kTextDark : kTextLight;
    final subColor = isDark ? kTextSubDark : kTextSubLight;

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        backgroundColor: bgColor,
        foregroundColor: textColor,
        title: Text(
          SupplierLocale.supplierCreate.getString(context),
          style: TextStyle(color: textColor),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: ShadForm(
          key: _formKey,
          child: Column(
            children: [
              ShadCard(
                backgroundColor: surfaceColor,
                child: Column(
                  children: [
                    ShadInputFormField(
                      id: 'name',
                      controller: nameController,
                      label: Text(
                        SupplierLocale.supplierName.getString(context),
                        style: TextStyle(color: subColor),
                      ),
                      placeholder: Text(
                        SupplierLocale.supplierName.getString(context),
                      ),
                    ),

                    const SizedBox(height: 16),

                    ShadInputFormField(
                      id: 'email',
                      controller: emailController,
                      keyboardType: TextInputType.emailAddress,
                      label: Text(
                        SupplierLocale.supplierEmail.getString(context),
                        style: TextStyle(color: subColor),
                      ),
                      placeholder: Text(
                        SupplierLocale.supplierEmail.getString(context),
                      ),
                    ),

                    const SizedBox(height: 16),

                    ShadInputFormField(
                      id: 'phone',
                      controller: phoneController,
                      keyboardType: TextInputType.phone,
                      label: Text(
                        SupplierLocale.supplierPhone.getString(context),
                        style: TextStyle(color: subColor),
                      ),
                      placeholder: Text(
                        SupplierLocale.supplierPhone.getString(context),
                      ),
                    ),

                    const SizedBox(height: 16),

                    ShadInputFormField(
                      id: 'address',
                      controller: addressController,
                      maxLines: 3,
                      label: Text(
                        SupplierLocale.supplierAddress.getString(context),
                        style: TextStyle(color: subColor),
                      ),
                      placeholder: Text(
                        SupplierLocale.supplierAddress.getString(context),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              GradientSubmitButton(
                onPressed: createSupplier,
                text: SupplierLocale.supplierCreate.getString(context),
                width: double.infinity,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
