import 'package:flutter/material.dart';
import 'package:flutter_localization/flutter_localization.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pos/api/user.api.dart';
import 'package:pos/localization/general-local.dart';
import 'package:pos/riverpod/company.riverpod.dart';
import 'package:pos/riverpod/selected-user.riverpod.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

class UserSelect extends ConsumerStatefulWidget {
  const UserSelect({super.key});

  @override
  ConsumerState<UserSelect> createState() => _UserSelectState();
}

class _UserSelectState extends ConsumerState<UserSelect> {
  String? selectedValue;

  @override
  Widget build(BuildContext context) {
    final company = ref.watch(companyStateProvider);

    if (company == null) {
      return const SizedBox.shrink();
    }

    final userAsync = ref.watch(userByCompanyProvider(company.id));

    return userAsync.when(
      data: (users) {
        /// Build options list
        final List<ShadOption<String>> shadOptions = [
          ShadOption<String>(
            value: '',
            child: Text(GeneralScreenLocale.all.getString(context)),
          ),
          ...users.map(
            (u) => ShadOption<String>(
              value: u.id.toString(),
              child: Text(u.email),
            ),
          ),
        ];

        /// default selection
        selectedValue ??= shadOptions.first.value;

        return SizedBox(
          width: 200,
          child: ShadSelect<String>(
            options: shadOptions,
            placeholder: Text(GeneralScreenLocale.all.getString(context)),
            onChanged: (value) {
              setState(() {
                selectedValue = value;
              });
              //print("user select value ${value == ''}");
              if (value == '' || value == null) {
                // All selected
                ref.read(selectedDataStateProvider.notifier).clearUser();
              } else {
                // Specific user selected
                ref
                    .read(selectedDataStateProvider.notifier)
                    .setUser(int.tryParse(value)!);
              }
            },
            selectedOptionBuilder: (context, value) {
              final option = shadOptions.firstWhere(
                (o) => o.value == value,
                orElse: () => ShadOption<String>(
                  value: '',
                  child: Text(GeneralScreenLocale.all.getString(context)),
                ),
              );

              return option.child;
            },
          ),
        );
      },
      loading: () => const SizedBox(
        width: 200,
        child: Center(child: CircularProgressIndicator(strokeWidth: 2)),
      ),
      error: (err, stack) {
        return SizedBox(width: 200, child: Text('Error: $err'));
      },
    );
  }
}
