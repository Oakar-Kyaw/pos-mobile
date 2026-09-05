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
  static const paymentDiscount = 'payment_discount';
  static const paymentDiscountPercent = 'payment_discount_percent';
  static const paymentDiscountAmount = 'payment_discount_amount';
  static const paymentVoucherDiscountPercent =
      'payment_voucher_discount_percent';
  static const paymentVoucherDiscountAmount = 'payment_voucher_discount_amount';
  static const paymentError = 'payment_error';
  static const paymentAmountError = 'payment_amount_error';
  static const selectPaymentMethod = 'select_payment_method';
  static const selectPaymentAccount = 'select_payment_account';
  static const paymentAmountExceedError = 'payment_amount_exceed_error';
  static const noPayment = 'no_payment';
  static const paidAmount = 'paid_amount';
  static const deliveryFee = 'delivery_fee';
  static const packagingFee = 'packaging_fee';
  static const cancel = 'cancel_payment';

  // Photo
  static const paymentPhoto = 'payment_photo';
  static const uploadPhoto = 'upload_photo';
  static const viewPhoto = 'view_photo';
  static const removePhoto = 'remove_photo';

  // Delete
  static const deletePaymentAccountConfirm = 'delete_payment_account_confirm';
  static const deletePaymentSuccess = 'delete_payment_success';
  static const deletePaymentFailed = 'delete_payment_failed';

  // ===== English =====
  static const EN = {
    paymentTitle: 'Payment',
    paymentDescription: 'Choose Payment Method',
    paymentCard: 'Credit Card',
    paymentEWallet: 'E-Wallet (Pay)',
    paymentBank: 'Bank Account',
    paymentCash: 'Cash',
    paymentMethod: 'Payment Method',
    paymentAmount: 'Amount',
    paymentTotalAmount: 'Payment Amount',
    paymentRemainingAmount: 'Remaining Amount',

    paymentDiscount: 'Discount',
    paymentDiscountAmount: 'Amount',
    paymentDiscountPercent: 'Percent',
    paymentVoucherDiscountAmount: 'Discount Amount',
    paymentVoucherDiscountPercent: 'Discount Percent',

    paymentAmountPlaceholder: 'Enter payment amount',
    paymentButton: 'Save',
    paymentCancel: 'Cancel',

    paymentSuccess: 'Payment completed successfully',
    paymentError: 'Payment failed. Please try again.',
    paymentAmountError: 'Please enter a valid amount',

    selectPaymentMethod: 'Please select a payment method',
    selectPaymentAccount: 'Select Payment Account',

    paymentAmountExceedError: "Payment amount can't exceed the total amount.",

    noPayment: 'No Payment',
    paidAmount: 'Paid Amount',
    deliveryFee: 'Delivery Fee',
    packagingFee: 'Packaging Fee',
    cancel: 'Cancel',

    paymentPhoto: 'Payment Photo (Optional)',
    uploadPhoto: 'Upload Photo',
    viewPhoto: 'View Photo',
    removePhoto: 'Remove Photo',

    deletePaymentAccountConfirm: 'Do you want to delete this payment account?',
    deletePaymentSuccess: 'Payment account deleted successfully.',
    deletePaymentFailed: 'Failed to delete payment account.',
  };

  // ===== Myanmar =====
  static const MM = {
    paymentTitle: 'ငွေပေးချေမှု',

    paymentDescription: 'ငွေပေးချေမှုနည်းလမ်းကို ရွေးချယ်ပါ',

    paymentCard: 'ခရက်ဒစ်ကတ်',

    paymentEWallet: 'ဒစ်ဂျစ်တယ်ပိုက်ဆံအိတ် (Pay)',

    paymentBank: 'ဘဏ်အကောင့်',

    paymentCash: 'ငွေသား',

    paymentMethod: 'ငွေပေးချေနည်းလမ်း',

    paymentAmount: 'ငွေပမာဏ',

    paymentTotalAmount: 'ပေးချေရမည့် ငွေပမာဏ',

    paymentRemainingAmount: 'ကျန်ရှိသော ငွေပမာဏ',

    paymentDiscount: 'လျှော့ဈေး',

    paymentDiscountAmount: 'လျှော့ဈေး ပမာဏ',

    paymentDiscountPercent: 'လျှော့ဈေး ရာခိုင်နှုန်း',

    paymentVoucherDiscountAmount: 'ဘောက်ချာ လျှော့ဈေး ပမာဏ',

    paymentVoucherDiscountPercent: 'ဘောက်ချာ လျှော့ဈေး ရာခိုင်နှုန်း',

    paymentAmountPlaceholder: 'ငွေပမာဏ ထည့်ပါ',

    paymentButton: 'သိမ်းမည်',

    paymentCancel: 'ပယ်ဖျက်မည်',

    paymentSuccess: 'ငွေပေးချေမှု အောင်မြင်စွာ ပြီးမြောက်ပါပြီ',

    paymentError: 'ငွေပေးချေမှု မအောင်မြင်ပါ။ ထပ်မံကြိုးစားပါ။',

    paymentAmountError: 'မှန်ကန်သော ငွေပမာဏကို ထည့်ပါ',

    selectPaymentMethod: 'ငွေပေးချေနည်းလမ်းကို ရွေးချယ်ပါ',

    selectPaymentAccount: 'ငွေပေးချေမှုအကောင့်ကို ရွေးချယ်ပါ',

    paymentAmountExceedError:
        'ပေးချေသည့် ငွေပမာဏသည် စုစုပေါင်းပမာဏထက် မကျော်လွန်ရပါ။',

    noPayment: 'ငွေပေးချေမှု မရှိပါ',

    paidAmount: 'ပေးချေပြီးသော ငွေပမာဏ',

    deliveryFee: 'ပို့ဆောင်ခ',

    packagingFee: 'ထုပ်ပိုးခ',

    cancel: 'ပယ်ဖျက်မည်',

    paymentPhoto: 'ငွေပေးချေမှု ဓာတ်ပုံ (မဖြစ်မနေ မဟုတ်ပါ)',

    uploadPhoto: 'ဓာတ်ပုံ တင်မည်',

    viewPhoto: 'ဓာတ်ပုံ ကြည့်မည်',

    removePhoto: 'ဓာတ်ပုံ ဖယ်ရှားမည်',

    deletePaymentAccountConfirm: 'ဤငွေပေးချေမှုအကောင့်ကို ဖျက်လိုပါသလား?',

    deletePaymentSuccess: 'ငွေပေးချေမှုအကောင့်ကို အောင်မြင်စွာ ဖျက်ပြီးပါပြီ။',

    deletePaymentFailed: 'ငွေပေးချေမှုအကောင့်ကို ဖျက်ရာတွင် မအောင်မြင်ပါ။',
  };
}
