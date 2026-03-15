import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pos/api/user.api.dart';
import 'package:pos/models/user.dart';
import 'package:pos/utils/app-theme.dart';
import 'package:pos/utils/font-size.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

class PayrollFilterBar extends ConsumerStatefulWidget {
  const PayrollFilterBar({
    super.key,
    required this.onChanged,
    this.selectedUserId,
    this.fromDate,
    this.toDate,
  });

  final int? selectedUserId;
  final DateTime? fromDate;
  final DateTime? toDate;
  final void Function(int? userId, DateTime? fromDate, DateTime? toDate)
  onChanged;

  @override
  ConsumerState<PayrollFilterBar> createState() => _PayrollFilterBarState();
}

class _PayrollFilterBarState extends ConsumerState<PayrollFilterBar> {
  int? _userId;
  DateTime? _fromDate;
  DateTime? _toDate;

  @override
  void initState() {
    super.initState();
    _userId = widget.selectedUserId;
    _fromDate = widget.fromDate;
    _toDate = widget.toDate;
  }

  @override
  void didUpdateWidget(covariant PayrollFilterBar oldWidget) {
    super.didUpdateWidget(oldWidget);
    _userId = widget.selectedUserId;
    _fromDate = widget.fromDate;
    _toDate = widget.toDate;
  }

  void _emit() {
    widget.onChanged(_userId, _fromDate, _toDate);
  }

  Future<void> _pickFromDate(BuildContext context) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _fromDate ?? DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
    );
    if (picked != null) {
      setState(() => _fromDate = picked);
      _emit();
    }
  }

  Future<void> _pickToDate(BuildContext context) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _toDate ?? DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
    );
    if (picked != null) {
      setState(() => _toDate = picked);
      _emit();
    }
  }

  String _formatDate(DateTime? date) {
    if (date == null) return '-';
    return DateFormat('dd MMM yyyy').format(date);
  }

  @override
  Widget build(BuildContext context) {
    final isDark = ref.watch(themeModeProvider) == ThemeMode.dark;
    final textColor = isDark ? kTextDark : kTextLight;
    final subColor = isDark ? kTextSubDark : kTextSubLight;

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isDark ? kSurfaceDark : kSurfaceLight,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Filters',
            style: TextStyle(
              fontSize: FontSizeConfig.body(context),
              fontWeight: FontWeight.w700,
              color: textColor,
            ),
          ),
          const SizedBox(height: 10),
          FutureBuilder<List<User>>(
            future: ref
                .read(userProvider.notifier)
                .getAllUser(page: 1, limit: 200),
            builder: (context, snapshot) {
              final users = snapshot.data ?? [];
              return Row(
                children: [
                  Expanded(
                    child: ShadSelect<int>(
                      decoration: const ShadDecoration(
                        secondaryBorder: ShadBorder.none,
                        secondaryFocusedBorder: ShadBorder.none,
                      ),
                      placeholder: Text(
                        'Select Employee',
                        style: TextStyle(color: subColor, fontSize: 13),
                      ),
                      selectedOptionBuilder: (context, value) {
                        final user = users.firstWhere(
                          (u) => u.id == value,
                          orElse: () => users.first,
                        );
                        final name =
                            '${user.firstName ?? ''} ${user.lastName ?? ''}'
                                .trim();
                        return Text(
                          name.isNotEmpty ? name : user.email,
                          style: TextStyle(color: textColor),
                        );
                      },
                      //value: _userId,
                      onChanged: (value) {
                        setState(() => _userId = value);
                        _emit();
                      },
                      options: [
                        ...users.map(
                          (u) => ShadOption(
                            value: u.id,
                            child: Text(
                              ('${u.firstName ?? ''} ${u.lastName ?? ''}')
                                      .trim()
                                      .isNotEmpty
                                  ? ('${u.firstName ?? ''} ${u.lastName ?? ''}')
                                        .trim()
                                  : u.email,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  IconButton(
                    tooltip: 'Clear user',
                    onPressed: () {
                      setState(() => _userId = null);
                      _emit();
                    },
                    icon: const Icon(LucideIcons.x, size: 16),
                  ),
                ],
              );
            },
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: _DateChip(
                  label: 'From',
                  value: _formatDate(_fromDate),
                  onTap: () => _pickFromDate(context),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _DateChip(
                  label: 'To',
                  value: _formatDate(_toDate),
                  onTap: () => _pickToDate(context),
                ),
              ),
              const SizedBox(width: 8),
              IconButton(
                tooltip: 'Clear dates',
                onPressed: () {
                  setState(() {
                    _fromDate = null;
                    _toDate = null;
                  });
                  _emit();
                },
                icon: const Icon(LucideIcons.x, size: 16),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _DateChip extends StatelessWidget {
  const _DateChip({
    required this.label,
    required this.value,
    required this.onTap,
  });

  final String label;
  final String value;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark ? kTextDark : kTextLight;
    final subColor = isDark ? kTextSubDark : kTextSubLight;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: isDark ? Colors.white.withOpacity(0.04) : Colors.black12,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: TextStyle(fontSize: 11, color: subColor)),
            const SizedBox(height: 4),
            Text(
              value,
              style: TextStyle(
                fontSize: FontSizeConfig.body(context),
                color: textColor,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
