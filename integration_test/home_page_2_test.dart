import 'package:ezscrip/home_page.dart';
import 'package:ezscrip/profile/model/appUser.dart';
import 'package:ezscrip/util/constants.dart';
import 'package:ezscrip/util/keys.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/intl.dart';
import 'package:patrol/patrol.dart';
import 'consultation/common/consultation_common.dart';
import 'login.dart';
import 'setup.dart';

void main() {
 
  patrolTest(
    'home page test',
    ($) async {
       AppUser profile =
          await loadTestDataProfile("assets/test/${C.TEST_DATA_PROFILE}.json");
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
      // DateTime endDate =
          // DateTime(DateTime.now().year, DateTime.now().month + 1, 0);
      // await $(Key(DateFormat('ddMMMyyyy').format(endDate))).scrollTo();
      // expect($(Key(DateFormat('ddMMMyyyy').format(endDate))), findsOneWidget);
      expect($(K.consultFabButton), findsOneWidget);
      expect($(HomePage), findsOneWidget);
      expect($(K.consultationSearchNButton), findsOneWidget);
    },
  );
}
