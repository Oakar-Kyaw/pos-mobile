import 'package:flutter/material.dart';
import 'package:flutter_localization/flutter_localization.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pos/api/category.api.dart';
import 'package:pos/localization/category-local.dart';
import 'package:pos/utils/font-size.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

class CategoryTable extends ConsumerWidget {
  const CategoryTable({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tableWidth = MediaQuery.of(context).size.width - 20;
    final actionsWidth = tableWidth * 0.40;
    final titleWidth = tableWidth * 0.60;

    // 🔹 Example (replace with your real provider)
    final categoryAsync = ref.watch(categoryProvider);
    if (categoryAsync.isLoading) {
      return const Center(
        child: SizedBox(
          height: 10,
          width: 10,
          child: CircularProgressIndicator(),
        ),
      );
    }

    if (categoryAsync.hasError) {
      return const Center(child: Text("Failed to load categories"));
    }

    final data = categoryAsync.value!;

    return SizedBox(
      width: tableWidth,
      child: ShadTable.list(
        columnSpanExtent: (index) {
          if (index == 0) {
            return FixedTableSpanExtent(titleWidth);
          }
          if (index == 1) {
            return FixedTableSpanExtent(actionsWidth);
          }
          return null;
        },
        header: [
          ShadTableCell.header(
            alignment: Alignment.centerLeft,
            child: Text(
              CategoryScreenLocale.categoryTitle.getString(context),
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: FontSizeConfig.body(context),
              ),
            ),
          ),
          ShadTableCell.header(
            alignment: Alignment.center,
            child: Text(
              CategoryScreenLocale.categoryAction.getString(context),
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: FontSizeConfig.body(context),
              ),
            ),
          ),
        ],
        children: data.map(
          (cate) => [
            ShadTableCell(
              alignment: Alignment.centerLeft,
              child: Text(
                cate.title,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: FontSizeConfig.body(context),
                ),
              ),
            ),
            ShadTableCell(
              alignment: Alignment.center,
              child: FittedBox(
                fit: BoxFit.scaleDown,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: Icon(
                        Icons.edit,
                        size: FontSizeConfig.iconSize(context),
                      ),
                      color: Colors.green,
                      onPressed: () {
                        debugPrint("Edit ${cate.title}");
                      },
                    ),
                    const SizedBox(width: 4),
                    IconButton(
                      icon: Icon(
                        Icons.delete,
                        size: FontSizeConfig.iconSize(context),
                      ),
                      color: Colors.red,
                      onPressed: () {
                        debugPrint("Delete ${cate.title}");
                      },
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
