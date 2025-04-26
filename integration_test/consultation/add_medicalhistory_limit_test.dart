import 'package:ezscrip/consultation/model/durationType.dart';
import 'package:ezscrip/consultation/model/medicalHistory.dart';
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
    tags:["consultation"] ,
    ($) async {

      AppUser profile =
          await loadTestDataProfile("assets/test/${C.TEST_DATA_PROFILE}.json");
      await createApp($, profile);
      await login($, "1111");

      await $(HomePage).waitUntilVisible();
      expect($(K.consultFabButton), findsOneWidget);
      await $(K.consultFabButton).tap();
      await $(ConsultationEditPage).waitUntilVisible();

      List<MedicalHistory> medicalHistoryList = [
        MedicalHistory("Diabetes", 3, DurationType.Month),
        MedicalHistory("Neuropathy", 4, DurationType.Year),
        MedicalHistory("Hypothyroidism", 1, DurationType.Day),
        MedicalHistory("Hyperthyroidism", 3, DurationType.Month),
        MedicalHistory("Muscular Dystrophy", 2, DurationType.Year),
        MedicalHistory("Multiple Sclerosis", 6, DurationType.Day),
        MedicalHistory("Fatty Liver", 10, DurationType.Month),
        MedicalHistory("Hyperlipidemia", 4, DurationType.Month),
        MedicalHistory("anxiety Neurosis", 3, DurationType.Month),
        MedicalHistory("Higpertension", 1, DurationType.Month),
        MedicalHistory("Hyperpigmentation", 2, DurationType.Month),
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

      if (medicalHistoryList.isNotEmpty) {

         for (int i = 0; i <= 2; i++) {
          if ($(K.medicalHistoryTile).$(K.tileStatusExpanded).exists) break;
          await $(K.medicalHistoryTile).$('Medical History').tap();
        
        }
        expect($(K.medicalHistoryList), findsOneWidget);
        for (int i = 0; i < medicalHistoryList.length; i++) {
          await addMedicalHistory(
              $,
              medicalHistoryList.elementAt(i).getDiseaseName(),
              medicalHistoryList.elementAt(i).getDuration(),
              medicalHistoryList.elementAt(i).getDurationType());
          await $.scrollUntilVisible(
              finder: $(K.medicalHistoryList)
                  .$(Row)
                  .$(medicalHistoryList.elementAt(i).getDiseaseName()),
              view: $(K.medicalHistoryList),
              dragDuration: const Duration(seconds: 1),
              scrollDirection: AxisDirection.down);
        }
      }

      expect($(K.medicalHistoryTile).$(Row).$("maximum is 10"), findsOneWidget);

      expect($(K.medicalHistoryList).$(Row).$("Muscular Dystrophy"),
          findsOneWidget);

      var finder = find.ancestor(
        of: find.text("Muscular Dystrophy"),
        matching: find.byType(Row),
      );

      expect($(K.medicalHistoryList).$(finder).$(IconButton), findsOneWidget);

      await $(K.medicalHistoryList).$(finder).$(IconButton).tap();

      expect(
          $(K.medicalHistoryList).$(Row).$("Muscular Dystrophy"), findsNothing);

      expect(
          $(K.medicalHistoryList).$(Row).$("Hyperlipidemia"), findsOneWidget);

      finder = find.ancestor(
        of: find.text("Hyperlipidemia"),
        matching: find.byType(Row),
      );

      expect($(K.medicalHistoryList).$(finder).$(IconButton), findsOneWidget);

      await $(K.medicalHistoryList).$(finder).$(IconButton).tap();

      expect($(K.medicalHistoryList).$(Row).$("Hyperlipidemia"), findsNothing);

      expect($(K.backNavButton), findsOneWidget);

      await $(K.backNavButton).tap();

      await $(HomePage).waitUntilVisible();

      await logoff($);

      await $.native.pressHome();
    },
  );
}
