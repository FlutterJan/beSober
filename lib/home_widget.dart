import 'dart:convert';
import 'package:flutter_widgetkit/flutter_widgetkit.dart';

void updateWidgetFun(List<String> days, List<String> names) {
  if (days.length != names.length) {
    throw Exception("Listy 'days' i 'names' muszą mieć tę samą długość.");
  }

  WidgetData widgetData = WidgetData(days, names);
  WidgetKit.setItem(
      'FlutterWidget', jsonEncode(widgetData), 'group.beSober2');
  WidgetKit.reloadAllTimelines();
}

class WidgetData {
  final List<String> days;
  final List<String> names;

  WidgetData(this.days, this.names);

  WidgetData.fromJson(Map<String, dynamic> json)
      : days = List<String>.from(json['days']),
        names = List<String>.from(json['names']);

  Map<String, dynamic> toJson() => {
        'days': days,
        'names': names,
      };
}
