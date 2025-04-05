import 'package:flutter_test/flutter_test.dart';

import 'home_page_2_test.dart' as home_test2;
import 'consultation/add_consultation_test.dart' as addconsultation_test;
import 'consultation/consultation_search_test.dart' as consultation_search_test;

void main() {
  group('app consultation feature tests', () {
    // home_test.main();
    addconsultation_test.main();
  
    home_test2.main();
    consultation_search_test.main();
  });
} 
