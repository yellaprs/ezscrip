import 'package:ezscrip/consultation/repository/consultation_repository.dart';
import 'package:ezscrip/main.dart';
import 'package:ezscrip/util/logger.dart';
import 'package:flutter/foundation.dart';
import 'package:get_it/get_it.dart';
import 'package:intl/intl.dart';
import 'package:ezscrip/consultation/model/consultation.dart';

class ConsultationModel extends ChangeNotifier {
  final Map<String, List<Consultation>> consultationMap = {};

  ConsultationModel() : super();

  Future<bool> loadConsultations(DateTime date) async {
    String matchedDate = consultationMap.keys.firstWhere(
        (key) => key == DateFormat('ddMMMyyyy').format(date),
        orElse: () => "");

    List<Consultation>? consultationList =
        await GetIt.instance<ConsultationRespository>().getAllByDate(date);
    if (matchedDate.isEmpty) {
      consultationList = consultationMap.putIfAbsent(
          DateFormat('ddMMMyyyy').format(date), () => consultationList!);
    } else {
      consultationList =
          consultationMap.update(matchedDate, (value) => consultationList!);
    }

    Logger.debug(
        " Consultation:(${matchedDate})=${consultationList.length.toString()}");

    return (consultationList != null);
  }

  List<Consultation> getConsultations(DateTime date) {
    List<Consultation> consultationList = [];

    consultationList = consultationMap[DateFormat('ddMMMyyyy').format(date)]!;

    Logger.debug(
        "get Consultations:( ${DateFormat('ddMMMyyyy').format(date)}  ${consultationList.length.toString()})");

    return consultationList;
  }

  Future<int> insert(Consultation consultation) async {
    int id =
        await GetIt.instance<ConsultationRespository>().insert(consultation);

    String matchedDate = consultationMap.keys.firstWhere(
        (key) => key == DateFormat('ddMMMyyyy').format(consultation.getStart()),
        orElse: () => "");

    if (matchedDate.isNotEmpty) {
      List<Consultation> consultationList = consultationMap[matchedDate]!;
      consultationList.add(consultation);
      consultationMap.update(matchedDate, (value) => consultationList);
    } else {
      List<Consultation> consultationList = [];
      consultationList.add(consultation);
      consultationMap.putIfAbsent(matchedDate, () => consultationList);
    }
    notifyListeners();
    return id;
  }

  Future<int> update(Consultation consultation) async {
    int id = await GetIt.instance<ConsultationRespository>()
        .updateConsultation(consultation);

    String matchedDate = consultationMap.keys.firstWhere(
        (key) => key == DateFormat('ddMMMyyyy').format(consultation.getStart()),
        orElse: () => "");

    List<Consultation> consultationList = consultationMap[matchedDate]!;

    consultationList.removeWhere((element) => element.id == consultation.id);
    consultationList.add(consultation);

    consultationMap.update(matchedDate, (value) => consultationList);

    notifyListeners();
    return id;
  }

  Future<int> delete(Consultation consultation) async {
    int id =
        await GetIt.instance<ConsultationRespository>().delete(consultation);

    String matchedDate = consultationMap.keys.firstWhere(
        (key) => key == DateFormat('ddMMMyyyy').format(consultation.getStart()),
        orElse: () => "");

    List<Consultation> consultationList = consultationMap[matchedDate]!;

    consultationList.removeWhere((element) => element.id == consultation.id);

    consultationMap.update(matchedDate, (value) => consultationList);
    notifyListeners();

    return id;
  }

  Future<DateTime> getMinDate() async {
    DateTime endDate =
        await GetIt.instance<ConsultationRespository>().getMinDate();
    return new DateTime(endDate.year, endDate.month + 1, 0);
  }
}
