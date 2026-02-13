mixin CategoryScreenLocale {
  static const categoryTitle = 'category_title';
  static const categoryDescription = 'category_description';
  static const categoryName = 'category_name';
  static const categoryDescriptionPlaceholder =
      'category_description_placeholder';
  static const categoryButton = 'category_button';
  static const categoryAction = 'category_action';
  static const categoryTitleError = 'category_title_error';

  static const categoryCreateSuccess = 'category_create_success';
  static const categoryCreateError = 'category_create_error';

  static const selectCategory = 'select_category';

  static const EN = {
    categoryTitle: 'Categories',
    categoryDescription:
        'Create and manage categories to organize your products.',
    categoryName: 'Category Name',
    categoryDescriptionPlaceholder:
        'E.g., Electronics, Clothing, Home Appliances',
    categoryButton: 'Add',
    categoryAction: "Actions",
    categoryTitleError: 'Please fill category title',

    // ✅ NEW
    categoryCreateSuccess: 'Category created successfully',
    categoryCreateError: 'Failed to create category',
    selectCategory: "Please select category",
  };

  static const MM = {
    categoryTitle: 'အမျိုးအစားများ',
    categoryDescription:
        'ပစ္စည်းများကို စနစ်တကျ စီမံနိုင်ရန် အမျိုးအစားများကို ဖန်တီးပြီး စီမံခန့်ခွဲပါ။',
    categoryName: 'အမျိုးအစား အမည်',
    categoryDescriptionPlaceholder:
        'ဥပမာ၊ အီလက်ထရောနစ်၊ အဝတ်အစား၊ အိမ်သုံးပစ္စည်းများ',
    categoryButton: 'ထည့်ရန်',
    categoryAction: 'လုပ်ဆောင်ချက်များ',
    categoryTitleError: 'အမျိုးအစား အမည်ကို ဖြည့်ပါ',

    categoryCreateSuccess: 'အမျိုးအစားကို အောင်မြင်စွာ ဖန်တီးပြီးပါပြီ',
    categoryCreateError: 'အမျိုးအစား ဖန်တီးမှု မအောင်မြင်ပါ',
    selectCategory: 'အမျိုးအစား ရွေးပါ',
  };
}
