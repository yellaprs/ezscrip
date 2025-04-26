import 'package:ezscrip/home_page.dart';
import 'package:ezscrip/login_page.dart';
import 'package:ezscrip/profile/model/appUser.dart';
import 'package:ezscrip/util/constants.dart';
import 'package:flutter/material.dart';
import '../consultation/common/consultation_common.dart';
import '../logoff.dart';
import '../setup.dart';
import 'package:ezscrip/profile/view/profile_page.dart';
import 'package:ezscrip/profile/view/view_profile_page.dart';
import 'package:ezscrip/util/keys.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:patrol/patrol.dart';

void main() {
  patrolTest(
    'modify profile test', tags: ["profile"],
    ($) async {
      AppUser profile =
          await loadTestDataProfile("assets/test/${C.TEST_DATA_PROFILE}.json");
      AppUser newProfile = await loadTestDataProfile(
          "assets/test/${C.TEST_DATA_PROFILE_1}.json");

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
      //await $(K.firstNameTextField).tap();

      await $(K.firstNameTextField).enterText(newProfile.getFirstName());
      expect($(K.lastNameTextField), findsOneWidget);
      // await $(K.lastNameTextField).tap();
      await $(K.lastNameTextField).enterText(newProfile.getLastName());
      expect($(K.credentialTextField), findsOneWidget);
      // await $(K.credentialTextField).tap();
      await $(K.credentialTextField).enterText(newProfile.getCredentials());
      expect($(K.specializationDropDown), findsOneWidget);
      await $(K.specializationDropDown).tap();
      //expect($('Dermatology'), findsOneWidget);
      await $(K.specializationDropDown).$(newProfile.getSpecialization()).tap();
      expect($(K.clinicTextField), findsOneWidget);
      //await $(K.clinicTextField).tap();
      await $(K.clinicTextField).enterText(newProfile.getClinic());
      expect($(K.contactNoField), findsOneWidget);
      //await $(K.contactNoField).tap();
      await $(K.contactNoField).enterText(newProfile.getContactNo().substring(newProfile.getContactNo().lastIndexOf(")") + 1));
      expect($(K.saveButton), findsOneWidget);
      await $(K.saveButton).tap();
      await $(ViewProfilePage).waitUntilVisible();

      String name = "${newProfile.getFirstName()} ${newProfile.getLastName()}";
      expect($(name), findsOneWidget);
      expect($(newProfile.getCredentials()), findsOneWidget);
      expect($(newProfile.getSpecialization()), findsOneWidget);
      expect($(newProfile.getClinic()), findsOneWidget);
      
      expect($(newProfile.getContactNo()), findsOneWidget);

      expect($(K.backNavButton), findsOneWidget);
      await $(K.backNavButton).tap();
      await $(HomePage).waitUntilVisible();
      await logoff($);
      await $.native.pressHome();
    },
  );
}
