import 'package:ezscrip/util/constants.dart';
import 'package:global_configuration/global_configuration.dart';
import 'package:newrelic_mobile/newrelic_mobile.dart';
import 'package:talker_flutter/talker_flutter.dart';
import 'package:get_it/get_it.dart';

class Logger {
  static final isRemoteLogEnabled = GlobalConfiguration().get(C.REMOTE_LOG);
  static final talker = GetIt.instance<Talker>();

  static warn(var message) {
    talker.warning(message);
  }

  static info(var message) {
    talker.info(message);
  }

  static error(var message) {
    talker.error(message);

    if (isRemoteLogEnabled) {
      NewrelicMobile.instance.recordError(error, StackTrace.current,
          attributes: {"error": message});
    }
  }

  static debug(var message) {
    talker.debug(message);
  }
}
