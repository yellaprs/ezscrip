import 'package:flutter/material.dart';

import 'package:state_notifier/state_notifier.dart';

class LocaleModel extends StateNotifier<Locale> {
  Locale _locale;

  LocaleModel(this._locale) : super(_locale);

  Locale get getLocale => _locale;

  void changelocale(Locale l) {
    _locale = l;
  }
}
