import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:flutter/material.dart';

class LocaleService {
  static Future<List<Locale>> getLocales() async {
    List<Locale> locales = [];
    final manifestContent = await rootBundle.loadString('AssetManifest.json');

    final Map<String, dynamic> manifestMap = json.decode(manifestContent) as Map<String,dynamic>;
    final files =
        manifestMap.keys.where((String key) => key.contains('l10n/')).toList();
    files.forEach((element) {
      String localeStr = element.substring(
          element.indexOf("intl") + 5, element.indexOf(".arb"));
      List<String> localeCodes = localeStr.split("_");
      locales.add(Locale.fromSubtags(
          languageCode: localeCodes[0],
          countryCode: (localeCodes.length > 1) ? localeCodes[1] : null));
    });
    return locales;
  }

  static Future<Map<String, String>> getLocaleNames() async {
    var json = await rootBundle.loadString('assets/cfg/languages_names.json');
    Map<String, dynamic> localeJson = jsonDecode(json) as Map<String, dynamic>;
    Map<String, String> localeMap =  Map<String, String>();

    localeJson.forEach((key, value) {
      localeMap.putIfAbsent(key, () => value['nativeName'] as String);
    });

    return localeMap;
  }
}
