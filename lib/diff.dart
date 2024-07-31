import 'package:intl/intl.dart';

List<int> caluclating(String date) {
  String now = DateTime.now().toString();

  DateTime date1 = DateFormat("yyyy-MM-dd HH:mm:ss.SSS").parse(now);
  DateTime date2 = DateFormat("yyyy-MM-dd HH:mm:ss.SSS").parse(date);
  Duration difference = date1.difference(date2);

  int years = date1.year - date2.year;
  int months = date1.month - date2.month;
  int days = date1.day - date2.day;
  int hours = difference.inHours % 24;

  if (months < 0) {
    years -= 1;
    months += 12;
  }

  if (days < 0) {
    months -= 1;
    DateTime tempDate = DateTime(date2.year, date2.month + 1, 0);
    days += tempDate.day;
  }
  return [years, months, days, hours];
}


int days(String date) {
  String now = DateTime.now().toString();

  DateTime date1 = DateFormat("yyyy-MM-dd HH:mm:ss.SSS").parse(now);
  DateTime date2 = DateFormat("yyyy-MM-dd HH:mm:ss.SSS").parse(date);

  int days = date1.day - date2.day;



  return days;
}
int konwertujNaMinuty(String czas) {
  List<String> czasRozdzielony = czas.split(':');
  int godziny = int.parse(czasRozdzielony[0]);
  int minuty = int.parse(czasRozdzielony[1]);
  return godziny * 60 + minuty;
}