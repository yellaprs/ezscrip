import 'package:animated_custom_dropdown/custom_dropdown.dart';
import 'package:enum_to_string/enum_to_string.dart';
import 'package:ezscrip/app_bar.dart';
import 'package:ezscrip/consultation/model/durationType.dart';
import 'package:ezscrip/settings/model/userprefs.dart';
import 'package:ezscrip/util/focus_nodes.dart';
import 'package:ezscrip/util/keys.dart';
import 'package:ezscrip/main.dart';
import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_spinbox/material.dart';
import 'package:flutter_vector_icons/flutter_vector_icons.dart';
import 'package:ezscrip/util/semantics.dart' as semantic;
import 'package:get_it/get_it.dart';
// or flutter_spinbox.dart for both
import 'package:auto_size_text/auto_size_text.dart';
import 'package:no_context_navigation/no_context_navigation.dart';
import 'package:validatorless/validatorless.dart';
import '../../util/mode.dart';

enum AmPm { am, pm }

enum FileteredDurationType { Day, Week, Month, Year }

class DurationTypeValidator {
  static String? isRequired(String errMsg, bool isEmpty) {
    return (isEmpty) ? errMsg : null;
  }
}

@immutable
class DataRetentionSettingPage extends StatefulWidget {
  final Mode mode;
  final bool dataRetentionEnabled;
  final int dataRetentionPeriod;
  final FileteredDurationType durationType;

  DataRetentionSettingPage(
      {required this.mode,
      required this.dataRetentionEnabled,
      this.dataRetentionPeriod = 7,
      this.durationType = FileteredDurationType.Day,
      key = K.dataRetentionSettingsPage})
      : super(key: key);

  @override
  _DataRetentionSettingPageState createState() =>
      _DataRetentionSettingPageState(
          mode, dataRetentionEnabled, dataRetentionPeriod, durationType);
}

class _DataRetentionSettingPageState extends State<DataRetentionSettingPage> {
  bool _dataRetentionEnabled;
  int _dataRetentionPeriod;
  final Mode _mode;
  late TimeOfDay _time;
  late FileteredDurationType _durationType;
  late GlobalKey<FormState> _formKey;

  late int _hour;
  late int _minute;
  late TextEditingController hourController,
      minuteController,
      dataRetentionController;
  _DataRetentionSettingPageState(this._mode, this._dataRetentionEnabled,
      this._dataRetentionPeriod, this._durationType);

  @override
  void initState() {
    _hour = 12;
    _minute = 0;

    hourController = TextEditingController();
    hourController.text = _hour.toString();
    _formKey = GlobalKey<FormState>();
    minuteController = TextEditingController();
    minuteController.text = _minute.toString();

    if (_dataRetentionEnabled) {
      dataRetentionController.text = _dataRetentionPeriod.toString();
    }

    dataRetentionController = TextEditingController();

    super.initState();
  }

  Future<bool> enableDataRetetionTask() async {
    bool isTaskEnabled = false;
    int duration = 24 * 60;

    if (await GetIt.instance<UserPrefs>().isDataRetentionTaskSetup()) {
      AwesomeNotifications().cancelAll();
    }
    if (_durationType == FileteredDurationType.Week) {
      duration = duration * 7;
    } else if (_durationType == FileteredDurationType.Month) {
      duration = duration * 30;
    } else if (_durationType == FileteredDurationType.Year) {
      duration = duration * 365;
    }

    setupDataRetentionTask(
        await GetIt.instance<UserPrefs>().getDataRetentionTaskName(),
        TimeOfDay(hour: _time.hour, minute: _time.minute),
        duration);

    bool isSaved = await GetIt.instance<UserPrefs>()
        .setDataRetentionPeriod(_dataRetentionPeriod);

    isSaved = await GetIt.instance<UserPrefs>().setDataRetentionPeriodType(
        DurationType.values.firstWhere((element) =>
            EnumToString.convertToString(element, camelCase: true) ==
            EnumToString.convertToString(_durationType, camelCase: true)));

    isSaved = await GetIt.instance<UserPrefs>().setDataRetentionScheduleTime(
        TimeOfDay(hour: _time.hour, minute: _time.minute).format(context));

    isTaskEnabled =
        await GetIt.instance<UserPrefs>().saveDataRetentionTask(isSaved);

    return isTaskEnabled;
  }

  List<Widget> buildActions() {
    List<Widget> actions = [];

    actions.add(IconButton(
        key: K.saveButton,
        focusNode: FocusNodes.saveSettingButton,
        tooltip: AppLocalizations.of(context)!.ezscrip,
        icon: IconTheme(
            data: Theme.of(context).iconTheme,
            child: const Icon(
              Foundation.check,
              size: 25,
              semanticLabel: semantic.S.SETTINGS_DONE_BTN,
            )),
        onPressed: (_mode == Mode.Preview)
            ? null
            : () async {
                if (_dataRetentionEnabled) {

                  if (_formKey.currentState!.validate()) {

                     _formKey.currentState!.save();
                     await enableDataRetetionTask();

                  }
                } else if (!_dataRetentionEnabled) {

                  AwesomeNotifications().cancelAll();
                  await GetIt.instance<UserPrefs>()
                      .saveDataRetentionTask(false);
                  await GetIt.instance<UserPrefs>().disableDataRetention();

                }
                navService.goBack();
              }));

    return actions;
  }

  void periodicDataRetentionTask() {
    // AwesomeNotifications().((task, inputData) async {
    //   return Future.value(true);
    // });
  }

  Widget buildDataRetentionWidget() {
    return Container(
        padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 5),
        width: MediaQuery.of(context).size.width * 0.8,
        height: MediaQuery.of(context).size.height * 0.12,
        child: Form(
            key: _formKey,
            child: AnimatedOpacity(
                duration: const Duration(seconds: 2),
                opacity: (_dataRetentionEnabled) ? 1.0 : 0.2,
                child: Stack(alignment: Alignment.center, children: [
                  Align(
                    alignment: Alignment.topCenter,
                    child: Stack(alignment: Alignment.centerLeft, children: [
                      const Icon(Icons.today, size: 25),
                      Container(
                          margin: const EdgeInsets.only(left: 30),
                          child: AutoSizeText("Retention Duration",
                              style: Theme.of(context).textTheme.displaySmall,
                              semanticsLabel:
                                  semantic.S.SETTINGS_RETENTION_DURATION_TITLE))
                    ]),
                  ),
                  Padding(
                      padding: const EdgeInsets.only(top: 20),
                      child: Focus(
                          child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                            SizedBox(
                                width: MediaQuery.of(context).size.width * 0.25,
                                child: Semantics(
                                  label: semantic
                                      .S.ADD_MEDICATION_DRUG_DURATION_FIELD,
                                  container: true,
                                  child: TextFormField(
                                    key: K.durationSpinbox,
                                    focusNode:
                                        FocusNodes.durationAutoSizeTextField,
                                    textAlign: TextAlign.center,
                                    decoration: InputDecoration(
                                      contentPadding: const EdgeInsets.all(10),
                                      label: Text(AppLocalizations.of(context)!.duration),
                                      labelStyle: Theme.of(context).textTheme.titleSmall,
                                      border: UnderlineInputBorder(
                                        borderRadius:
                                            BorderRadius.circular(10.0),
                                      ),
                                    ),
                                    keyboardType:  TextInputType.number,
                                    onChanged: (value) {
                                      _dataRetentionPeriod = int.parse(value);
                                      setState(() {});
                                    },
                                    validator: Validatorless.multiple([
                                      Validatorless.required(
                                          AppLocalizations.of(context)!
                                              .isRequired(
                                                  AppLocalizations.of(context)!
                                                      .duration)),
                                      Validatorless.numbersBetweenInterval(
                                          1,
                                          100,
                                          AppLocalizations.of(context)!
                                              .valueRangeWithoutField(1, 100)),
                                    ]),
                                  ),
                                )),
                            const SizedBox(width: 10),
                            SizedBox(
                                width: MediaQuery.of(context).size.width * 0.35,
                                //height: MediaQuery.of(context).size.height * 0.125,
                                child: Padding(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 5, vertical: 5),
                                    child: Semantics(
                                        container: true,
                                        identifier: semantic.S
                                            .ADD_MEDICATION_DRUG_DURATION_TYPE_DROPDWON,
                                        child: CustomDropdown<
                                            FileteredDurationType>.search(
                                          key: K.durationTypeField,
                                          hintText:
                                              AppLocalizations.of(context)!
                                                  .duration,
                                          initialItem: _durationType,
                                          decoration: CustomDropdownDecoration(
                                              closedFillColor: Theme.of(context)
                                                  .primaryColor,
                                              closedBorder: Border.all(
                                                  color: Colors.black),
                                              errorStyle: const TextStyle(
                                                  color: Colors.red),
                                              expandedFillColor:
                                                  Theme.of(context)
                                                      .primaryColor,
                                              headerStyle: Theme.of(context)
                                                  .textTheme
                                                  .titleSmall,
                                              closedErrorBorder: Border.all(
                                                  color: Colors.red)),
                                          headerBuilder: (context, durationType,
                                              displayHeader) {
                                            return Semantics(
                                                container: true,
                                                identifier: semantic.S
                                                    .ADD_MEDICATION_DURATION_TYPE_OPTION,
                                                child: AutoSizeText(EnumToString
                                                    .convertToString(
                                                        durationType,
                                                        camelCase: true)));
                                          },
                                          validator: (val) {
                                            String? isValid =
                                                DurationTypeValidator.isRequired(
                                                    AppLocalizations.of(
                                                            context)!
                                                        .isRequired(
                                                            AppLocalizations.of(
                                                                    context)!
                                                                .duration),
                                                    (val == null));
                                            return isValid;
                                          },
                                          items: FileteredDurationType.values,
                                          listItemBuilder: (context,
                                              durationType, selected, onTap) {
                                            return Container(
                                                alignment: Alignment.centerLeft,
                                                padding:
                                                    const EdgeInsets.all(3),
                                                child: ListTile(
                                                    title: AutoSizeText(
                                                        EnumToString
                                                            .convertToString(
                                                                durationType,
                                                                camelCase:
                                                                    true))));
                                          },
                                          onChanged: (_mode == Mode.Preview)
                                              ? null
                                              : (val) {
                                                  setState(() {
                                                    _durationType = val!;
                                                  });
                                                },
                                        ))))
                          ])))
                ]))));
  }

  // Widget buildDataRetentionWidget() {
  // Widget dataRetentionWidget;

  // dataRetentionWidget = AnimatedOpacity(
  // duration: const Duration(seconds: 2),
  // opacity: (_dataRetentionEnabled) ? 1.0 : 0.2,
  // child: Stack(alignment: Alignment.center, children: [
  // Align(
  // alignment: Alignment.topCenter,
  // child: Stack(alignment: Alignment.centerLeft, children: [
  // const Icon(Icons.today, size: 25),
  // Container(
  // margin: const EdgeInsets.only(left: 30),
  // child: AutoSizeText("Retention Duration",
  // style: Theme.of(context).textTheme.displaySmall,
  // semanticsLabel:
  // semantic.S.SETTINGS_RETENTION_DURATION_TITLE))
  // ]),
  // ),
  // Align(alignment: Alignment.bottomCenter, child: buildTimeStampWidget()),
  // Padding(
  // padding: const EdgeInsets.all(35),
  // child: Focus(
  // focusNode: FocusNodes.setRetentionDuration,
  // child: Container(
  // alignment: Alignment.center,
  // padding: const EdgeInsets.all(5),
  //color: Theme.of(context).primaryColor,
  // child: Column(
  // mainAxisAlignment: MainAxisAlignment.center,
  // crossAxisAlignment: CrossAxisAlignment.center,
  // children: [
  // ConstrainedBox(
  // constraints: BoxConstraints(
  // maxWidth:
  // MediaQuery.of(context).size.width *
  // 0.65,
  // maxHeight:
  // MediaQuery.of(context).size.height *
  // 0.3),
  // child: Padding(
  // padding: const EdgeInsets.symmetric(
  // horizontal: 20, vertical: 20),
  // child: Semantics(
  // identifier: semantic
  // .S.SETTINGS_RETENTION_DURATION_FLD,
  // child: SpinnerInput(
  // minValue: 7,
  // maxValue: 365,
  // step: 5,
  // plusButton: SpinnerButtonStyle(
  // elevation: 0,
  // child: CircleAvatar(
  // backgroundColor: Theme.of(context)
  // .indicatorColor,
  // radius: 25,
  // child: Icon(Icons.add,
  // color: Colors.white, size: 20)),
  // color: Theme.of(context).indicatorColor,
  // ),
  // minusButton: SpinnerButtonStyle(
  // elevation: 0,
  // child: CircleAvatar(
  // backgroundColor: Theme.of(context)
  // .indicatorColor,
  // radius: 25,
  // child: Icon(Icons.remove,
  // color: Colors.white, size: 20)),
  // color: Theme.of(context).indicatorColor,
  // ),
  // middleNumberWidth: 70,
  // middleNumberStyle:
  // const TextStyle(fontSize: 21),
  // spinnerValue:
  // _dataRetentionPeriod.toDouble(),
  // onChange: (newValue) {
  // setState(() {
  // _dataRetentionPeriod =
  // newValue.round();
  // });
  // },
  // ),
  // ),
  // )),
  // Padding(
  // padding: const EdgeInsets.all(10),
  // child: AutoSizeText("Days",
  // style: Theme.of(context)
  // .textTheme
  // .titleMedium)),
  // ])))),
  // ]));

  // return dataRetentionWidget;
  // }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBarBuilder.buildAppBar(
            context,
            const Icon(Ionicons.settings, size: 25),
            AppLocalizations.of(context)!.settings,
            buildActions()),
        body: Container(
            height: MediaQuery.of(context).size.height * 0.8,
            width: MediaQuery.of(context).size.width * 0.9,
            margin: const EdgeInsets.symmetric(vertical: 40, horizontal: 20),
            alignment: Alignment.center,
            child: OrientationBuilder(builder: (context, orientation) {
              return Stack(alignment: Alignment.center, children: [
                Align(
                    alignment: Alignment.topCenter,
                    child: Container(
                        padding: const EdgeInsets.only(
                            top: 25, left: 5, right: 5, bottom: 10),
                        child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              AutoSizeText(
                                "enable data retention policy ?",
                                maxLines: 2,
                                textAlign: TextAlign.center,
                                softWrap: true,
                                semanticsLabel:
                                    semantic.S.SETTINGS_ENABLE_SETTINGS_TITLE,
                                style: Theme.of(context).textTheme.bodyLarge,
                              ),
                              Padding(
                                padding: const EdgeInsets.only(left: 2),
                                child: Semantics(
                                    identifier: semantic
                                        .S.SETTINGS_RETENTION_SETTINGS_SWITCH,
                                    child: Switch(
                                        key: K.dataRetentionSwitch,
                                        focusNode:
                                            FocusNodes.dataRetentionSwitch,
                                        activeTrackColor:
                                            Theme.of(context).primaryColor,
                                        activeColor:
                                            Theme.of(context).indicatorColor,
                                        trackOutlineColor:
                                            MaterialStateProperty.all(
                                                Theme.of(context)
                                                    .indicatorColor),
                                        value: (_dataRetentionEnabled),
                                        onChanged: (value) {
                                          _dataRetentionEnabled = value;
                                          _dataRetentionPeriod = 7;

                                          setState(() {});
                                        })),
                              )
                            ]))),
                SizedBox(
                    height: MediaQuery.of(context).size.height * 0.3,
                    child: buildDataRetentionWidget())
              ]);
            })));
  }
}
