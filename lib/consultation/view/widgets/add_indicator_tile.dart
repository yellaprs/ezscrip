import 'package:auto_size_text/auto_size_text.dart';
import 'package:ezscrip/consultation/model/consultation.dart';
import 'package:ezscrip/profile/model/appUser.dart';
import 'package:ezscrip/util/focus_nodes.dart';
import 'package:ezscrip/util/keys.dart';
import 'package:ezscrip/util/mode.dart';
import 'package:flutter/material.dart';
import 'package:flutter_advanced_switch/flutter_advanced_switch.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_vector_icons/flutter_vector_icons.dart';
import 'package:validatorless/validatorless.dart';
import 'package:ezscrip/util/semantics.dart' as semantic;

class AddIndicatorTile extends StatefulWidget {
  final Mode mode;
  final Consultation consultation;
  final AppUser user;
  final Map<String, dynamic> propertiesMap;

  const AddIndicatorTile(
      {required this.mode,
      required this.consultation,
      required this.user,
      required this.propertiesMap,
      Key key = K.addConsultationPage})
      : super(key: key);

  @override
  _AddIndicatorTileState createState() => _AddIndicatorTileState(
      this.mode, this.consultation, this.user, this.propertiesMap);
}

class _AddIndicatorTileState extends State<AddIndicatorTile> {
  Mode _mode;
  Consultation _consultation;
  AppUser _user;
  Map<String, dynamic> _propertiesMap;

  late ExpansionTileController _indicatorsTileController;

  late TextEditingController _systolicController,
      _diastolicController,
      _pulserateController,
      _tempController,
      _spo2Controller;

  late ValueNotifier<bool> _bpEnabled,
      _heartrateEnabled,
      _temperatureEnabled,
      _spo2Enabled;

  late FocusNode _systolicFocusNode,
      _diastolicFocusNode,
      _hrFocusNode,
      _tempFocusNode,
      _spo2FocusNode;

  int? _systolic, _diastolic, _pulseRate, _spo2;

  double? _temp;

  late bool _isVitalsExpanded;

  _AddIndicatorTileState(
      this._mode, this._consultation, this._user, this._propertiesMap);

  void initState() {
    _indicatorsTileController = ExpansionTileController();

    _systolicController = TextEditingController();
    _diastolicController = TextEditingController();
    _pulserateController = TextEditingController();
    _tempController = TextEditingController();
    _spo2Controller = TextEditingController();

    super.initState();
  }

  dynamic getPropertyValue(String name, String type) {
    var property = (_propertiesMap[name]!);

    return property[type];
  }

  Widget buildBPIndicatorWidget() {
    return Padding(
        padding: const EdgeInsets.all(10),
        child: Stack(alignment: Alignment.centerLeft, children: [
          SizedBox(
            height: 30,
            width: 70,
            child: Container(
              decoration: BoxDecoration(
                  border: Border.all(width: 3.0, color: Colors.grey),
                  borderRadius: BorderRadius.circular(21)),
              child: Semantics(
                  identifier: semantic.S.VITAL_SIGN_BP_SWITCH,
                  child: AdvancedSwitch(
                    key: K.bpSwitch,
                    controller: _bpEnabled,
                    activeColor: Theme.of(context).primaryColor,
                    inactiveColor: Colors.white30,
                    borderRadius: const BorderRadius.all(Radius.circular(15)),
                    width: 70.0,
                    height: 30.0,
                    enabled: true,
                    initialValue: _bpEnabled.value,
                    activeChild: Text('BP',
                        softWrap: true,
                        style: Theme.of(context).textTheme.titleSmall),
                    inactiveChild: Text('BP',
                        style: Theme.of(context).textTheme.titleSmall),
                    thumb: CircleAvatar(
                      backgroundColor: Theme.of(context).indicatorColor,
                    ),
                    disabledOpacity: 0.5,
                    onChanged: (val) {
                      setState(() {
                        _bpEnabled.value = val;
                      });
                    },
                  )),
            ),
          ),
          Visibility(
              visible: _bpEnabled.value,
              child: Container(
                  width: MediaQuery.of(context).size.width,
                  padding: const EdgeInsets.only(left: 100),
                  child: Row(children: [
                    SizedBox(
                        width: MediaQuery.of(context).size.width / 4 - 20,
                        height: 50,
                        child: Semantics(
                            identifier: semantic.S.VITAL_SIGNS_BP_SYSTOLIC,
                            child: TextFormField(
                                key: K.bpSystolicField,
                                focusNode: _systolicFocusNode,
                                autovalidateMode:
                                    AutovalidateMode.onUserInteraction,
                                decoration: InputDecoration(
                                    labelText:
                                        AppLocalizations.of(context)!.systolic,
                                    contentPadding: const EdgeInsets.all(10),
                                    errorStyle:
                                        const TextStyle(height: 1, fontSize: 8),
                                    errorMaxLines: 2,
                                    errorBorder: const UnderlineInputBorder(
                                      // width: 0.0 produces a thin "hairline" border
                                      borderSide: BorderSide(
                                          color: Colors.red, width: 1.0),
                                    ),
                                    border: const UnderlineInputBorder(
                                      // width: 0.0 produces a thin "hairline" border
                                      borderSide: BorderSide(
                                          color: Colors.grey, width: 1.0),
                                    ),
                                    counterText: ""),
                                style: Theme.of(context).textTheme.bodyMedium,
                                controller: _systolicController,
                                maxLength: 3,
                                keyboardType: TextInputType.number,
                                onFieldSubmitted: (val) {
                                  FocusScope.of(context)
                                      .requestFocus(_diastolicFocusNode);
                                },
                                validator: Validatorless.numbersBetweenInterval(
                                    getPropertyValue("systolic", "min")
                                        .toDouble(),
                                    getPropertyValue("systolic", "max")
                                        .toDouble(),
                                    AppLocalizations.of(context)!
                                        .valueRangeWithoutField(
                                            getPropertyValue("systolic", "min"),
                                            getPropertyValue(
                                                "systolic", "max"))),
                                onSaved: (val) {
                                  if (val!.trim().isNotEmpty) {
                                    _systolic = int.parse(val);
                                  }
                                }))),
                    const SizedBox(
                      height: 25,
                      width: 4,
                      child: VerticalDivider(
                          width: 2.0, thickness: 1.0, color: Colors.blueGrey),
                    ),
                    SizedBox(
                      width: MediaQuery.of(context).size.width / 4,
                      height: 50,
                      child: Semantics(
                          identifier: semantic.S.VITAL_SIGNS_BP_DIASTOLIC,
                          child: TextFormField(
                            key: K.bpDiastolicField,
                            focusNode: _diastolicFocusNode,
                            controller: _diastolicController,
                            autovalidateMode:
                                AutovalidateMode.onUserInteraction,
                            onFieldSubmitted: (val) {
                              FocusScope.of(context).requestFocus(_hrFocusNode);
                            },
                            style: Theme.of(context).textTheme.bodyMedium,
                            maxLength: 3,
                            decoration: InputDecoration(
                                labelText:
                                    AppLocalizations.of(context)!.diastolic,
                                contentPadding: const EdgeInsets.all(10),
                                errorStyle:
                                    const TextStyle(height: 1, fontSize: 8),
                                errorMaxLines: 2,
                                errorBorder: const UnderlineInputBorder(
                                    // width: 0.0 produces a thin "hairline" border
                                    borderSide: BorderSide(
                                        color: Colors.red, width: 1.0)),
                                border: const UnderlineInputBorder(
                                  // width: 0.0 produces a thin "hairline" border
                                  borderSide: BorderSide(
                                      color: Colors.grey, width: 1.0),
                                ),
                                counterText: ""),
                            keyboardType: TextInputType.number,
                            validator: Validatorless.numbersBetweenInterval(
                                getPropertyValue("diastolic", "min").toDouble(),
                                getPropertyValue("diastolic", "max").toDouble(),
                                AppLocalizations.of(context)!
                                    .valueRangeWithoutField(
                                        getPropertyValue("diastolic", "min"),
                                        getPropertyValue("diastolic", "max"))),
                            onSaved: (val) {
                              if (val!.trim().isNotEmpty) {
                                _diastolic = int.parse(val.trim());
                              }
                            },
                          )),
                    ),
                    const Padding(
                        padding: EdgeInsets.only(left: 6),
                        child: AutoSizeText("mm/hg"))
                  ])))
        ]));
  }

  Widget buildHRWidget() {
    return Padding(
        padding: const EdgeInsets.all(10),
        child: SizedBox(
            width: MediaQuery.of(context).size.width - 50,
            child: Stack(alignment: Alignment.centerLeft, children: [
              SizedBox(
                height: 30,
                width: 70,
                child: Container(
                  decoration: BoxDecoration(
                      border: Border.all(width: 3.0, color: Colors.grey),
                      borderRadius: BorderRadius.circular(21)),
                  child: Semantics(
                    identifier: semantic.S.VITAL_SIGNS_HR_SWITCH,
                    child: AdvancedSwitch(
                      key: K.hrSwitch,
                      controller: _heartrateEnabled,
                      activeColor: Theme.of(context).primaryColor,
                      inactiveColor: Colors.white,
                      borderRadius: const BorderRadius.all(Radius.circular(21)),
                      activeChild: Text('HR',
                          style: Theme.of(context).textTheme.titleSmall),
                      inactiveChild: Text('HR',
                          style: Theme.of(context).textTheme.titleSmall),
                      width: 70.0,
                      height: 30.0,
                      enabled: true,
                      initialValue: _heartrateEnabled.value,
                      thumb: CircleAvatar(
                        backgroundColor: Theme.of(context).indicatorColor,
                        // child: SvgPicture.asset("assets/hr.svg",
                        //     width: 25, height: 25, color: Colors.white)
                      ),
                      disabledOpacity: 0.5,
                      onChanged: (value) {
                        setState(() {
                          _heartrateEnabled.value = value;
                        });
                      },
                    ),
                  ),
                ),
              ),
              Visibility(
                  visible: _heartrateEnabled.value,
                  child: Container(
                      padding: const EdgeInsets.only(left: 100),
                      child: Row(children: [
                        SizedBox(
                            width: 100,
                            height: 50,
                            child: Semantics(
                                identifier: semantic.S.VITAL_SIGNS_HR,
                                child: TextFormField(
                                  key: K.hrField,
                                  focusNode: _hrFocusNode,
                                  controller: _pulserateController,
                                  autovalidateMode:
                                      AutovalidateMode.onUserInteraction,
                                  onFieldSubmitted: (val) {
                                    FocusScope.of(context)
                                        .requestFocus(_tempFocusNode);
                                  },
                                  maxLength: 3,
                                  style: Theme.of(context).textTheme.bodyMedium,
                                  decoration: InputDecoration(
                                      labelText:
                                          AppLocalizations.of(context)!.hr,
                                      contentPadding: const EdgeInsets.all(10),
                                      errorStyle: const TextStyle(
                                          height: 1, fontSize: 8),
                                      errorMaxLines: 2,
                                      errorBorder: const UnderlineInputBorder(
                                        // width: 0.0 produces a thin "hairline" border
                                        borderSide: BorderSide(
                                            color: Colors.grey, width: 1),
                                      ),
                                      border: const UnderlineInputBorder(
                                        // width: 0.0 produces a thin "hairline" border
                                        borderSide: BorderSide(
                                            color: Colors.red, width: 1),
                                      ),
                                      counterText: ""),
                                  keyboardType: TextInputType.number,
                                  validator:
                                      Validatorless.numbersBetweenInterval(
                                          getPropertyValue("heartrate", "min")
                                              .toDouble(),
                                          getPropertyValue("heartrate", "max")
                                              .toDouble(),
                                          AppLocalizations.of(context)!
                                              .valueRangeWithoutField(
                                                  getPropertyValue(
                                                      "heartrate", "min"),
                                                  getPropertyValue(
                                                      "heartrate", "max"))),
                                  onSaved: (val) {
                                    if (val!.trim().isNotEmpty) {
                                      _pulseRate = int.parse(val.trim());
                                    }
                                  },
                                ))),
                        const Padding(
                            padding: EdgeInsets.only(left: 10),
                            child: AutoSizeText("/min"))
                      ])))
            ])));
  }

  Widget buildTemperatureWidget() {
    return Padding(
        padding: const EdgeInsets.only(left: 10),
        child: SizedBox(
            width: MediaQuery.of(context).size.width - 50,
            child: Stack(alignment: Alignment.centerLeft, children: [
              Stack(alignment: Alignment.centerLeft, children: [
                SizedBox(
                  height: 30,
                  width: 70,
                  child: Container(
                    decoration: BoxDecoration(
                        border: Border.all(width: 3.0, color: Colors.grey),
                        borderRadius: BorderRadius.circular(21)),
                    child: AdvancedSwitch(
                      key: K.tempSwitch,
                      controller: _temperatureEnabled,
                      initialValue: _temperatureEnabled.value,
                      activeColor: Theme.of(context).primaryColor,
                      inactiveColor: Colors.white,
                      activeChild: Text('Temp',
                          style: Theme.of(context).textTheme.titleSmall),
                      inactiveChild: Text('Temp',
                          style: Theme.of(context).textTheme.titleSmall),
                      thumb: CircleAvatar(
                        backgroundColor: Theme.of(context).indicatorColor,
                        // child: SvgPicture.asset("assets/temperature.svg",
                        //     width: 25, height: 25, color: Colors.white)
                      ),
                      borderRadius: const BorderRadius.all(Radius.circular(21)),
                      width: 70.0,
                      height: 30.0,
                      enabled: true,
                      disabledOpacity: 0.5,
                      onChanged: (val) {
                        setState(() {
                          _temperatureEnabled.value = val;
                        });
                      },
                    ),
                  ),
                ),
                Visibility(
                    visible: _temperatureEnabled.value,
                    child: Padding(
                        padding: const EdgeInsets.only(left: 80),
                        child: Row(
                          children: [
                            SizedBox(
                              height: 60,
                              width: MediaQuery.of(context).size.width / 2,
                              child: Semantics(
                                  identifier: semantic.S.VITAL_SIGNS_TEMP,
                                  child: Slider(
                                    key: K.tempSlider,
                                    value: _temp!,
                                    onChanged: (val) {
                                      setState(() {
                                        _temp = val;
                                      });
                                    },
                                    activeColor:
                                        Theme.of(context).indicatorColor,
                                    inactiveColor: Colors.grey[100],
                                    divisions: 200,
                                    max: 110.0,
                                    min: 90.0,
                                  )),
                            ),
                            Padding(
                                padding: const EdgeInsets.only(left: 10),
                                child: AutoSizeText("${_temp} F",
                                    key: K.tempValue))
                          ],
                        )))
              ])
            ])));
  }

  Widget buildSpo2Widget() {
    return Padding(
        padding: const EdgeInsets.only(left: 10),
        child: SizedBox(
            width: MediaQuery.of(context).size.width - 50,
            child: Stack(
              alignment: Alignment.centerLeft,
              children: [
                SizedBox(
                  height: 30,
                  width: 70,
                  child: Container(
                    decoration: BoxDecoration(
                        border: Border.all(width: 3.0, color: Colors.grey),
                        borderRadius: BorderRadius.circular(21)),
                    child: Semantics(
                        identifier: semantic.S.VITAL_SIGNS_SPO2,
                        child: AdvancedSwitch(
                            key: K.spo2Switch,
                            controller: _spo2Enabled,
                            initialValue: _spo2Enabled.value,
                            activeColor: Theme.of(context).primaryColor,
                            inactiveColor: Colors.white,
                            activeChild: Text('Spo2',
                                style: Theme.of(context).textTheme.titleSmall),
                            inactiveChild: Text('Spo2',
                                style: Theme.of(context).textTheme.titleSmall),
                            thumb: CircleAvatar(
                              backgroundColor: Theme.of(context).indicatorColor,
                              // child: SvgPicture.asset("assets/spo2.svg",
                              //     width: 25, height: 25, color: Colors.white)
                            ),
                            borderRadius: const BorderRadius.all(
                                const Radius.circular(21)),
                            width: 70.0,
                            height: 30.0,
                            enabled: true,
                            disabledOpacity: 0.5,
                            onChanged: (val) {
                              _spo2Enabled.value = val;
                            })),
                  ),
                ),
                Visibility(
                  visible: _spo2Enabled.value,
                  child: Padding(
                      padding: const EdgeInsets.only(left: 80),
                      child: Row(children: [
                        SizedBox(
                            height: 60,
                            width: MediaQuery.of(context).size.width / 2,
                            child: Slider(
                              key: K.spo2Slider,
                              value: _spo2!.toDouble(),
                              onChanged: (val) {
                                setState(() {
                                  _spo2 = val.ceil();
                                });
                              },
                              activeColor: Theme.of(context).indicatorColor,
                              inactiveColor: Colors.grey[100],
                              divisions: 100,
                              max: 100.0,
                              min: 0,
                            )),
                        Padding(
                            padding: const EdgeInsets.only(left: 10),
                            child: AutoSizeText("${_spo2} %", key: K.spo2Value))
                      ])),
                ),
              ],
            )));
  }

  @override
  Widget build(BuildContext context) {
    return Focus(
        focusNode: FocusNodes.vitalSignsTile,
        child: Card(
            elevation: 0,
            margin: const EdgeInsets.all(0),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            color: Theme.of(context).primaryColor,
            clipBehavior: Clip.antiAlias,
            child: ExpansionTile(
                key: K.vitalSignsTile,
                backgroundColor: Theme.of(context).primaryColor,
                initiallyExpanded:
                    (_mode == Mode.Preview) ? false : _isVitalsExpanded,
                onExpansionChanged: (isExpanded) {
                  _isVitalsExpanded = isExpanded;
                  setState(() {});
                },
                controller: _indicatorsTileController,
                leading: const Icon(Ionicons.pulse_sharp, size: 30),
                title: AutoSizeText(AppLocalizations.of(context)!.vitals,
                    style: Theme.of(context).textTheme.titleLarge),
                trailing: Semantics(
                    identifier: (_isVitalsExpanded)
                        ? semantic.S.VITAL_EXPANDED_LABEL
                        : semantic.S.VITAL_COLLAPSED_LABEL,
                    container: true,
                    child: SizedBox(
                        key: (_isVitalsExpanded)
                            ? K.tileStatusExpanded
                            : K.tileStatusCollapsed,
                        height: 25,
                        width: 25)),
                children: [
                  Container(
                      width: MediaQuery.of(context).size.width,
                      height: 320,
                      color: Colors.white,
                      child: Container(
                          padding: const EdgeInsets.all(5),
                          decoration: BoxDecoration(
                              border: Border.all(
                                  color: Theme.of(context).primaryColor,
                                  width: 4)),
                          child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                Container(
                                    padding: const EdgeInsets.all(5),
                                    child: buildBPIndicatorWidget()),
                                Container(
                                    padding: const EdgeInsets.all(5),
                                    child: buildHRWidget()),
                                Container(
                                    padding: const EdgeInsets.all(5),
                                    child: buildTemperatureWidget()),
                                Container(
                                    padding: const EdgeInsets.all(5),
                                    child: buildSpo2Widget())
                              ])))
                ])));
  }
}
