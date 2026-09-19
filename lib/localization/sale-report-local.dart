mixin SaleReportLocale {
  static const saleReportTitle = 'sale_report_title';
  static const saleReportDate = 'sale_report_date';
  static const saleReportChange = 'sale_report_change';
  static const saleReportClosingReport = 'sale_report_closing_report';
  static const saleReportDailySummary = 'sale_report_daily_summary';
  static const saleReportTodaySales = 'sale_report_today_sales';
  static const saleReportError = 'sale_report_error';

  static const saleReportOpeningAmount = 'sale_report_opening_amount';
  static const saleReportClosingAmount = 'sale_report_closing_amount';
  static const saleReportGeneralExpense = 'sale_report_general_expense';
  static const saleReportTotalPurchase = 'sale_report_total_purchase';
  static const saleReportSave = 'sale_report_save';
  static const saleReportTransfer = 'sale_report_transfer';
  static const saleReportSaveFailed = 'sale_report_save_failed';
  static const saleReportSaved = 'sale_report_saved';

  static const saleReportTotalPaid = 'sale_report_total_paid';
  static const saleReportTotalDebt = 'sale_report_total_debt';
  static const saleReportTotalRefund = 'sale_report_total_refund';
  static const saleReportTotalRepay = 'sale_report_total_repay';
  static const saleReportTotalTransfer = 'sale_report_total_transfer';
  static const saleReportClosed = 'sale_report_closed';
  static const saleReportOpen = 'sale_report_open';
  static const saleReportExternalTransferAmount =
      'sale_report_external_transfer_amount';
  static const saleReportInternalTransferAmount =
      'sale_report_internal_transfer_amount';

  // ── newly added ──────────────────────────────
  static const saleReportNoOpeningBalanceSet =
      'sale_report_no_opening_balance_set';
  static const saleReportEnterOpeningBalanceHint =
      'sale_report_enter_opening_balance_hint';
  static const saleReportSaveOpeningBalance =
      'sale_report_save_opening_balance';
  static const saleReportNoClosingAmountToTransfer =
      'sale_report_no_closing_amount_to_transfer';
  static const saleReportOpeningBalanceSaved =
      'sale_report_opening_balance_saved';
  static const saleReportFailedToSaveOpeningBalance =
      'sale_report_failed_to_save_opening_balance';
  static const saleReportHistory = 'sale_report_history';
  static const saleReportNoRecordsForDay = 'sale_report_no_records_for_day';
  static const saleReportNoRecords = 'sale_report_no_records'; // 👈 Added
  static const saleReportTransferDatas = 'sale_report_transfer_datas';
  static const saleReportNoTransfersForDay = 'sale_report_no_transfers_for_day';
  static const saleReportDeleteTransferTitle =
      'sale_report_delete_transfer_title';
  static const saleReportDeleteTransferConfirm =
      'sale_report_delete_transfer_confirm';
  static const saleReportDeleteSaleReportTitle =
      'sale_report_delete_sale_report_title';
  static const saleReportDeleteSaleReportConfirm =
      'sale_report_delete_sale_report_confirm';
  static const saleReportDeleteSuccess = 'sale_report_delete_success';
  static const saleReportDeleteError = 'sale_report_delete_error';

  // 🇺🇸 English
  static const EN = {
    saleReportTitle: 'Sale Report',
    saleReportDate: 'Date',
    saleReportChange: 'Change',

    saleReportClosingReport: 'Closing Report',
    saleReportDailySummary: 'Daily Summary',
    saleReportTodaySales: "Today's Sales",
    saleReportError: 'Error',

    saleReportOpeningAmount: 'Opening Amount',
    saleReportClosingAmount: 'Closing Amount',
    saleReportGeneralExpense: 'General Expense',
    saleReportTotalPurchase: 'Total Purchase',

    saleReportSave: "Save",
    saleReportTransfer: "Transfer",

    saleReportSaveFailed: 'Failed to save report',
    saleReportSaved: 'Report saved successfully',

    saleReportTotalPaid: 'Total Paid',
    saleReportTotalDebt: 'Total Debt',
    saleReportTotalRefund: 'Total Refund',
    saleReportTotalRepay: 'Total Repay',
    saleReportTotalTransfer: 'Total Transfer',
    saleReportClosed: 'Closed',
    saleReportOpen: 'Open',
    saleReportExternalTransferAmount: 'External Transfer Amount',
    saleReportInternalTransferAmount: 'Internal Transfer Amount',

    saleReportNoOpeningBalanceSet: 'No opening balance set for company',
    saleReportEnterOpeningBalanceHint:
        "Enter today's opening balance to start recording sales",
    saleReportSaveOpeningBalance: 'Save Opening Balance',
    saleReportNoClosingAmountToTransfer: 'No closing amount to transfer',
    saleReportOpeningBalanceSaved: 'Opening balance saved successfully',
    saleReportFailedToSaveOpeningBalance: 'Failed to save opening balance',
    saleReportHistory: 'Sale Report History',
    saleReportNoRecordsForDay: 'No records for this day',
    saleReportNoRecords: 'No records found', // 👈 Added
    saleReportTransferDatas: 'Transfer Data',
    saleReportNoTransfersForDay: 'No transfers for this day',
    saleReportDeleteTransferTitle: 'Delete Transfer',
    saleReportDeleteTransferConfirm: 'Do you want to delete this transfer?',
    saleReportDeleteSaleReportTitle: 'Delete Sale Report',
    saleReportDeleteSaleReportConfirm: 'Do you want to delete this record?',
    saleReportDeleteSuccess: 'Deleted successfully',
    saleReportDeleteError: 'An error occurred while deleting',
  };

  // 🇲🇲 Burmese
  static const MM = {
    saleReportTitle: 'ရောင်းအားအစီရင်ခံစာ',
    saleReportDate: 'နေ့စွဲ',
    saleReportChange: 'ပြောင်းလဲရန်',
    saleReportClosingReport: 'နေ့စဉ်ပိတ်သိမ်းအစီရင်ခံစာ',
    saleReportDailySummary: 'နေ့စဉ်အကျဉ်းချုပ်',
    saleReportTodaySales: 'ယနေ့ရောင်းအား',
    saleReportError: 'အမှား',

    saleReportOpeningAmount: 'အစငွေ',
    saleReportClosingAmount: 'အပိတ်ငွေ',
    saleReportGeneralExpense: 'အထွေထွေအသုံးစရိတ်',
    saleReportTotalPurchase: 'စုစုပေါင်းဝယ်ယူမှု',

    saleReportSave: "သိမ်းဆည်းပါ",
    saleReportTransfer: "ငွေလွှဲမည်",

    saleReportSaveFailed: 'အစီရင်ခံစာ သိမ်းဆည်းမှု မအောင်မြင်ပါ',
    saleReportSaved: 'အစီရင်ခံစာကို အောင်မြင်စွာသိမ်းဆည်းပြီးပါပြီ',

    saleReportTotalPaid: 'စုစုပေါင်းရရှိငွေ',
    saleReportTotalDebt: 'စုစုပေါင်းအကြွေးငွေ',
    saleReportTotalRefund: 'စုစုပေါင်းပြန်အမ်းငွေ',
    saleReportTotalRepay: 'စုစုပေါင်းအကြွေးဆပ်ငွေ',
    saleReportTotalTransfer: 'စုစုပေါင်းငွေလွှဲမှု',
    saleReportClosed: 'ပိတ်ပြီး',
    saleReportOpen: 'ဖွင့်ထား',
    saleReportExternalTransferAmount: 'ပြင်ပသို့ လွှဲပြောင်းငွေ ပမာဏ',
    saleReportInternalTransferAmount: 'အတွင်းပိုင်း လွှဲပြောင်းငွေ ပမာဏ',

    saleReportNoOpeningBalanceSet:
        'ကုမ္ပဏီအတွက် အစပိုငွေ သတ်မှတ်ထားခြင်းမရှိသေးပါ',
    saleReportEnterOpeningBalanceHint:
        'ရောင်းအားများ မှတ်တမ်းတင်ရန် ယနေ့အတွက် အစပိုငွေ ထည့်သွင်းပါ',
    saleReportSaveOpeningBalance: 'အစပိုငွေ သိမ်းဆည်းမည်',
    saleReportNoClosingAmountToTransfer: 'လွှဲပြောင်းရန် အဆုံးပိုငွေ မရှိပါ',
    saleReportOpeningBalanceSaved: 'အစပိုငွေ အောင်မြင်စွာ သိမ်းဆည်းပြီးပါပြီ',
    saleReportFailedToSaveOpeningBalance: 'အစပိုငွေ သိမ်းဆည်းမှု မအောင်မြင်ပါ',
    saleReportHistory: 'ရောင်းအား အစီရင်ခံစာ မှတ်တမ်း',
    saleReportNoRecordsForDay: 'ဒီနေ့အတွက် မှတ်တမ်းမရှိပါ',
    saleReportNoRecords: 'မှတ်တမ်းများ မရှိပါ',
    saleReportTransferDatas: 'ငွေလွှဲပြောင်းမှု အချက်အလက်များ',
    saleReportNoTransfersForDay: 'ဒီနေ့အတွက် ငွေလွှဲပြောင်းမှုမရှိပါ',
    saleReportDeleteTransferTitle: 'ငွေလွှဲပြောင်းမှု ဖျက်မည်',
    saleReportDeleteTransferConfirm:
        'ဤငွေလွှဲပြောင်းမှုကို ဖျက်ရန် သေချာပါသလား?',
    saleReportDeleteSaleReportTitle: 'ရောင်းအားအစီရင်ခံစာ ဖျက်မည်',
    saleReportDeleteSaleReportConfirm: 'ဤမှတ်တမ်းကို ဖျက်ရန် သေချာပါသလား?',
    saleReportDeleteSuccess: 'အောင်မြင်စွာ ဖျက်ပြီးပါပြီ',
    saleReportDeleteError: 'ဖျက်နေစဉ် အမှားတစ်ခု ဖြစ်ပေါ်ခဲ့သည်',
  };
}
