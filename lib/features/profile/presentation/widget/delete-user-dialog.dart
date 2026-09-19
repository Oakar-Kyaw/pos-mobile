import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localization/flutter_localization.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pos/api/user.api.dart';
import 'package:pos/localization/login-local.dart';
import 'package:pos/localization/profile-local.dart';
import 'package:pos/utils/app-theme.dart';
import 'package:pos/utils/shad-toaster.dart';

class DeleteAccountDialog extends ConsumerStatefulWidget {
  const DeleteAccountDialog({super.key});

  @override
  ConsumerState<DeleteAccountDialog> createState() =>
      _DeleteAccountDialogState();
}

class _DeleteAccountDialogState extends ConsumerState<DeleteAccountDialog> {
  final _formKey = GlobalKey<FormState>();
  final _passwordController = TextEditingController();

  bool _isLoading = false;
  String? _errorMessage;

  @override
  void dispose() {
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _deleteAccount() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    FocusScope.of(context).unfocus();

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      await ref
          .read(userProvider.notifier)
          .deleteAccount(password: _passwordController.text.trim());

      if (!mounted) return;

      Navigator.of(context).pop(true);
    } on DioException catch (e) {
      debugPrint("e of mesage is $e");
      if (!mounted) return;

      final responseData = e.response?.data;

      String message = 'Something went wrong.';

      if (e.toString().contains(LoginScreenLocale.passwordWrong)) {
        message = LoginScreenLocale.passwordWrong.getString(context);
      }

      setState(() {
        _isLoading = false;
        _errorMessage = message;
      });

      // ShowToast(
      //   context,
      //   description: Text(message, style: TextStyle(color: kRed)),
      //   isError: true,
      // );
    } catch (e) {
      if (!mounted) return;

      final message = e.toString().replaceFirst('Exception: ', '');

      setState(() {
        _isLoading = false;
        _errorMessage = message;
      });

      ShowToast(
        context,
        description: Text(message, style: TextStyle(color: kRed)),
        isError: true,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final keyboardHeight = MediaQuery.of(context).viewInsets.bottom;

    return AlertDialog(
      scrollable: true,
      insetPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
      title: Text(ProfileScreenLocale.deleteAccountTitle.getString(context)),
      content: Padding(
        padding: EdgeInsets.only(bottom: keyboardHeight > 0 ? 8 : 0),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(ProfileScreenLocale.deleteAccountMessage.getString(context)),
              const SizedBox(height: 16),
              TextFormField(
                controller: _passwordController,
                obscureText: true,
                enabled: !_isLoading,
                textInputAction: TextInputAction.done,
                onFieldSubmitted: (_) {
                  if (!_isLoading) {
                    _deleteAccount();
                  }
                },
                decoration: InputDecoration(
                  labelText: ProfileScreenLocale.deleteAccountPassword
                      .getString(context),
                  border: const OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return ProfileScreenLocale.deleteAccountPasswordRequired
                        .getString(context);
                  }

                  return null;
                },
              ),
              if (_errorMessage != null) ...[
                const SizedBox(height: 12),
                Text(
                  _errorMessage!,
                  style: TextStyle(color: Theme.of(context).colorScheme.error),
                ),
              ],
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: _isLoading
              ? null
              : () {
                  Navigator.of(context).pop(false);
                },
          child: Text(ProfileScreenLocale.profileCancel.getString(context)),
        ),
        FilledButton(
          style: FilledButton.styleFrom(
            backgroundColor: kRed,
            foregroundColor: Colors.white,
          ),
          onPressed: _isLoading ? null : _deleteAccount,
          child: _isLoading
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Colors.white,
                  ),
                )
              : Text(
                  ProfileScreenLocale.deleteAccountConfirm.getString(context),
                ),
        ),
      ],
    );
  }
}
