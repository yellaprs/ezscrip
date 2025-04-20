import 'package:ezscrip/login_page.dart';
import 'package:ezscrip/main.dart' as app;
import 'package:ezscrip/profile/model/appUser.dart';
import 'package:ezscrip/setup/view/initialize_page.dart';
import 'package:ezscrip/util/keys.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:patrol/patrol.dart';

final _patrolTesterConfig = PatrolTesterConfig();
final _nativeAutomatorConfig = NativeAutomatorConfig(
  findTimeout: Duration(seconds: 20), // 10 seconds is too short for some CIs
);

const nativeConfig = NativeAutomatorConfig(
  packageName: 'com.example.ezscrip',
  androidAppName: 'ezscrip',
  bundleId: "com.example.ezscrip",
);

createApp(PatrolIntegrationTester $, AppUser profile) async {
  app.main();
  await $(IntroductionPage).waitUntilVisible();

  expect($(K.pageStepper), findsOneWidget);
  expect($(K.informationSlideKey), findsOneWidget);

  await $(K.nextStep).tap();

  await $.pumpAndSettle();

  expect($(K.doctorsProfileSlideKey), findsOneWidget);
  expect($(K.firstNameTextField), findsOneWidget);

  await $(K.firstNameTextField).enterText(profile.getFirstName());

  expect($(K.lastNameTextField), findsOneWidget);

  await $(K.lastNameTextField).enterText(profile.getLastName());

  expect($(K.credentialTextField), findsOneWidget);

  await $(K.credentialTextField).enterText(profile.getCredentials());

  expect($(K.specializationDropDown), findsOneWidget);
  await $(K.specializationDropDown).tap();

  expect($(profile.getSpecialization()), findsOneWidget);
  await $(K.specializationDropDown).$(profile.getSpecialization()).tap();

  expect($(K.clinicTextField), findsOneWidget);
  await $(K.clinicTextField).enterText(profile.getClinic());

  expect($(K.contactNoField), findsOneWidget);
  await $(K.contactNoField).enterText(profile.getContactNo());

  await $(K.nextStep).tap();

  expect($(K.pinTextField), findsOneWidget);

  await $(K.pinTextField).$(TextField).first.enterText('1');

  await $(K.pinTextField).$(TextField).at(1).enterText('1');

  await $(K.pinTextField).$(TextField).at(2).enterText('1');

  await $(K.pinTextField).$(TextField).at(3).enterText('1');

  expect($(K.checkButton), findsOneWidget);

  await $(K.checkButton).tap();

  await $(K.startTourButton).waitUntilVisible(timeout: Duration(seconds: 10));

  expect($(K.startTourButton), findsOneWidget);

  expect($(K.skipBuutton), findsOneWidget);

  await $(K.skipBuutton).tap();

  await $(LoginPage).waitUntilVisible();
}

void patrol(
  String description,
  Future<void> Function(PatrolIntegrationTester) callback, {
  bool? skip,
  NativeAutomatorConfig? nativeAutomatorConfig,
  LiveTestWidgetsFlutterBindingFramePolicy framePolicy =
      LiveTestWidgetsFlutterBindingFramePolicy.fadePointers,
}) {
  patrolTest(
    description,
    config: _patrolTesterConfig,
    nativeAutomatorConfig: nativeAutomatorConfig ?? _nativeAutomatorConfig,
    framePolicy: framePolicy,
    skip: skip,
    callback,
  );
}
