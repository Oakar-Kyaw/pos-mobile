import 'dart:math';

mixin GeneralExpenseLocale {
  static const expenseDescription = 'expense_description';
  static const addExpense = 'add_expense';
  static const expenseNo = 'expense_no';
  static const expenseTitle = 'expense_title';
  static const expenseAmount = 'expense_amount';
  static const expenseCategory = 'expense_category';
  static const expenseDate = 'expense_date';
  static const expensePaymentMethod = 'expense_payment_method';
  static const expenseButton = 'expense_button';
  static const expenseSaveSuccess = 'expense_save_success';
  static const expenseSaveFailed = 'expense_save_failed';
  static const expenseForm = 'expense_form';
  static const expenseReason = 'expense_category_reason';
  static const expenseValidationError = 'expense_validation_error';
  static const expenseAmountValidator = 'expense_amount_validator';
  static const expenseNoItems = 'expense_no_items';

  /// English translations
  static const EN = {
    expenseDescription: 'POS',
    expenseNo: 'No',
    addExpense: 'Add your expense you have used',
    expenseTitle: 'Expense Title',
    expenseAmount: 'Amount',
    expenseCategory: 'Category',
    expenseDate: 'Date',
    expensePaymentMethod: 'Payment Method',
    expenseButton: 'Create Expense',
    expenseSaveSuccess: 'Expense saved successfully',
    expenseSaveFailed: 'Failed to save expense',
    expenseForm: 'General Expense Form',
    expenseReason: 'Reason',
    expenseValidationError: 'Please fill out all required fields correctly.',
    expenseAmountValidator: 'Invalid amount',
    expenseNoItems: 'No items found',
  };

  /// Burmese translations
  static const MM = {
    expenseDescription: 'အရောင်း ဆော့ဖ်ဝဲ',
    expenseNo: 'စဉ်',
    addExpense: 'သင်အသုံးစရိတ်ကို ထည့်ပါ',
    expenseTitle: 'ခေါင်းစဉ်',
    expenseAmount: 'ငွေပမာဏ',
    expenseCategory: 'အမျိုးအစား',
    expenseDate: 'ရက်စွဲ',
    expensePaymentMethod: 'ငွေပေးချေမှုနည်းလမ်း',
    expenseButton: 'အသုံးစရိတ်ထည့်မည်',
    expenseSaveSuccess: 'အထွေထွေ အသုံးစရိတ်ကို အောင်မြင်စွာ သိမ်းဆည်းပြီးပါပြီ',
    expenseSaveFailed: 'အထွေထွေ အသုံးစရိတ် သိမ်းဆည်းမှု မအောင်မြင်ပါ',
    expenseForm: 'အထွေထွေ အသုံးစရိတ် ဖောင်',
    expenseReason: 'အကြောင်းရင်း',
    expenseValidationError:
        'ကျေးဇူးပြု၍ လိုအပ်သော အကွက်များကို မှန်ကန်စွာ ဖြည့်ပါ။',
    expenseAmountValidator: 'ငွေပမာဏ မမှန်ကန်ပါ',
    expenseNoItems: 'ပစ္စည်း မတွေ့ပါ',
  };
}
