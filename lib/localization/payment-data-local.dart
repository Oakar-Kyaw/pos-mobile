mixin PaymentDataLocale {
  // Keys
  static const drawerPaymentData = 'drawer_payment_data';
  static const accountForm = 'account_form';
  static const name = 'account_name';
  static const addAccount = 'add_account';
  static const accountNo = 'account_no';
  static const bankName = 'bank_name';
  static const accountHolder = 'account_holder';
  static const balance = 'balance';
  static const type = 'account_type';
  static const accountNoItems = 'account_no_items';
  static const accountSaveSuccess = 'account_save_success';
  static const accountSaveFailed = 'account_save_failed';
  static const accountEditSuccess = 'account_edit_success';
  static const accountEditFailed = 'account_edit_failed';
  static const accountValidationError = 'account_validation_error';
  static const saveButton = 'save_button';
  static const editButton = 'edit_button';
  static const accountNumber = 'account_number';

  /// English translations
  static const EN = {
    drawerPaymentData: 'Payment Accounts',
    name: 'Name',
    accountNumber: 'Account No',
    accountForm: 'Account Form',
    addAccount: 'Add new account here',
    accountNo: 'No',
    bankName: 'Bank / Service Name',
    accountHolder: 'Account Holder',
    balance: 'Balance',
    type: 'Account Type',
    accountNoItems: 'No accounts found',
    accountSaveSuccess: 'Account saved successfully',
    accountSaveFailed: 'Failed to save account',
    accountEditSuccess: 'Account edited successfully',
    accountEditFailed: 'Failed to edit account',
    accountValidationError: 'Please fill out all required fields correctly.',
    saveButton: 'Save Account',
    editButton: 'Edit Account',
  };

  /// Burmese translations
  static const MM = {
    drawerPaymentData: 'ငွေပေးချေမှုအကောင့်များ',
    name: 'နာမည်',
    accountNumber: 'အကောင့်နံပါတ်',
    accountForm: 'အကောင့်ဖောင်',
    addAccount: 'အကောင့်အသစ် ထည့်ရန်',
    accountNo: 'စဉ်',
    bankName: 'အကောင့် နာမည်',
    accountHolder: 'အကောင့်ပိုင်ရှင်',
    balance: 'လတ်ကျန်',
    type: 'အမျိုးအစား',
    accountNoItems: 'အကောင့်မရှိပါ',
    accountSaveSuccess: 'အကောင့်ကို အောင်မြင်စွာ သိမ်းဆည်းပြီးပါပြီ',
    accountSaveFailed: 'အကောင့် သိမ်းဆည်းမှု မအောင်မြင်ပါ',
    accountEditSuccess: 'အကောင့်ကို အောင်မြင်စွာ ပြင်ဆင်ပြီးပါပြီ',
    accountEditFailed: 'အကောင့် ပြင်ဆင်မှု မအောင်မြင်ပါ',
    accountValidationError:
        'ကျေးဇူးပြု၍ လိုအပ်သော အကွက်များကို မှန်ကန်စွာ ဖြည့်ပါ။',
    saveButton: 'အကောင့် သိမ်းမည်',
    editButton: 'အကောင့် ပြင်မည်',
  };
}
