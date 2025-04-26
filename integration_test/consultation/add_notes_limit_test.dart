import 'package:eva_icons_flutter/eva_icons_flutter.dart';
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
    tags:["consultation"], 
    ($) async {

      AppUser profile =
          await loadTestDataProfile("assets/test/${C.TEST_DATA_PROFILE}.json");
      await createApp($, profile);
      await login($, "1111");

      await $(HomePage).waitUntilVisible();
      expect($(K.consultFabButton), findsOneWidget);
      await $(K.consultFabButton).tap();
      await $(ConsultationEditPage).waitUntilVisible();

      List<String> notes = [
        "Review after 2 months",
        "Review after 3 months",
        "Review after 4 months",
        "Review after 5 months",
        "Review after 6 months"
        "Review after 7 months",
        "Review after 8 months"
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
        if ($(K.testsTile).$('Investigations').$(K.tileStatusCollapsed).exists){
           break;
        }   
      }

      for (int i = 0; i <= 2; i++) {
        await $(K.notesTile).$('Notes').tap();
        if ($(K.notesTile).$(K.tileStatusExpanded).exists) break;
      }

      if (notes.isNotEmpty) {
        for (int i = 0; i < notes.length; i++) {
          await addNote($, notes.elementAt(i));
          
        }
      }

      expect($(K.notesTile).$(Row).$("maximum is 5"), findsOneWidget);
      var finder = find.descendant(
        of: $(K.notlesList).$(Row).at(0),
        matching: find.byIcon(EvaIcons.closeCircleOutline),
      );

      expect($(finder), findsOneWidget);
      await $(finder).tap();
       
      finder = find.descendant(
        of: $(K.notlesList).$(Row).at(0),
        matching: find.byIcon(EvaIcons.closeCircleOutline),
      );
      expect($(finder), findsOneWidget);
      await $(finder).tap();

      finder = find.descendant(
        of: $(K.notlesList).$(Row).at(0),
        matching: find.byIcon(EvaIcons.closeCircleOutline),
      );
      expect($(finder), findsOneWidget);
      await $(finder).tap();
   
      expect($(K.notesTile).$(Row).$("maximum is 5"), findsNothing);
      await $(K.backNavButton).tap();
      expect($(HomePage), findsOneWidget);
      await logoff($);

      await $.native.pressHome();
    },
  );
}
