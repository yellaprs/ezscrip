import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter/widgets.dart';

enum Status { InActive, Active, InProgress, Incomplete, Complete }

abstract class StatusHelper {
  static String toValue(Status status, BuildContext context) {
    switch (status) {
      case Status.InActive:
        return AppLocalizations.of(context)!.active;

      case Status.Active:
        return AppLocalizations.of(context)!.active;

      case Status.Complete:
        return AppLocalizations.of(context)!.complete;

      case Status.InProgress:
        return AppLocalizations.of(context)!.inProgress;

      case Status.Incomplete:
        return AppLocalizations.of(context)!.inComplete;
    }
  }
}
