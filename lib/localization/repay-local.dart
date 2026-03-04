mixin RepayLocaleScreen {
  static const String repay = "repay";
  static const repayDescription = 'repay_description';
  static const repayNo = 'repay_no';
  static const addRepay = 'add_repay';
  static const repayTitle = 'repay_title';
  static const repayAmount = 'repay_amount';
  static const repayDate = 'repay_date';
  static const repayPaymentMethod = 'repay_payment_method';
  static const repayButton = 'repay_button';
  static const repaySaveSuccess = 'repay_save_success';
  static const repaySaveFailed = 'repay_save_failed';
  static const repayForm = 'repay_form';
  static const repayNote = 'repay_note';
  static const repayValidationError = 'repay_validation_error';
  static const repayAmountValidator = 'repay_amount_validator';
  static const repayNoItems = 'repay_no_items';
  static const repayAmountPlaceholder = 'repay_amount_placeholder';
  static const repayNotePlaceholder = 'repay_note_placeholder';

  // 🔥 NEW — Debt & Remaining
  static const repayRemainingAmount = 'repay_remaining_amount';
  static const repayTotalPaid = 'repay_total_paid';
  static const repayFullyPaid = 'repay_fully_paid';
  static const repayHistoryTable = 'repay_history_table';
  static const repaid = 'repaid';

  /// English translations
  static const EN = {
    repay: 'Repayment',
    repaid: 'Repaid',
    repayHistoryTable: 'Repayment History',
    repayDescription: 'POS Repayment System',
    repayNo: 'No',
    repayAmountPlaceholder: 'Enter repayment amount',
    addRepay: 'Add repayment',
    repayTitle: 'Repayment',
    repayAmount: 'Amount',
    repayDate: 'Date',
    repayPaymentMethod: 'Payment Method',
    repayButton: 'Pay Now',
    repaySaveSuccess: 'Repayment saved successfully',
    repaySaveFailed: 'Failed to save repayment',
    repayForm: 'Repayment Form',
    repayNote: 'Note',
    repayValidationError: 'Please fill out all required fields correctly.',
    repayAmountValidator: 'Invalid amount',
    repayNoItems: 'No repayment records found',
    repayNotePlaceholder: 'Enter repayment note',

    // 🔥 NEW
    repayRemainingAmount: 'Remaining Amount',
    repayTotalPaid: 'Total Paid',
    repayFullyPaid: 'Fully Paid',
  };

  /// Burmese translations
  static const MM = {
    repay: 'အကြွေးပေးချေမှု',
    repaid: 'ပေးချေပြီး',
    repayHistoryTable: 'အကြွေးပေးချေမှု မှတ်တမ်းဇယား',
    repayDescription: 'အကြွေးပေးချေမှု စနစ်',
    repayNo: 'စဉ်',
    repayAmountPlaceholder: 'ပေးချေမည့် ငွေပမာဏ ထည့်ပါ',
    addRepay: 'အကြွေးပေးချေမှု ထည့်ပါ',
    repayTitle: 'အကြွေးပေးချေမှု',
    repayAmount: 'ငွေပမာဏ',
    repayDate: 'ရက်စွဲ',
    repayPaymentMethod: 'ငွေပေးချေမှုနည်းလမ်း',
    repayButton: 'ယခု ပေးချေမည်',
    repaySaveSuccess: 'အကြွေးပေးချေမှုကို အောင်မြင်စွာ သိမ်းဆည်းပြီးပါပြီ',
    repaySaveFailed: 'အကြွေးပေးချေမှု သိမ်းဆည်းမှု မအောင်မြင်ပါ',
    repayForm: 'အကြွေးပေးချေမှု ဖောင်',
    repayNote: 'မှတ်ချက်',
    repayValidationError:
        'ကျေးဇူးပြု၍ လိုအပ်သော အကွက်များကို မှန်ကန်စွာ ဖြည့်ပါ။',
    repayAmountValidator: 'ငွေပမာဏ မမှန်ကန်ပါ',
    repayNoItems: 'အကြွေးပေးချေမှု မှတ်တမ်း မတွေ့ပါ',
    repayNotePlaceholder: 'ပေးချေမှု မှတ်ချက် ထည့်ပါ',

    // 🔥 NEW
    repayRemainingAmount: 'ကျန်ရှိနေသေးသော ငွေပမာဏ',
    repayTotalPaid: 'စုစုပေါင်း ပေးချေပြီးငွေ',
    repayFullyPaid: 'အကြွေးပြည့်စုံ ပေးချေပြီး',
  };
}
