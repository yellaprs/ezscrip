import 'package:ezscrip/consultation/model/preparation.dart';
import 'package:ezscrip/consultation/model/unit.dart';
import 'package:ezscrip/consultation/view/add_consultation_page.dart';
import 'package:ezscrip/consultation/view/add_medication_page.dart';
import 'package:ezscrip/home_page.dart';
import 'package:ezscrip/profile/model/appUser.dart';
import 'package:ezscrip/profile/model/userType.dart';
import 'package:ezscrip/util/constants.dart';
import 'package:ezscrip/util/keys.dart';
import 'package:enum_to_string/enum_to_string.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:global_configuration/global_configuration.dart';
import 'package:patrol/patrol.dart';
import '../login.dart';
import '../setup.dart';
import 'common/consultation_common.dart';

void main() {
  
  patrolTest(
    'Add Consultation Page (Symtoms count limit test',
    ($) async {

        AppUser profile =
          await loadTestDataProfile("assets/test/${C.TEST_DATA_PROFILE}.json");
      await createApp($, profile);
      await login($, "1111");
      await $(HomePage).waitUntilVisible();
      expect($(K.consultFabButton), findsOneWidget);
      await $(K.consultFabButton).tap();
      await $(ConsultationEditPage).waitUntilVisible();

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

      expect($(K.presciptionTile), findsOneWidget);
      await $(K.presciptionTile).tap();

      expect($(K.addMedicatioButton), findsOneWidget);

      await $(K.addMedicatioButton).tap();

      expect($(AddMedicationPage), findsOneWidget);

      expect($(K.drugInfoSlide), findsOneWidget);

      expect($(K.medicationNameAutoSizeTextField), findsOneWidget);
      await $(K.medicationNameAutoSizeTextField).enterText("Dolo 650 mg");

      expect($(K.routeDropDown), findsOneWidget);
      await $(K.routeDropDown).tap();
      await $(K.routeDropDown).$(TextField).enterText(
          EnumToString.convertToString(Preparation.Tablet, camelCase: true)
              .toLowerCase());
      await $(K.routeDropDown).$(ListTile).tap();

      expect($(K.unitDropDown), findsOneWidget);
      await $(K.unitDropDown).tap();

      await $(K.unitDropDown)
          .$(TextField)
          .enterText(EnumToString.convertToString(Unit.ml, camelCase: true));

      await $(K.unitDropDown).$(ListTile).tap();

      await $.pumpAndSettle();

      expect($("invalid combination of Preparation and Unit"),
          findsAtLeastNWidgets(1));

      await $(K.routeDropDown).$(TextField).enterText(
          EnumToString.convertToString(Preparation.Capsule, camelCase: true)
              .toLowerCase());
      await $(K.routeDropDown).$(ListTile).tap();

      expect(
          $(find.descendant(
              of: $(K.unitDropDown),
              matching: $("invalid combination of Preparation and Unit"))),
          findsAtLeastNWidgets(1));

      await $(K.unitDropDown).tap();

      await $(K.unitDropDown)
          .$(TextField)
          .enterText(EnumToString.convertToString(Unit.cc, camelCase: true));

      await $(K.unitDropDown).$(ListTile).tap();

      await $.pumpAndSettle();

      expect(
          $(find.descendant(
              of: $(K.unitDropDown),
              matching: $("invalid combination of Preparation and Unit"))),
          findsAtLeastNWidgets(1));
    },
  );
}
