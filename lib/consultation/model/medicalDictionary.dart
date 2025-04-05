import 'package:flutter/widgets.dart';
import 'package:flutter/material.dart';


class MedicalDictionary extends ChangeNotifier {
  List<String> _words;

  MedicalDictionary(this._words);

  List<String> get words {
    return List.from(_words);
  }
}
