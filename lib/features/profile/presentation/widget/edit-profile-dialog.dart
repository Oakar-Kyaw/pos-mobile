import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:pos/api/user.api.dart';
import 'package:pos/features/profile/data/model/user.dart';
import 'package:pos/riverpod/user.riverpod.dart';
import 'package:pos/utils/app-theme.dart';
import 'package:pos/utils/font-size.dart';
import 'package:pos/utils/shad-toaster.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

class EditProfileDialog extends ConsumerStatefulWidget {
  const EditProfileDialog({super.key, required this.user});

  final User user;

  @override
  ConsumerState<EditProfileDialog> createState() => _EditProfileDialogState();
}

class _EditProfileDialogState extends ConsumerState<EditProfileDialog> {
  late final TextEditingController _firstNameController;
  late final TextEditingController _lastNameController;
  late final TextEditingController _emailController;
  late final TextEditingController _phoneController;
  late final TextEditingController _addressController;
  final TextEditingController _passwordController = TextEditingController();

  File? _pickedPhoto;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();

    _firstNameController = TextEditingController(
      text: widget.user.firstName ?? '',
    );

    _lastNameController = TextEditingController(
      text: widget.user.lastName ?? '',
    );

    _emailController = TextEditingController(text: widget.user.email ?? '');

    _phoneController = TextEditingController(text: widget.user.phone ?? '');

    _addressController = TextEditingController(text: widget.user.address ?? '');
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    _passwordController.dispose();
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
    if (_firstNameController.text.trim().isEmpty) {
      ShowToast(
        context,
        isError: true,
        description: const Text(
          "First name is required",
          style: TextStyle(color: kRed),
        ),
      );

      return false;
    }

    if (_passwordController.text.isNotEmpty &&
        _passwordController.text.length < 6) {
      ShowToast(
        context,
        isError: true,
        description: const Text(
          "Password must be at least 6 characters",
          style: TextStyle(color: kRed),
        ),
      );

      return false;
    }

    return true;
  }

  void _save(int id) async {
    if (!_validate()) return;

    setState(() => _isSaving = true);

    try {
      final formData = FormData.fromMap({
        "firstName": _firstNameController.text.trim(),
        "lastName": _lastNameController.text.trim(),
        "email": _emailController.text.trim(),
        "phone": _phoneController.text.trim(),
        "address": _addressController.text.trim(),
        if (_passwordController.text.isNotEmpty)
          "password": _passwordController.text,
        if (_pickedPhoto != null)
          "photoUrl": await MultipartFile.fromFile(
            _pickedPhoto!.path,
            filename: _pickedPhoto!.path.split('/').last,
          ),
      });

      final success = await ref
          .read(userProvider.notifier)
          .updateUser(id, formData);

      if (!mounted) return;

      if (success) {
        final latestUser = await ref
            .read(userProvider.notifier)
            .getUserById(userId: id);

        ref.read(userStateProvider.notifier).state = latestUser;

        if (!mounted) return;

        context.pop();

        ShowToast(
          context,
          description: const Text(
            "Profile updated successfully",
            style: TextStyle(color: kGreen),
          ),
        );
      } else {
        ShowToast(
          context,
          isError: true,
          description: const Text(
            "Failed to update profile",
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
      if (mounted) {
        ShowToast(
          context,
          isError: true,
          description: const Text(
            "Something went wrong",
            style: TextStyle(color: kRed),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isSaving = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = ref.watch(themeModeProvider) == ThemeMode.dark;
    final user = ref.watch(userStateProvider);
    final surfaceColor = isDark ? kSurfaceDark : kSurfaceLight;
    final textColor = isDark ? kTextDark : kTextLight;

    final hasExistingPhoto =
        widget.user.photoUrl != null && widget.user.photoUrl!.isNotEmpty;

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
                "Edit Profile",
                style: TextStyle(
                  fontSize: FontSizeConfig.title(context),
                  fontWeight: FontWeight.w700,
                  color: textColor,
                ),
              ),

              const SizedBox(height: 16),

              Center(
                child: GestureDetector(
                  onTap: _pickPhoto,
                  child: Stack(
                    children: [
                      ClipOval(
                        child: _pickedPhoto != null
                            ? Image.file(
                                _pickedPhoto!,
                                width: 88,
                                height: 88,
                                fit: BoxFit.cover,
                              )
                            : hasExistingPhoto
                            ? CachedNetworkImage(
                                imageUrl: widget.user.photoUrl!,
                                width: 88,
                                height: 88,
                                fit: BoxFit.cover,
                                errorWidget: (context, url, error) => Container(
                                  width: 88,
                                  height: 88,
                                  color: kPrimary.withOpacity(0.1),
                                  child: const Icon(
                                    LucideIcons.user,
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
                                  LucideIcons.user,
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

              _FieldLabel("First Name", textColor),
              const SizedBox(height: 6),
              ShadInput(controller: _firstNameController),

              const SizedBox(height: 16),

              _FieldLabel("Last Name", textColor),
              const SizedBox(height: 6),
              ShadInput(controller: _lastNameController),

              const SizedBox(height: 16),

              _FieldLabel("Email", textColor),
              const SizedBox(height: 6),
              ShadInput(
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
              ),

              const SizedBox(height: 16),

              _FieldLabel("Phone", textColor),
              const SizedBox(height: 6),
              ShadInput(
                controller: _phoneController,
                keyboardType: TextInputType.phone,
              ),

              const SizedBox(height: 16),

              _FieldLabel("Address", textColor),
              const SizedBox(height: 6),
              ShadInput(controller: _addressController, maxLines: 2),

              const SizedBox(height: 16),

              _FieldLabel("New Password (optional)", textColor),
              const SizedBox(height: 6),
              ShadInput(
                controller: _passwordController,
                obscureText: true,
                placeholder: const Text("Leave blank to keep current password"),
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
                    onPressed: _isSaving ? null : () => _save(user!.id),
                    child: _isSaving
                        ? const SizedBox(
                            height: 18,
                            width: 18,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : const Text(
                            "Save",
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
