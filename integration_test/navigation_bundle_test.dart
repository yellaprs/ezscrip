import 'package:flutter_test/flutter_test.dart';
import 'home_page_2_test.dart' as home_test;
import 'profile/profile_test.dart' as profile_test;

import 'preferences/select_template_test.dart' as selecttemplate_test;
import 'settings/home_page_navigation_test.dart' as settings_test;

void main() {
  group('app navigation feature tests', () {
    home_test.main();
    profile_test.main();
    
    selecttemplate_test.main();
    settings_test.main();
  });
}
