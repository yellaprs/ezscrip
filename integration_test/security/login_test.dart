import 'package:ezscrip/home_page.dart';
import 'package:ezscrip/login_page.dart';
import 'package:ezscrip/profile/model/appUser.dart';
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
    'Login page sucessful login and invalid pin test',
    ($) async {
      await createApp($, profile);
      expect($(LoginPage), findsOneWidget);
      expect($(K.pinTextField), findsOneWidget);
      await $(K.pinTextField).$(TextField).first.enterText('1');
      await $(K.pinTextField).$(TextField).at(1).enterText('1');
      await $(K.pinTextField).$(TextField).at(2).enterText('1');
      await $(K.pinTextField).$(TextField).at(3).enterText('1');
      await $(K.loginButton).tap();
      await $(HomePage).waitUntilVisible();
      expect($(HomePage), findsOneWidget);
      expect($(K.logoutButton), findsOneWidget);
      await $(K.logoutButton).tap();
      expect($(LoginPage), findsOneWidget);
      await $(K.pinTextField).$(TextField).first.enterText('1');
      await $(K.pinTextField).$(TextField).at(1).enterText('2');
      await $(K.pinTextField).$(TextField).at(2).enterText('3');
      await $(K.pinTextField).$(TextField).at(3).enterText('4');
      await $(K.loginButton).tap();
      await $.pumpAndSettle();
      expect($(LoginPage), findsOneWidget);
    },
  );

  
}
