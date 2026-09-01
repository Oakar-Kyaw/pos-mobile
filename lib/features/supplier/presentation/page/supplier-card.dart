import 'package:flutter/material.dart';
import 'package:flutter_localization/flutter_localization.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pos/core/utils/check-email.dart';
import 'package:pos/core/utils/check-phone.dart';
import 'package:pos/core/widgets/custom-action-button.dart';
import 'package:pos/core/widgets/delete-icon.dart';
import 'package:pos/features/supplier/data/model/supplier.dart';
import 'package:pos/features/supplier/presentation/page/supplier.dart';
import 'package:pos/features/supplier/presentation/provider/supplier-provider.dart';
import 'package:pos/localization/general-local.dart';
import 'package:pos/localization/supplier-local.dart';
import 'package:pos/utils/app-theme.dart';
import 'package:pos/utils/font-size.dart';
import 'package:pos/utils/left-bar-accent.dart';
import 'package:pos/utils/shad-toaster.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

class SupplierCard extends ConsumerStatefulWidget {
  const SupplierCard({
    super.key,
    required this.supplier,
    required this.textColor,
    required this.subColor,
    this.onDelete,
    this.onEdit,
    this.onDetail,
  });

  final Supplier supplier;

  final Color textColor;
  final Color subColor;

  final VoidCallback? onDelete;
  final VoidCallback? onEdit;
  final VoidCallback? onDetail;

  @override
  ConsumerState<SupplierCard> createState() => _SupplierCardState();
}

class _SupplierCardState extends ConsumerState<SupplierCard> {
  late final TextEditingController _name;
  late final TextEditingController _phone;
  late final TextEditingController _email;
  late final TextEditingController _address;

  @override
  void initState() {
    super.initState();

    _name = TextEditingController(text: widget.supplier.name);

    _phone = TextEditingController(text: widget.supplier.phone ?? '');

    _email = TextEditingController(text: widget.supplier.email ?? '');

    _address = TextEditingController(text: widget.supplier.address ?? '');
  }

  @override
  void didUpdateWidget(covariant SupplierCard oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.supplier.id != widget.supplier.id ||
        oldWidget.supplier.name != widget.supplier.name ||
        oldWidget.supplier.phone != widget.supplier.phone ||
        oldWidget.supplier.email != widget.supplier.email ||
        oldWidget.supplier.address != widget.supplier.address) {
      _name.text = widget.supplier.name;
      _phone.text = widget.supplier.phone ?? '';
      _email.text = widget.supplier.email ?? '';
      _address.text = widget.supplier.address ?? '';
    }
  }

  @override
  void dispose() {
    _name.dispose();
    _phone.dispose();
    _email.dispose();
    _address.dispose();

    super.dispose();
  }

  bool get isEditing =>
      ref.watch(editingSupplierIdProvider) == widget.supplier.id;

  bool get isAnotherSupplierEditing {
    final editingId = ref.watch(editingSupplierIdProvider);

    return editingId != null && editingId != widget.supplier.id;
  }

  Color get _accentColor => kPrimary;

  // ============================================================
  // START EDITING
  // ============================================================

  void _startEditing() {
    final editingId = ref.read(editingSupplierIdProvider);

    // Don't allow editing another supplier
    if (editingId != null && editingId != widget.supplier.id) {
      return;
    }

    ref.read(editingSupplierIdProvider.notifier).state = widget.supplier.id;
  }

  // ============================================================
  // SAVE
  // ============================================================
  // ======================================================
  // SAVE
  // ======================================================

  Future<void> _saveEdit() async {
    debugPrint('🚨🚨🚨 _saveEdit CALLED 🚨🚨🚨');

    try {
      if (_email.text.trim().isNotEmpty) {
        bool isEmail = isValidEmail(_email.text.trim());
        debugPrint("the data is email $isEmail");
        if (!isEmail) throw InvalidEmailException();
      }

      if (_phone.text.trim().isNotEmpty) {
        bool isPhone = isValidPhone(_phone.text.trim());
        debugPrint("the data is email $_phone");
        if (!isPhone) throw InvalidPhoneException();
      }
      final payload = {
        if (_name.text.trim().isNotEmpty) 'name': _name.text.trim(),
        if (_phone.text.trim().isNotEmpty) 'phone': _phone.text.trim(),
        if (_email.text.trim().isNotEmpty) 'email': _email.text.trim(),
        if (_address.text.trim().isNotEmpty) 'address': _address.text.trim(),
      };

      final success = await ref
          .read(supplierProvider.notifier)
          .updateSupplier(widget.supplier.id, payload);

      if (success) {
        if (!mounted) return;

        ShowToast(
          context,
          description: Text(
            SupplierLocale.supplierEditSuccess.getString(context),
            style: TextStyle(color: kGreen),
          ),
        );

        // Remove cursor / keyboard focus
        FocusScope.of(context).unfocus();

        // Exit edit mode
        ref.read(editingSupplierIdProvider.notifier).state = null;
      }
    } on InvalidEmailException {
      if (!mounted) return;
      ShowToast(
        context,
        isError: true,
        description: Text(
          GeneralScreenLocale.invalidEmail.getString(context),
          style: TextStyle(color: kRed),
        ),
      );
    } on InvalidPhoneException {
      ShowToast(
        context,
        isError: true,
        description: Text(
          GeneralScreenLocale.invalidPhone.getString(context),
          style: TextStyle(color: kRed),
        ),
      );
    } catch (e) {
      if (!mounted) return;

      ShowToast(
        context,
        isError: true,
        description: Text(
          SupplierLocale.supplierEditFail.getString(context),
          style: TextStyle(color: kRed),
        ),
      );
    }
  }
  // ============================================================
  // CANCEL
  // ============================================================

  void _cancelEditing() {
    _name.text = widget.supplier.name;
    _phone.text = widget.supplier.phone ?? '';
    _email.text = widget.supplier.email ?? '';
    _address.text = widget.supplier.address ?? '';

    FocusManager.instance.primaryFocus?.unfocus();

    ref.read(editingSupplierIdProvider.notifier).state = null;
  }

  @override
  Widget build(BuildContext context) {
    final accent = _accentColor;

    // Other supplier is editing
    final disabled = isAnotherSupplierEditing;

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 6),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(.05),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Stack(
        children: [
          // ============================================================
          // LEFT ACCENT
          // ============================================================
          LeftAccentBar(accent: accent),

          // ============================================================
          // DELETE
          // ============================================================
          if (widget.onDelete != null && !disabled)
            DeleteIcon(onDelete: widget.onDelete, top: 12),

          Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 16, 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ======================================================
                // HEADER
                // ======================================================
                Row(
                  children: [
                    CircleAvatar(
                      radius: 22,
                      backgroundColor: accent.withOpacity(.15),
                      child: Icon(LucideIcons.truck, color: accent, size: 21),
                    ),

                    const SizedBox(width: 12),

                    SizedBox(
                      width: MediaQuery.of(context).size.width * 0.6,
                      child: ShadInputFormField(
                        controller: _name,
                        enabled: isEditing,
                        style: TextStyle(
                          fontSize: FontSizeConfig.title(context),
                          fontWeight: FontWeight.w700,
                          color: widget.textColor,
                        ),
                        validator: (value) {
                          if (value.trim().isEmpty) {
                            return SupplierLocale.supplierNameRequired
                                .getString(context);
                          }

                          return null;
                        },
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 12),

                // ======================================================
                // DIVIDER
                // ======================================================
                Container(
                  height: 1,
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Color.fromARGB(255, 168, 167, 167),
                        Color.fromARGB(255, 85, 84, 84),
                        Colors.transparent,
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 12),

                // ======================================================
                // PHONE
                // ======================================================
                SupplierInfoRow(
                  controller: _phone,
                  icon: LucideIcons.phone,
                  title: SupplierLocale.supplierPhone.getString(context),
                  textColor: widget.textColor,
                  subColor: widget.subColor,
                  accent: accent,
                  enabled: isEditing,
                ),

                const SizedBox(height: 8),

                // ======================================================
                // EMAIL
                // ======================================================
                SupplierInfoRow(
                  controller: _email,
                  icon: LucideIcons.mail,
                  title: SupplierLocale.supplierEmail.getString(context),
                  textColor: widget.textColor,
                  subColor: widget.subColor,
                  accent: accent,
                  enabled: isEditing,
                ),

                const SizedBox(height: 8),

                // ======================================================
                // ADDRESS
                // ======================================================
                SupplierInfoRow(
                  controller: _address,
                  icon: LucideIcons.mapPin,
                  title: SupplierLocale.supplierAddress.getString(context),
                  textColor: widget.textColor,
                  subColor: widget.subColor,
                  accent: accent,
                  enabled: isEditing,
                  isAddress: true,
                ),

                const SizedBox(height: 12),

                // ======================================================
                // ACTION BUTTONS
                // ======================================================
                if (isEditing)
                  Row(
                    children: [
                      CustomActionButton(
                        type: CustomActionType.cancel,
                        onPressed: _cancelEditing,
                      ),

                      const SizedBox(width: 10),

                      CustomActionButton(
                        type: CustomActionType.update,
                        onPressed: _saveEdit,
                      ),
                      const SizedBox(width: 10),
                    ],
                  )
                else if (!disabled)
                  CustomActionButton(
                    type: CustomActionType.edit,
                    onPressed: _startEditing,
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ============================================================
// SUPPLIER INFO ROW
// ============================================================

class SupplierInfoRow extends StatelessWidget {
  const SupplierInfoRow({
    super.key,
    required this.controller,
    required this.icon,
    required this.title,
    required this.textColor,
    required this.subColor,
    required this.accent,
    required this.enabled,
    this.isAddress = false,
  });

  final TextEditingController controller;

  final IconData icon;
  final String title;

  final Color textColor;
  final Color subColor;
  final Color accent;

  final bool enabled;
  final bool isAddress;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Icon(icon, size: 18, color: accent),

        const SizedBox(width: 8),

        Text(
          title,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(color: subColor, fontWeight: FontWeight.w500),
        ),

        const SizedBox(width: 10),

        if (isAddress)
          Flexible(
            child: ShadTextarea(
              controller: controller,
              enabled: enabled,
              minHeight: 60,
              maxHeight: 120,
            ),
          )
        else
          Flexible(
            child: ShadInputFormField(controller: controller, enabled: enabled),
          ),
      ],
    );
  }
}
