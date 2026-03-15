import 'package:flutter/material.dart';
import 'package:flutter_localization/flutter_localization.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pos/api/hr-rule.api.dart';
import 'package:pos/component/input.dart';
import 'package:pos/localization/drawer-local.dart';
import 'package:pos/models/hr-rule.dart';
import 'package:pos/utils/app-theme.dart';
import 'package:pos/utils/button.dart';
import 'package:pos/utils/shad-toaster.dart';
import 'package:shadcn_ui/shadcn_ui.dart';
import 'package:pos/localization/hr-rule-local.dart';

class HrRuleForm extends ConsumerStatefulWidget {
  const HrRuleForm({super.key});

  @override
  ConsumerState<HrRuleForm> createState() => _HrRuleFormState();
}

class _HrRuleFormState extends ConsumerState<HrRuleForm> {
  final _formKey = GlobalKey<ShadFormState>();

  final thresholdMinuteCtrl = TextEditingController();
  final thresholdDayCtrl = TextEditingController();
  final amountCtrl = TextEditingController();
  final percentCtrl = TextEditingController();

  String? ruleType; // DEDUCT / OVERTIME / EARLY_LEAVE / LEAVE_ALLOW
  String? thresholdType; // MINUTES / DAYS
  bool showThresholdType = false;
  bool showAmountAndPercent = true;

  void _submit() async {
    // debugPrint('Rule Type: $ruleType');
    // debugPrint('Threshold Type: $thresholdType');
    // debugPrint('Threshold Minute: ${thresholdMinuteCtrl.text}');
    // debugPrint('Threshold Day: ${thresholdDayCtrl.text}');
    // debugPrint('Amount: ${amountCtrl.text}');
    // debugPrint('Percent: ${percentCtrl.text}');
    final rule = HrRule(
      id: 0,
      companyId: 0,
      type: ruleType!,
      thresholdMinute: int.tryParse(thresholdMinuteCtrl.text),
      thresholdDays: int.tryParse(thresholdDayCtrl.text),
      thresholdAmount: int.tryParse(amountCtrl.text),
      thresholdAmountPercent: int.tryParse(percentCtrl.text),
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
    //debugPrint("Created Rule: ${rule.toJson()}");
    try {
      // Replace this with your provider/API call
      final api = await ref
          .read(hrRuleProvider.notifier)
          .createHrRule(rule.toJson());

      if (api["success"]) {
        ShowToast(
          context,
          description: Text(
            HrRuleLocaleScreen.hrRuleSaveSuccess.getString(context),
            style: TextStyle(color: Colors.green),
          ),
        );

        // Clear form
        _resetForm();
      } else {
        ShowToast(
          context,
          description: Text(
            HrRuleLocaleScreen.hrRuleSaveFailed.getString(context),
            style: TextStyle(color: Colors.red),
          ),
        );
      }
    } catch (e) {
      ShowToast(
        context,
        description: Text(
          HrRuleLocaleScreen.hrRuleSaveFailed.getString(context),
          style: TextStyle(color: Colors.red),
        ),
      );
    }
  }

  void _resetForm() {
    /// reset text fields
    thresholdMinuteCtrl.clear();
    thresholdDayCtrl.clear();
    amountCtrl.clear();
    percentCtrl.clear();

    /// reset states
    setState(() {
      ruleType = null;
      thresholdType = null;
      showThresholdType = false;
      showAmountAndPercent = true;
    });

    /// reset shad form
    _formKey.currentState?.reset();
  }

  @override
  void dispose() {
    thresholdMinuteCtrl.dispose();
    thresholdDayCtrl.dispose();
    amountCtrl.dispose();
    percentCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = ref.watch(themeModeProvider) == ThemeMode.dark;
    final labelColor = isDark ? kTextDark : kTextLight;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(8),
      child: ShadForm(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildRuleTypeSelector(context),
            const SizedBox(height: 20),
            if (showThresholdType) _buildThresholdTypeSelector(context),
            const SizedBox(height: 20),
            if (thresholdType != null)
              _buildThresholdInput(context, labelColor),
            const SizedBox(height: 20),
            showAmountAndPercent
                ? AmountWidget(
                    labelColor: labelColor,
                    amountCtrl: amountCtrl,
                    percentCtrl: percentCtrl,
                  )
                : SizedBox(),
            const SizedBox(height: 20),
            GradientSubmitButton(
              onPressed: _submit,
              text: DrawerScreenLocale.drawerCreate.getString(context),
              width: double.infinity,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRuleTypeSelector(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8.0),
      child: ShadRadioGroup<String>(
        alignment: WrapAlignment.start,
        onChanged: (value) {
          setState(() {
            ruleType = value;
            switch (value) {
              case 'OVERTIME':
                showThresholdType = true;
                thresholdType = null;
                showAmountAndPercent = true;
                break;
              case 'DEDUCT':
              case 'EARLY_LEAVE':
                showThresholdType = false;
                thresholdType = 'MINUTES';
                showAmountAndPercent = true;
                break;
              case 'LEAVE_ALLOW':
                showThresholdType = false;
                thresholdType = 'DAYS';
                showAmountAndPercent = false;
                break;
            }
          });
        },
        spacing: 10,
        runSpacing: 10,
        items: [
          _buildRadio(context, HrRuleLocaleScreen.hrRuleDeduct, 'DEDUCT'),
          _buildRadio(
            context,
            HrRuleLocaleScreen.hrRuleEarlyLeave,
            'EARLY_LEAVE',
          ),
          _buildRadio(context, HrRuleLocaleScreen.hrRuleOvertime, 'OVERTIME'),
          _buildRadio(
            context,
            HrRuleLocaleScreen.hrRuleLeave,
            'LEAVE_ALLOW',
            width: 120,
            maxLines: 3,
          ),
        ],
      ),
    );
  }

  Widget _buildThresholdTypeSelector(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          HrRuleLocaleScreen.hrRuleThreshold.getString(context),
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 10),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8.0),
          child: ShadRadioGroup<String>(
            alignment: WrapAlignment.start,
            onChanged: (value) => setState(() => thresholdType = value),
            spacing: 10,
            runSpacing: 10,
            items: [
              _buildRadio(
                context,
                HrRuleLocaleScreen.hrRuleByMinute,
                'MINUTES',
              ),
              _buildRadio(context, HrRuleLocaleScreen.hrRuleByDay, 'DAYS'),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildThresholdInput(BuildContext context, Color labelColor) {
    return thresholdType == 'MINUTES'
        ? input(
            context,
            label: HrRuleLocaleScreen.hrRuleThresholdMinute.getString(context),
            controller: thresholdMinuteCtrl,
            labelColor: labelColor,
            isNumber: true,
          )
        : input(
            context,
            label: HrRuleLocaleScreen.hrRuleThresholdDay.getString(context),
            controller: thresholdDayCtrl,
            labelColor: labelColor,
            isNumber: true,
          );
  }

  ShadRadio<String> _buildRadio(
    BuildContext context,
    String labelKey,
    String value, {
    double? width,
    int maxLines = 2,
  }) {
    return ShadRadio(
      value: value,
      label: width != null
          ? SizedBox(
              width: width,
              child: Text(
                labelKey.getString(context),
                maxLines: maxLines,
                softWrap: true,
                overflow: TextOverflow.ellipsis,
              ),
            )
          : Text(
              labelKey.getString(context),
              maxLines: maxLines,
              softWrap: true,
            ),
    );
  }
}

/// Amount / Percent Tab Widget
class AmountWidget extends StatefulWidget {
  const AmountWidget({
    super.key,
    required this.labelColor,
    required this.amountCtrl,
    required this.percentCtrl,
  });

  final Color labelColor;
  final TextEditingController amountCtrl;
  final TextEditingController percentCtrl;

  @override
  State<AmountWidget> createState() => _AmountWidgetState();
}

class _AmountWidgetState extends State<AmountWidget>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  @override
  void initState() {
    super.initState();

    _tabController = TabController(length: 2, vsync: this);

    _tabController.addListener(() {
      if (_tabController.index == 0) {
        /// amount tab
        widget.percentCtrl.clear();
      } else {
        /// percent tab
        widget.amountCtrl.clear();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Column(
        children: [
          TabBar(
            controller: _tabController,
            labelColor: Theme.of(context).primaryColor,
            unselectedLabelColor: widget.labelColor,
            tabs: [
              Tab(text: HrRuleLocaleScreen.hrRuleAmount.getString(context)),
              Tab(text: HrRuleLocaleScreen.hrRulePercent.getString(context)),
            ],
          ),
          const SizedBox(height: 15),
          SizedBox(
            height: 80,
            child: TabBarView(
              controller: _tabController,
              children: [
                input(
                  context,
                  label: HrRuleLocaleScreen.hrRuleAmount.getString(context),
                  controller: widget.amountCtrl,
                  labelColor: widget.labelColor,
                  isNumber: true,
                ),
                input(
                  context,
                  label: HrRuleLocaleScreen.hrRulePercent.getString(context),
                  controller: widget.percentCtrl,
                  labelColor: widget.labelColor,
                  isNumber: true,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
