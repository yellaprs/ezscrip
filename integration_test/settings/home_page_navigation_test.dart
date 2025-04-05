import 'dart:ui';

import 'package:ezscrip/consultation/view/add_consultation_page.dart';
import 'package:ezscrip/home_page.dart';
import 'package:ezscrip/profile/model/appUser.dart';

import 'package:ezscrip/profile/view/profile_page.dart';
import 'package:ezscrip/settings/view/data_retention_setting_page.dart';
import 'package:ezscrip/util/constants.dart';
import 'package:ezscrip/util/keys.dart';
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
    'home page test',
    ($) async {
      createApp($, profile);
      expect($(HomePage), findsOneWidget);
      expect($(K.profileNavigationButton), findsOneWidget);
      expect($(K.letterHeadNavigationButton), findsOneWidget);
      expect($(K.securityNavigatioButton), findsOneWidget);
      expect($(K.consultationSearchNButton), findsOneWidget);
      await $(K.profileNavigationButton).tap();
      expect(ProfilePage, findsOneWidget);
      expect($(K.backNavButton), findsOneWidget);
      await $(K.backNavButton).tap();
      expect(DataRetentionSettingPage, findsOneWidget);
      expect($(K.backNavButton), findsOneWidget);
      await $(K.backNavButton).tap();
      expect($(K.letterHeadNavigationButton), findsOneWidget);
      await $(K.letterHeadNavigationButton).tap();
      expect($(K.securityNavigatioButton), findsOneWidget);
      await $(K.securityNavigatioButton).tap();
      expect(DataRetentionSettingPage, findsOneWidget);
      expect($(K.backNavButton), findsOneWidget);
      await $(K.backNavButton).tap();
    },
  );
}
