import 'package:ezscrip/consultation/model/consultation.dart';
import 'package:ezscrip/consultation/view/add_consultation_page.dart';
import 'package:ezscrip/consultation/view/consultation_search_page.dart';
import 'package:ezscrip/home_page.dart';
import 'package:ezscrip/profile/model/appUser.dart';
import 'package:ezscrip/util/constants.dart';
import 'package:ezscrip/util/keys.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/intl.dart';
import 'package:patrol/patrol.dart';
import 'package:toggle_switch/toggle_switch.dart';
import '../login.dart';
import '../logoff.dart';
import '../setup.dart';
import 'common/consultation_common.dart';

void main() {

  patrolTest(
    'consultation search by patient name test',
    tags:["consultation"],
    ($) async {

     Consultation consultation = await loadTestDateConsultation(
          "assets/test/${C.TEST_DATA_CONSULTATION_SEARCH}.json");
       Consultation consultation1 = await loadTestDateConsultation(
          "assets/test/${C.TEST_DATA_CONSULTATION_SEARCH_1}.json");
      AppUser profile =
          await loadTestDataProfile("assets/test/${C.TEST_DATA_PROFILE}.json");
      await createApp($, profile);
      await login($, "1111");
      await $(HomePage).waitUntilVisible();
      expect($(K.consultFabButton), findsOneWidget);
      await $(K.consultFabButton).tap();
      await $(ConsultationEditPage).waitUntilVisible();
      await addConsultation(
          $,
          consultation.getPatientName(),
          consultation.getGender(),
          consultation.getPatientAge(),
          consultation.getWeight()!,
          consultation.getSymptoms(),
          consultation.getIndicators(),
          consultation.getTests(),
          consultation.getMedicalHistory(),
          consultation.getParameters(),
          consultation.getNotes(),
          consultation.prescription);

      expect($(K.saveButton), findsOneWidget);
      await $(K.saveButton).tap();
      await $(K.backNavButton).tap();
      expect($(HomePage), findsOneWidget);
      await $(Key(DateFormat('ddMMMyyyy').format(DateTime.now()))).scrollTo();
      expect($(Key(DateFormat('ddMMMyyyy').format(DateTime.now()))),
          findsOneWidget);
      await $(Key(DateFormat('ddMMMyyyy').format(DateTime.now())))
          .$(ListTile)
          .$(consultation.getPatientName())
          .waitUntilExists();
      expect(
          $(Key(DateFormat('ddMMMyyyy').format(DateTime.now())))
              .$(ListTile)
              .$(consultation.getPatientName()),
          findsOneWidget);

      expect($(K.consultFabButton), findsOneWidget);

      await $(K.consultFabButton).tap();
      await $(ConsultationEditPage).waitUntilVisible();
      await addConsultation(
          $,
          consultation1.getPatientName(),
          consultation1.getGender(),
          consultation1.getPatientAge(),
          consultation1.getWeight()!,
          consultation1.getSymptoms(),
          consultation1.getIndicators(),
          consultation1.getTests(),
          consultation1.getMedicalHistory(),
          consultation1.getParameters(),
          consultation1.getNotes(),
          consultation1.prescription);

      expect($(K.saveButton), findsOneWidget);
      await $(K.saveButton).tap();
      await $(K.backNavButton).tap();
      expect($(HomePage), findsOneWidget);
      await $(Key(DateFormat('ddMMMyyyy').format(DateTime.now()))).scrollTo();
      expect($(Key(DateFormat('ddMMMyyyy').format(DateTime.now()))),
          findsOneWidget);
      await $(Key(DateFormat('ddMMMyyyy').format(DateTime.now())))
          .$(ListTile)
          .$(consultation1.getPatientName())
          .waitUntilExists();
      expect(
          $(Key(DateFormat('ddMMMyyyy').format(DateTime.now())))
              .$(ListTile)
              .$(consultation1.getPatientName()),
          findsOneWidget);

      expect($(K.consultFabButton), findsOneWidget);
      await $(K.consultFabButton).tap();
      await $(ConsultationEditPage).waitUntilVisible();
      expect($(K.saveButton), findsOneWidget);
      await $(K.saveButton).tap();
      await $(K.backNavButton).tap();
      expect($(HomePage), findsOneWidget);
      expect($(K.consultationSearchNButton), findsOneWidget);
      await $(K.consultationSearchNButton).tap();
      expect($(ConsultationSearchPage), findsOneWidget);
      expect($(K.consultationSearchList), findsOneWidget);
      await $(K.patientNameSearchAutoSizeTextField).tap();
      await $(K.patientNameSearchAutoSizeTextField)
          .enterText(consultation.getPatientName());
      expect($(Card).$(consultation.getPatientName()), findsOneWidget);
      await $(K.patientNameSearchAutoSizeTextField).tap();
      await $(K.patientNameSearchAutoSizeTextField).enterText("");
      await $(K.patientNameSearchAutoSizeTextField)
          .enterText(consultation1.getPatientName());
      expect($(Card).$(consultation1.getPatientName()), findsOneWidget);
      expect($(K.dateFilterSwitch), findsOneWidget);
      await $(K.dateFilterSwitch).tap();

      expect($(K.dateOptionSwitch).$("Before"), findsOneWidget);

      expect($(K.dateOptionSwitch).$("After"), findsOneWidget);

      expect($(K.dateOptionSwitch).$("Between"), findsOneWidget);

      expect($(ToggleSwitch).$('Before'), findsOneWidget);

      await $(K.patientNameSearchAutoSizeTextField).tap();
      await $(K.patientNameSearchAutoSizeTextField).enterText("");

      await $(ToggleSwitch).$('Before').tap();

      expect($(Card).$(consultation.getPatientName()), findsNothing);

      expect($(Card).$(consultation1.getPatientName()), findsNothing);

      expect($(K.backNavButton), findsOneWidget);

      await $(K.backNavButton).tap();

      await $(HomePage).waitUntilVisible();

      await logoff($);

      await $.native.pressHome();
    },
  );
}
