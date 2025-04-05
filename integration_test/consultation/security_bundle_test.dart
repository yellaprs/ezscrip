import 'package:flutter_test/flutter_test.dart';
import '../security/login_test.dart' as login_test;
import '../security/reset_pin_test.dart' as changepin_test;

void main() {
  group('app security feature tests', () {
    login_test.main();
    changepin_test.main();
  });
}
