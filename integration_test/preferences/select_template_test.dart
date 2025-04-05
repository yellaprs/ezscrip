import 'package:ezscrip/home_page.dart';
import 'package:ezscrip/login_page.dart';
import 'package:ezscrip/profile/model/appUser.dart';
import 'package:ezscrip/settings/view/letterhead_selection_page.dart';
import 'package:ezscrip/util/constants.dart';
import 'package:ezscrip/util/keys.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:global_configuration/global_configuration.dart';
import 'package:patrol/patrol.dart';
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
    'select template test',
    config: const PatrolTesterConfig(),
    nativeAutomatorConfig: nativeConfig,
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
      expect($(K.letterHeadNavigationButton), findsOneWidget);
      await $(K.letterHeadNavigationButton).tap();
      await $(LetterheadSelectionPage).waitUntilVisible();
      expect($(K.letterHeadSelectionCoursel), findsOneWidget);
      await $.pumpAndSettle(duration: Duration(seconds: 2));
      await $(K.letterHeadSelectionCoursel).scrollTo(
          scrollDirection: AxisDirection.left,
          dragDuration: Duration(seconds: 1));
      await $(K.letterHeadSelectionCoursel).tap();
      expect($(Key("1.pdf")).$(K.unchecked), findsOneWidget);
      expect($(Key("2.pdf")).$(K.checked), findsOneWidget);
      expect($(K.saveButton), findsOneWidget);
      await $(K.saveButton).tap();
      await $(HomePage).waitUntilVisible();
    },
  );
}
