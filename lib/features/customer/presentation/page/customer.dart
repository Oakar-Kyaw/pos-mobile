import 'dart:io';

import 'package:dio/dio.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localization/flutter_localization.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:go_router/go_router.dart';
import 'package:pos/component/app-bar.dart';
import 'package:pos/core/utils/confirm-dialog.dart';
import 'package:pos/features/customer/data/model/customer-model.dart';
import 'package:pos/features/customer/presentation/page/customer-list.dart';
import 'package:pos/features/customer/presentation/provider/customer-provider.dart';
import 'package:pos/localization/customer-local.dart';
import 'package:pos/utils/app-theme.dart';
import 'package:pos/utils/button.dart';
import 'package:pos/utils/inventory-configuration.dart';
import 'package:pos/utils/responsive.dart';
import 'package:pos/utils/route-constant.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

final editingCustomerIdProvider = StateProvider<int?>((ref) => null);

class CustomerPage extends ConsumerStatefulWidget {
  const CustomerPage({super.key});

  @override
  ConsumerState<CustomerPage> createState() => _CustomerPageState();
}

class _CustomerPageState extends ConsumerState<CustomerPage> {
  double _uploadProgress = 0;
  bool _isUploading = false;
  bool _uploadCompleted = false;

  //upload excel
  Future<void> _uploadExcelFile() async {
    debugPrint("🟣 _uploadExcelFile called");

    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['xlsx', 'xls'],
    );

    if (result == null || result.files.single.path == null) {
      debugPrint("🟣 No file selected");
      return;
    }

    final file = File(result.files.single.path!);
    debugPrint("🟣 Picked file: ${file.path}");

    setState(() {
      _uploadProgress = 0;
      _isUploading = true;
      _uploadCompleted = false;
    });

    if (!mounted) return;

    StateSetter? dialogSetState;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            dialogSetState = setDialogState;

            return AlertDialog(
              title: Text(
                _uploadCompleted
                    ? CustomerLocale.customerUploadComplete.getString(context)
                    : CustomerLocale.customerUploading.getString(context),
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (!_uploadCompleted) ...[
                    LinearProgressIndicator(value: _uploadProgress / 100),
                    const SizedBox(height: 12),
                    Text(
                      "${_uploadProgress.toStringAsFixed(0)}%",
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                  if (_uploadCompleted)
                    Text(CustomerLocale.customerUploaded.getString(context)),
                ],
              ),
            );
          },
        );
      },
    );

    try {
      final response = await ref
          .read(customerProvider.notifier)
          .uploadProductExcel(
            file,
            onSendProgress: (sent, total) {
              if (total <= 0) return;

              final percent = (sent / total) * 100;

              debugPrint("🟡 Upload progress: $percent%");

              if (!mounted) return;

              setState(() {
                _uploadProgress = percent;
              });

              dialogSetState?.call(() {});
            },
          );

      debugPrint("✅ UPLOAD RESPONSE: $response");

      if (!mounted) return;

      setState(() {
        _uploadProgress = 100;
        _isUploading = false;
        _uploadCompleted = true;
      });

      if (Navigator.canPop(context)) {
        Navigator.pop(context);
      }

      if (!mounted) return;

      await showConfirmDialog(
        context,
        title: CustomerLocale.customerUploadComplete.getString(context),
        content: CustomerLocale.customerUploaded.getString(context),
        confirmLabel: "OK",
        cancelLabel: "",
      );
    } on DioException catch (e) {
      debugPrint("🔴 UPLOAD ERROR (Dio): ${e.message}");

      String errorMessage = CustomerLocale.customerUploadFailed.getString(
        context,
      );

      if (e.response?.data != null && e.response!.data is Map) {
        final data = e.response!.data as Map;
        errorMessage = data['message']?.toString() ?? errorMessage;
      }

      if (!mounted) return;

      setState(() {
        _isUploading = false;
        _uploadCompleted = false;
      });

      if (Navigator.canPop(context)) {
        Navigator.pop(context);
      }

      if (!mounted) return;

      await showConfirmDialog(
        context,
        title: CustomerLocale.customerUploadFailed.getString(context),
        content: errorMessage,
        confirmLabel: "OK",
        cancelLabel: "",
      );
    } catch (e) {
      debugPrint("🔴 UPLOAD ERROR: $e");

      if (!mounted) return;

      setState(() {
        _isUploading = false;
        _uploadCompleted = false;
      });

      if (Navigator.canPop(context)) {
        Navigator.pop(context);
      }

      if (!mounted) return;

      await showConfirmDialog(
        context,
        title: CustomerLocale.customerUploadFailed.getString(context),
        content: e.toString(),
        confirmLabel: "OK",
        cancelLabel: "",
      );
    }
  }

  //Widget for responsive
  Widget _buildActionButtons(BuildContext context) {
    final createButton = GradientSubmitButton(
      onPressed: () {
        context.pushNamed(AppRoute.customerCreate);
      },
      text: CustomerLocale.customerCreate.getString(context),
      width: double.infinity,
    );

    final uploadButton = GradientSubmitButton(
      onPressed: _isUploading ? () {} : _uploadExcelFile,
      text: _isUploading
          ? CustomerLocale.customerUploading.getString(context)
          : CustomerLocale.customerUploadExcel.getString(context),
      width: double.infinity,
      decoration: BoxDecoration(color: kGreen),
    );

    // TABLET
    if (Responsive.isTablet(context) || Responsive.isDesktop(context)) {
      return Row(
        children: [
          Expanded(child: createButton),
          const SizedBox(width: 12),
          Expanded(child: uploadButton),
        ],
      );
    }

    // PHONE
    return Column(
      children: [createButton, const SizedBox(height: 10), uploadButton],
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = ref.watch(themeModeProvider) == ThemeMode.dark;

    final bgColor = isDark ? kBgDark : kBgLight;

    final config = InventoryActionConfig('Customer', context);

    return Scaffold(
      backgroundColor: bgColor,

      appBar: CustomAppBar(
        leading: IconButton(
          onPressed: () => context.pop(),
          icon: const Icon(LucideIcons.arrowLeft),
        ),
        title: CustomerLocale.customerManagementTitle.getString(context),
      ),

      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildActionButtons(context),
            const SizedBox(height: 20),

            /// ==========================
            /// CUSTOMER LIST
            /// ==========================
            const Expanded(child: CustomerLists()),
          ],
        ),
      ),
    );
  }
}
