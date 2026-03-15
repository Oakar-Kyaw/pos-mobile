import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pos/api/user.api.dart';
import 'package:pos/models/user.dart';
import 'package:pos/component/loading-component.dart';
import 'package:pos/utils/app-theme.dart';
import 'package:pos/utils/font-size.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

class UserSearchField<T> extends ConsumerStatefulWidget {
  // final Function(String) onSearchChanged;
  final Function(T) onUserSelected;
  final T Function(User item) itemBuilder;

  const UserSearchField({
    super.key,
    // required this.onSearchChanged,
    required this.onUserSelected,
    required this.itemBuilder,
  });

  @override
  ConsumerState<UserSearchField> createState() => _UserSearchFieldState<T>();
}

class _UserSearchFieldState<T> extends ConsumerState<UserSearchField<T>> {
  late final TextEditingController searchController;
  bool showSuggestions = false;
  String searchQuery = "";

  @override
  void initState() {
    super.initState();
    searchController = TextEditingController();
  }

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = ref.watch(themeModeProvider) == ThemeMode.dark;
    final textColor = isDark ? kTextDark : kTextLight;
    final subColor = isDark ? kTextSubDark : kTextSubLight;

    // Watch searchUserProvider with the current query
    final usersAsync = ref.watch(searchUserProvider(searchQuery));

    return Column(
      children: [
        ShadInputFormField(
          controller: searchController,
          decoration: const ShadDecoration(
            secondaryFocusedBorder: ShadBorder.none,
          ),
          placeholder: Text(
            "Search user...",
            style: TextStyle(color: subColor),
          ),
          onChanged: (value) {
            //widget.onSearchChanged(value);

            setState(() {
              searchQuery = value.trim();
              showSuggestions = searchQuery.isNotEmpty;
            });
          },
        ),

        const SizedBox(height: 15),

        if (!showSuggestions)
          const SizedBox()
        else
          usersAsync.when(
            data: (items) {
              if (items == null || items.isEmpty) return const SizedBox();

              return Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: kPrimary.withOpacity(0.2)),
                ),
                child: ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: items.length,
                  itemBuilder: (context, index) {
                    final user = items[index];

                    return ListTile(
                      title: Text(
                        "${user.firstName} ${user.lastName}",
                        style: TextStyle(
                          color: textColor,
                          fontWeight: FontWeight.bold,
                          fontSize: FontSizeConfig.body(context),
                        ),
                      ),
                      subtitle: Text(
                        user.email,
                        style: TextStyle(color: subColor),
                      ),
                      onTap: () {
                        final item = widget.itemBuilder(user);
                        widget.onUserSelected(item);

                        setState(() {
                          showSuggestions = false;
                          searchController.clear();
                        });
                      },
                    );
                  },
                ),
              );
            },
            loading: () => const LoadingWidget(),
            error: (_, __) => const SizedBox(),
          ),
      ],
    );
  }
}
