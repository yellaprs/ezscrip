import 'package:ezscrip/home_page.dart';
import 'package:ezscrip/profile/model/appUser.dart';
import 'package:ezscrip/settings/view/data_retention_setting_page.dart';
import 'package:ezscrip/util/constants.dart';
import 'package:ezscrip/util/keys.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:patrol/patrol.dart';
import '../consultation/common/consultation_common.dart';
import '../login.dart';
import '../logoff.dart';
import '../setup.dart';

void main() {
  patrolTest(
    'Data Retention settings test',
    tags: ["settings"],
    ($) async {
      AppUser profile =
          await loadTestDataProfile("assets/test/${C.TEST_DATA_PROFILE}.json");

      await createApp($, profile);
      await login($, "1111");

      await $(HomePage).waitUntilVisible();
      expect($(K.settingsButton), findsOneWidget);

      await $(K.settingsButton).tap();

      await $(DataRetentionSettingPage).waitUntilVisible();
   
      expect($(K.dataRetentionSwitch), findsOneWidget);

      //  await $.tester
      // .drag(find.byType(Switch), const Offset(5.0, 0));

      await $(K.dataRetentionSwitch).tap();

      expect($(K.durationSpinbox), findsOneWidget);

      expect($(K.durationTypeField), findsOneWidget);

      await $(K.durationSpinbox).enterText("10");

      await $(K.durationTypeField).tap();

      await $(K.durationTypeField).$(TextField).enterText("week");

      await $(K.durationTypeField).$(ListTile).tap();

      expect($(K.saveButton), findsOneWidget);

      await $(K.saveButton).tap();

      await $.pumpAndSettle();

      expect($(HomePage), findsOneWidget);

      await logoff($);
      await $.native.pressHome();
    },
  );
}
