import 'package:ezscrip/consultation/model/consultation.dart';
import 'package:ezscrip/consultation/view/add_consultation_page.dart';
import 'package:ezscrip/consultation/view/consultation_page.dart';
import 'package:ezscrip/consultation/view/consultation_search_page.dart';
import 'package:ezscrip/home_page.dart';
import 'package:ezscrip/prescription/view/prescription_preview_page.dart';
import 'package:ezscrip/profile/model/appUser.dart';
import 'package:ezscrip/util/constants.dart';
import 'package:ezscrip/util/keys.dart';
import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:global_configuration/global_configuration.dart';
import 'package:intl/intl.dart';
import 'package:patrol/patrol.dart';
import '../login.dart';
import '../logoff.dart';
import '../setup.dart';
import 'common/consultation_common.dart';

void main() {
  late Consultation consultation;
  late AppUser profile;

  setUp(() async {
    await GlobalConfiguration().loadFromAsset(C.TEST_DATA_CONSULTATION);
    var testDataJson = GlobalConfiguration().getValue(C.TEST_DATA_JSON);
    consultation = Consultation.fromMap(testDataJson);
    await GlobalConfiguration().loadFromAsset(C.TEST_DATA_PROFILE);
    var profileDataJson = GlobalConfiguration().getValue(C.TEST_DATA);
    profile = AppUser(
        profileDataJson['firstname'],
        profileDataJson['lastname'],
        profileDataJson['cedential'],
        profileDataJson['specialization'],
        profileDataJson['clinic'],
        Locale('EN_US'),
        profileDataJson['contact_no']);
  });

  patrolTest(
    'Add Consultation with prescription 1 test',
    ($) async {
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
      await $(Key(DateFormat('ddMMMyyyy').format(DateTime.now())))
          .$(Slidable)
          .tap();
      await $(Key(DateFormat('ddMMMyyyy').format(DateTime.now())))
          .$(Slidable)
          .$('Edit')
          .tap();
      await $(ConsultationEditPage).waitUntilVisible();

      await $(ConsultationEditPage).waitUntilVisible();
      expect($(K.checkButton), findsOneWidget);
      await $(K.checkButton).tap();

      expect($(ConsultationPage), findsOneWidget);

      expect($(K.prescriptionViewButton), findsOneWidget);
      await $(K.prescriptionViewButton).tap();
      await $(PrescriptionPdfViewPage).waitUntilVisible();

      expect($(PrescriptionPdfViewPage).$(K.backNavButton), findsOneWidget);
      await $(PrescriptionPdfViewPage).$(K.backNavButton).tap();

      await $(ConsultationPage).waitUntilVisible();
      expect($(K.checkButton), findsOneWidget);
      await $(K.checkButton).tap();

      await $(HomePage).waitUntilVisible();
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
      await $(Key(DateFormat('ddMMMyyyy').format(DateTime.now())))
          .$(Slidable)
          .tap();
      await $(Key(DateFormat('ddMMMyyyy').format(DateTime.now())))
          .$(Slidable)
          .$('View')
          .tap();
      await viewConsultation(
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

      expect($(K.consultationSearchNButton), findsOneWidget);
      await $(K.consultationSearchNButton).tap();

      expect($(ConsultationSearchPage), findsOneWidget);

      expect($(K.consultationSearchList), findsOneWidget);

      await $(K.patientNameSearchAutoSizeTextField).tap();
      await $(K.patientNameSearchAutoSizeTextField)
          .enterText(consultation.getPatientName());

      expect($(Card).$(consultation.getPatientName()), findsOneWidget);

      await $(Slidable).$(consultation.getPatientName()).tap();
      await $(Slidable).$(CustomSlidableAction).$('View').tap();

      await $(ConsultationPage).waitUntilVisible();

      expect($(K.backNavButton), findsOneWidget);
      await $(K.backNavButton).tap();

      expect($(K.backNavButton), findsOneWidget);
      await $(K.backNavButton).tap();

      await $(HomePage).waitUntilVisible();

      await logoff($);

      await $.native.pressHome();
      await $.native.pressHome();
    },
  );
}
