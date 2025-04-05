import 'package:ezscrip/util/mode.dart';

class DataRetentionSettingPageArguments {
  final Mode mode;
  final bool dataRetentionEnabled;
  final int dataRetentionPeriod;

  DataRetentionSettingPageArguments(
      {required this.mode,
      required this.dataRetentionEnabled,
      this.dataRetentionPeriod = 0});
}
