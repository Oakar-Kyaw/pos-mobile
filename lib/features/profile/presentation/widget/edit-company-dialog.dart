import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localization/flutter_localization.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:pos/api/company.api.dart';
import 'package:pos/features/company/data/model/company.dart';
import 'package:pos/localization/company-local.dart';
import 'package:pos/utils/app-theme.dart';
import 'package:pos/utils/font-size.dart';
import 'package:pos/utils/shad-toaster.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

class EditCompanyDialog extends ConsumerStatefulWidget {
  const EditCompanyDialog({super.key, required this.company});

  final Company company;

  @override
  ConsumerState<EditCompanyDialog> createState() => _EditCompanyDialogState();
}

class _EditCompanyDialogState extends ConsumerState<EditCompanyDialog> {
  late final TextEditingController _nameController;
  late final TextEditingController _emailController;
  late final TextEditingController _phoneController;
  late final TextEditingController _addressController;
  late final TextEditingController _codeController;
  late final TextEditingController _countryController;
  File? _pickedPhoto;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.company.name);
    _emailController = TextEditingController(text: widget.company.email);
    _phoneController = TextEditingController(text: widget.company.phone ?? '');
    _addressController = TextEditingController(
      text: widget.company.address ?? '',
    );
    _codeController = TextEditingController(text: widget.company.code ?? '');
    _countryController = TextEditingController(text: widget.company.country);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    _codeController.dispose();
    _countryController.dispose();
    super.dispose();
  }

  Future<void> _pickPhoto() async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 80,
    );
    if (picked != null) {
      setState(() => _pickedPhoto = File(picked.path));
    }
  }

  bool _validate() {
    debugPrint("validate for company edit ${_nameController.text.trim()}");
    if (_nameController.text.trim().isEmpty) {
      ShowToast(
        context,
        isError: true,
        description: const Text(
          "Company name is required",
          style: TextStyle(color: kRed),
        ),
      );
      return false;
    }
    final email = _emailController.text.trim();
    final emailRegex = RegExp(r'^[\w\.\-]+@([\w\-]+\.)+[\w\-]{2,4}$');
    if (email.isEmpty || !emailRegex.hasMatch(email)) {
      ShowToast(
        context,
        isError: true,
        description: const Text(
          "A valid email is required",
          style: TextStyle(color: kRed),
        ),
      );
      return false;
    }
    if (_countryController.text.trim().isEmpty) {
      ShowToast(
        context,
        isError: true,
        description: const Text(
          "Country is required",
          style: TextStyle(color: kRed),
        ),
      );
      return false;
    }
    return true;
  }

  void _save() async {
    if (!_validate()) return;
    setState(() => _isSaving = true);
    debugPrint("Edit company edit ✍️ $_nameController");
    try {
      final formData = FormData.fromMap({
        "name": _nameController.text.trim(),
        "email": _emailController.text.trim().toLowerCase(),
        "phone": _phoneController.text.trim(),
        "address": _addressController.text.trim(),
        "code": _codeController.text.trim(),
        "country": _countryController.text.trim(),
        if (_pickedPhoto != null)
          "photoUrl": await MultipartFile.fromFile(
            _pickedPhoto!.path,
            filename: _pickedPhoto!.path.split('/').last,
          ),
      });

      final success = await ref
          .read(companyProvider.notifier)
          .updateCompany(widget.company.id, formData);

      if (!mounted) return;

      if (success) {
        Navigator.of(context).pop(true);
        ShowToast(
          context,
          description: const Text(
            "Company updated successfully",
            style: TextStyle(color: kGreen),
          ),
        );
      } else {
        ShowToast(
          context,
          isError: true,
          description: const Text(
            "Failed to update company",
            style: TextStyle(color: kRed),
          ),
        );
      }
    } on DioException catch (e) {
      String errorMessage = 'Update failed';
      if (e.response?.data != null && e.response?.data is Map) {
        final data = e.response!.data as Map;
        errorMessage = data['message']?.toString() ?? errorMessage;
      }
      if (mounted) {
        ShowToast(
          context,
          isError: true,
          description: Text(errorMessage, style: const TextStyle(color: kRed)),
        );
      }
    } catch (e) {
      ShowToast(
        context,
        isError: true,
        description: const Text(
          "Something went wrong",
          style: TextStyle(color: kRed),
        ),
      );
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = ref.watch(themeModeProvider) == ThemeMode.dark;
    final surfaceColor = isDark ? kSurfaceDark : kSurfaceLight;
    final textColor = isDark ? kTextDark : kTextLight;
    final hasExistingPhoto =
        widget.company.photoUrl != null && widget.company.photoUrl!.isNotEmpty;

    return AlertDialog(
      insetPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 24),
      backgroundColor: surfaceColor,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      content: SizedBox(
        width: double.maxFinite,
        child: SingleChildScrollView(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom + 20,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                CompanyRegisterScreenLocal.editCompany.getString(context),
                style: TextStyle(
                  fontSize: FontSizeConfig.title(context),
                  fontWeight: FontWeight.w700,
                  color: textColor,
                ),
              ),
              const SizedBox(height: 16),

              // ── Photo picker ─────────────────
              Center(
                child: GestureDetector(
                  onTap: _pickPhoto,
                  child: Stack(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(16),
                        child: _pickedPhoto != null
                            ? Image.file(
                                _pickedPhoto!,
                                width: 88,
                                height: 88,
                                fit: BoxFit.cover,
                              )
                            : hasExistingPhoto
                            ? CachedNetworkImage(
                                imageUrl: widget.company.photoUrl!,
                                width: 88,
                                height: 88,
                                fit: BoxFit.cover,
                                errorWidget: (context, url, error) => Container(
                                  width: 88,
                                  height: 88,
                                  color: kPrimary.withOpacity(0.1),
                                  child: const Icon(
                                    LucideIcons.building2,
                                    size: 32,
                                    color: kPrimary,
                                  ),
                                ),
                              )
                            : Container(
                                width: 88,
                                height: 88,
                                color: kPrimary.withOpacity(0.1),
                                child: const Icon(
                                  LucideIcons.building2,
                                  size: 32,
                                  color: kPrimary,
                                ),
                              ),
                      ),
                      Positioned(
                        bottom: -4,
                        right: -4,
                        child: Container(
                          padding: const EdgeInsets.all(6),
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [kPrimary, kSecondary],
                            ),
                            shape: BoxShape.circle,
                            border: Border.all(color: surfaceColor, width: 2),
                          ),
                          child: const Icon(
                            LucideIcons.camera,
                            size: 14,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),

              _FieldLabel(
                CompanyRegisterScreenLocal.companyName.getString(context),
                textColor,
              ),
              const SizedBox(height: 6),
              ShadInput(controller: _nameController),
              const SizedBox(height: 16),

              _FieldLabel(
                CompanyRegisterScreenLocal.companyCode.getString(context),
                textColor,
              ),
              const SizedBox(height: 6),
              ShadInput(controller: _codeController),
              const SizedBox(height: 16),

              _FieldLabel(
                CompanyRegisterScreenLocal.country.getString(context),
                textColor,
              ),
              const SizedBox(height: 6),
              ShadInput(controller: _countryController),
              const SizedBox(height: 16),

              _FieldLabel(
                CompanyRegisterScreenLocal.companyPhone.getString(context),
                textColor,
              ),
              const SizedBox(height: 6),
              ShadInput(
                controller: _phoneController,
                keyboardType: TextInputType.phone,
              ),
              const SizedBox(height: 16),

              _FieldLabel(
                CompanyRegisterScreenLocal.companyAddress.getString(context),
                textColor,
              ),
              const SizedBox(height: 6),
              ShadInput(controller: _addressController, maxLines: 2),
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
                    onPressed: _isSaving ? null : _save,
                    child: _isSaving
                        ? const SizedBox(
                            height: 18,
                            width: 18,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : Text(
                            CompanyRegisterScreenLocal.editCompany.getString(
                              context,
                            ),
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
        ),
      ),
    );
  }
}

class _FieldLabel extends StatelessWidget {
  const _FieldLabel(this.text, this.color);
  final String text;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: TextStyle(fontSize: FontSizeConfig.body(context), color: color),
    );
  }
}
