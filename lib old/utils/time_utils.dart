import 'package:intl/intl.dart';

String changeTimeFormat(String inputDateTime, String format) {
  DateTime dateTime = DateFormat('HH:mm:ss').parse(inputDateTime);
  dateTime.toLocal();
  return DateFormat(format).format(dateTime);
}

String changeTime12to24HFormat(String inputDateTime, String format) {
  DateTime dateTime = DateFormat('hh:mm a').parse(inputDateTime);
  return DateFormat('HH:mm:ss').format(dateTime);
}

String changeDateTimeFormat(DateTime inputDateTime, String format) {
  DateTime dateTime = inputDateTime.toLocal();
  return DateFormat(format).format(dateTime);
}

String changeDateTime(String inputDateTime, String format, String toFormat) {
  DateFormat inputFormat = DateFormat(format);
  DateTime parsedDate = inputFormat.parse(inputDateTime);
  DateFormat outputFormat = DateFormat(toFormat);
  return outputFormat.format(parsedDate);
}

String changeDateFormat(String inputDate) {
  return DateFormat("yyyy-MM-dd'T'00:00:00.000")
      .format(DateFormat('dd/MM/yyyy').parse(inputDate));
}

String formatTime(int seconds) {
  int minutes = seconds ~/ 60;
  int remainingSeconds = seconds % 60;
  return '${minutes.toString().padLeft(2, '0')}:${remainingSeconds.toString().padLeft(2, '0')}';
}

dateTimeAccordingZone(date){
 DateTime utcTime = DateTime.parse(date);
  DateTime localTime = utcTime.toLocal();

  String formattedDate = DateFormat("MMM dd, yyyy - hh:mm a").format(localTime);
  String timezone = localTime.timeZoneName; // e.g. PKT, PST

  return "$formattedDate $timezone";
}