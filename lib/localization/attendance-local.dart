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
  static const attendanceEarlyLeave = 'attendance_early_leave';

  static const attendanceNote = 'attendance_note';
  static const attendanceAction = 'attendance_action';

  static const attendanceSearchPlaceholder = 'attendance_search_placeholder';

  static const attendanceSuccess = 'attendance_success';
  static const attendanceFail = 'attendance_fail';
  static const attendanceDeleteConfirm = 'attendance_delete_confirm';
  static const attendanceDeleteSuccess = 'attendance_delete_success';
  static const attendanceDeleteFail = 'attendance_delete_fail';

  static const attendanceForm = 'attendance_form';
  static const attendanceCreate = 'attendance_create';
  static const attendanceSelectUser = 'attendance_select_user';
  static const attendanceSelectDate = 'attendance_select_date';

  static const attendanceStatusPlaceholder = 'attendance_status_placeholder';
  static const attendanceCheckInPlaceholder = 'attendance_check_in_placeholder';
  static const attendanceCheckOutPlaceholder =
      'attendance_check_out_placeholder';

  static const attendanceWorkingMinutes = 'attendance_working_minutes';
  static const attendanceWorkingMinutesPlaceholder =
      'attendance_working_minutes_placeholder';

  static const attendanceNotePlaceholder = 'attendance_note_placeholder';
  static const attendanceValidationError = 'attendance_validation_error';

  // ✅ NEW VALIDATION KEYS
  static const attendanceCheckInRequired = 'attendance_check_in_required';
  static const attendanceCheckOutRequired = 'attendance_check_out_required';
  static const attendanceOvertime = 'attendance_overtime';
  static const attendanceHour = 'attendance_hour';
  static const attendanceDay = 'attendance_day';
  static const attendanceOvertimePlaceholder =
      'attendance_overtime_placeholder';
  static const attendanceOvertimeRequired = 'attendance_overtime_required';
  static const attendanceWorkingMinutesRequired =
      'attendance_working_minutes_required';

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
    attendanceEarlyLeave: 'Early Leave',

    attendanceNote: 'Note',
    attendanceAction: 'Action',

    attendanceSearchPlaceholder: 'Search attendance...',

    attendanceSuccess: 'Attendance recorded successfully!',
    attendanceFail: 'Failed to record attendance.',
    attendanceDeleteConfirm: 'Do you want to delete this attendance?',
    attendanceDeleteSuccess: 'Attendance deleted successfully',
    attendanceDeleteFail: 'Failed to delete attendance',

    attendanceForm: 'Attendance Form',
    attendanceCreate: 'Create Attendance',
    attendanceSelectUser: 'Select Employee',
    attendanceSelectDate: 'Select Date',

    attendanceStatusPlaceholder: 'Select Status',
    attendanceCheckInPlaceholder: 'Select check-in time',
    attendanceCheckOutPlaceholder: 'Select check-out time',

    attendanceWorkingMinutes: 'Working Minutes',
    attendanceWorkingMinutesPlaceholder: 'Enter working minutes',

    attendanceNotePlaceholder: 'Enter note',
    attendanceValidationError: 'Please select a date.',

    // ✅ VALIDATIONS
    attendanceCheckInRequired: 'Check-in time is required',
    attendanceCheckOutRequired: 'Check-out time is required',
    attendanceOvertime: 'Overtime',
    attendanceHour: 'Hour',
    attendanceDay: 'Day',
    attendanceOvertimePlaceholder: 'Enter overtime value',
    attendanceOvertimeRequired: 'Please add Overtime Minute or Day',
    attendanceWorkingMinutesRequired: 'Working minutes are required',
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
    attendanceLeave: 'ခွင့်ယူ',
    attendanceHalfDay: 'နေ့တပိုင်း',
    attendanceHoliday: 'ပိတ်ရက်',
    attendanceEarlyLeave: 'စောထွက်',

    attendanceNote: 'မှတ်ချက်',
    attendanceAction: 'လုပ်ဆောင်ချက်',

    attendanceSearchPlaceholder: 'တက်ရောက်မှု ရှာရန်...',

    attendanceSuccess: 'တက်ရောက်မှုကို အောင်မြင်စွာ မှတ်တမ်းတင်ပြီးပါပြီ!',
    attendanceFail: 'တက်ရောက်မှု မှတ်တမ်းတင်ရာတွင် မအောင်မြင်ပါ။',
    attendanceDeleteConfirm: 'ဤတက်ရောက်မှုကို ဖျက်လိုပါသလား?',
    attendanceDeleteSuccess: 'တက်ရောက်မှုကို အောင်မြင်စွာ ဖျက်ပြီးပါပြီ',
    attendanceDeleteFail: 'တက်ရောက်မှု ဖျက်ရန် မအောင်မြင်ပါ',

    attendanceForm: 'တက်ရောက်မှု ဖောင်',
    attendanceCreate: 'တက်ရောက်မှု ဖန်တီးရန်',
    attendanceSelectUser: 'ဝန်ထမ်းရွေးရန်',
    attendanceSelectDate: 'ရက်စွဲရွေးရန်',

    attendanceStatusPlaceholder: 'အခြေအနေရွေးရန်',
    attendanceCheckInPlaceholder: 'အလုပ်ဝင်ချိန် ရွေးရန်',
    attendanceCheckOutPlaceholder: 'အလုပ်ဆင်းချိန် ရွေးရန်',

    attendanceWorkingMinutes: 'အလုပ်လုပ်ချိန် (မိနစ်)',
    attendanceWorkingMinutesPlaceholder: 'အလုပ်လုပ်ချိန် မိနစ် ထည့်ပါ',

    attendanceNotePlaceholder: 'မှတ်ချက် ထည့်ပါ',
    attendanceValidationError: 'ရက်စွဲကို ရွေးချယ်ပါ။',

    // ✅ VALIDATIONS
    attendanceCheckInRequired: 'အလုပ်ဝင်ချိန် ရွေးရန်လိုအပ်ပါသည်',
    attendanceCheckOutRequired: 'အလုပ်ဆင်းချိန် ရွေးရန်လိုအပ်ပါသည်',
    attendanceOvertime: 'အချိန်ပို',
    attendanceHour: 'နာရီ',
    attendanceDay: 'နေ့',
    attendanceOvertimePlaceholder: 'အချိန်ပိုနာရီ တန်ဖိုး ထည့်ပါ',
    attendanceOvertimeRequired: 'အချိန်ပို  ထည့်ပါ',
    attendanceWorkingMinutesRequired:
        'အလုပ်လုပ်ချိန် (မိနစ်) ထည့်ရန်လိုအပ်ပါသည်',
  };
}
