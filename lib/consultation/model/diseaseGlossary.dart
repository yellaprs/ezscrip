import 'package:flutter/widgets.dart';
import 'package:flutter/material.dart';

class DiaseaseGlossary extends ChangeNotifier {
  List<String> _words;

  DiaseaseGlossary(this._words);

  List<String> get words {
    return List.from(_words);
  }
}
