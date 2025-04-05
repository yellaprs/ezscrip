import 'dart:convert';

import 'package:ezscrip/consultation/model/time.dart';
import 'package:ezscrip/util/speciality.dart';
import 'package:flutter/services.dart';

class UtilsService {
  Future<Map<String, String>> getTimeIconMap() async {
    Map<String, String> iconMap = {};

    Time.values.forEach((time) async {
      String iconStr = await rootBundle.loadString(
          "assets/images/${time.toString().substring(time.toString().indexOf(".") + 1)}.svg");
      iconMap.putIfAbsent(
          time.toString().substring(time.toString().indexOf(".") + 1),
          () => iconStr);
    });

    return iconMap;
  }

  DateTime getWeekStart(DateTime date) {
    DateTime start = (date.weekday > DateTime.monday)
        ? date.subtract(Duration(days: (date.weekday - 1) - DateTime.monday))
        : date;
    return DateTime(start.year, start.month, start.day, 0, 0);
  }

  DateTime getWeekEnd(DateTime date) {
    DateTime end = getWeekStart(date).add(Duration(days: 6));
    return DateTime(end.year, end.month, end.day, 23, 59);
  }

  DateTime getMonthStart(DateTime date) {
    return DateTime(date.year, date.month, 1, 0, 0);
  }

  DateTime getMonthEnd(DateTime date) {
    return DateTime(date.year, date.month + 1, 0, 23, 59);
  }

  Future<List<Speciality>> loadSpecialities() async {
    String specialitiesJson =
        await rootBundle.loadString("assets/cfg/specialities.json");

    List<dynamic> specialitiesMap =
        json.decode(specialitiesJson)['specialities'];

    List<Speciality> specialtiesList =
        specialitiesMap.map((e) => Speciality.fromJson(e)).toList();
    print(specialtiesList.length);

    return specialtiesList;
  }

  Future<Map<String, dynamic>> loadProperties() async {
    String propertiesJson =
        await rootBundle.loadString("assets/cfg/medical_properties.json");
    return json.decode(propertiesJson);
  }
}
