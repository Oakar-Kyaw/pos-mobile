import 'package:flutter/material.dart';
import 'package:flutter_localization/flutter_localization.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pos/core/utils/check-email.dart';
import 'package:pos/core/utils/check-phone.dart';
import 'package:pos/core/widgets/custom-action-button.dart';
import 'package:pos/core/widgets/delete-icon.dart';
import 'package:pos/features/customer/data/model/customer-model.dart';
import 'package:pos/features/customer/presentation/page/customer.dart';
import 'package:pos/features/customer/presentation/provider/customer-provider.dart';
import 'package:pos/localization/customer-local.dart';
import 'package:pos/localization/general-local.dart';
import 'package:pos/utils/app-theme.dart';
import 'package:pos/utils/font-size.dart';
import 'package:pos/utils/left-bar-accent.dart';
import 'package:pos/utils/shad-toaster.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

class CustomerCard extends ConsumerStatefulWidget {
  const CustomerCard({
    super.key,
    required this.customer,
    required this.textColor,
    required this.subColor,
    this.onDelete,
    this.onEdit,
    this.onDetail,
  });

  final Customer customer;

  final Color textColor;
  final Color subColor;

  final VoidCallback? onDelete;
  final VoidCallback? onEdit;
  final VoidCallback? onDetail;

  @override
  ConsumerState<CustomerCard> createState() => _CustomerCardState();
}

class _CustomerCardState extends ConsumerState<CustomerCard> {
  late TextEditingController _name;
  late TextEditingController _phone;
  late TextEditingController _email;
  late TextEditingController _address;

  // ======================================================
  // INIT
  // ======================================================

  @override
  void initState() {
    super.initState();

    _name = TextEditingController(text: widget.customer.name);

    _phone = TextEditingController(text: widget.customer.phone ?? '');

    _email = TextEditingController(text: widget.customer.email ?? '');

    _address = TextEditingController(text: widget.customer.address ?? '');
  }

  // ======================================================
  // EDITING STATE
  // ======================================================

  /// This customer is currently being edited.
  bool get isEditing {
    return ref.watch(editingCustomerIdProvider) == widget.customer.id;
  }

  /// Another customer is currently being edited.
  bool get isAnotherCustomerEditing {
    final editingId = ref.watch(editingCustomerIdProvider);

    return editingId != null && editingId != widget.customer.id;
  }

  // ======================================================
  // START EDIT
  // ======================================================

  void _startEditing() {
    ref.read(editingCustomerIdProvider.notifier).state = widget.customer.id;
  }

  // ======================================================
  // SAVE
  // ======================================================

  Future<void> _saveEdit() async {
    debugPrint("🔥🔥🔥 SAVE EDIT CALLED 🔥🔥🔥");
    debugPrint("email ${_email.text.isEmpty}");
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
          .read(customerProvider.notifier)
          .updateCustomer(widget.customer.id, payload);

      if (success) {
        if (!mounted) return;

        ShowToast(
          context,
          description: Text(
            CustomerLocale.customerEditSuccess.getString(context),
            style: TextStyle(color: kGreen),
          ),
        );
        // Remove cursor / keyboard focus
        FocusScope.of(context).unfocus();

        // Exit edit mode
        ref.read(editingCustomerIdProvider.notifier).state = null;
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
      final error = e.toString();
      ShowToast(
        context,
        isError: true,
        description: Text(
          error.isNotEmpty
              ? e.toString()
              : CustomerLocale.customerEditFail.getString(context),
          style: TextStyle(color: kRed),
        ),
      );
    }
  }

  // ======================================================
  // CANCEL
  // ======================================================

  void _cancelEditing() {
    // Restore original values
    _name.text = widget.customer.name;
    _phone.text = widget.customer.phone ?? '';
    _email.text = widget.customer.email ?? '';
    _address.text = widget.customer.address ?? '';

    // Exit edit mode
    ref.read(editingCustomerIdProvider.notifier).state = null;
    FocusScope.of(context).unfocus();
  }

  // ======================================================
  // DISPOSE
  // ======================================================

  @override
  void dispose() {
    _name.dispose();
    _phone.dispose();
    _email.dispose();
    _address.dispose();

    super.dispose();
  }

  // ======================================================
  // ACCENT
  // ======================================================

  Color get _accentColor {
    return kPrimary;
  }

  // ======================================================
  // BUILD
  // ======================================================

  @override
  Widget build(BuildContext context) {
    final accent = _accentColor;

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
          // ==================================================
          // LEFT ACCENT
          // ==================================================
          LeftAccentBar(accent: accent),

          // ==================================================
          // DELETE
          // ==================================================
          if (widget.onDelete != null)
            DeleteIcon(
              onDelete: isAnotherCustomerEditing ? null : widget.onDelete,
              top: 12,
            ),

          // ==================================================
          // CONTENT
          // ==================================================
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 16, 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ==============================================
                // HEADER / NAME
                // ==============================================
                Row(
                  children: [
                    CircleAvatar(
                      radius: 20,
                      backgroundColor: accent.withOpacity(.15),
                      child: Icon(
                        Icons.person_rounded,
                        color: accent,
                        size: 21,
                      ),
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
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 12),

                // ==============================================
                // DIVIDER
                // ==============================================
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

                // ==============================================
                // PHONE
                // ==============================================
                CustomerInfoRow(
                  controller: _phone,
                  icon: Icons.phone_outlined,
                  title: CustomerLocale.customerPhone.getString(context),
                  value: widget.customer.phone ?? '-',
                  textColor: widget.textColor,
                  subColor: widget.subColor,
                  accent: accent,
                  enabled: isEditing,
                ),

                const SizedBox(height: 8),

                // ==============================================
                // EMAIL
                // ==============================================
                CustomerInfoRow(
                  controller: _email,
                  icon: Icons.email_outlined,
                  title: CustomerLocale.customerEmail.getString(context),
                  value: widget.customer.email ?? '-',
                  textColor: widget.textColor,
                  subColor: widget.subColor,
                  accent: accent,
                  enabled: isEditing,
                ),

                const SizedBox(height: 8),

                // ==============================================
                // ADDRESS
                // ==============================================
                CustomerInfoRow(
                  controller: _address,
                  icon: Icons.location_on_outlined,
                  title: CustomerLocale.customerAddress.getString(context),
                  value: widget.customer.address ?? '-',
                  textColor: widget.textColor,
                  subColor: widget.subColor,
                  accent: accent,
                  enabled: isEditing,
                ),

                const SizedBox(height: 12),

                // ==============================================
                // ACTION BUTTONS
                // ==============================================
                if (isEditing) ...[
                  // --------------------------------------------
                  // CURRENT CARD IS EDITING
                  // --------------------------------------------
                  Row(
                    children: [
                      // CANCEL
                      CustomActionButton(
                        type: CustomActionType.cancel,
                        onPressed: _cancelEditing,
                      ),

                      const SizedBox(width: 10),

                      // SAVE
                      CustomActionButton(
                        type: CustomActionType.update,
                        onPressed: _saveEdit,
                      ),
                    ],
                  ),
                ] else if (!isAnotherCustomerEditing) ...[
                  // --------------------------------------------
                  // NOBODY ELSE IS EDITING
                  // --------------------------------------------
                  CustomActionButton(
                    type: CustomActionType.edit,
                    onPressed: _startEditing,
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ======================================================
// CUSTOMER INFO ROW
// ======================================================

class CustomerInfoRow extends StatelessWidget {
  const CustomerInfoRow({
    super.key,
    required this.controller,
    required this.icon,
    required this.title,
    required this.value,
    required this.textColor,
    required this.subColor,
    required this.accent,
    required this.enabled,
  });

  final TextEditingController controller;

  final IconData icon;
  final String title;
  final String value;

  final Color textColor;
  final Color subColor;
  final Color accent;

  final bool enabled;

  @override
  Widget build(BuildContext context) {
    final isAddress =
        title == CustomerLocale.customerAddress.getString(context);

    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        // ====================================================
        // ICON
        // ====================================================
        Icon(icon, size: 18, color: accent),

        const SizedBox(width: 8),

        // ====================================================
        // LABEL
        // ====================================================
        Text(
          title,
          textAlign: TextAlign.right,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(color: subColor, fontWeight: FontWeight.w500),
        ),

        const SizedBox(width: 10),

        // ====================================================
        // INPUT
        // ====================================================
        Expanded(
          child: isAddress
              ? ShadTextarea(controller: controller, enabled: enabled)
              : ShadInputFormField(
                  controller: controller,
                  enabled: enabled,
                  validator: (value) {
                    if (value.isEmpty) {
                      return 'This field is required';
                    }

                    return null;
                  },
                ),
        ),
      ],
    );
  }
}
