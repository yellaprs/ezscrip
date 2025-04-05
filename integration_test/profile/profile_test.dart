import 'package:ezscrip/home_page.dart';
import 'package:ezscrip/login_page.dart';
import 'package:ezscrip/profile/model/appUser.dart';
import 'package:ezscrip/util/constants.dart';
import 'package:flutter/material.dart';
import 'package:global_configuration/global_configuration.dart';
import '../setup.dart';
import 'package:ezscrip/profile/view/profile_page.dart';
import 'package:ezscrip/profile/view/view_profile_page.dart';
import 'package:ezscrip/util/keys.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:patrol/patrol.dart';

void main() {
  late AppUser profile, newProfile;

  setUp(() async {
    await GlobalConfiguration().loadFromAsset(C.TEST_DATA_PROFILE);
    var testDataJson = GlobalConfiguration().getValue(C.TEST_DATA);
    profile = AppUser(
        testDataJson['firstname'],
        testDataJson['lastname'],
        testDataJson['cedential'],
        testDataJson['specialization'],
        testDataJson['clinic'],
        Locale('EN_US'),
        testDataJson['contact_no']);

    await GlobalConfiguration().loadFromAsset(C.TEST_DATA_PROFILE_1);
    var newTestDataJson = GlobalConfiguration().getValue(C.TEST_DATA);

    profile = AppUser(
        testDataJson['firstname'],
        testDataJson['lastname'],
        testDataJson['cedential'],
        testDataJson['specialization'],
        testDataJson['clinic'],
        Locale('EN_US'),
        testDataJson['contact_no']);

    newProfile = AppUser(
        newTestDataJson['firstname'],
        newTestDataJson['lastname'],
        newTestDataJson['cedential'],
        newTestDataJson['specialization'],
        newTestDataJson['clinic'],
        Locale('EN_US'),
        newTestDataJson['contact_no']);
  });

  patrolTest(
    'modify profile test',
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
      expect($(K.profileNavigationButton), findsOneWidget);
      await $(K.profileNavigationButton).tap();
      await $(ViewProfilePage).waitUntilVisible();
      expect($(K.editProfileButtonKey), findsOneWidget);
      await $(K.editProfileButtonKey).tap();
      await $(ProfilePage).waitUntilVisible();
      expect($(K.firstNameTextField), findsOneWidget);
      await $(K.firstNameTextField).tap();
      await $(K.firstNameTextField).enterText(profile.getFirstName());
      expect($(K.lastNameTextField), findsOneWidget);
      await $(K.lastNameTextField).tap();
      await $(K.lastNameTextField).enterText(profile.getLastName());
      expect($(K.credentialTextField), findsOneWidget);
      await $(K.credentialTextField).tap();
      await $(K.credentialTextField).enterText(profile.getCredentials());
      expect($(K.specializationDropDown), findsOneWidget);
      await $(K.specializationDropDown).tap();
      expect($('Dermatology'), findsOneWidget);
      await $(K.specializationDropDown).$(profile.getSpecialization()).tap();
      expect($(K.clinicTextField), findsOneWidget);
      await $(K.clinicTextField).tap();
      await $(K.clinicTextField).enterText(profile.getClinic());
      expect($(K.contactNoField), findsOneWidget);
      await $(K.contactNoField).tap();
      await $(K.contactNoField).enterText(profile.getContactNo());
      expect($(K.saveButton), findsOneWidget);
      await $(K.saveButton).tap();
      await $(ViewProfilePage).waitUntilVisible();
      expect($(profile.getFirstName()), findsOneWidget);
      expect($(profile.getCredentials()), findsOneWidget);
      expect($(profile.getClinic()), findsOneWidget);
      expect($(profile.getContactNo()), findsOneWidget);
      await $(K.backNavButton).tap();
      await $(HomePage).waitUntilVisible();
    },
  );
}
