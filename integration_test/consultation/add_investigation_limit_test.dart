
import 'package:ezscrip/consultation/view/add_consultation_page.dart';
import 'package:ezscrip/home_page.dart';
import 'package:ezscrip/profile/model/appUser.dart';
import 'package:ezscrip/util/constants.dart';
import 'package:ezscrip/util/keys.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:patrol/patrol.dart';
import '../login.dart';
import '../logoff.dart';
import '../setup.dart';
import 'common/consultation_common.dart';

void main() {

  patrolTest(
    'Add Consultation with prescription 1 test ( 2 symtpms,  2 presctiption)',
    ($) async {

      AppUser profile =
          await loadTestDataProfile("assets/test/${C.TEST_DATA_PROFILE}.json");
      await createApp($, profile);
      await login($, "1111");

      await $(HomePage).waitUntilVisible();
      expect($(K.consultFabButton), findsOneWidget);
      await $(K.consultFabButton).tap();
      await $(ConsultationEditPage).waitUntilVisible();

      List<String> investigationsList = [
        "Comple Blood Profile",
        "Serum Calicum",
        "Serum Albumin",
        "Serum Potassium",
        "Vitamin D3",
        "Vitamin B12",
        "Lipid Profile",
        "Kidney Profile",
        "Urine Analysis",
        "Heamogram",
        "Liver Functioning Test",
        "Urine Culture"
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

      await $.scrollUntilVisible(finder: $(K.testsTile));

      if (investigationsList.isNotEmpty) {

         for (int i = 0; i <= 2; i++) {
            if ($(K.testsTile).$(K.tileStatusExpanded).exists) break;
            await $(K.testsTile).$('Investigations').tap();
        }
        for (int i = 0; i < investigationsList.length; i++) {
         
          await addInvestigation($, investigationsList.elementAt(i));
          await $.scrollUntilVisible(
              finder: $(K.testsList).$(Row).$(investigationsList.elementAt(i)),
              view: $(K.testsList),
              dragDuration: const Duration(seconds: 1),
              scrollDirection: AxisDirection.down);
        }
      }

      await $.scrollUntilVisible(
          finder: $(K.testsTile).$("Investigations"),
          view: $(ConsultationEditPage),
          scrollDirection: AxisDirection.up);

      expect($(K.testsTile).$(Row).$("maximum is 10"), findsOneWidget);
      expect($(K.testsList).$(Row).$("Serum Albumin"), findsOneWidget);

      var finder = find.ancestor(
        of: find.text("Serum Albumin"),
        matching: find.byType(Row),
      );

      expect($(K.testsList).$(finder).$(IconButton), findsOneWidget);

      await $(K.testsList).$(finder).$(IconButton).tap();

      expect($(K.testsList).$(Row).$("Serum Albumin"), findsNothing);

      expect($(K.testsList).$(Row).$("Urine Analysis"), findsOneWidget);

      finder = find.ancestor(
        of: find.text("Urine Analysis"),
        matching: find.byType(Row),
      );

      await $(K.testsList).$(finder).$(IconButton).tap();

      expect($(K.testsList).$(Row).$("Urine Analysis"), findsNothing);

      expect($(K.testsList).$(Row).$("maximum is 10"), findsNothing);

      expect($(K.backNavButton), findsOneWidget);

      await $(K.backNavButton).tap();

      await $(HomePage).waitUntilVisible();

      await logoff($);

      await $.native.pressHome();
    },
  );
}
