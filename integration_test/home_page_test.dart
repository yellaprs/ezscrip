import 'package:ezscrip/login_page.dart';
import 'package:ezscrip/profile/model/appUser.dart';
import 'package:ezscrip/util/constants.dart';
import 'package:ezscrip/util/keys.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:global_configuration/global_configuration.dart';
import 'package:patrol/patrol.dart';
import 'setup.dart';

void main() {
  late AppUser profile;
  setUp(() async {
    await GlobalConfiguration().loadFromAsset(C.TEST_DATA_PROFILE);
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
    'home page Consultation Search page Navigation',
    ($) async {
      await createApp($, profile);
      await $(LoginPage).waitUntilVisible();
      await $(K.pinTextField).$(TextField).first.enterText('1');
      await $(K.pinTextField).$(TextField).at(1).enterText('1');
      await $(K.pinTextField).$(TextField).at(2).enterText('1');
      await $(K.pinTextField).$(TextField).at(3).enterText('1');
      await $(K.loginButton).tap();
      await $.pumpAndSettle();
      expect($(K.consultationSearchNButton), findsOneWidget);
      expect($(K.profileNavigationButton), findsOneWidget);
      expect($(K.letterHeadNavigationButton), findsOneWidget);
      expect($(K.consultationSearchNButton), findsOneWidget);
      expect($(K.consultFabButton), findsOneWidget);
    },
  );
}
