import 'package:intl/intl.dart';

/// Validate
class Val {
  static String validateTitle(String input) {
    if (input == null || input.isEmpty) {
      return 'Title can not be empty';
    }

    return null;
  }

  static String validateExpireDate(String expireDateString) {
    return DateUtils.isValidDate(expireDateString)
        ? null
        : 'Not a valid future date';
  }

  static String getExpiryString(String expires) {
    var expiresDate = DateUtils.convertToDate(expires) ?? DateTime.now();
    var today = DateTime.now();

    Duration differenceDur = expiresDate.difference(today);
    int inDays = differenceDur.inDays + 1;

    if (inDays > 0) {
      return inDays.toString();
    } else {
      return '0';
    }
  }

  static bool stringToBool(String input) {
    return int.parse(input) > 0 ? true : false;
  }

  static bool intToBool(int input) {
    return input > 0 ? true : false;
  }

  static String boolToString(bool input) {
    return input ? "1" : "0";
  }

  static int boolToInt(bool input) {
    return input ? 1 : 0;
  }
}

/// Date utils
class DateUtils {
  static DateTime convertToDate(String input) {
    try {
      var d = DateFormat("yyyy-MM-dd").parseStrict(input);
      return d;
    } catch (err) {
      print(err.toString());
      return null;
    }
  }

  static String trimDate(String date) {
    if (date.contains(" ")) {
      List<String> splitDates = date.split(" ");
      return splitDates.first;
    }

    return date;
  }

  static String convertToDateFull(String input) {
    try {
      var d = DateFormat("yyyy-MM-dd").parseStrict(input);
      var formatter = DateFormat('dd MMM yyyy');
      return formatter.format(d);
    } catch (e) {
      print(e.toString());
      return null;
    }
  }

  static String convertToDateFullDt(DateTime input) {
    try {
      var formatter = DateFormat('dd MMM yyyy');
      return formatter.format(input);
    } catch (err) {
      print(err.toString());
      return null;
    }
  }

  static bool isDate(String dateString) {
    try {
      var _ = DateFormat('yyyy-MM-dd').parseStrict(dateString);
      return true;
    } catch (err) {
      print(err.toString());
      return false;
    }
  }

  static bool isValidDate(String dateString) {
    if (dateString == null ||
        dateString.isEmpty ||
        dateString.length < 10 ||
        !dateString.contains("-")) {
      return false;
    }

    List<String> dtItems = dateString.split("-");
    DateTime now = DateTime.now();

    var date = DateTime(
        int.parse(dtItems[0]), int.parse(dtItems[1]), int.parse(dtItems[2]));

    return date != null && isDate(dateString) && date.isAfter(now);
  }

  static String daysAheadAsString(int daysAhead) {
    var now = DateTime.now();
    DateTime ft = now.add(Duration(days: daysAhead));
    return ftDateAsString(ft);
  }

  static String ftDateAsString(DateTime ft) {
    return ft.year.toString() +
        "-" +
        ft.month.toString().padLeft(2, "0") +
        "-" +
        ft.day.toString().padLeft(2, "0");
  }
}
