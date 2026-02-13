mixin CompanyRegisterScreenLocal {
  // =======================
  // Keys
  // =======================
  static const companyTitle = 'company_title';
  static const companyDescription = 'company_description';

  static const companyCode = 'company_code';
  static const companyCodePlaceholder = 'company_code_placeholder';

  static const companyName = 'company_name';
  static const companyNamePlaceholder = 'company_name_placeholder';

  static const companyDescriptionPlaceholder =
      'company_description_placeholder';

  static const companyAddress = 'company_address';
  static const companyAddressPlaceholder = 'company_address_placeholder';

  static const companyEmail = 'company_email';
  static const companyEmailPlaceholder = 'company_email_placeholder';

  static const companyPassword = 'company_password';
  static const companyPasswordPlaceholder = 'company_password_placeholder';

  static const companyPhone = 'company_phone';
  static const companyPhonePlaceholder = 'company_phone_placeholder';

  static const companyButton = 'company_button';
  static const companyAction = 'company_action';

  // Validation Errors
  static const requiredError = 'required_error';
  static const emailInvalidError = 'email_invalid_error';
  static const phoneInvalidError = 'phone_invalid_error';
  static const passwordRequiredError = 'password_required_error';

  // Status messages
  static const createdSuccess = 'created_success';
  static const createFailed = 'create_failed';
  static const serverError = 'server_error';

  // =======================
  // English
  // =======================
  static const EN = {
    companyTitle: 'Company',
    companyDescription: 'Please create your company profile',

    companyCode: 'Company Code',
    companyCodePlaceholder: 'E.g., C001, C002',

    companyName: 'Company Name',
    companyNamePlaceholder: 'E.g., ABC Corp, XYZ Ltd',

    companyAddress: 'Address',
    companyAddressPlaceholder: 'E.g., No. 123, Main Street, City',

    companyEmail: 'Email',
    companyEmailPlaceholder: 'E.g., info@company.com',

    companyPassword: 'Password',
    companyPasswordPlaceholder: 'Enter your password',

    companyPhone: 'Phone',
    companyPhonePlaceholder: 'E.g., +95 9 123 456 789',

    companyButton: 'Add',
    companyAction: 'Actions',

    // Errors
    requiredError: 'This field is required',
    emailInvalidError: 'Please enter a valid email address',
    phoneInvalidError: 'Please enter a valid phone number',
    passwordRequiredError: 'Password is required',

    // Status messages
    createdSuccess: 'Company created successfully',
    createFailed: 'Failed to create company',
    serverError: 'Server error occurred, please try again',
  };

  // =======================
  // Burmese (Myanmar)
  // =======================
  static const MM = {
    companyTitle: 'ကုမ္ပဏီ',
    companyDescription: 'ကျေးဇူးပြု၍ သင့်ကုမ္ပဏီကို ဖန်တီးပါ',

    companyCode: 'ကုမ္ပဏီကုဒ်',
    companyCodePlaceholder: 'ဥပမာ၊ C001, C002',

    companyName: 'ကုမ္ပဏီအမည်',
    companyNamePlaceholder: 'ဥပမာ၊ ABC Corp, XYZ Ltd',

    companyAddress: 'လိပ်စာ',
    companyAddressPlaceholder: 'ဥပမာ၊ အမှတ် 123၊ မိန်းလမ်း၊ မြို့',

    companyEmail: 'အီးမေးလ်',
    companyEmailPlaceholder: 'ဥပမာ၊ info@company.com',

    companyPassword: 'စကားဝှက်',
    companyPasswordPlaceholder: 'သင့်စကားဝှက်ကို ထည့်ပါ',

    companyPhone: 'ဖုန်းနံပါတ်',
    companyPhonePlaceholder: 'ဥပမာ၊ +95 9 123 456 789',

    companyButton: 'ထည့်ရန်',
    companyAction: 'လုပ်ဆောင်ချက်များ',

    // Errors
    requiredError: 'ဤအချက်အလက်ကို မဖြစ်မနေ ထည့်သွင်းရပါမည်',
    emailInvalidError: 'မှန်ကန်သော အီးမေးလ်လိပ်စာကို ထည့်ပါ',
    phoneInvalidError: 'မှန်ကန်သော ဖုန်းနံပါတ်ကို ထည့်ပါ',
    passwordRequiredError: 'စကားဝှက်ကို မဖြစ်မနေ ထည့်ရပါမည်',

    // Status messages
    createdSuccess: 'ကုမ္ပဏီကို အောင်မြင်စွာ ဖန်တီးပြီးပါပြီ',
    createFailed: 'ကုမ္ပဏီ ဖန်တီးမှု မအောင်မြင်ပါ',
    serverError: 'ဆာဗာမှ အမှား ဖြစ်ပွားနေသည်၊ နောက်မှ ပြန်ကြိုးစားပါ',
  };
}
