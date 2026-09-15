mixin NotificationScreenLocale {
  // Navigation & Page Titles
  static const notificationTitle = 'notification_title';
  static const markAllAsRead = 'mark_all_as_read';
  static const clearAll = 'clear_all';

  // Tabs
  static const tabSystem = 'tab_system';
  static const tabLowStock = 'tab_low_stock';
  static const tabPayment = 'tab_payment';

  // Item Details
  static const unread = 'unread';
  static const read = 'read';
  static const markAsRead = 'mark_as_read';
  static const deleteNotification = 'delete_notification';

  // Empty States & Errors
  static const noNotifications = 'no_notifications';
  static const noNotificationsDesc = 'no_notifications_desc';
  static const errorLoading = 'error_loading';
  static const retry = 'retry';

  // Time & Status Placeholders
  static const justNow = 'just_now';
  static const today = 'today';
  static const yesterday = 'yesterday';

  static const EN = {
    notificationTitle: 'Notifications',
    markAllAsRead: 'Mark all as read',
    clearAll: 'Clear all',

    tabSystem: 'System',
    tabLowStock: 'Low Stock',
    tabPayment: 'Payment',

    unread: 'Unread',
    read: 'Read',
    markAsRead: 'Mark as read',
    deleteNotification: 'Delete notification',

    noNotifications: 'No notifications',
    noNotificationsDesc: 'You are all caught up! Check back later.',
    errorLoading: 'Failed to load notifications',
    retry: 'Retry',

    justNow: 'Just now',
    today: 'Today',
    yesterday: 'Yesterday',
  };

  static const MM = {
    notificationTitle: 'အကြောင်းကြားချက်များ',
    markAllAsRead: 'အားလုံးဖတ်ပြီးသားအဖြစ် မှတ်သားမည်',
    clearAll: 'အားလုံးရှင်းထုတ်မည်',

    tabSystem: 'စနစ်',
    tabLowStock: 'ပစ္စည်းလက်ကျန်နည်း',
    tabPayment: 'ငွေပေးချေမှု',

    unread: 'မဖတ်ရသေးပါ',
    read: 'ဖတ်ပြီးပါပြီ',
    markAsRead: 'ဖတ်ပြီးသားအဖြစ် မှတ်သားမည်',
    deleteNotification: 'အကြောင်းကြားချက် ဖျက်မည်',

    noNotifications: 'အကြောင်းကြားချက် မရှိပါ',
    noNotificationsDesc: 'အကြောင်းကြားချက်အသစ်များ မရှိသေးပါ။',
    errorLoading: 'အကြောင်းကြားချက်များ ရယူ၍ မရပါ',
    retry: 'ပြန်လည်ကြိုးစားမည်',

    justNow: 'ခုနက',
    today: 'ယနေ့',
    yesterday: 'မနေ့က',
  };
}
