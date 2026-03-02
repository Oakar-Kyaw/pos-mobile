import 'dart:math';

mixin RefundLocale {
  static const String refund = "refund";
  static const refundDescription = 'refund_description';
  static const refundNo = 'refund_no';
  static const addRefund = 'add_refund';
  static const refundTitle = 'refund_title';
  static const refundAmount = 'refund_amount';
  static const refundDate = 'refund_date';
  static const refundPaymentMethod = 'refund_payment_method';
  static const refundButton = 'refund_button';
  static const refundSaveSuccess = 'refund_save_success';
  static const refundSaveFailed = 'refund_save_failed';
  static const refundForm = 'refund_form';
  static const refundReason = 'refund_reason';
  static const refundValidationError = 'refund_validation_error';
  static const refundAmountValidator = 'refund_amount_validator';
  static const refundNoItems = 'refund_no_items';
  static const refundAmountPlaceholder = 'refund_amount_placeholder';
  static const refundReasonPlaceholder = 'refund_reason_placeholder';

  // 🔥 NEW — Refund Method & Voucher
  static const refundMethod = 'refund_method';
  static const refundCash = 'refund_cash';
  static const refundOriginalPayment = 'refund_original_payment';
  static const refundStoreCredit = 'refund_store_credit';
  static const refundVoucher = 'refund_voucher';
  static const refundVoucherCreated = 'refund_voucher_created';
  static const refundTable = 'refund_table';

  /// English translations
  static const EN = {
    refund: 'Refund',
    refundTable: 'Refund Table',
    refundDescription: 'POS',
    refundNo: 'No',
    refundAmountPlaceholder: 'Enter refund amount',
    addRefund: 'Add your refund you have given',
    refundTitle: 'Refund Title',
    refundAmount: 'Amount',
    refundDate: 'Date',
    refundPaymentMethod: 'Payment Method',
    refundButton: 'Create Refund',
    refundSaveSuccess: 'Refund saved successfully',
    refundSaveFailed: 'Failed to save refund',
    refundForm: 'Refund Form',
    refundReason: 'Reason',
    refundValidationError: 'Please fill out all required fields correctly.',
    refundAmountValidator: 'Invalid amount',
    refundNoItems: 'No items found',
    refundReasonPlaceholder: 'Enter reason for refund',
    // 🔥 NEW
    refundMethod: 'Refund Method',
    refundCash: 'Cash Refund',
    refundOriginalPayment: 'Refund to Original Payment',
    refundStoreCredit: 'Store Credit (Refund Voucher)',
    refundVoucher: 'Refund Voucher',
    refundVoucherCreated: 'Refund voucher created successfully',
  };

  /// Burmese translations
  static const MM = {
    refund: 'ပြန်အမ်းပေးမှု',
    refundTable: 'ပြန်အမ်းပေးမှု ဇယား',
    refundAmountPlaceholder: 'ပြန်အမ်းပေးမှု ငွေပမာဏ ထည့်ပါ',
    refundDescription: 'အရောင်း ဆော့ဖ်ဝဲ',
    refundNo: 'စဉ်',
    addRefund: 'သင်ပြန်အမ်းပေးမှုကို ထည့်ပါ',
    refundTitle: 'ခေါင်းစဉ်',
    refundAmount: 'ငွေပမာဏ',
    refundDate: 'ရက်စွဲ',
    refundPaymentMethod: 'ငွေပေးချေမှုနည်းလမ်း',
    refundButton: 'ပြန်အမ်းပေးမည်',
    refundReasonPlaceholder: 'ပြန်အမ်းပေးမှု အကြောင်းရင်း ထည့်ပါ',
    refundSaveSuccess: 'ပြန်အမ်းပေးမှုကို အောင်မြင်စွာ သိမ်းဆည်းပြီးပါပြီ',
    refundSaveFailed: 'ပြန်အမ်းပေးမှု သိမ်းဆည်းမှု မအောင်မြင်ပါ',
    refundForm: 'ပြန်အမ်းပေးမှု ဖောင်',
    refundReason: 'အကြောင်းရင်း',
    refundValidationError:
        'ကျေးဇူးပြု၍ လိုအပ်သော အကွက်များကို မှန်ကန်စွာ ဖြည့်ပါ။',
    refundAmountValidator: 'ငွေပမာဏ မမှန်ကန်ပါ',
    refundNoItems: 'ပစ္စည်း မတွေ့ပါ',

    // 🔥 NEW
    refundMethod: 'ပြန်အမ်းပေးနည်းလမ်း',
    refundCash: 'ငွေသားဖြင့် ပြန်အမ်း',
    refundOriginalPayment: 'မူလ ငွေပေးချေမှုနည်းလမ်းသို့ ပြန်အမ်း',
    refundStoreCredit: 'ဆိုင်ခွဲအသုံးပြုနိုင်သော ကဒ် (Refund Voucher)',
    refundVoucher: 'ပြန်အမ်းကဒ်',
    refundVoucherCreated: 'ပြန်အမ်းကဒ် အောင်မြင်စွာ ဖန်တီးပြီးပါပြီ',
  };
}
