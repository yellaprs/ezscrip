import 'package:ezscrip/home_page.dart';
import 'package:ezscrip/login_page.dart';
import 'package:ezscrip/util/keys.dart';
import 'package:flutter_test/flutter_test.dart';

Future<bool> logoff($) async {
  expect($(HomePage), findsOneWidget);
  expect($(K.logoutButton), findsOneWidget);
  await $(K.logoutButton).tap();
  expect($(LoginPage), findsOneWidget);
  return true;
}
