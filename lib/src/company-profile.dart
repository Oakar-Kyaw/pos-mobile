import 'package:flutter/material.dart';
import 'package:flutter_localization/flutter_localization.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:pos/component/app-bar.dart';
import 'package:pos/component/company-form.dart';
import 'package:pos/localization/company-local.dart';
import 'package:pos/utils/font-size.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

class CompanyProfilePage extends ConsumerWidget {
  const CompanyProfilePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: CustomAppBar(
        leading: IconButton(
          onPressed: () => context.pop(),
          icon: Icon(LucideIcons.arrowLeft),
        ),
        title: CompanyRegisterScreenLocal.companyTitle.getString(context),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 5),
          child: Column(
            children: [
              Center(
                child: Text(
                  CompanyRegisterScreenLocal.companyDescription.getString(
                    context,
                  ),
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: FontSizeConfig.body(context),
                    height: 2,
                  ),
                ),
              ),
              const SizedBox(height: 10),
              const CompanyForm(),
              // const Expanded(child: CompanyTable()),
            ],
          ),
        ),
      ),
    );
  }
}
