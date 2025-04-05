import 'package:flutter/widgets.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

enum Gender { Male, Female, Trans }

abstract class GenderHelper {
  static String toValue(Gender gender, BuildContext context) {
    switch (gender) {
      case Gender.Female:
        return AppLocalizations.of(context)!.female;

      case Gender.Male:
        return AppLocalizations.of(context)!.male;

      case Gender.Trans:
        return AppLocalizations.of(context)!.trans;
    }
  }

  static String toStringValue(Gender gender) {
    return gender.toString().substring(gender.toString().indexOf(".") + 1);
  }
}
