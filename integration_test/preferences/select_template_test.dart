import 'package:ezscrip/home_page.dart';
import 'package:ezscrip/login_page.dart';
import 'package:ezscrip/profile/model/appUser.dart';
import 'package:ezscrip/settings/view/letterhead_selection_page.dart';
import 'package:ezscrip/util/constants.dart';
import 'package:ezscrip/util/keys.dart';
import 'package:flutter/material.dart';
import 'package:flutter_carousel_widget/flutter_carousel_widget.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:patrol/patrol.dart';
import '../consultation/common/consultation_common.dart';
import '../logoff.dart';
import '../setup.dart';

void main() {
  const nativeConfig = NativeAutomatorConfig(
    packageName: 'com.example.ezscrip',
    androidAppName: 'ezscrip',
    bundleId: "com.example.ezscrip",
  );

  patrolTest(
    'select template test',
    config: const PatrolTesterConfig(),
    nativeAutomatorConfig: nativeConfig,
    ($) async {
      AppUser profile =
          await loadTestDataProfile("assets/test/${C.TEST_DATA_PROFILE}.json");
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
      await $.pumpAndSettle(duration: const Duration(seconds: 2));
      var carouselCardFinder =
          find.ancestor(of: $(const Key("1")), matching: $(Stack));
      expect($(carouselCardFinder).$(Icons.check_circle), findsOneWidget);
      final screenWidth = $.tester.view.physicalSize.width;
      await $.tester.drag(find.byType(FlutterCarousel), Offset(-screenWidth/2, 0));
      await $.pumpAndSettle(duration: const Duration(seconds: 2));
      expect($(carouselCardFinder).$(Icons.check_circle), findsNothing);
      carouselCardFinder =
          find.ancestor(of: $(const Key("2")), matching: $(Stack));
      expect($(carouselCardFinder).$(Icons.circle_outlined), findsOneWidget);
      await $(K.letterHeadSelectionCoursel).tap();
      expect($(carouselCardFinder).$(Icons.check_circle), findsOneWidget);
      expect($(K.checkButton), findsOneWidget);
      await $(K.checkButton).tap();
      await $(HomePage).waitUntilVisible();
      await logoff($);
      await $.native.pressHome();

    },
  );
}
