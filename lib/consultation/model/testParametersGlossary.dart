import 'package:flutter/widgets.dart';
import 'package:flutter/material.dart';

class TestParametersGlossary extends ChangeNotifier {
  List<String> _parameterNames;

  TestParametersGlossary(this._parameterNames);

  List<String> get names {
    return List.from(_parameterNames);
  }
}
