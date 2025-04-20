import 'dart:convert';

import 'package:ezscrip/consultation/model/consultation.dart';
import 'package:ezscrip/consultation/model/direction.dart';
import 'package:ezscrip/consultation/model/durationType.dart';
import 'package:ezscrip/consultation/model/frequencyType.dart';
import 'package:ezscrip/consultation/model/indicator.dart';
import 'package:ezscrip/consultation/model/medStatus.dart';
import 'package:ezscrip/consultation/model/medicalHistory.dart';
import 'package:ezscrip/consultation/model/medschedule.dart';
import 'package:ezscrip/consultation/model/preparation.dart';
import 'package:ezscrip/consultation/model/testParameter.dart';
import 'package:ezscrip/consultation/model/time.dart';
import 'package:ezscrip/consultation/model/unit.dart';
import 'package:ezscrip/consultation/view/add_consultation_page.dart';
import 'package:ezscrip/consultation/view/add_medicalhistory_page.dart';
import 'package:ezscrip/consultation/view/add_medication_page.dart';
import 'package:ezscrip/consultation/view/add_notes_page.dart';
import 'package:ezscrip/consultation/view/add_parameter_page.dart';
import 'package:ezscrip/consultation/view/add_symptom_page.dart';
import 'package:ezscrip/consultation/view/add_tests_page.dart';
import 'package:ezscrip/consultation/view/remove_medication_page.dart';
import 'package:ezscrip/profile/model/appUser.dart';
import 'package:ezscrip/profile/model/userType.dart';
import 'package:ezscrip/util/constants.dart';
import 'package:ezscrip/util/gender.dart';
import 'package:ezscrip/util/keys.dart';
import 'package:enum_to_string/enum_to_string.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:patrol/patrol.dart';

Future<AppUser> loadTestDataProfile(String fileLocation) async {
  Map<String, dynamic> profileData =
      await rootBundle.loadStructuredData(fileLocation, (data) async {
    return await json.decode(data);
  });
  Map<String, dynamic> profileDataJson = profileData[C.TEST_DATA_JSON];

  AppUser profile = AppUser(
      profileDataJson['firstname'],
      profileDataJson['lastname'],
      profileDataJson['credentials'],
      profileDataJson['specialization'],
      profileDataJson['clinic'],
      const Locale('EN_US'),
      profileDataJson['contact_no'],
      UserType.values.firstWhere((userType) =>
          EnumToString.convertToString(userType) ==
          profileDataJson['user_type']));
  return profile;
}

Future<Consultation> loadTestDateConsultation(String fileLocation) async {
  Map<String, dynamic> testDataJson =
      await rootBundle.loadStructuredData(fileLocation, (data) async {
    return await json.decode(data);
  });

  Consultation consultation =
      Consultation.fromMap(testDataJson[C.TEST_DATA_JSON]);

  return consultation;
}

Future<bool> viewConsultation(
    PatrolIntegrationTester $,
    String name,
    Gender gender,
    int age,
    double weight,
    List<String> symptoms,
    List<Indicator> indicators,
    List<String> investigations,
    List<MedicalHistory> medicalHistory,
    List<TestParameter> testParameters,
    List<String> notes,
    List<MedSchedule> medicationList) async {
  expect($(K.patientSummaryViewTile).$(name), findsOneWidget);
  expect(
      $(K.patientSummaryViewTile)
          .$(EnumToString.convertToString(gender, camelCase: true)),
      findsOneWidget);
  expect(
      $(K.patientSummaryViewTile).$("${age.toString()} Years"), findsOneWidget);

  await $.scrollUntilVisible(finder: $(K.vitalSignsViewTile));
  for (int i = 0; i < indicators.length; i++) {
    expect(
        $(K.vitalSignsViewTile).$(Stack).$(
            "${EnumToString.convertToString(indicators.elementAt(i).getType(), camelCase: true)} ${indicators.elementAt(i).getValue().toString()} ${indicators.elementAt(i).getUnits()}"),
        findsOneWidget);
  }

  await $.scrollUntilVisible(finder: $(K.symptomsViewList));

  for (int i = 0; i < symptoms.length; i++) {
    expect($(K.symptomsViewList).$(symptoms.elementAt(i)), findsOneWidget);
  }

  await $.scrollUntilVisible(finder: $(K.medicaHistoryViewList));

  for (int i = 0; i < medicalHistory.length; i++) {
    expect(
        $(K.medicaHistoryViewList)
            .$(medicalHistory.elementAt(i).getDiseaseName()),
        findsOneWidget);
  }

  await $.scrollUntilVisible(finder: $(K.investgationsViewList));

  for (int i = 0; i < investigations.length; i++) {
    expect($(K.investgationsViewList).$(Row).$(investigations.elementAt(i)),
        findsOneWidget);
  }

  await $.scrollUntilVisible(finder: $(K.parametersViewList));

  for (int i = 0; i < testParameters.length; i++) {
    expect(
        $(K.parametersViewList).$(Row).$(testParameters.elementAt(i).getName()),
        findsOneWidget);
    expect(
        $(K.parametersViewList).$(Row).$(
            "${testParameters.elementAt(i).getValue()} ${testParameters.elementAt(i).getUnit()}"),
        findsOneWidget);
  }

  await $.scrollUntilVisible(finder: $(K.prescriptionViewList));

  for (int index = 0; index < medicationList.length; index++) {
    MedSchedule medSchedule = medicationList.elementAt(index);

    await $.scrollUntilVisible(
        finder: $(K.prescriptionViewList).$(Card).at(index).$(Row));

    if (medSchedule.getStatus() != MedStatus.Discontinue) {
      var prescriptionDrugInfoFinder =
          $(K.prescriptionViewList).$(Card).at(index).$(Row).$(SizedBox).at(1);

      expect($(prescriptionDrugInfoFinder), findsOneWidget);

      var prescriptionCDrugInfoRow0Finder = $(prescriptionDrugInfoFinder)
          .$(Column)
          .$(Padding)
          .at(0)
          .$(Stack)
          .at(0);

      expect(prescriptionCDrugInfoRow0Finder, findsOneWidget);

      expect(
          $(prescriptionCDrugInfoRow0Finder).$(
              "${medSchedule.dosage.toString()} ${EnumToString.convertToString(medSchedule.unit, camelCase: true).toLowerCase()} ${medSchedule.getName()}"),
          findsOneWidget);

      var prescriptionCDrugInfoRow2Finder =
          $(prescriptionDrugInfoFinder).$(Column).$(Padding).at(1);

      expect($(prescriptionCDrugInfoRow2Finder), findsOneWidget);

      var stackFinder = find.ancestor(
          of: find.byIcon(Icons.timer),
          matching: $(prescriptionDrugInfoFinder).$(find.byType(Stack)));

      expect($(stackFinder), findsOneWidget);

      expect($(stackFinder).$(find.byIcon(Icons.timer)), findsOneWidget);

      var frequencyFinder = find.descendant(
          of: $(stackFinder),
          matching: $(
              "${medSchedule.getFrequencyType().toString().substring(medSchedule.getFrequencyType().toString().indexOf(".") + 1, medSchedule.getFrequencyType().toString().indexOf("_"))}"));

      expect(frequencyFinder, findsOneWidget);

      if (medSchedule.times!.isNotEmpty && medSchedule.times!.length > 0) {
        for (int i = 0; i < medSchedule.times!.length; i++) {
          var iconListFinder = find.descendant(
              of: stackFinder, matching: $(LimitedBox).$(K.timesIconList));

          expect($(iconListFinder), findsOneWidget);

          List<Time> times = medSchedule.times!;

          if (times.elementAt(i) == Time.daybreak) {
            expect($(iconListFinder).$(K.daybreak), findsOneWidget);
          } else if (times.elementAt(i) == Time.morning) {
            expect($(iconListFinder).$(K.morning), findsOneWidget);
          } else if (times.elementAt(i) == Time.afternoon) {
            expect($(iconListFinder).$(K.afternoon), findsOneWidget);
          } else if (times.elementAt(i) == Time.evening) {
            expect($(iconListFinder).$(K.evening), findsOneWidget);
          } else if (times.elementAt(i) == Time.night) {
            expect($(iconListFinder).$(K.night), findsOneWidget);
          }
        }
      }

      var durationWidgetFinder =
          find.ancestor(of: find.byIcon(Icons.timelapse), matching: $(Stack));

      expect(
          $(durationWidgetFinder).$(
              "${medSchedule.duration.toString()} ${EnumToString.convertToString(medSchedule.durationType)}"),
          findsOneWidget);

      if (medSchedule.getDirection() != Direction.NotApplicable) {
        var directionWidgetFinder =
            find.ancestor(of: find.byIcon(Icons.comment), matching: $(Stack));

        String direction = EnumToString.convertToString(
            medSchedule.getDirection(),
            camelCase: true);

        expect($(directionWidgetFinder).$(direction), findsOneWidget);
      }
    } else {
      var prescriptionDrugInfoFinder = find.ancestor(
          of: $(Icon),
          matching: $(K.prescriptionViewList)
              .$(Card)
              .at(index)
              .$(Row)
              .$(Container)
              .$(Stack));

      expect(prescriptionDrugInfoFinder, findsOneWidget);

      var durgNameContainerFinder = $(prescriptionDrugInfoFinder).$(Padding);

      expect($(durgNameContainerFinder), findsOneWidget);

      expect(
          $(durgNameContainerFinder).$(
              "${medSchedule.getName()} ${EnumToString.convertToString(medSchedule.getPreparation(), camelCase: true)}"),
          findsOneWidget);
    }
  }

  expect($(K.backNavButton), findsOneWidget);
  await $(K.backNavButton).tap();
  return true;
}

Future<bool> addConsultation(
    PatrolIntegrationTester $,
    String name,
    Gender gender,
    int age,
    double weight,
    List<String> symptoms,
    List<Indicator> indicators,
    List<String> investigations,
    List<MedicalHistory> medicalHistory,
    List<TestParameter> testParameters,
    List<String> notes,
    List<MedSchedule> medicationList) async {
  await addPatientPorfile($, name, gender, age, weight);

  for (int i = 0; i <= 2; i++) {
    await $(K.patientSummaryTile).$('Patient').tap();
    if ($(K.patientSummaryTile).$(K.tileStatusCollapsed).exists) break;
  }

  for (int i = 0; i <= 2; i++) {
    await $(K.symptomsTile).$('Symptoms').tap();
    if ($(K.symptomsTile).$(K.tileStatusCollapsed).exists) break;
  }

  for (int i = 0; i <= 2; i++) {
    await $(K.vitalSignsTile).$('Vital Signs').tap();
    if ($(K.vitalSignsTile).$(K.tileStatusCollapsed).exists) break;
  }

  for (int i = 0; i <= 2; i++) {
    await $(K.medicalHistoryTile).$('Medical History').tap();
    if ($(K.medicalHistoryTile).$(K.tileStatusCollapsed).exists) break;
  }

  for (int i = 0; i <= 2; i++) {
    await $(K.parametersTile).$('Parameters').tap();
    if ($(K.parametersTile).$(K.tileStatusCollapsed).exists) break;
  }

  for (int i = 0; i <= 2; i++) {
    await $(K.testsTile).tap();
    if ($(K.testsTile).$('Investigations').$(K.tileStatusCollapsed).exists)
      break;
  }

  for (int i = 0; i <= 2; i++) {
    await $(K.notesTile).$('Notes').tap();
    if ($(K.notesTile).$(K.tileStatusCollapsed).exists) break;
  }

  for (int i = 0; i <= 2; i++) {
    await $(K.symptomsTile).$('Symptoms').tap();
    if ($(K.symptomsTile).$(K.tileStatusExpanded).exists) break;
  }

  if (symptoms.length > 0) {
    for (int i = 0; i < symptoms.length; i++) {
      await addSymptom($, symptoms.elementAt(i));
    }
  }

  for (int i = 0; i <= 2; i++) {
    await $(K.symptomsTile).$('Symptoms').tap();
    if ($(K.symptomsTile).$(K.tileStatusCollapsed).exists) break;
  }

  for (int i = 0; i <= 2; i++) {
    await $(K.vitalSignsTile).$('Vital Signs').tap();
    if ($(K.vitalSignsTile).$(K.tileStatusExpanded).exists) break;
  }

  if (indicators.length > 0) {
    for (int i = 0; i < indicators.length; i++) {
      await addIndicator($, indicators.elementAt(i));
    }
  }

  for (int i = 0; i <= 2; i++) {
    await $(K.vitalSignsTile).$('Vital Signs').tap();
    if ($(K.vitalSignsTile).$(K.tileStatusCollapsed).exists) break;
  }

  for (int i = 0; i <= 2; i++) {
    await $(K.testsTile).$('Investigations').tap();
    if ($(K.testsTile).$('Investigations').$(K.tileStatusExpanded).exists)
      break;
  }

  if (investigations.length > 0) {
    for (int i = 0; i < investigations.length; i++) {
      await addInvestigation($, investigations.elementAt(i));
    }
  }

  for (int i = 0; i <= 2; i++) {
    await $(K.testsTile).$('Investigations').tap();
    if ($(K.testsTile).$('Investigations').$(K.tileStatusCollapsed).exists)
      break;
  }

  for (int i = 0; i <= 2; i++) {
    await $(K.medicalHistoryTile).$('Medical History').tap();
    if ($(K.medicalHistoryTile).$(K.tileStatusExpanded).exists) break;
  }

  if (medicalHistory.length > 0) {
    for (int i = 0; i < medicalHistory.length; i++) {
      await addMedicalHistory(
          $,
          medicalHistory.elementAt(i).getDiseaseName(),
          medicalHistory.elementAt(i).getDuration(),
          medicalHistory.elementAt(i).getDurationType());
    }
  }

  for (int i = 0; i <= 2; i++) {
    await $(K.medicalHistoryTile).$('Medical History').tap();
    if ($(K.medicalHistoryTile).$(K.tileStatusCollapsed).exists) break;
  }

  for (int i = 0; i <= 2; i++) {
    await $(K.parametersTile).$('Parameters').tap();
    if ($(K.parametersTile).$(K.tileStatusExpanded).exists) break;
  }

  if (testParameters.length > 0) {
    for (int i = 0; i < testParameters.length; i++) {
      await addParameter(
          $,
          testParameters.elementAt(i).getName(),
          testParameters.elementAt(i).getValue(),
          testParameters.elementAt(i).getUnit());
    }
  }

  for (int i = 0; i <= 2; i++) {
    await $(K.parametersTile).$('Parameters').tap();
    if ($(K.parametersTile).$(K.tileStatusCollapsed).exists) break;
  }

  for (int i = 0; i <= 2; i++) {
    await $(K.notesTile).$('Notes').tap();
    if ($(K.notesTile).$(K.tileStatusExpanded).exists) break;
  }

  if (notes.length > 0) {
    for (int i = 0; i < notes.length; i++) {
      await addNote($, notes.elementAt(i));
    }
  }

  for (int i = 0; i <= 2; i++) {
    await $(K.notesTile).$('Notes').tap();
    if ($(K.notesTile).$(K.tileStatusCollapsed).exists) break;
  }

  for (int i = 0; i <= 2; i++) {
    await $(K.notesTile).$('Notes').tap();
    if ($(K.notesTile).$(K.tileStatusExpanded).exists) break;
  }

  if (medicationList.length > 0) {
    for (int i = 0; i < medicationList.length; i++) {
      if (medicationList.elementAt(i).getStatus() == MedStatus.Discontinue) {
        await stopMedication(
          $,
          medicationList.elementAt(i).getName(),
          i,
          medicationList.elementAt(i).getPreparation(),
        );
      } else {
        Direction? direction = medicationList.elementAt(i).getDirection();
        List<String> times = medicationList
            .elementAt(i)
            .getTimes()
            .map((time) => EnumToString.convertToString(time, camelCase: false))
            .toList();
        await addMedication($, i, medicationList.elementAt(i).getName(),
            medicationList.elementAt(i).getPreparation(),
            unit: medicationList.elementAt(i).getUnit()!,
            dosage: medicationList.elementAt(i).getDosage(),
            frequency: medicationList.elementAt(i).getFrequencyType()!,
            duration: medicationList.elementAt(i).getDuration()!,
            durationType: medicationList.elementAt(i).getDurationType()!,
            times: times,
            direction: (direction != null)
                ? medicationList.elementAt(i).getDirection()!
                : Direction.NotApplicable);
      }
    }
  }
  return true;
}

Future<bool> addIndicator(
    PatrolIntegrationTester $, Indicator indicator) async {
  if (indicator.getType() == IndicatorType.BloodPressure) {
    expect($(K.bpSwitch), findsOneWidget);
    await $(K.bpSwitch).tap();
    expect($(K.bpSystolicField), findsOneWidget);
    await $(K.bpSystolicField).enterText(indicator
        .getValue()
        .toString()
        .substring(0, indicator.getValue().toString().indexOf("/")));
    expect($(K.bpDiastolicField), findsOneWidget);
    await $(K.bpDiastolicField).enterText(indicator
        .getValue()
        .toString()
        .substring(indicator.getValue().toString().indexOf("/") + 1));
  } else if (indicator.getType() == IndicatorType.HeartRate) {
    expect($(K.hrSwitch), findsOneWidget);
    await $(K.hrSwitch).tap();
    expect($(K.hrField), findsOneWidget);
    await $(K.hrField).enterText(indicator.getValue().toString());
  } else if (indicator.getType() == IndicatorType.Temperature) {
    expect($(K.tempSwitch), findsOneWidget);
    await $(K.tempSwitch).tap();
    expect($(K.tempSlider), findsOneWidget);
    expect($(K.tempValue).$("98.6 ${indicator.getUnits()}"), findsOneWidget);
    await $.dragUntilVisible(
        finder: $(K.tempValue)
            .$("${indicator.getValue().toString()} ${indicator.getUnits()}"),
        view: $(K.tempSlider),
        moveStep: Offset(5.0, 0.0),
        dragDuration: Duration(seconds: 2));
  } else if (indicator.getType() == IndicatorType.Spo2) {
    expect($(K.spo2Switch), findsOneWidget);
    await $(K.spo2Switch).tap();
    expect($(K.spo2Slider), findsOneWidget);
    expect($(K.spo2Value).$("90 ${indicator.getUnits()}"), findsOneWidget);
    await $.dragUntilVisible(
        finder: $(K.spo2Value)
            .$("${indicator.getValue().toString()} ${indicator.getUnits()}"),
        view: $(K.spo2Slider),
        moveStep: Offset(20.0, 0.0),
        dragDuration: Duration(seconds: 10));
  }
  return true;
}

Future<bool> addPatientPorfile(PatrolIntegrationTester $, String name,
    Gender gender, int age, double weight) async {
  expect($(K.patientSummaryTile), findsOneWidget);
  expect($(K.patientNameAutoSizeTextField), findsOneWidget);

  await $(K.patientNameAutoSizeTextField).enterText(name);
  expect($(K.genderField), findsOneWidget);
  await $(K.genderField).$(EnumToString.convertToString(gender)).tap();
  expect($(K.patientAgeAutoSizeTextField), findsOneWidget);
  await $(K.patientAgeAutoSizeTextField).enterText(age.toString());
  await $.tester.testTextInput.receiveAction(TextInputAction.done);
  expect($(K.patientWeightTextField), findsOneWidget);
  await $(K.patientWeightTextField).enterText(weight.toString());
  await $.tester.testTextInput.receiveAction(TextInputAction.done);

  return true;
}

Future<bool> addSymptom(PatrolIntegrationTester $, String symptomName) async {
  expect($(K.addSymptomButton), findsOneWidget);
  await $(K.addSymptomButton).tap();
  expect($(K.symptomNameAutoSizeTextField), findsOneWidget);
  await $(K.symptomNameAutoSizeTextField).enterText(symptomName);

  await $.tester.testTextInput.receiveAction(TextInputAction.done);

  expect($(AddSymptomPage).$(K.checkButton), findsOneWidget);
  await $(AddSymptomPage).$(K.checkButton).tap();
  expect($(ConsultationEditPage), findsOneWidget);
  
  return true;
}

Future<bool> addInvestigation(
    PatrolIntegrationTester $, String investigationName) async {

  expect($(K.addTestButton), findsOneWidget);
  await $(K.addTestButton).tap();
  expect($(AddTestsPage), findsOneWidget);
  expect($(K.testName), findsOneWidget);
  // await $(K.testName).tap();
  await $(K.testName).enterText(investigationName);
  await $.tester.testTextInput.receiveAction(TextInputAction.done);
  expect($(AddTestsPage).$(K.checkButton), findsOneWidget);
  await $(AddTestsPage).$(K.checkButton).tap();
  expect($(ConsultationEditPage), findsOneWidget);

  // expect($(K.testsList), findsOneWidget);
  // expect($(K.testsList).$(investigationName), findsOneWidget);
  return true;
}

Future<bool> addMedicalHistory(PatrolIntegrationTester $, String medicalHistory,
    int duration, DurationType durationType) async {
  expect($(K.addMedicalHistory), findsOneWidget);
  await $(K.addMedicalHistory).tap();

  expect($(AddMedicalHistoryPage), findsOneWidget);
  expect($(K.medicalHistoryName), findsOneWidget);
  await $(K.medicalHistoryName).tap();
  await $(K.medicalHistoryName).enterText(medicalHistory);
  await $.tester.testTextInput.receiveAction(TextInputAction.done);
  expect($(K.durationField), findsOneWidget);
  await $(K.durationField).tap();
  await $(K.durationField).enterText(duration.toString());
  expect($(K.durationTypeField), findsOneWidget);
  await $(K.durationTypeField).tap();
  await $(K.durationTypeField)
      .$(TextField)
      .enterText(EnumToString.convertToString(durationType));
  await $(K.durationTypeField).$(ListTile).tap();

  expect($(AddMedicalHistoryPage).$(K.checkButton), findsOneWidget);
  await $(AddMedicalHistoryPage).$(K.checkButton).tap();

  expect($(ConsultationEditPage), findsOneWidget);

  expect($(K.medicalHistoryList).$(medicalHistory), findsOneWidget);

  return true;
}

Future<bool> selectTime(PatrolIntegrationTester $, List<String> times,
    FrequencyType frequency) async {
  for (int i = 0; i < times.length; i++) {
    String time = times.elementAt(i).toLowerCase().trim();
    if ((frequency == FrequencyType.Qam_1XDayMorning && time == "morning") ||
        (((frequency == FrequencyType.Hs_1XBedTime ||
                frequency == FrequencyType.Qpm_1XNight) &&
            time == "night"))) {
      continue;
    }
    expect($(K.timeChoiceChip).$(ChoiceChip).$(time), findsOneWidget);
    await $(K.timeChoiceChip)
        .$(ChoiceChip)
        .$(time)
        .tap(visibleTimeout: Duration(seconds: 15));
  }
  return true;
}

Future<bool> addParameter(PatrolIntegrationTester $, String parameter,
    String parameterValue, String? units) async {
  expect($(K.addParameterButton), findsOneWidget);
  await $(K.addParameterButton).tap();
  expect($(K.parameterNameField), findsOneWidget);
  await $(K.parameterNameField).enterText(parameter);
  await $.tester.testTextInput.receiveAction(TextInputAction.done);
  expect($(K.parameterValueField), findsOneWidget);
  await $(K.parameterValueField).enterText(parameterValue);
  await $.tester.testTextInput.receiveAction(TextInputAction.done);
  expect($(K.paramaeterUnitField), findsOneWidget);
  if (units != null) {
    await $(K.paramaeterUnitField).enterText(units);
    await $.tester.testTextInput.receiveAction(TextInputAction.done);
  }

  expect($(AddParameterPage).$(K.checkButton), findsOneWidget);
  await $(AddParameterPage).$(K.checkButton).tap();
  expect($(ConsultationEditPage), findsOneWidget);
  expect($(K.parameterList), findsOneWidget);
  expect($(K.parameterList).$(parameter), findsOneWidget);

  return true;
}

Future<bool> addNote(PatrolIntegrationTester $, String note) async {
  expect($(K.notesTile), findsOneWidget);
  expect($(K.addToNotesButton), findsOneWidget);
  await $(K.addToNotesButton).tap();
  expect($(AddNotesPage), findsOneWidget);
  expect($(K.noteTextField), findsOneWidget);
  await $(K.noteTextField).tap();
  await $(K.noteTextField).enterText(note);
  expect($(AddNotesPage).$(K.checkButton), findsOneWidget);
  await $(AddNotesPage).$(K.checkButton).tap();

  return true;
}

Future<bool> stopMedication(PatrolIntegrationTester $, String drugName,
    int index, Preparation preparation) async {
  expect($(K.deleteMedicationButton), findsOneWidget);
  await $(K.deleteMedicationButton).tap();
  await $(RemoveMedicationPage).waitUntilVisible();
  expect($(K.medicationNameAutoSizeTextField), findsOneWidget);
  await $(K.medicationNameAutoSizeTextField).enterText(drugName);

  expect($(K.routeDropDown), findsOneWidget);
  await $(K.routeDropDown).tap();
  await $(K.routeDropDown).$(TextField).enterText(
      EnumToString.convertToString(preparation, camelCase: true).toLowerCase());
  await $(K.routeDropDown).$(ListTile).tap();
  expect($(RemoveMedicationPage).$(K.checkButton), findsOneWidget);
  await $(RemoveMedicationPage).$(K.checkButton).tap();
  expect($(ConsultationEditPage), findsOneWidget);

  expect($(ConsultationEditPage), findsOneWidget);

  expect($(K.presciptionTile), findsOneWidget);

  await $.scrollUntilVisible(
      finder: $(K.presciptionTile).$(Card).at(index).$(Row),
      dragDuration: Duration(seconds: 3));

  Finder drugNameFinder =
      $(K.presciptionTile).$(Card).at(index).$(Row).$(drugName);

  expect(drugNameFinder, findsOneWidget);

  Finder preparationFinder = $(K.presciptionTile)
      .$(Card)
      .at(index)
      .$(Row)
      .$(EnumToString.convertToString(preparation));

  expect(preparationFinder, findsOneWidget);

  return true;
}

Future<bool> addMedication(PatrolIntegrationTester $, int index,
    String drugName, Preparation preparation,
    {Unit unit = Unit.tabs,
    int dosage = 0,
    FrequencyType frequency = FrequencyType.Qd_1XDay,
    int duration = 0,
    DurationType durationType = DurationType.NotApplicable,
    List<String> times = const [],
    bool isHalfTab = false,
    Direction direction = Direction.NotApplicable,
    String advice = ""}) async {
  expect($(K.addMedicatioButton), findsOneWidget);
  await $(K.addMedicatioButton).tap();
  await $(AddMedicationPage).waitUntilVisible();

  expect($(K.drugInfoSlide), findsOneWidget);
  expect($(K.medicationNameAutoSizeTextField), findsOneWidget);
  await $(K.medicationNameAutoSizeTextField).enterText(drugName);

  expect($(K.routeDropDown), findsOneWidget);

  if (preparation == Preparation.Tablet && (dosage == 0 && isHalfTab)) {
    expect($(K.isHalfOption), findsOneWidget);
    expect($(K.isHalfOption).$("Half"), findsOneWidget);
    await $(K.isHalfOption).$("Half").tap();
  } else {
    await $(K.routeDropDown).tap();
    await $(K.routeDropDown).$(TextField).enterText(
        EnumToString.convertToString(preparation, camelCase: true)
            .toLowerCase());
    await $(K.routeDropDown).$(ListTile).tap();
    await $(K.dosageAutoSizeTextField).enterText(dosage.toString());
  }

  expect($(K.unitDropDown), findsOneWidget);
  await $(K.unitDropDown).tap();
  await $(K.unitDropDown).$(TextField).enterText(
      EnumToString.convertToString(unit, camelCase: true).toLowerCase());
  await $(K.unitDropDown).$(ListTile).tap();

  expect($(K.nextStep), findsOneWidget);
  await $(K.nextStep).tap();

  expect($(K.scheduleSlide), findsOneWidget);
  await $(K.frequencyDropDownButton).tap();

  await $(K.frequencyDropDownButton).$(TextField).enterText(frequency
      .toString()
      .substring(frequency.toString().indexOf(".") + 1)
      .replaceAll("_", " ("));
  await $(K.frequencyDropDownButton)
      .$(frequency
          .toString()
          .substring(frequency.toString().indexOf(".") + 1)
          .replaceAll("_", " ("))
      .tap();
  await $(K.frequencyDropDownButton).$(ListTile).tap();

  for (int i = 1; i < duration; i++) {
    if (!$(K.durationSpinbox).$("${duration.toString()}").exists)
      await $(K.addDays).tap();
  }
  expect($(K.durationTypeField), findsOneWidget);
  await $(K.durationTypeField).tap();
  await $(K.durationTypeField).$(TextField).enterText(
      EnumToString.convertToString(durationType, camelCase: true)
          .toLowerCase());
  await $(K.durationTypeField).$(ListTile).tap();

  if (times.length > 0) {
    await selectTime($, times, frequency);
  }

  if (direction != Direction.NotApplicable) {
    expect(
        $(K.directionsChoiceList)
            .$(ChoiceChip)
            .$(EnumToString.convertToString(direction, camelCase: true)),
        findsOneWidget);
    await $(K.directionsChoiceList)
        .$(ChoiceChip)
        .$(EnumToString.convertToString(direction, camelCase: true))
        .tap();
  }

  expect($(AddMedicationPage).$(K.checkButton), findsOneWidget);

  await $(AddMedicationPage).$(K.checkButton).tap();

  expect($(ConsultationEditPage), findsOneWidget);

  expect($(K.presciptionTile), findsOneWidget);

  await $.scrollUntilVisible(
      finder: $(K.presciptionTile).$(Card).at(index).$(Icons.timer),
      dragDuration: Duration(seconds: 3));

  var prescriptionDrugInfoFinder =
      $(K.prescriptionList).$(Card).at(index).$(Row).$(SizedBox).at(1);

  expect($(prescriptionDrugInfoFinder), findsOneWidget);

  var prescriptionCDrugInfoRow0Finder =
      $(prescriptionDrugInfoFinder).$(Column).$(Padding).at(0).$(Stack).at(0);

  expect($(prescriptionCDrugInfoRow0Finder), findsOneWidget);

  expect(
      $(prescriptionCDrugInfoRow0Finder).$(
          "${dosage.toString()} ${EnumToString.convertToString(unit, camelCase: true).toLowerCase()} ${drugName}"),
      findsOneWidget);

  var prescriptionCDrugInfoRow2Finder =
      $(prescriptionDrugInfoFinder).$(Column).$(Padding).at(1);

  expect($(prescriptionCDrugInfoRow2Finder), findsOneWidget);

  var stackFinder = find.ancestor(
      of: find.byIcon(Icons.timer),
      matching: $(prescriptionDrugInfoFinder).$(find.byType(Stack)));

  var frequencyFinder = find.descendant(
      of: stackFinder,
      matching: $(
          "${frequency.toString().substring(frequency.toString().indexOf(".") + 1, frequency.toString().indexOf("_"))}"));

  expect(frequencyFinder, findsOneWidget);

  if (times.isNotEmpty && times.length > 0) {
    for (int i = 0; i < times.length; i++) {
      var iconListFinder = find.descendant(
          of: stackFinder,
          matching: $(stackFinder).$(LimitedBox).$(K.timesIconList));

      expect($(iconListFinder), findsOneWidget);

      if (times.elementAt(i) == Time.daybreak) {
        expect($(iconListFinder).$(K.daybreak), findsOneWidget);
      } else if (times.elementAt(i) == Time.morning) {
        expect($(iconListFinder).$(K.morning), findsOneWidget);
      } else if (times.elementAt(i) == Time.afternoon) {
        expect($(iconListFinder).$(K.afternoon), findsOneWidget);
      } else if (times.elementAt(i) == Time.evening) {
        expect($(iconListFinder).$(K.evening), findsOneWidget);
      } else if (times.elementAt(i) == Time.night) {
        expect($(iconListFinder).$(K.night), findsOneWidget);
      }
    }
  }

  var durationWidgetFinder =
      find.ancestor(of: find.byIcon(Icons.timelapse), matching: $(Stack));

  expect(
      $(durationWidgetFinder).$(
          "${duration.toString()} ${EnumToString.convertToString(durationType)}"),
      findsOneWidget);

  if (direction != Direction.NotApplicable) {
    var directionWidgetFinder =
        find.ancestor(of: find.byIcon(Icons.comment), matching: $(Stack));

    expect(
        $(directionWidgetFinder)
            .$(EnumToString.convertToString(direction, camelCase: true)),
        findsOneWidget);
  }

  return true;
}
