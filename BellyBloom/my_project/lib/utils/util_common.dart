import 'dart:developer';

class UtilsCommon {
  static DateTime calculateDueDate(DateTime currentDate, int currentWeek) {
    const totalWeeks = 40;
    int weeksRemaining = totalWeeks - currentWeek;
    final data = currentDate.add(Duration(days: weeksRemaining * 7));
    return data;
  }

  static int getPregnancyDay(DateTime createAt, int week) {
    // Thai kỳ = 280 ngày
    const totalDays = 280;

    int currentDay = getCurrentDayInPregnancy(createAt, week);

    return totalDays - currentDay;
  }

  //Lấy ngày hiện tại trong thai kì
  static int getCurrentDayInPregnancy(DateTime createAt, int week) {
    // Thai kỳ = 280 ngày
    const totalDays = 280;

    //=> ngày 15
    // createAt = DateTime(2025, 11, 01);
    // 2*7 = 14
    int days = week * 7;
    int daysLeft = DateTime.now().difference(createAt).inDays;
    int currentDay = days + daysLeft;

    log('days: $days');
    log('daysLeft: $daysLeft');
    log('currentDay: $currentDay');
    return currentDay;
  }

  static int getCurrentWeekInPregnancy(DateTime createAt, int week) {
    int currentDay = getCurrentDayInPregnancy(createAt, week);
    return currentDay ~/ 7;
  }

  // Tính tuần thai kỳ cho một ngày cụ thể
  static int getWeekForDate(DateTime createAt, int initialWeek, DateTime targetDate) {
    // Tính số ngày từ createAt đến targetDate
    int daysFromStart = targetDate.difference(createAt).inDays;
    // Tuần ban đầu + số tuần đã trôi qua
    int totalDays = (initialWeek * 7) + daysFromStart;
    int weekNumber = (totalDays ~/ 7) + 1; // +1 vì tuần bắt đầu từ 1
    return weekNumber.clamp(1, 40); // Giới hạn từ tuần 1 đến 40
  }
}
