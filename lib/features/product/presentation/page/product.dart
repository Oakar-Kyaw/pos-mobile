import 'dart:io';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:dio/dio.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_localization/flutter_localization.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:pos/api/product.api.dart';
import 'package:pos/component/app-bar.dart';
import 'package:pos/core/utils/confirm-dialog.dart';
import 'package:pos/features/product/presentation/widget/product-form.dart';
import 'package:pos/localization/product-local.dart';
import 'package:pos/localization/refund-local.dart';
import 'package:pos/utils/app-theme.dart';
import 'package:pos/utils/button.dart';
import 'package:shadcn_ui/shadcn_ui.dart';
import 'package:flutter_file_downloader/flutter_file_downloader.dart';

class ProductPage extends ConsumerStatefulWidget {
  const ProductPage({super.key});

  @override
  ConsumerState<ProductPage> createState() => _ProductPageState();
}

class _ProductPageState extends ConsumerState<ProductPage> {
  double _downloadProgress = 0;
  bool _isDownloading = false;
  bool _downloadCompleted = false;
  String? _downloadedPath;

  double _uploadProgress = 0;
  bool _isUploading = false;
  bool _uploadCompleted = false;

  // Future<void> _openExcelFolder() async {
  //   try {
  //     if (Platform.isIOS) {
  //       if (!mounted) return;

  //       ScaffoldMessenger.of(context).showSnackBar(
  //         SnackBar(
  //           content: Text(
  //             _downloadedPath != null
  //                 ? "${ProductScreenLocale.savedTo.getString(context)}: $_downloadedPath\n${ProductScreenLocale.openFilesApp.getString(context)}"
  //                 : ProductScreenLocale.fileSavedSuccessfully.getString(
  //                     context,
  //                   ),
  //           ),
  //           duration: const Duration(seconds: 5),
  //         ),
  //       );
  //       return;
  //     }

  //     final result = await OpenFolder.openFolder(
  //       "/storage/emulated/0/Download/POS Master/Excel/",
  //     );

  //     if (!result.isSuccess && mounted) {
  //       ScaffoldMessenger.of(context).showSnackBar(
  //         SnackBar(
  //           content: Text(
  //             "${ProductScreenLocale.couldNotOpenFolder.getString(context)}: ${result.message}",
  //           ),
  //         ),
  //       );
  //     }
  //   } catch (e) {
  //     if (!mounted) return;

  //     ScaffoldMessenger.of(context).showSnackBar(
  //       SnackBar(
  //         content: Text(
  //           "${ProductScreenLocale.couldNotOpenFolder.getString(context)}: $e",
  //         ),
  //       ),
  //     );
  //   }
  // }

  Future<bool> _requestStoragePermission() async {
    if (!Platform.isAndroid) return true;

    final androidInfo = await DeviceInfoPlugin().androidInfo;
    debugPrint("📱 Android SDK: ${androidInfo.version.sdkInt}");

    if (androidInfo.version.sdkInt >= 30) {
      final status = await Permission.manageExternalStorage.request();
      debugPrint("🔐 manageExternalStorage status: $status");
      return status.isGranted;
    } else {
      final status = await Permission.storage.request();
      debugPrint("🔐 storage status: $status");
      return status.isGranted;
    }
  }

  Future<void> _downloadFromNetwork() async {
    debugPrint("🟢 _downloadFromNetwork called");

    final hasPermission = await _requestStoragePermission();
    debugPrint("🟢 hasPermission: $hasPermission");

    if (!hasPermission) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            ProductScreenLocale.storagePermissionRequired.getString(context),
          ),
        ),
      );
      return;
    }

    final url = dotenv.env["DOWNLOAD_URL"] ?? "";
    debugPrint("🟢 Download URL: $url");

    if (url.isEmpty) {
      debugPrint("🔴 URL is empty, returning early");

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            ProductScreenLocale.downloadUrlUnavailable.getString(context),
          ),
        ),
      );
      return;
    }

    setState(() {
      _downloadProgress = 0;
      _isDownloading = true;
      _downloadCompleted = false;
      _downloadedPath = null;
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
                _downloadCompleted
                    ? ProductScreenLocale.downloadComplete.getString(context)
                    : ProductScreenLocale.downloading.getString(context),
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (!_downloadCompleted) ...[
                    LinearProgressIndicator(value: _downloadProgress / 100),
                    const SizedBox(height: 12),
                    Text(
                      "${_downloadProgress.toStringAsFixed(0)}%",
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                  if (_downloadCompleted)
                    Text(
                      ProductScreenLocale.productExcelDownloaded.getString(
                        context,
                      ),
                    ),
                ],
              ),
            );
          },
        );
      },
    );

    debugPrint("🟢 Calling FileDownloader.downloadFile...");

    final subPath = Platform.isIOS ? null : "POS Master/Excel";

    FileDownloader.downloadFile(
      url: url,
      name: "Product Excel.xlsx",
      subPath: subPath,
      onProgress: (fileName, value) {
        debugPrint("🟡 file name: $fileName, progress: $value");

        if (!mounted) return;

        setState(() {
          _downloadProgress = value;
        });

        dialogSetState?.call(() {});
      },
      onDownloadCompleted: (String path) async {
        debugPrint("✅ FILE DOWNLOADED TO PATH: $path");

        if (!mounted) return;

        setState(() {
          _downloadProgress = 100;
          _isDownloading = false;
          _downloadCompleted = true;
          _downloadedPath = path;
        });

        if (Navigator.canPop(context)) {
          Navigator.pop(context);
        }

        if (!mounted) return;

        final openFolder = await showConfirmDialog(
          context,
          title: ProductScreenLocale.downloadComplete.getString(context),
          content: ProductScreenLocale.productExcelDownloaded.getString(
            context,
          ),
          confirmLabel: Platform.isIOS
              ? ProductScreenLocale.viewLocation.getString(context)
              : ProductScreenLocale.openFolder.getString(context),
          cancelLabel: RefundLocale.cancel.getString(context),
        );

        // if (openFolder == true) {
        //   await _openExcelFolder();
        // }
      },
      onDownloadError: (String error) async {
        debugPrint("🔴 DOWNLOAD ERROR: $error");

        if (!mounted) return;

        setState(() {
          _isDownloading = false;
          _downloadCompleted = false;
        });

        if (Navigator.canPop(context)) {
          Navigator.pop(context);
        }

        if (!mounted) return;

        await showConfirmDialog(
          context,
          title: ProductScreenLocale.downloadFailed.getString(context),
          content: error,
          confirmLabel: "OK",
          cancelLabel: "",
        );
      },
    );
  }

  Future<void> _uploadExcelFile() async {
    debugPrint("🟣 _uploadExcelFile called");

    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['xlsx'],
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
                    ? ProductScreenLocale.uploadComplete.getString(context)
                    : ProductScreenLocale.uploading.getString(context),
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
                    Text(
                      ProductScreenLocale.productExcelUploaded.getString(
                        context,
                      ),
                    ),
                ],
              ),
            );
          },
        );
      },
    );

    try {
      final response = await ref
          .read(productProvider.notifier)
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
        title: ProductScreenLocale.uploadComplete.getString(context),
        content: ProductScreenLocale.productExcelUploaded.getString(context),
        confirmLabel: "OK",
        cancelLabel: "",
      );
    } on DioException catch (e) {
      debugPrint("🔴 UPLOAD ERROR (Dio): ${e.message}");

      String errorMessage = ProductScreenLocale.uploadFailed.getString(context);

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
        title: ProductScreenLocale.uploadFailed.getString(context),
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
        title: ProductScreenLocale.uploadFailed.getString(context),
        content: e.toString(),
        confirmLabel: "OK",
        cancelLabel: "",
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = ref.watch(themeModeProvider) == ThemeMode.dark;

    final bgColor = isDark ? kBgDark : kBgLight;
    final surfaceColor = isDark ? kSurfaceDark : kSurfaceLight;

    return Scaffold(
      backgroundColor: bgColor,
      appBar: CustomAppBar(
        leading: IconButton(
          onPressed: () => context.pop(),
          icon: const Icon(LucideIcons.arrowLeft),
        ),
        title: ProductScreenLocale.productTitle.getString(context),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        child: Column(
          children: [
            Row(
              children: [
                // Expanded(
                //   child: GradientSubmitButton(
                //     onPressed: _downloadFromNetwork,
                //     text: _isDownloading
                //         ? ProductScreenLocale.downloading.getString(context)
                //         : ProductScreenLocale.getExcel.getString(context),
                //     width: double.infinity,
                //   ),
                // ),
                const SizedBox(width: 16),
                Expanded(
                  child: GradientSubmitButton(
                    onPressed: _isUploading ? () {} : _uploadExcelFile,
                    text: _isUploading
                        ? ProductScreenLocale.uploading.getString(context)
                        : ProductScreenLocale.uploadExcel.getString(context),
                    width: double.infinity,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Container(
                  width: 4,
                  height: 18,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [kPrimary, kSecondary],
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                    ),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(width: 10),
                Text(
                  ProductScreenLocale.productTitle.getString(context),
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: isDark ? kTextDark : kTextLight,
                    letterSpacing: -0.2,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  color: surfaceColor,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: isDark
                          ? kPrimary.withOpacity(0.1)
                          : Colors.black.withOpacity(0.06),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                clipBehavior: Clip.antiAlias,
                child: const SingleChildScrollView(
                  padding: EdgeInsets.all(20),
                  child: ProductForm(),
                ),
              ),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}
