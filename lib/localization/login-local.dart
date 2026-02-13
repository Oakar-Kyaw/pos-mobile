mixin LoginScreenLocale {
  // ===== Keys =====
  static const loginTitle = 'login_title';
  static const loginDescription = 'login_description';

  static const email = 'login_email';
  static const emailPlaceholder = 'login_email_placeholder';
  static const emailError = 'email_error';
  static const emailNotFound = 'email_not_found';

  static const phone = 'login_phone';
  static const phonePlaceholder = 'login_phone_placeholder';
  static const phoneError = 'phone_error';

  static const password = 'login_password';
  static const passwordPlaceholder = 'login_password_placeholder';
  static const passwordError = 'password_error';
  static const passwordWrong = 'password_wrong';

  static const signIn = 'login_sign_in';

  // 👇 NEW (Register section)
  static const newToPos = 'login_new_to_pos';
  static const register = 'login_register';

  // ===== English =====
  static const EN = {
    loginTitle: 'Sign In',
    loginDescription: 'Please sign in to continue',

    email: 'Email',
    emailPlaceholder: 'Enter your email',
    emailError: 'Email is required',
    emailNotFound: 'User with this email not found',

    phone: 'Phone',
    phonePlaceholder: 'Enter your phone number',
    phoneError: 'Phone number is required',

    password: 'Password',
    passwordPlaceholder: 'Enter your password',
    passwordError: 'Password must be at least 6 characters',
    passwordWrong: 'Password was wrong.',

    signIn: 'Sign In',

    newToPos: 'New to POS Master',
    register: 'Register',
  };

  // ===== Burmese (Myanmar) =====
  static const MM = {
    loginTitle: 'လော့ဂ်အင်',
    loginDescription: 'ဆက်လက်အသုံးပြုရန် လော့ဂ်အင်လုပ်ပါ',

    email: 'အီးမေးလ်',
    emailPlaceholder: 'အီးမေးလ်ကို ထည့်ပါ',
    emailError: 'အီးမေးလ်လိုအပ်ပါသည်',
    emailNotFound: 'ဤအီးမေးလ်ဖြင့် အသုံးပြုသူ မတွေ့ပါ',

    phone: 'ဖုန်းနံပါတ်',
    phonePlaceholder: 'ဖုန်းနံပါတ်ကို ထည့်ပါ',
    phoneError: 'ဖုန်းနံပါတ်လိုအပ်ပါသည်',

    password: 'စကားဝှက်',
    passwordPlaceholder: 'စကားဝှက်ကို ထည့်ပါ',
    passwordError: 'စကားဝှက်သည် အနည်းဆုံး ၆ လုံးရှိရမည်',
    passwordWrong: 'စကားဝှက် မှားယွင်းနေပါသည်',

    signIn: 'ဝင်ရောက်မည်',

    newToPos: 'POS Master အသုံးပြုသူ အသစ်လား',
    register: 'စာရင်းသွင်းမည်',
  };
}
