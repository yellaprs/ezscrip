import 'dart:convert';
import 'package:ezscrip/consultation/model/indicator.dart';
import 'package:ezscrip/consultation/model/medicalHistory.dart';
import 'package:ezscrip/consultation/model/medschedule.dart';
import 'package:ezscrip/consultation/model/status.dart';
import 'package:ezscrip/consultation/model/testParameter.dart';
import 'package:ezscrip/util/gender.dart';
import 'package:flutter/foundation.dart';

class Consultation extends ChangeNotifier {
  int? id;
  String _patientName;
  double? _weight;
  int _patientAge;
  Gender _gender;
  DateTime _start;
  DateTime _end;
  List<String> _symptoms;
  List<TestParameter> _parameters;
  List<MedicalHistory> _medicalHistory;
  late List<Indicator> indicators;
  List<String> _investigations;
  List<String> _notes;

  late List<MedSchedule> prescription;

  Status _status;

  Consultation(
      this._patientName,
      this._gender,
      this._patientAge,
      this._weight,
      this._start,
      this._end,
      this._symptoms,
      this._medicalHistory,
      this._parameters,
      this._investigations,
      this._notes,
      this._status,
      {this.indicators = const [],
      this.prescription = const []});

  Map<String, dynamic> toMap() {
    List<Map<String, dynamic>> indicatorsJson = [];

    if (indicators.isNotEmpty) {
      indicatorsJson = indicators.map((e) => e.toMap()).toList();
    }
    List<Map<String, dynamic>> prescriptionJson =
        prescription.map((element) => element.toMap()).toList();
    List<Map<String, dynamic>> medicalHistoryJson =
        _medicalHistory.map((element) => element.toMap()).toList();
    List<Map<String, dynamic>> parameterJson =
        _parameters.map((element) => element.toMap()).toList();

    return {
      'patient_name': _patientName,
      'gender': GenderHelper.toStringValue(_gender),
      'patient_age': _patientAge,
      'weight': _weight,
      'start': _start.toLocal().millisecondsSinceEpoch,
      'end': _end.toLocal().millisecondsSinceEpoch,
      'indicators': indicatorsJson,
      'symptoms': _symptoms,
      'test_parameters': parameterJson,
      'medical_history': medicalHistoryJson,
      'tests': _investigations,
      'notes': _notes,
      "prescription": prescriptionJson,
      'status':
          _status.toString().substring(_status.toString().indexOf(".") + 1),
    };
  }

  String getPatientName() => _patientName;

  int getPatientAge() => _patientAge;

  Gender getGender() => _gender;

  DateTime getStart() => _start;

  double? getWeight() => _weight;

  DateTime getEnd() => _end;

  List<String> getSymptoms() => _symptoms;

  List<Indicator> getIndicators() => indicators;

  List<MedicalHistory> getMedicalHistory() => _medicalHistory;

  List<String> getTests() => _investigations;

  List<String> getNotes() => _notes;

  Status getStatus() => _status;

  List<TestParameter> getParameters() => _parameters;

  void setPatientAge(int age) {
    _patientAge = age;
  }

  void setPatientName(String name) {
    _patientName = name;
  }

  void setGender(Gender gender) {
    _gender = gender;
  }

  void setWeight(double weight) {
    _weight = weight;
  }

  void setStart(DateTime start) {
    _start = start;
  }

  void setEnd(DateTime end) {
    _end = end;
  }

  void setParameters(List<TestParameter> parameter) {
    _parameters = parameter;
  }

  void setSymptoms(List<String> symptoms) {
    _symptoms = symptoms;
  }

  void addSymptom(String symptom) {
    _symptoms.add(symptom);
  }

  void addIndicator(Indicator indicator) {
    indicators.add(indicator);
  }

  void addToMedicalHistory(MedicalHistory medicalHistory) {
    _medicalHistory.add(medicalHistory);
  }

  void addInvestigation(String test) {
    _investigations.add(test);
  }

  void addNote(String note) {
    _notes.add(note);
  }

  void setIndicators(List<Indicator> indicatos) {
    indicators = indicators;
  }

  void setStatus(Status status) {
    _status = status;
  }

  void setInvestigations(List<String> tests) {
    _investigations = tests;
  }

  void setNotes(List<String> notes) {
    _notes = notes;
  }

  void setMedicalHistory(List<MedicalHistory> medicalHistory) {
    _medicalHistory = medicalHistory;
  }

  void removeSymptom(String symptom) {
    _symptoms.remove(symptom);
  }

  void removeFromMedicalHistory(MedicalHistory medicalHistory) {
    _medicalHistory.remove(medicalHistory);
  }

  void removeInvestigation(String test) {
    _investigations.remove(test);
  }

  void removeParameter(TestParameter parameter) {
    _parameters.remove(parameter);
  }

  void removeNote(String note) {
    _notes.remove(note);
  }

  factory Consultation.getInstance(
    String patientName,
    String contactNo,
    Gender gender,
    double weight,
    int patientAge,
    DateTime start,
    DateTime end,
    List<String> symptoms,
    List<MedicalHistory> medicalHistory,
    List<TestParameter> parameters,
    List<String> tests,
    List<MedSchedule> medSchedule,
    Map<String, String> reports,
    List<String> notes,
    List<MedSchedule> prescription,
    Status status,
  ) {
    return Consultation(patientName, gender, patientAge, weight, start, end,
        symptoms, medicalHistory, parameters, tests, notes, status,
        prescription: prescription);
  }
  factory Consultation.fromMap(Map<String, dynamic> map) {
    print("json: " + json.encode(map));

    String patientName = map['patient_name'] as String;
    Gender gender = Gender.values.firstWhere((element) =>
        element.toString().substring(element.toString().indexOf(".") + 1) ==
        map['gender']);
    int patientAge = map['patient_age'] as int;

    double weight = (map['weight'] != null) ? map['weight'] as double : 0.0;

    DateTime start =
        DateTime.fromMillisecondsSinceEpoch(map['start'] as int, isUtc: false);
    DateTime end =
        DateTime.fromMillisecondsSinceEpoch(map['end'] as int, isUtc: false);

    List<dynamic> symptomsList =
        (map['symptoms'] != null) ? map['symptoms'] : [];

    List<String> symptoms = symptomsList.map((e) => e as String).toList();

    List<dynamic> indicatorMap =
        (map['indicators'] != null) ? map['indicators'] : [];

    List<Indicator> indicators = (indicatorMap.length > 0)
        ? indicatorMap
            .map(
                (element) => Indicator.fromMap(element as Map<String, dynamic>))
            .toList()
        : [];

    List<dynamic> medicalHistoryList =
        (map['medical_history'] != null) ? map['medical_history'] : [];

    List<MedicalHistory> medicalHistory = (medicalHistoryList.length > 0)
        ? medicalHistoryList
            .map((element) =>
                MedicalHistory.fromMap(element as Map<String, dynamic>))
            .toList()
        : [];

    List<dynamic> parameterList =
        (map['test_parameters'] != null) ? map['test_parameters'] : [];

    List<TestParameter> parameters = (parameterList.length > 0)
        ? parameterList
            .map((element) =>
                TestParameter.fromMap(element as Map<String, dynamic>))
            .toList()
        : [];

    List<dynamic> testsList = (map['tests'] != null) ? map['tests'] : [];

    List<String> tests = testsList.map((e) => e as String).toList();

    List<dynamic> notesList = (map['notes'] != null) ? map['notes'] : [];

    List<String> notes = notesList.map((e) => e as String).toList();

    Status status = Status.values.firstWhere((element) =>
        element.toString().substring(element.toString().indexOf(".") + 1) ==
        (map['status'] as String));

    List<dynamic> presciptionMap =
        (map['prescription'] != null) ? map['prescription'] : [];

    List<MedSchedule> prescription = (presciptionMap.length > 0)
        ? presciptionMap
            .map((element) =>
                MedSchedule.fromMap(element as Map<String, dynamic>))
            .toList()
        : [];

    int? id = (map['id'] != null) ? map['id'] : -1;

    Consultation consultation = Consultation(
        patientName,
        gender,
        patientAge,
        weight,
        start,
        end,
        symptoms,
        medicalHistory,
        parameters,
        tests,
        notes,
        status,
        prescription: prescription,
        indicators: indicators);

    consultation.id = id!;

    return consultation;
  }

  factory Consultation.copyInstance(Consultation consultation) {
    return Consultation(
        consultation._patientName,
        consultation._gender,
        consultation._patientAge,
        consultation._weight,
        consultation._start,
        consultation._end,
        consultation._symptoms,
        consultation._medicalHistory,
        consultation._parameters,
        consultation._investigations,
        consultation._notes,
        consultation._status);
  }

  factory Consultation.newConsultation() {
    return Consultation(
        "",
        Gender.Male,
        -1,
        0.0,
        DateTime.now(),
        DateTime.now().add(const Duration(minutes: 1)),
        [],
        [],
        [],
        [],
        [],
        Status.Active);
  }

  void addSchedule(MedSchedule medSchedule) {
    prescription.add(medSchedule);
    notifyListeners();
  }

  void removeSchedule(MedSchedule medSchedule) {
    prescription.remove(medSchedule);
    notifyListeners();
  }
}
