mixin PaymentScreenLocale {
  // ===== Keys =====
  static const paymentTitle = 'payment_title';
  static const paymentCard = 'payment_card';
  static const paymentEWallet = 'payment_ewallet';
  static const paymentBank = 'payment_bank';
  static const paymentCash = 'payment_cash';
  static const paymentDescription = 'payment_description';
  static const paymentMethod = 'payment_method';
  static const paymentAmount = 'payment_amount';
  static const paymentTotalAmount = 'payment_total_amount';
  static const paymentRemainingAmount = 'payment_remaining_amount';
  static const paymentAmountPlaceholder = 'payment_amount_placeholder';
  static const paymentButton = 'payment_button';
  static const paymentCancel = 'payment_cancel';
  static const paymentSuccess = 'payment_success';
  static const paymentError = 'payment_error';
  static const paymentAmountError = 'payment_amount_error';
  static const selectPaymentMethod = 'select_payment_method';
  static const selectPaymentAccount = 'select_payment_account';
  static const paymentAmountExceedError = 'payment_amount_exceed_error';
  static const noPayment = 'no_payment';
  static const paidAmount = 'paid_amount';
  static const deliveryFee = 'delivery_fee'; // ✅ NEW

  // ✅ NEW PHOTO KEYS
  static const paymentPhoto = 'payment_photo';
  static const uploadPhoto = 'upload_photo';
  static const viewPhoto = 'view_photo';
  static const removePhoto = 'remove_photo';

  // ===== English =====
  static const EN = {
    paymentTitle: 'Payment',
    paymentDescription: 'Choose Payment Method',
    paymentCard: "Credit Card",
    paymentEWallet: "E-Wallet (Pay)",
    paymentBank: "Bank Account",
    paymentCash: "Cash",
    paymentMethod: 'Payment Method',
    paymentAmount: 'Amount',
    paymentTotalAmount: 'Total Payment Amount',
    paymentRemainingAmount: 'Remaining Payment Amount',
    paymentAmountPlaceholder: 'Enter payment amount',
    paymentButton: 'Save',
    paymentCancel: 'Cancel',
    paymentSuccess: 'Payment completed successfully',
    paymentError: 'Payment failed. Please try again.',
    paymentAmountError: 'Please enter a valid amount',
    selectPaymentMethod: 'Please select a payment method',
    selectPaymentAccount: 'Select Payment Account',
    paymentAmountExceedError: "Pay Amount can't exceed total Amount",
    noPayment: 'No payment',
    paidAmount: 'Paid Amount',
    deliveryFee: 'Delivery Fee', // ✅ NEW

    paymentPhoto: 'Payment Photo (Optional)',
    uploadPhoto: 'Upload Photo',
    viewPhoto: 'View Photo',
    removePhoto: 'Remove Photo',
  };

  // ===== Burmese =====
  static const MM = {
    paymentTitle: 'ငွေပေးချေမှု',
    paymentDescription: 'ငွေပေးချေမှုအမျိုးအစားအား ရွေးချယ်ပါ',
    paymentMethod: 'ငွေပေးချေနည်းလမ်း',
    paymentAmount: 'ငွေပမာဏ',
    paymentTotalAmount: 'ပေးချေရမည့် ငွေပမာဏ',
    paymentRemainingAmount: 'ပေးချေရန် ကျန်ရှိသည့် ပမာဏ',
    paymentCard: "ခရက်ဒစ်ကတ်",
    paymentEWallet: "ဒစ်ဂျစ်တယ် ပိုက်ဆံအိတ် (Pay)",
    paymentBank: "ဘဏ်အကောင့်",
    paymentCash: "ငွေသား",
    paymentAmountPlaceholder: 'ငွေပမာဏ ထည့်ပါ',
    paymentButton: 'သိမ်းရန်',
    paymentCancel: 'ပယ်ဖျက်ရန်',
    paymentSuccess: 'ငွေပေးချေမှု အောင်မြင်စွာ ပြီးမြောက်ပါပြီ',
    paymentError: 'ငွေပေးချေမှု မအောင်မြင်ပါ။ ထပ်မံကြိုးစားပါ။',
    paymentAmountError: 'မှန်ကန်သော ငွေပမာဏ ထည့်ပါ',
    selectPaymentMethod: 'ငွေပေးချေနည်းလမ်း ရွေးပါ',
    selectPaymentAccount: 'အကောင့် ရွေးချယ်ပါ',
    paymentAmountExceedError: 'ပေးရန် ငွေပမာဏသည် စုစုပေါင်းကိုကျော်၍မရပါ',
    noPayment: 'ငွေပေးချေမှု မရှိပါ',
    paidAmount: 'ပေးချေထားသည့် ပမာဏ',
    deliveryFee: 'ပို့ဆောင်ခ', // ✅ NEW

    paymentPhoto: 'ငွေပေးချေမှု ဓာတ်ပုံ (မတင်လည်း ရ)',
    uploadPhoto: 'ဓာတ်ပုံ တင်ရန်',
    viewPhoto: 'ဓာတ်ပုံ ကြည့်ရန်',
    removePhoto: 'ဓာတ်ပုံ ဖယ်ရှားရန်',
  };
}
