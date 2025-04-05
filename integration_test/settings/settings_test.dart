import 'package:ezscrip/home_page.dart';
import 'package:ezscrip/login_page.dart';
import 'package:ezscrip/profile/model/appUser.dart';
import 'package:ezscrip/settings/view/data_retention_setting_page.dart';
import 'package:ezscrip/util/constants.dart';
import 'package:ezscrip/util/keys.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:global_configuration/global_configuration.dart';
import 'package:patrol/patrol.dart';
import '../setup.dart';

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
    'Data Retention settings test',
    ($) async {
      await createApp($, profile);

      await $(LoginPage).waitUntilVisible();

      expect($(K.pinTextField), findsOneWidget);
      await $(K.pinTextField).$(TextField).first.enterText('1');
      await $(K.pinTextField).$(TextField).at(1).enterText('1');
      await $(K.pinTextField).$(TextField).at(2).enterText('1');
      await $(K.pinTextField).$(TextField).at(3).enterText('1');
      await $(K.loginButton).tap();

      await $(HomePage).waitUntilVisible();
      expect($(K.securityNavigatioButton), findsOneWidget);
      await $(K.securityNavigatioButton).tap();
      expect(DataRetentionSettingPage, findsOneWidget);
      expect(K.dataRetentionSwitch, findsOneWidget);

      await $(K.dataRetentionSwitch).tap();

      expect(K.dataRetentionTouchSpin, findsOneWidget);

      expect($(K.addDays), findsOneWidget);
      expect($(K.subtractDays), findsOneWidget);

      await $(K.addDays).tap();

      expect("5", findsOneWidget);

      await $(K.addDays).tap();

      expect("10", findsOneWidget);

      await $(K.subtractDays).tap();
      await $(K.subtractDays).tap();

      expect("0", findsOneWidget);

      expect($(K.saveButton), findsOneWidget);

      await $(K.saveButton).tap();
      await $.pumpAndSettle();

      expect($(HomePage), findsOneWidget);
    },
  );
}
