import 'package:ezscrip/home_page.dart';
import 'package:ezscrip/login_page.dart';
import 'package:ezscrip/profile/model/appUser.dart';
import 'package:ezscrip/security/view/forgot_pin_page.dart';
import 'package:ezscrip/util/constants.dart';
import 'package:ezscrip/util/keys.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:global_configuration/global_configuration.dart';
import 'package:patrol/patrol.dart';
import 'package:ezscrip/main.dart' as app;

import '../setup.dart';

void main() {
  const nativeConfig = NativeAutomatorConfig(
    packageName: 'com.example.ezscrip',
    androidAppName: 'Docsribe',
    bundleId: "com.example.ezscrip",
  );

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
    'forgot pin test ',
    config: const PatrolTesterConfig(),
    nativeAutomatorConfig: nativeConfig,
    ($) async {
      await createApp($, profile);
      await $(LoginPage).waitUntilVisible();
      expect($(K.pinTextField), findsOneWidget);
      expect($(K.forgotPinButton), findsOneWidget);
      await $(K.forgotPinButton).tap();

      await $(ForgotPinPage).waitUntilVisible();
      expect($(K.datePicker), findsOneWidget);
      expect($(K.nextButton), findsOneWidget);
      await $(K.nextButton).tap();

      await $(K.pinTextField).waitUntilVisible();
      await $(K.pinTextField).$(TextField).first.enterText('1');
      await $(K.pinTextField).$(TextField).at(1).enterText('2');
      await $(K.pinTextField).$(TextField).at(2).enterText('3');
      await $(K.pinTextField).$(TextField).at(3).enterText('4');

      expect($(K.checkButton), findsOneWidget);
      await $(K.checkButton).tap();

      await $(LoginPage).waitUntilVisible();

      expect($(K.pinTextField), findsOneWidget);
      await $(K.pinTextField).$(TextField).first.enterText('1');
      await $(K.pinTextField).$(TextField).at(1).enterText('2');
      await $(K.pinTextField).$(TextField).at(2).enterText('3');
      await $(K.pinTextField).$(TextField).at(3).enterText('4');

      expect($(K.loginButton), findsOneWidget);
      await $(K.loginButton).tap();
      await $(HomePage).waitUntilVisible();
    },
  );
}
