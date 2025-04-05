import 'package:ezscrip/login_page.dart';
import 'package:ezscrip/util/keys.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

Future<bool> login($, String pin) async {
  expect($(LoginPage), findsOneWidget);
  expect($(K.pinTextField), findsOneWidget);
  await $(K.pinTextField).$(TextField).first.enterText(pin.substring(0, 1));
  await $(K.pinTextField).$(TextField).at(1).enterText(pin.substring(1, 2));
  await $(K.pinTextField).$(TextField).at(2).enterText(pin.substring(2, 3));
  await $(K.pinTextField).$(TextField).at(3).enterText(pin.substring(3, 4));
  await $(K.loginButton).tap();

  return true;
}
