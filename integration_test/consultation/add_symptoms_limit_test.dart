import 'package:ezscrip/consultation/view/add_consultation_page.dart';
import 'package:ezscrip/home_page.dart';
import 'package:ezscrip/profile/model/appUser.dart';
import 'package:ezscrip/util/constants.dart';
import 'package:ezscrip/util/keys.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:global_configuration/global_configuration.dart';
import 'package:patrol/patrol.dart';
import '../login.dart';
import '../logoff.dart';
import '../setup.dart';
import 'common/consultation_common.dart';

void main() {
  late AppUser profile;

  setUp(() async {
    await GlobalConfiguration().loadFromAsset(C.TEST_DATA_CONSULTATION);
    var profileDataJson = GlobalConfiguration().getValue(C.TEST_DATA);
    profile = AppUser(
        profileDataJson['firstname'],
        profileDataJson['lastname'],
        profileDataJson['credential'],
        profileDataJson['specialization'],
        profileDataJson['clinic'],
        Locale('EN_US'),
        profileDataJson['contact_no']);
  });

  patrolTest(
    'Add Consultation with prescription 1 test ( 2 symtpms,  2 presctiption)',
    ($) async {
      await createApp($, profile);
      await login($, "1111");

      await $(HomePage).waitUntilVisible();
      expect($(K.consultFabButton), findsOneWidget);
      await $(K.consultFabButton).tap();
      await $(ConsultationEditPage).waitUntilVisible();

      List<String> symptoms = [
        "fever",
        "cold",
        "dysuria",
        "dyspesia",
        "neuropathy",
        "tachycardia",
        "cough",
        "anxiety",
        "arrythmia",
        "myligia"
            "palpitations"
            "neuraligia",
        "angina"
      ];

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

      if (symptoms.length > 0) {
        for (int i = 0; i < symptoms.length; i++) {
          await addSymptom($, symptoms.elementAt(i));
        }
      }
      expect($(K.symptomsTile).$(Row).$("maximum is 10"), findsOneWidget);

      expect($(K.saveButton), findsOneWidget);
      await $(K.saveButton).tap();

      expect($(K.symptomsTile).$(Row).$("neuropathy"), findsOneWidget);

      var finder = find.ancestor(
        of: find.text("neuropathy"),
        matching: find.byType(Row),
      );

      expect($(K.symptomsTile).$(finder).$(IconButton), findsOneWidget);

      await $(K.symptomsTile).$(finder).$(IconButton).tap();

      expect($(K.symptomsTile).$(finder).$(IconButton), findsNothing);

      expect($(K.symptomsTile).$(Row).$("tachycardia"), findsOneWidget);

      finder = find.ancestor(
        of: find.text("tachycardia"),
        matching: find.byType(Row),
      );

      expect($(K.symptomsTile).$(finder).$(IconButton), findsOneWidget);

      await $(K.symptomsTile).$(finder).$(IconButton).tap();

      expect($(K.symptomsTile).$(finder).$(IconButton), findsNothing);

      expect($(K.symptomsTile).$("maximum is 10"), findsNothing);

      expect($(K.backNavButton), findsOneWidget);
      await $(K.backNavButton).tap();

      await $(HomePage).waitUntilVisible();

      await logoff($);

      await $.native.pressHome();
    },
  );
}
