mixin VoucherScreenLocale {
  // ===== Keys =====
  static const title = 'voucher_title';
  static const noItems = 'voucher_no_items';
  static const subtotal = 'voucher_subtotal';
  static const tax = 'voucher_tax';
  static const total = 'voucher_total';
  static const note = 'voucher_note';
  static const save = 'voucher_save';
  static const quantity = 'voucher_quantity';
  static const price = 'voucher_price';
  static const addItem = 'voucher_add_item'; // <-- new key

  // ===== English =====
  static const EN = {
    title: 'Create Voucher',
    noItems: 'No items selected',
    subtotal: 'Subtotal',
    tax: 'Tax',
    total: 'Total',
    note: 'Note',
    save: 'Save Voucher',
    quantity: 'Quantity',
    price: 'Price',
    addItem: 'Add New Item', // <-- English text
  };

  // ===== Myanmar =====
  static const MM = {
    title: 'ဘောက်ချာ ဖန်တီးခြင်း',
    noItems: 'ပစ္စည်း မရွေးချယ်ရသေးပါ',
    subtotal: 'စုစုပေါင်း (အခွန်မပါ)',
    tax: 'အခွန်',
    total: 'စုစုပေါင်း',
    note: 'မှတ်ချက်',
    save: 'ဘောက်ချာ သိမ်းမည်',
    quantity: 'အရေအတွက်',
    price: 'စျေးနှုန်း',
    addItem: 'ပစ္စည်း အသစ် ထည့်မည်', // <-- Myanmar translation
  };
}
