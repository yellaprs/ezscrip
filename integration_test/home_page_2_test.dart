import 'package:ezscrip/home_page.dart';
import 'package:ezscrip/profile/model/appUser.dart';
import 'package:ezscrip/util/constants.dart';
import 'package:ezscrip/util/keys.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:global_configuration/global_configuration.dart';
import 'package:intl/intl.dart';
import 'package:patrol/patrol.dart';
import 'login.dart';
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
    'home page test',
    ($) async {
      await createApp($, profile);
      await login($, "1111");
      await $(HomePage).waitUntilVisible();
      if (DateTime(DateTime.now().year, DateTime.now().month, 1)
          .isBefore(DateTime.now())) {
        await $(Key(DateFormat('ddMMMyyyy').format(DateTime.now())))
            .scrollTo(scrollDirection: AxisDirection.up);
      } else {
        await $(Key(DateFormat('ddMMMyyyy').format(DateTime.now())))
            .scrollTo(scrollDirection: AxisDirection.down);
      }
      expect($(Key(DateFormat('ddMMMyyyy').format(DateTime.now()))),
          findsOneWidget);
      DateTime endDate =
          DateTime(DateTime.now().year, DateTime.now().month + 1, 0);
      await $(Key(DateFormat('ddMMMyyyy').format(endDate))).scrollTo();
      expect($(Key(DateFormat('ddMMMyyyy').format(endDate))), findsOneWidget);
      expect($(K.consultFabButton), findsOneWidget);
      expect($(HomePage), findsOneWidget);
      expect($(K.consultationSearchNButton), findsOneWidget);
    },
  );
}
