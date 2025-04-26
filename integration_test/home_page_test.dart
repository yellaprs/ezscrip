import 'package:ezscrip/profile/model/appUser.dart';
import 'package:ezscrip/util/constants.dart';
import 'package:ezscrip/util/keys.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:patrol/patrol.dart';
import 'consultation/common/consultation_common.dart';
import 'login.dart';
import 'setup.dart';
      
void main() {

  patrolTest(
    'home page Consultation Search page Navigation',
    ($) async {
      AppUser profile =
          await loadTestDataProfile("assets/test/${C.TEST_DATA_PROFILE}.json");
      await createApp($, profile);
      await login( $, "1111");
      await $.pumpAndSettle();
      expect($(K.consultationSearchNButton), findsOneWidget);
      expect($(K.profileNavigationButton), findsOneWidget);
      expect($(K.letterHeadNavigationButton), findsOneWidget);
      expect($(K.consultationSearchNButton), findsOneWidget);
      expect($(K.consultFabButton), findsOneWidget);
    },
  );
}
