import 'package:ezscrip/home_page.dart';
import 'package:ezscrip/login_page.dart';
import 'package:ezscrip/profile/model/appUser.dart';
import 'package:ezscrip/security/view/forgot_pin_page.dart';
import 'package:ezscrip/util/constants.dart';
import 'package:ezscrip/util/keys.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:patrol/patrol.dart';
import '../consultation/common/consultation_common.dart';
import '../setup.dart';

void main() {
  const nativeConfig = NativeAutomatorConfig(
    packageName: 'com.example.ezscrip',
    androidAppName: 'ezscrip',
    bundleId: "com.example.ezscrip",
  );

  patrolTest(
    'forgot pin test ',
    config: const PatrolTesterConfig(),
    nativeAutomatorConfig: nativeConfig,
    ($) async {
      AppUser profile =
          await loadTestDataProfile("assets/test/${C.TEST_DATA_PROFILE}.json");
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

      expect($(K.logoutButton), findsOneWidget);
      await $(K.logoutButton).tap();

      expect($(LoginPage), findsOneWidget);
    },
  );
}
