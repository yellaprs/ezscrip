import 'package:enum_to_string/enum_to_string.dart';
import 'package:ezscrip/home_page.dart';
import 'package:ezscrip/login_page.dart';
import 'package:ezscrip/profile/model/appUser.dart';
import 'package:ezscrip/profile/model/userType.dart';
import 'package:ezscrip/util/constants.dart';
import 'package:ezscrip/util/keys.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:global_configuration/global_configuration.dart';
import 'package:patrol/patrol.dart';
import '../consultation/common/consultation_common.dart';
import '../setup.dart';

void main() {

  patrolTest(
    'Login page sucessful login and invalid pin test',
    ($) async {

      AppUser profile =
          await loadTestDataProfile("assets/test/${C.TEST_DATA_PROFILE}.json");
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
