import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pos/features/customer/data/model/customer-model.dart';
import 'package:pos/features/customer/presentation/provider/customer-provider.dart';
import 'package:pos/utils/app-theme.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

class CustomerVoucher extends ConsumerStatefulWidget {
  final Function(Customer customer) onChanged;
  const CustomerVoucher({super.key, required this.onChanged});

  @override
  ConsumerState<CustomerVoucher> createState() => _CustomerVoucherState();
}

class _CustomerVoucherState extends ConsumerState<CustomerVoucher> {
  final _searchCtrl = TextEditingController();
  final _newNameCtrl = TextEditingController();
  final _newPhoneCtrl = TextEditingController();

  Customer? _selectedCustomer;
  List<Customer> _results = [];
  bool _isSearching = false;
  bool _showCreateForm = false;
  Timer? _debounce;

  @override
  void dispose() {
    _searchCtrl.dispose();
    _newNameCtrl.dispose();
    _newPhoneCtrl.dispose();
    _debounce?.cancel();
    super.dispose();
  }

  void _onSearchChanged(String value) {
    if (_debounce?.isActive ?? false) _debounce!.cancel();

    if (value.trim().isEmpty) {
      setState(() {
        _results = [];
        _showCreateForm = false;
      });
      return;
    }

    _debounce = Timer(const Duration(milliseconds: 400), () async {
      setState(() => _isSearching = true);
      try {
        final results = await ref
            .read(customerProvider.notifier)
            .searchCustomers(search: value);
        debugPrint("result for customer $results");
        if (!mounted) return;
        setState(() {
          _results = results;
          _showCreateForm = results.isEmpty;
        });
      } catch (_) {
        if (mounted) {
          setState(() {
            _results = [];
            _showCreateForm = true;
          });
        }
      } finally {
        if (mounted) setState(() => _isSearching = false);
      }
    });
  }

  void _selectCustomer(Customer customer) {
    setState(() {
      _selectedCustomer = customer;
      _results = [];
      _showCreateForm = false;
      _searchCtrl.text = customer.name;
      widget.onChanged.call(customer);
    });

    // ⚠️ Attach customerId to the voucher state — add a `customerId` param
    // to VoucherDetailNotifier.updateVoucher() if it doesn't exist yet.
    // ref.read(voucherDetailProvider.notifier).updateVoucher(customerId: customer.id);
  }

  void _clearCustomer() {
    setState(() {
      _selectedCustomer = null;
      _searchCtrl.clear();
      _results = [];
      _showCreateForm = false;
    });
    // ref.read(voucherDetailProvider.notifier).updateVoucher(customerId: null);
  }

  Future<void> _createNewCustomer() async {
    final name = _newNameCtrl.text.trim();
    if (name.isEmpty) return;
    final phone = _newPhoneCtrl.text.trim();
    if (phone.isEmpty) return;

    try {
      // ⚠️ Replace with your actual create-customer call, e.g.:
      // final newCustomer = await ref
      //     .read(customerProvider.notifier)
      //     .createCustomer(name: name, phone: _newPhoneCtrl.text.trim());
      Customer newCustomer = Customer(
        id: 0,
        name: name,
        phone: phone,
      ); // placeholder

      if (!mounted) return;
      _selectCustomer(newCustomer);
      _newNameCtrl.clear();
      _newPhoneCtrl.clear();
    } catch (_) {
      // handle error / toast
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = ref.watch(themeModeProvider) == ThemeMode.dark;
    final surfaceColor = isDark ? kSurfaceDark : kSurfaceLight;
    final textColor = isDark ? kTextDark : kTextLight;
    final subColor = isDark ? kTextSubDark : kTextSubLight;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: surfaceColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: isDark
                ? kPrimary.withOpacity(0.08)
                : Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: _selectedCustomer != null
          // ── Selected customer chip ──
          ? Row(
              children: [
                CircleAvatar(
                  radius: 16,
                  backgroundColor: kPrimary.withOpacity(0.12),
                  child: Icon(LucideIcons.user, size: 16, color: kPrimary),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _selectedCustomer!.name,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: textColor,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      if (_selectedCustomer!.phone != null)
                        Text(
                          _selectedCustomer!.phone!,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: textColor,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                    ],
                  ),
                ),
                IconButton(
                  onPressed: _clearCustomer,
                  icon: Icon(LucideIcons.x, color: subColor, size: 18),
                  constraints: const BoxConstraints(),
                  padding: EdgeInsets.zero,
                ),
              ],
            )
          // ── Search / create flow ──
          : Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Customer (optional)',
                  style: TextStyle(color: subColor, fontSize: 12),
                ),
                const SizedBox(height: 8),

                ShadInputFormField(
                  controller: _searchCtrl,
                  placeholder: const Text('Search by name or phone...'),
                  onChanged: _onSearchChanged,
                  trailing: _isSearching
                      ? const SizedBox(
                          width: 14,
                          height: 14,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : null,
                ),

                // Search results — bounded height so ListView doesn't blow up
                if (_results.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  ConstrainedBox(
                    constraints: const BoxConstraints(maxHeight: 180),
                    child: ListView.builder(
                      shrinkWrap: true,
                      padding: EdgeInsets.zero,
                      itemCount: _results.length,
                      itemBuilder: (context, index) {
                        final c = _results[index];
                        return ListTile(
                          dense: true,
                          contentPadding: EdgeInsets.zero,
                          leading: const Icon(LucideIcons.user, size: 18),
                          title: Text(
                            c.name, // ⚠️ adjust field name
                            style: TextStyle(color: textColor),
                          ),
                          subtitle: c.phone != null
                              ? Text(
                                  c.phone!,
                                  style: TextStyle(color: subColor),
                                )
                              : null,
                          onTap: () => _selectCustomer(c),
                        );
                      },
                    ),
                  ),
                ],

                // No results → quick create-new form
                if (_showCreateForm) ...[
                  const SizedBox(height: 12),
                  Text(
                    'No customer found. Create new:',
                    style: TextStyle(color: subColor, fontSize: 12),
                  ),
                  const SizedBox(height: 8),
                  ShadInputFormField(
                    controller: _newNameCtrl,
                    placeholder: const Text('Customer name'),
                  ),
                  const SizedBox(height: 8),
                  ShadInputFormField(
                    controller: _newPhoneCtrl,
                    placeholder: const Text('Phone (optional)'),
                    keyboardType: TextInputType.phone,
                  ),
                  const SizedBox(height: 8),
                  SizedBox(
                    width: double.infinity,
                    child: ShadButton.outline(
                      onPressed: _createNewCustomer,
                      child: const Text('Create & Select'),
                    ),
                  ),
                ],
              ],
            ),
    );
  }
}
