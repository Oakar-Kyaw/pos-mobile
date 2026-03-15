mixin AttendanceLocaleScreenLocale {
  // Keys
  static const attendanceTitle = 'attendance_title';
  static const attendanceDescription = 'attendance_description';
  static const attendanceCard = 'attendance_card';

  static const attendanceEmployee = 'attendance_employee';
  static const attendanceDate = 'attendance_date';

  static const attendanceCheckIn = 'attendance_check_in';
  static const attendanceCheckOut = 'attendance_check_out';
  static const attendanceCompleted = 'attendance_completed';

  static const attendanceWorkingHours = 'attendance_working_hours';
  static const attendanceStatus = 'attendance_status';

  static const attendancePresent = 'attendance_present';
  static const attendanceAbsent = 'attendance_absent';
  static const attendanceLate = 'attendance_late';
  static const attendanceLeave = 'attendance_leave';
  static const attendanceHalfDay = 'attendance_half_day';
  static const attendanceHoliday = 'attendance_holiday';
  static const attendanceEarlyLeave = 'attendance_early_leave'; // ✅ Added

  static const attendanceNote = 'attendance_note';
  static const attendanceAction = 'attendance_action';

  static const attendanceSearchPlaceholder = 'attendance_search_placeholder';

  static const attendanceSuccess = 'attendance_success';
  static const attendanceFail = 'attendance_fail';

  // 🇺🇸 English
  static const EN = {
    attendanceTitle: 'Attendance',
    attendanceDescription: 'Manage employee attendance records.',
    attendanceCard: 'Attendance List',

    attendanceEmployee: 'Employee',
    attendanceDate: 'Date',

    attendanceCheckIn: 'Check In',
    attendanceCheckOut: 'Check Out',
    attendanceCompleted: 'Completed',

    attendanceWorkingHours: 'Working Hours',
    attendanceStatus: 'Status',

    attendancePresent: 'Present',
    attendanceAbsent: 'Absent',
    attendanceLate: 'Late',
    attendanceLeave: 'Leave',
    attendanceHalfDay: 'Half Day',
    attendanceHoliday: 'Holiday',
    attendanceEarlyLeave: 'Early Leave', // ✅ Added

    attendanceNote: 'Note',

    attendanceAction: 'Action',

    attendanceSearchPlaceholder: 'Search attendance...',

    attendanceSuccess: 'Attendance recorded successfully!',
    attendanceFail: 'Failed to record attendance.',
  };

  // 🇲🇲 Burmese
  static const MM = {
    attendanceTitle: 'အလုပ်တက်ရောက်မှု',
    attendanceDescription: 'အလုပ် တက်ရောက်မှု မှတ်တမ်းများကို စီမံနိုင်ပါသည်။',
    attendanceCard: 'တက်ရောက်မှု စာရင်း',

    attendanceEmployee: 'ဝန်ထမ်း',
    attendanceDate: 'ရက်စွဲ',

    attendanceCheckIn: 'အလုပ်ဝင်ချိန်',
    attendanceCheckOut: 'အလုပ်ဆင်းချိန်',
    attendanceCompleted: 'ပြီးစီးပြီး',

    attendanceWorkingHours: 'အလုပ်လုပ်ချိန်',
    attendanceStatus: 'အခြေအနေ',

    attendancePresent: 'တက်ရောက်',
    attendanceAbsent: 'မတက်',
    attendanceLate: 'နောက်ကျ',
    attendanceLeave: 'ရုံးလွတ်',
    attendanceHalfDay: 'ခွဲနေ့',
    attendanceHoliday: 'ပိတ်ရက်',
    attendanceEarlyLeave: 'စောထွက်', // ✅ Added

    attendanceNote: 'မှတ်ချက်',

    attendanceAction: 'လုပ်ဆောင်ချက်',

    attendanceSearchPlaceholder: 'တက်ရောက်မှု ရှာရန်...',

    attendanceSuccess: 'တက်ရောက်မှုကို အောင်မြင်စွာ မှတ်တမ်းတင်ပြီးပါပြီ!',
    attendanceFail: 'တက်ရောက်မှု မှတ်တမ်းတင်ရာတွင် မအောင်မြင်ပါ။',
  };
}
