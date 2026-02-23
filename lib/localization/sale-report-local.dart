mixin SaleReportLocale {
  // Keys
  static const saleReportTitle = 'sale_report_title';
  static const saleReportDate = 'sale_report_date';
  static const saleReportTotal = 'sale_report_total';
  static const saleReportProductsSold = 'sale_report_products_sold';
  static const saleReportRevenue = 'sale_report_revenue';
  static const saleReportProfit = 'sale_report_profit';
  static const saleReportFilter = 'sale_report_filter';
  static const saleReportExport = 'sale_report_export';
  static const saleReportNoData = 'sale_report_no_data';
  static const saleReportOpeningAmount =
      'sale_report_opening_amount'; // ✅ Added
  static const saleReportClosingAmount =
      'sale_report_closing_amount'; // ✅ Added

  // 🇺🇸 English
  static const EN = {
    saleReportTitle: 'Sale Report',
    saleReportDate: 'Date',
    saleReportTotal: 'Total',
    saleReportProductsSold: 'Products Sold',
    saleReportRevenue: 'Revenue',
    saleReportProfit: 'Profit',
    saleReportFilter: 'Filter',
    saleReportExport: 'Export',
    saleReportNoData: 'No data available',
    saleReportOpeningAmount: 'Opening Amount', // ✅ Added
    saleReportClosingAmount: 'Closing Amount', // ✅ Added
  };

  // 🇲🇲 Burmese
  static const MM = {
    saleReportTitle: 'ရောင်းအားအစီရင်ခံစာ',
    saleReportDate: 'နေ့စွဲ',
    saleReportTotal: 'စုစုပေါင်း',
    saleReportProductsSold: 'ရောင်းအားကုန်ပစ္စည်းများ',
    saleReportRevenue: 'ဝင်ငွေ',
    saleReportProfit: 'အမြတ်အစွန်း',
    saleReportFilter: 'စစ်ထုတ်ရန်',
    saleReportExport: 'ထုတ်ပေးရန်',
    saleReportNoData: 'ဒေတာမရှိသေးပါ',
    saleReportOpeningAmount: 'အစပိုငွေ', // ✅ Added
    saleReportClosingAmount: 'အဆုံးပိုငွေ', // ✅ Added
  };
}
