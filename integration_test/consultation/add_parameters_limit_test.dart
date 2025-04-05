import 'package:ezscrip/consultation/model/testParameter.dart';
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

      List<TestParameter> testParameterList = [
        TestParameter("Erythrocytes", "30000", "cells/mm"),
        TestParameter("Leucocytes", "40000", "cells"),
        TestParameter("Serum Creatinine", "1.1", "mg/dl"),
        TestParameter("Serum Calicium", "5.1", "mg/dl"),
        TestParameter("Serum Albumin", "10.2", "mg"),
        TestParameter("esr", "4.6", "mg"),
        TestParameter("C Reactive protien", "68.4", "mg"),
        TestParameter("Sodium", "1000", "mg"),
        TestParameter("H1BAC", "7.0", "units"),
        TestParameter("Fasting Glucose", "110", "units"),
        TestParameter("Post Prandial", "140", "units")
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
        await $(K.testsTile).tap();
        if ($(K.testsTile).$('Investigations').$(K.tileStatusCollapsed).exists)
          break;
      }

      for (int i = 0; i <= 2; i++) {
        await $(K.notesTile).$('Notes').tap();
        if ($(K.notesTile).$(K.tileStatusCollapsed).exists) break;
      }

      if (testParameterList.length > 0) {
        for (int i = 0; i < testParameterList.length; i++) {
          await addParameter(
              $,
              testParameterList.elementAt(i).getName(),
              testParameterList.elementAt(i).getValue(),
              testParameterList.elementAt(i).getUnit());
          await $.scrollUntilVisible(
              finder: $(K.parameterList)
                  .$(Row)
                  .$(testParameterList.elementAt(i).getName()),
              view: $(K.parameterList),
              dragDuration: Duration(seconds: 1),
              scrollDirection: AxisDirection.down);
        }
      }

      expect($(K.parametersTile).$(Row).$("maximum is 10"), findsOneWidget);

      expect($(K.parametersTile).$(Row).$(SizedBox).$("Erythrocytes"),
          findsOneWidget);

      var finder = find.ancestor(
        of: find.text("Erythrocytes"),
        matching: find.byType(Row),
      );

      expect($(K.parameterList).$(finder).$(IconButton), findsOneWidget);

      await $(K.parameterList).$(finder).$(IconButton).tap();

      expect($(K.parameterList).$(Row).$(SizedBox).$("Erythrocytes"),
          findsNothing);

      expect($(K.parameterList).$(Row).$(SizedBox).$("C Reactive protien"),
          findsOneWidget);

      finder = find.ancestor(
        of: find.text("C Reactive protien"),
        matching: find.byType(Row),
      );

      expect($(K.parameterList).$(finder).$(IconButton), findsOneWidget);

      await $(K.parameterList).$(finder).$(IconButton).tap();

      expect($(K.parameterList).$(Row).$(SizedBox).$("C Reactive protien"),
          findsNothing);

      expect($(K.backNavButton), findsOneWidget);

      await $(K.backNavButton).tap();

      await $(HomePage).waitUntilVisible();

      await logoff($);

      await $.native.pressHome();
    },
  );
}
