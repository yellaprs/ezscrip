import 'package:animated_toggle_switch/animated_toggle_switch.dart';
import 'package:ezscrip/consultation/model/direction.dart';
import 'package:ezscrip/consultation/model/durationType.dart';
import 'package:ezscrip/consultation/model/frequencyType.dart';
import 'package:ezscrip/consultation/model/medschedule.dart';
import 'package:ezscrip/consultation/model/preparation.dart';
import 'package:ezscrip/consultation/model/time.dart';
import 'package:ezscrip/consultation/model/unit.dart';
import 'package:ezscrip/resources/resources.dart';
import 'package:ezscrip/util/focus_nodes.dart';
import 'package:ezscrip/util/keys.dart';
import 'package:ezscrip/util/ui_constants.dart';
import 'package:dots_indicator/dots_indicator.dart';
import 'package:enum_to_string/enum_to_string.dart';
import 'package:animated_custom_dropdown/custom_dropdown.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:flutter_vector_icons/flutter_vector_icons.dart';
import 'package:no_context_navigation/no_context_navigation.dart';
import 'package:toggle_switch/toggle_switch.dart';
import 'package:validatorless/validatorless.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:auto_size_text/auto_size_text.dart';
import '../../util/mode.dart';
import '../../util/semantics.dart' as semantic;
import '../model/medStatus.dart';
import 'package:flutter_spinbox/material.dart';

class DrugInfo {
  String medName;
  Preparation preparation;
  Unit unit;
  int dosage;
  bool isHalf;

  DrugInfo(this.medName, this.preparation, this.unit, this.isHalf, this.dosage);
}

class SheduleInfo {
  FrequencyType frequency;
  int duration;
  DurationType durationType;
  List<Time> times;
  String direction;

  SheduleInfo(this.frequency, this.duration, this.durationType, this.times,
      this.direction);
}

class PreparationFilter with CustomDropdownListFilter {
  final Preparation preparation;

  const PreparationFilter(this.preparation);

  @override
  String toString() {
    return preparation.toString();
  }

  @override
  bool filter(String query) {
    return EnumToString.convertToString(preparation)
        .toLowerCase()
        .contains(query.replaceAll(RegExp(r"\s+\b|\b\s"), "").toLowerCase());
  }

  @override
  bool operator ==(Object other) {
    if (other is PreparationFilter) {
      return preparation == other.preparation;
    }
    return false;
  }

  @override
  int get hashCode => preparation.hashCode;
}

class UnitFilter with CustomDropdownListFilter {
  final Unit unit;

  const UnitFilter(this.unit);

  @override
  String toString() {
    return unit.toString();
  }

  @override
  bool filter(String query) {
    return EnumToString.convertToString(unit)
        .toLowerCase()
        .contains(query.replaceAll(RegExp(r"\s+\b|\b\s"), "").toLowerCase());
  }

  @override
  bool operator ==(Object other) {
    if (other is UnitFilter) {
      return unit == other.unit;
    }
    return false;
  }

  @override
  int get hashCode => unit.hashCode;
}

class FrequencyTypeFilter with CustomDropdownListFilter {
  final FrequencyType frequencyType;

  const FrequencyTypeFilter(this.frequencyType);

  @override
  String toString() {
    return frequencyType.toString();
  }

  @override
  bool filter(String query) {
    return EnumToString.convertToString(frequencyType)
        .toLowerCase()
        .replaceAll("_", "")
        .contains(query
            .replaceAll(RegExp(r"\p{P}", unicode: true), "")
            .replaceAll(RegExp(r"\s+\b|\s"), "")
            .toLowerCase());
  }

  @override
  bool operator ==(Object other) {
    if (other is FrequencyTypeFilter) {
      return frequencyType == other.frequencyType;
    }
    return false;
  }

  @override
  int get hashCode => frequencyType.hashCode;
}

class DosageValidator {
  static String? isValid(String errMessage, String dosage, int min, int max) {
    bool isValid = true;
    if (int.parse(dosage) < min || int.parse(dosage) > max) isValid = false;

    return (isValid) ? null : errMessage;
  }

  static String? isRequired(String errMgs, bool isEmpty) {
    return (isEmpty) ? errMgs : null;
  }
}

class DurationTypeValidator {
  static String? isRequired(String errMsg, bool isEmpty) {
    return (isEmpty) ? errMsg : null;
  }
}

class FrequencyTypeValidator {
  static String? isValid(
      String errMessage, FrequencyType type, List<Time> times) {
    bool isValid = true;

    switch (type) {
      case FrequencyType.Bid_2XDay:
        if (times.isNotEmpty && times.length != 2) isValid = false;
        break;
      case FrequencyType.Qd_1XDay:
        if (times.isNotEmpty && times.length != 1) isValid = false;
        break;
      case FrequencyType.Qpm_1XNight:
        if (times.isNotEmpty && times.length != 1) isValid = false;
        break;
      case FrequencyType.Qod_AlternateDays:
        if (times.isNotEmpty && times.length != 1) isValid = false;
        break;
      case FrequencyType.Qam_1XDayMorning:
        if (times.isNotEmpty && times.length != 1) isValid = false;
        break;
      case FrequencyType.Hs_1XBedTime:
        if (times.isNotEmpty && times.length != 1) isValid = false;

        break;
      case FrequencyType.Tw_TwiceAWeek:
        if (times.isNotEmpty && times.length != 1) isValid = false;
        break;
      case FrequencyType.QH_EveryHour:
        if (times.isNotEmpty && times.length != 5) isValid = false;
        break;

      case FrequencyType.Tid_3XDay:
        if (times.isNotEmpty && times.length != 3) isValid = false;
        break;
      case FrequencyType.Qid_4XDay:
        if (times.isNotEmpty && times.length != 4) isValid = false;
        break;
      case FrequencyType.Weekly_OnceWeekly:
        if (times.isNotEmpty && times.length != 1) isValid = false;
        break;
    }

    return (isValid ? null : errMessage);
  }

  static String? isRequired(String errMsg, bool isEmpty) {
    return (isEmpty) ? errMsg : null;
  }
}

class UnitsValidator {
  static String? isValid(
      String errMessage, Unit value, Preparation preparation) {
    bool isValid = true;

    switch (value) {
      case Unit.drops:
        {
          if (preparation != Preparation.EarDrops &&
              preparation != Preparation.EyeDrops &&
              preparation != Preparation.NasalDrops) {
            isValid = false;
          }
          break;
        }

      case Unit.ml:
        {
          if (preparation != Preparation.InjectionIm &&
              preparation != Preparation.InjectionIv) {
            isValid = false;
          }
          break;
        }

      case Unit.caps:
        {
          if (preparation != Preparation.Capsule) {
            isValid = false;
          }
          break;
        }

      case Unit.tabs:
        {
          if (preparation != Preparation.Tablet) {
            isValid = false;
          }
          break;
        }

      case Unit.tsp:
        {
          if (preparation != Preparation.OralSyrup) {
            isValid = false;
          }
          break;
        }
      case Unit.cc:
        {
          if (preparation != Preparation.InjectionIm &&
              preparation != Preparation.InjectionIv) {
            isValid = false;
          }
          break;
        }
    }
    return (isValid ? null : errMessage);
  }

  static String? isRequired(String errMessage, bool isEmpty) {
    return (isEmpty) ? errMessage : null;
  }
}

class PreparationValidator {
  static String? isValid(String errMessage, Preparation value, Unit unit) {
    bool isValueValid = true;

    switch (value) {
      case Preparation.Capsule:
        {
          if (unit != Unit.caps) {
            isValueValid = false;
          }
          break;
        }

      case Preparation.Tablet:
        {
          if (unit != Unit.tabs) {
            isValueValid = false;
          }
          break;
        }

      case Preparation.EarDrops:
        {
          if (unit != Unit.drops) {
            isValueValid = false;
          }
          break;
        }

      case Preparation.EyeDrops:
        {
          if (unit != Unit.drops) {
            isValueValid = false;
          }
          break;
        }

      case Preparation.InjectionIm:
        {
          if (unit != Unit.ml && unit != Unit.cc) {
            isValueValid = false;
          }
          break;
        }
      case Preparation.InjectionIv:
        {
          if (unit != Unit.ml && unit != Unit.cc) {
            isValueValid = false;
          }
          break;
        }

      case Preparation.OralSyrup:
        {
          if (unit != Unit.tsp) {
            isValueValid = false;
          }
          break;
        }

      case Preparation.NasalDrops:
        {
          if (unit != Unit.drops) {
            isValueValid = false;
          }
          break;
        }

      case Preparation.Ointment:
        {
          if (unit != Unit.ml) {
            isValueValid = false;
          }
          break;
        }
    }
    return (isValueValid) ? null : errMessage;
  }

  static String? isRequired(String errMsg, bool isEmpty) {
    return (isEmpty) ? errMsg : null;
  }
}

class AddMedicationPage extends StatefulWidget {
  final int pageIndex;
  final Mode mode;
  final Map<String, dynamic> propertiesMap;

  const AddMedicationPage(
      {required this.mode,
      required this.propertiesMap,
      this.pageIndex = 0,
      Key key = K.addMedicationPage})
      : super(key: key);
  _AddMedicationPageState createState() =>
      _AddMedicationPageState(mode, propertiesMap, pageIndex);
}

class _AddMedicationPageState extends State<AddMedicationPage> {
  late GlobalKey<FormState> _drugInfoformKey;
  late GlobalKey<FormState> _scheduleformKey;
  late String _medName;
  late int _strength;
  late int _dosage;
  late bool _isHalf;
  late Unit _unit;
  late FrequencyType _frequencyType;
  late int _frequency;
  late DurationType _durationType;
  late int _duration;
  late Preparation _preparation;
  Direction? _directions;
  late List<Time> _times;
  int _currentPageIndex;

  late bool _isDrugInfoValid;
  late bool _isScheduleValid;

  Mode _mode;
  late MedStatus _status;

  late TextEditingController _medicineController,
      _instructionsController,
      _strengthController,
      _durationController,
      _dosageController;

  late PageController _pageContoller;

  late List<PreparationFilter> _preparationList;
  late List<UnitFilter> _unitList;
  late List<FrequencyTypeFilter> _frequencyList;

  late PreparationFilter _initialPreparationFilter;
  late UnitFilter _initialUnitFilter;
  late FrequencyTypeFilter _initialFrequencyFilter;
  late Map<String, dynamic> _propertiesMap;

  _AddMedicationPageState(
      this._mode, this._propertiesMap, this._currentPageIndex);

  bool get wantKeepAlive => true;

  @override
  void initState() {
    _drugInfoformKey = GlobalKey<FormState>();
    _scheduleformKey = GlobalKey<FormState>();
    _medicineController = TextEditingController();
    _medicineController.text = "";
    _instructionsController = TextEditingController();
    _instructionsController.text = "";
    _dosageController = TextEditingController();
    _dosageController.text = '0';
    _isHalf = false;
    _strengthController = TextEditingController();
    _strengthController.text = "";
    _dosage = 1;
    _unit = Unit.tabs;
    _unitList = Unit.values.map((e) => UnitFilter(e)).toList();
    _initialUnitFilter =
        _unitList.firstWhere((element) => element.unit == _unit);
    _preparation = Preparation.Tablet;
    _preparationList =
        Preparation.values.map((e) => PreparationFilter(e)).toList();
    _frequencyType = FrequencyType.Qd_1XDay;
    _frequencyList =
        FrequencyType.values.map((e) => FrequencyTypeFilter(e)).toList();
    _durationType = DurationType.Day;

    _initialPreparationFilter = _preparationList
        .firstWhere((element) => element.preparation == _preparation);

    _initialFrequencyFilter = _frequencyList
        .firstWhere((element) => element.frequencyType == _frequencyType);

    _duration = 1;
    _durationController = TextEditingController();
    _durationController.text = _duration.toString();
    _isDrugInfoValid = true;
    _isScheduleValid = true;
    _status = MedStatus.New;
    _times = [];
    _directions = Direction.NotApplicable;
    _pageContoller = PageController();
    super.initState();
  }

  Widget getPreparationIcon(Preparation preparation) {
    Widget icon = const Icon(Fontisto.pills, size: 20);

    switch (preparation) {
      case Preparation.Capsule:
        icon = const Icon(MaterialCommunityIcons.pill, size: 15);
        break;
      case Preparation.Tablet:
        icon = const Icon(MaterialCommunityIcons.pill, size: 15);
        break;
      case Preparation.InjectionIm:
        icon = const Icon(Fontisto.injection_syringe, size: 15);
        break;
      case Preparation.InjectionIv:
        icon = const Icon(Fontisto.injection_syringe, size: 15);
        break;
      case Preparation.EarDrops:
        icon = const Icon(FontAwesome.eyedropper, size: 15);
        break;
      case Preparation.EyeDrops:
        icon = const Icon(FontAwesome.eyedropper, size: 15);
        break;
      case Preparation.NasalDrops:
        icon = const Icon(FontAwesome.eyedropper, size: 20);
        break;
      case Preparation.Ointment:
        icon = SvgPicture.asset(Images.ointment, height: 15, width: 15);
        break;
      case Preparation.OralSyrup:
        icon = const Icon(MaterialCommunityIcons.bottle_tonic_plus, size: 20);
        break;
    }
    return icon;
  }

  Widget getUnitIcon(Unit unit) {
    Widget icon = const Icon(Fontisto.pills, size: 15);

    switch (unit) {
      case Unit.caps:
        icon = const Icon(MaterialCommunityIcons.pill, size: 15);
        break;
      case Unit.tabs:
        icon = const Icon(MaterialCommunityIcons.pill, size: 15);
        break;
      case Unit.ml:
        icon = const Icon(MaterialCommunityIcons.cup_water, size: 15);
        break;
      case Unit.tsp:
        icon = const Icon(FontAwesome.spoon, size: 15);
        break;
      case Unit.drops:
        icon = const Icon(Entypo.drop, size: 20);
        break;
      case Unit.cc:
        icon = const Icon(MaterialCommunityIcons.cup_water, size: 15);
        break;
    }
    return icon;
  }

  Widget getTimeIcon(Time time, bool isSelected) {
    Icon icon;
    switch (time) {
      case Time.daybreak:
        icon = Icon(Feather.sunrise,
            size: 20, color: (isSelected) ? Colors.white : Colors.black);
        break;
      case Time.morning:
        icon = Icon(Fontisto.day_sunny,
            size: 20, color: (isSelected) ? Colors.white : Colors.black);
        break;
      case Time.afternoon:
        icon = Icon(Fontisto.day_sunny,
            size: 20, color: (isSelected) ? Colors.white : Colors.black);
        break;
      case Time.evening:
        icon = Icon(Feather.sunset,
            size: 20, color: (isSelected) ? Colors.white : Colors.black);
        break;
      case Time.night:
        icon = Icon(Fontisto.night_clear,
            size: 20, color: (isSelected) ? Colors.white : Colors.black);
        break;
    }

    return icon;
  }

  String getSemanticTimeLabel(Time time) {
    String label;

    switch (time) {
      case Time.daybreak:
        label = semantic.S.ADD_MEDICATION_DRUG_TIME_DAYBREAK;
        break;
      case Time.morning:
        label = semantic.S.ADD_MEDICATION_DRUG_TIME_MORNING;
        break;
      case Time.afternoon:
        label = semantic.S.ADD_MEDICATION_DRUG_TIME_AFTERNOON;
        break;
      case Time.evening:
        label = semantic.S.ADD_MEDICATION_DRUG_TIME_EVENING;
        break;
      case Time.night:
        label = semantic.S.ADD_MEDICATION_DRUG_TIME_NIGHT;
        break;
    }

    return label;
  }

  String getSemanticDirectionLabel(Direction direction) {
    String label;

    switch (direction) {
      case Direction.Fasting:
        label = semantic.S.ADD_MEDCIATION_DRUG_DIRECTION_FASTING;
        break;
      case Direction.BeforeMeal:
        label = semantic.S.ADD_MEDICATION_DRUG_DIRECTION_PRE_MEALS;
        break;
      case Direction.PostMeal:
        label = semantic.S.ADD_MEDICATION_DRUG_DIRECTION_POST_MEALS;
        break;
      case Direction.SOS:
        label = semantic.S.ADD_MEDICATION_DRUG_DIRECTION_SOS;
      case Direction.NotApplicable:
        label = semantic.S.ADD_MEDICATION_DRUG_DIRECTION_NOT_APPLICABLE;
    }

    return label;
  }

  Widget getTimeChecked(Time time) {
    return _times.contains(time)
        ? const Icon(Icons.check,
            size: 10,
            color: Colors.white,
            semanticLabel: semantic.S.ADD_MEDICATION_TIME_SELECTED)
        : SizedBox(width: 10, child: Container());
  }

  Widget getDirectionChecked(Direction direction) {
    return (_directions == direction)
        ? const Icon(Icons.check, size: 10, color: Colors.white)
        : SizedBox(width: 10, child: Container());
  }

  Widget buildTimeWidget(Orientation orientation) {
    List<Widget> widgets = [];
    widgets.addAll(Time.values
        .map((time) => Semantics(
              label: getSemanticTimeLabel(time),
              container: true,
              child: ChoiceChip(
                  key: Key(EnumToString.convertToString(time, camelCase: true)
                      .toLowerCase()),
                  backgroundColor: Theme.of(context).primaryColor,
                  avatar: getTimeIcon(time, (_times.contains(time))),
                  labelPadding:
                      const EdgeInsets.symmetric(horizontal: 2, vertical: 2),
                  padding: const EdgeInsets.all(5),
                  label: SizedBox(
                    height: 18,
                    width: 65,
                    child: Stack(children: [
                      AutoSizeText(
                        EnumToString.convertToString(time, camelCase: true)
                            .toLowerCase(),
                      ),
                      Align(
                          alignment: Alignment.topRight,
                          child: Padding(
                              padding:
                                  const EdgeInsets.only(left: 2, bottom: 5),
                              child: getTimeChecked(time)))
                    ]),
                  ),
                  showCheckmark: false,
                  selected: (_times.isNotEmpty)
                      ? (_times.any((element) =>
                          EnumToString.convertToString(element, camelCase: true)
                              .toLowerCase() ==
                          EnumToString.convertToString(time, camelCase: true)
                              .toLowerCase()))
                      : false,
                  selectedColor: Colors.brown,
                  labelStyle: (_times.contains(time))
                      ? const TextStyle(color: Colors.white)
                      : const TextStyle(color: Colors.black),
                  onSelected: (_mode == Mode.Preview)
                      ? null
                      : (val) {
                          if (val) {
                            _times.add(time);
                          } else {
                            _times.remove(time);
                          }
                          setState(() {});
                        }),
            ))
        .toList());

    return Focus(
        focusNode: FocusNodes.timeChoiceChip,
        child: Container(
            padding: const EdgeInsets.all(5),
            height: (orientation == Orientation.portrait)
                ? MediaQuery.of(context).size.height * 0.170
                : MediaQuery.of(context).size.height * 0.10,
            width: MediaQuery.of(context).size.width * 0.9,
            child: Stack(alignment: Alignment.topLeft, children: [
              Text('Time', style: Theme.of(context).textTheme.titleSmall),
              Padding(
                  padding: const EdgeInsets.only(top: 20),
                  child: Wrap(
                      key: K.timeChoiceChip,
                      spacing: 4,
                      runSpacing: 2,
                      children: widgets))
            ])));
  }

  Widget buildUnitsWidget(Orientation orientation) {
    return Container(
        width: MediaQuery.of(context).size.width * 0.6,
        alignment: Alignment.center,
        height: MediaQuery.of(context).size.height * 0.125,
        child: Stack(children: [
          Text(AppLocalizations.of(context)!.unit,
              style: Theme.of(context).textTheme.titleSmall),
          Padding(
              padding: const EdgeInsets.only(top: 20),
              child: Focus(
                  focusNode: FocusNodes.unitDropDown,
                  child: CustomDropdown<UnitFilter>.search(
                      hintText: AppLocalizations.of(context)!.unit,
                      key: K.unitDropDown,
                      decoration: CustomDropdownDecoration(
                          closedFillColor: Theme.of(context).primaryColor,
                          closedBorder: Border.all(color: Colors.black),
                          expandedFillColor: Theme.of(context).primaryColor,
                          headerStyle: Theme.of(context).textTheme.titleSmall,
                          errorStyle: const TextStyle(fontSize: 10),
                          closedErrorBorder: Border.all(color: Colors.red)),
                      initialItem: _initialUnitFilter,
                      headerBuilder: (context, unit, displayHeader) {
                        return Stack(
                          alignment: Alignment.centerLeft,
                          children: [
                            getUnitIcon(unit.unit),
                            Padding(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 30, vertical: 10),
                                child: AutoSizeText(
                                    EnumToString.convertToString(unit.unit,
                                            camelCase: true)
                                        .toLowerCase()))
                          ],
                        );
                      },
                      validator: (val) {
                        String? isValid = UnitsValidator.isRequired(
                            AppLocalizations.of(context)!
                                .isRequired(AppLocalizations.of(context)!.unit),
                            (val == null));

                        if (isValid?.isEmpty ?? true) {
                          Unit unit = Unit.values.firstWhere(
                            (unit) => (unit
                                    .toString()
                                    .substring(unit.toString().indexOf(".") + 1)
                                    .toLowerCase() ==
                                val!.unit
                                    .toString()
                                    .substring(val.toString().indexOf(".") + 1)
                                    .toLowerCase()),
                          );

                          isValid = UnitsValidator.isValid(
                              AppLocalizations.of(context)!.invalidCombination(
                                  AppLocalizations.of(context)!.preparation,
                                  AppLocalizations.of(context)!.unit),
                              unit,
                              _preparation);
                        }

                        return isValid;
                      },
                      listItemBuilder: (context, unit, selected, onTap) {
                        return Semantics(
                            identifier: semantic.S.ADD_MEDICATION_UNIT_OPTION,
                            child: Container(
                                padding: const EdgeInsets.all(3),
                                child: ListTile(
                                    leading: getUnitIcon(unit.unit),
                                    title: Padding(
                                        padding:
                                            const EdgeInsets.only(left: 20),
                                        child: AutoSizeText(
                                            EnumToString.convertToString(
                                                    unit.unit,
                                                    camelCase: true)
                                                .toLowerCase())))));
                      },
                      items: Unit.values.map((e) => UnitFilter(e)).toList(),
                      onChanged: (_mode == Mode.Preview)
                          ? null
                          : (val) {
                              _unit = val!.unit;
                              setState(() {});
                            })))
        ]));
  }

  Widget buildDurationWidget(Orientation orientation) {
    return Container(
        padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 5),
        width: (orientation == Orientation.portrait)
            ? MediaQuery.of(context).size.width * 0.9
            : MediaQuery.of(context).size.width * 0.5,
        height: (orientation == Orientation.portrait)
            ? MediaQuery.of(context).size.height * 0.12
            : 65,
        //padding: const EdgeInsets.only(left: 10),
        child: Stack(alignment: Alignment.topLeft, children: [
          Text(AppLocalizations.of(context)!.duration,
              style: Theme.of(context).textTheme.titleSmall),
          Padding(
              padding: const EdgeInsets.only(top: 20),
              child: Focus(
                  child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                    SizedBox(
                        width: MediaQuery.of(context).size.width * 0.35,
                        // height: MediaQuery.of(context).size.width * 0.125,
                        child: Semantics(
                          label: semantic.S.ADD_MEDICATION_DRUG_DURATION_FIELD,
                          container: true,
                          child: SpinBox(
                            key: K.durationSpinbox,
                            focusNode: FocusNodes.durationAutoSizeTextField,
                            textAlign: TextAlign.center,
                            decoration: InputDecoration(
                              contentPadding: const EdgeInsets.all(10),
                              //label: Text(AppLocalizations.of(context)!.duration),
                              //labelStyle: Theme.of(context).textTheme.titleSmall,
                              border: UnderlineInputBorder(
                                borderRadius: BorderRadius.circular(10.0),
                              ),
                            ),
                            incrementIcon: const Icon(key: K.addDays, Icons.add, size: 25),
                            decrementIcon: const Icon(key: K.subtractDays, Icons.minimize, size: 25),
                            min: 1,
                            max: 10,
                            value: _duration.toDouble(),
                            onChanged: (value) {
                              _duration = value.ceil();
                              setState(() {});
                            },
                            validator: Validatorless.multiple([
                              Validatorless.required(
                                  AppLocalizations.of(context)!.isRequired(
                                      AppLocalizations.of(context)!.duration)),
                              Validatorless.numbersBetweenInterval(
                                  1,
                                  100,
                                  AppLocalizations.of(context)!
                                      .valueRangeWithoutField(1, 100)),
                            ]),
                          ),
                        )),
                    SizedBox(
                        width: MediaQuery.of(context).size.width * 0.45,
                        //height: MediaQuery.of(context).size.height * 0.125,
                        child: Padding(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 5, vertical: 5),
                            child: Semantics(
                                container: true,
                                identifier: semantic.S
                                    .ADD_MEDICATION_DRUG_DURATION_TYPE_DROPDWON,
                                child: CustomDropdown<DurationType>.search(
                                  key: K.durationTypeField,
                                  hintText:
                                      AppLocalizations.of(context)!.duration,
                                  initialItem: _durationType,
                                  decoration: CustomDropdownDecoration(
                                      closedFillColor:
                                          Theme.of(context).primaryColor,
                                      closedBorder:
                                          Border.all(color: Colors.black),
                                      errorStyle:
                                          const TextStyle(color: Colors.red),
                                      expandedFillColor:
                                          Theme.of(context).primaryColor,
                                      headerStyle: Theme.of(context)
                                          .textTheme
                                          .titleSmall,
                                      closedErrorBorder:
                                          Border.all(color: Colors.red)),
                                  headerBuilder:
                                      (context, durationType, displayHeader) {
                                    return Semantics(
                                        container: true,
                                        identifier: semantic.S
                                            .ADD_MEDICATION_DURATION_TYPE_OPTION,
                                        child: AutoSizeText(
                                            EnumToString.convertToString(
                                                durationType,
                                                camelCase: true)));
                                  },
                                  validator: (val) {
                                    String? isValid =
                                        DurationTypeValidator.isRequired(
                                            AppLocalizations.of(context)!
                                                .isRequired(AppLocalizations.of(
                                                        context)!
                                                    .duration),
                                            (val == null));
                                    return isValid;
                                  },
                                  items: DurationType.values,
                                  listItemBuilder:
                                      (context, durationType, selected, onTap) {
                                    return Container(
                                        alignment: Alignment.centerLeft,
                                        padding: const EdgeInsets.all(3),
                                        child: ListTile(
                                            title: AutoSizeText(
                                                EnumToString.convertToString(
                                                    durationType,
                                                    camelCase: true))));
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
        ]));
  }

  Widget buildRouteWidget(Orientation orientation) {
    return Container(
        padding: const EdgeInsets.all(10),
        height: MediaQuery.of(context).size.height * 0.175,
        width: MediaQuery.of(context).size.width * 0.6,
        alignment: Alignment.center,
        constraints:
            BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.6),
        child: Stack(alignment: Alignment.topLeft, children: [
          Text(
            AppLocalizations.of(context)!.preparation,
            style: Theme.of(context).textTheme.titleSmall,
          ),
          Padding(
              padding: const EdgeInsets.only(top: 20),
              child: Focus(
                  focusNode: FocusNodes.routeDropDown,
                  child: Semantics(
                      label:
                          semantic.S.ADD_MEDICATION_DRUG_PREPARATION_DROPDOWN,
                      container: true,
                      child: CustomDropdown<PreparationFilter>.search(
                        key: K.routeDropDown,
                        hintText: AppLocalizations.of(context)!.preparation,
                        excludeSelected: false,
                        initialItem: _initialPreparationFilter,
                        decoration: CustomDropdownDecoration(
                            closedFillColor: Theme.of(context).primaryColor,
                            closedBorder: Border.all(color: Colors.black),
                            expandedFillColor: Theme.of(context).primaryColor,
                            headerStyle: Theme.of(context).textTheme.titleSmall,
                            errorStyle: const TextStyle(fontSize: 10),
                            closedErrorBorder: Border.all(color: Colors.red)),
                        validator: (val) {
                          String? isValid;

                          isValid = PreparationValidator.isRequired(
                              AppLocalizations.of(context)!.isRequired(
                                  AppLocalizations.of(context)!.preparation),
                              (val == null));
                          if (isValid?.isEmpty ?? true) {
                            Preparation preparation =
                                Preparation.values.firstWhere(
                              (element) =>
                                  element
                                      .toString()
                                      .substring(
                                          element.toString().indexOf(".") + 1)
                                      .toLowerCase() ==
                                  val!.preparation
                                      .toString()
                                      .substring(
                                          val.toString().indexOf(".") + 1)
                                      .toLowerCase(),
                            );

                            isValid = PreparationValidator.isValid(
                                AppLocalizations.of(context)!
                                    .invalidCombination(
                                        AppLocalizations.of(context)!
                                            .preparation,
                                        AppLocalizations.of(context)!.unit),
                                preparation,
                                _unit);
                          }

                          return isValid;
                        },
                        headerBuilder: (context, preparation, displayHeader) {
                          return Stack(
                              alignment: Alignment.centerLeft,
                              children: [
                                getPreparationIcon(preparation.preparation),
                                Padding(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 30, vertical: 5),
                                    child: Text(EnumToString.convertToString(
                                            preparation.preparation,
                                            camelCase: true)
                                        .toLowerCase()))
                              ]);
                        },
                        items: Preparation.values
                            .map((e) => PreparationFilter(e))
                            .toList(),
                        listItemBuilder:
                            (context, preparation, selected, onTap) {
                          return ListTile(
                              leading:
                                  getPreparationIcon(preparation.preparation),
                              title: Text(EnumToString.convertToString(
                                      preparation.preparation,
                                      camelCase: true)
                                  .toLowerCase()));
                        },
                        onChanged: (_mode == Mode.Preview)
                            ? null
                            : (val) {
                                _preparation = val!.preparation;
                                setState(() {});
                              },
                      ))))
        ]));
  }

  Widget buildDirectionWidget(Orientation orientation) {
    List<Widget> widgets = [];

    List<Direction> reducedList = [];

    reducedList.addAll(Direction.values);
    reducedList
        .retainWhere((direction) => direction != Direction.NotApplicable);

    widgets = reducedList
        .map((direction) => Semantics(
            label: getSemanticDirectionLabel(direction),
            container: true,
            child: ChoiceChip(
                labelPadding: const EdgeInsets.all(2),
                key: Key(
                    EnumToString.convertToString(direction, camelCase: true)
                        .toLowerCase()),
                backgroundColor: Theme.of(context).primaryColor,
                label: SizedBox(
                  width: 90,
                  height: 20,
                  child: Stack(children: [
                    Text(
                        "${EnumToString.convertToString(direction, camelCase: true)}"),
                    Align(
                        alignment: Alignment.topRight,
                        child: Padding(
                            padding: const EdgeInsets.only(left: 2, bottom: 4),
                            child: getDirectionChecked(direction)))
                  ]),
                ),
                selected: (_directions != null)
                    ? (EnumToString.convertToString(_directions,
                                camelCase: true)
                            .toLowerCase() ==
                        EnumToString.convertToString(direction, camelCase: true)
                            .toLowerCase())
                    : false,
                selectedColor: Colors.brown,
                labelStyle: (_directions == direction)
                    ? const TextStyle(color: Colors.white)
                    : const TextStyle(color: Colors.black),
                showCheckmark: false,
                onSelected: (_mode == Mode.Preview)
                    ? null
                    : (val) {
                        if (val) {
                          setState(() {
                            _directions = direction;
                          });
                        }
                      })))
        .toList();
    return Container(
        padding: const EdgeInsets.all(2),
        width: MediaQuery.of(context).size.width * 0.95,
        height: (orientation == Orientation.portrait)
            ? MediaQuery.of(context).size.height * 0.125
            : MediaQuery.of(context).size.height * 0.3,
        child: Stack(alignment: Alignment.topLeft, children: [
          Text(AppLocalizations.of(context)!.directions,
              style: Theme.of(context).textTheme.titleSmall),
          Padding(
              padding: const EdgeInsets.only(top: 15),
              child: Focus(
                  child: Wrap(
                key: K.directionsChoiceList,
                spacing: 5.0,
                runSpacing: 0,
                children: widgets,
              )))
        ]));
  }

  Widget buildFrequencyWidget(Orientation orientation) {
    return Container(
        padding: const EdgeInsets.all(4),
        width: (orientation == Orientation.portrait)
            ? (MediaQuery.of(context).size.width * 0.7 - 30)
            : (MediaQuery.of(context).size.width * 0.35),
        height: (orientation == Orientation.portrait)
            ? MediaQuery.of(context).size.height * 0.125
            : 65,
        child: Stack(children: [
          Text(AppLocalizations.of(context)!.frequency,
              style: Theme.of(context).textTheme.titleSmall),
          Padding(
              padding: const EdgeInsets.only(top: 20),
              child: Focus(
                  focusNode: FocusNodes.frequencyDropDowButton,
                  child: Semantics(
                    label: semantic.S.ADD_MEDICATION_DRUG_FREQUENCY_DROPDOWN,
                    container: true,
                    child: CustomDropdown<FrequencyTypeFilter>.search(
                        hintText: AppLocalizations.of(context)!.frequency,
                        key: K.frequencyDropDownButton,
                        decoration: CustomDropdownDecoration(
                            closedFillColor: Theme.of(context).primaryColor,
                            closedBorder: Border.all(color: Colors.black),
                            expandedFillColor: Theme.of(context).primaryColor,
                            headerStyle: Theme.of(context).textTheme.titleSmall,
                            closedErrorBorder: Border.all(color: Colors.red)),
                        initialItem: _initialFrequencyFilter,
                        headerBuilder: (context, frequencyType,
                                displayHeader) =>
                            AutoSizeText(
                                "${frequencyType.frequencyType.toString().substring(frequencyType.frequencyType.toString().indexOf(".") + 1).replaceAll("_", " (")})"),
                        items: FrequencyType.values
                            .map((e) => FrequencyTypeFilter(e))
                            .toList(),
                        listItemBuilder:
                            (context, frequencyType, selected, onTap) {
                          return Container(
                              padding: const EdgeInsets.all(2),
                              child: ListTile(
                                  title: AutoSizeText(
                                      "${frequencyType.frequencyType.toString().substring(frequencyType.frequencyType.toString().indexOf(".") + 1).replaceAll("_", " (")})")));
                        },
                        validator: (val) {
                          String? isValid;

                          isValid = FrequencyTypeValidator.isRequired(
                              AppLocalizations.of(context)!.preparation,
                              (val == null));

                          if (isValid?.isEmpty ?? true) {
                            FrequencyType frequencyType = FrequencyType.values
                                .firstWhere((frequencyType) =>
                                    EnumToString.convertToString(frequencyType,
                                            camelCase: true)
                                        .toLowerCase() ==
                                    EnumToString.convertToString(
                                            val!.frequencyType,
                                            camelCase: true)
                                        .toLowerCase());

                            isValid = FrequencyTypeValidator.isValid(
                                "Invalid Combination of Frequency and Medication Time",
                                frequencyType,
                                _times);
                          }

                          return isValid;
                        },
                        onChanged: (_mode == Mode.Preview)
                            ? null
                            : (selectedValue) {
                                FrequencyType frequencyType =
                                    FrequencyType.values.firstWhere((value) =>
                                        EnumToString.convertToString(value,
                                                camelCase: true)
                                            .toLowerCase() ==
                                        EnumToString.convertToString(
                                                selectedValue!.frequencyType,
                                                camelCase: true)
                                            .toLowerCase());

                                if (frequencyType ==
                                    FrequencyType.Hs_1XBedTime) {
                                  _times.clear();
                                  _times.add(Time.night);
                                } else if (frequencyType ==
                                    FrequencyType.Qam_1XDayMorning) {
                                  _times.clear();
                                  _times.add(Time.morning);
                                } else if (frequencyType ==
                                    FrequencyType.Qpm_1XNight) {
                                  _times.clear();
                                  _times.add(Time.night);
                                }

                                setState(() {
                                  _frequencyType = frequencyType;
                                });
                              }),
                  )))
        ]));
  }

  Widget buildMedNameWidget(Orientation orientation) {
    return Focus(
        focusNode: FocusNodes.medicationNameAutoSizeTextField,
        child: Container(
            width: (orientation == Orientation.portrait)
                ? MediaQuery.of(context).size.width * 0.75
                : MediaQuery.of(context).size.width * 0.4,
            height: MediaQuery.of(context).size.height * 0.1,
            alignment: Alignment.center,
            child: Padding(
                padding: const EdgeInsets.all(5),
                child: Semantics(
                    identifier: semantic.S.ADD_MEDICATION_DRUG_FIELD,
                    child: TextFormField(
                        key: K.medicationNameAutoSizeTextField,
                        readOnly: (_mode == Mode.Preview) ? true : false,
                        autovalidateMode: AutovalidateMode.onUserInteraction,
                        decoration: InputDecoration(
                            errorMaxLines: 2,
                            errorStyle: const TextStyle(height: 1, fontSize: 8),
                            errorBorder: const UnderlineInputBorder(
                              // width: 0.0 produces a thin "hairline" border
                              borderSide:
                                  BorderSide(color: Colors.red, width: 1.0),
                            ),
                            border: UnderlineInputBorder(
                                borderSide: const BorderSide(
                                    color: Colors.grey, width: 1.0),
                                borderRadius: BorderRadius.circular(9)),
                            labelText:
                                "${AppLocalizations.of(context)!.drug} ${AppLocalizations.of(context)!.name}",
                            labelStyle: Theme.of(context).textTheme.bodyMedium),
                        controller: _medicineController,
                        validator: Validatorless.multiple([
                          Validatorless.max(30,
                              "${AppLocalizations.of(context)!.drug} ${AppLocalizations.of(context)!.name}"),
                          Validatorless.required(AppLocalizations.of(context)!
                              .isRequired(
                                  "${AppLocalizations.of(context)!.drug} ${AppLocalizations.of(context)!.name}"))
                        ]),
                        onChanged: (val) {
                          _medName = val;
                        },
                        onSaved: (val) {
                          _medName = val!;
                        })))));
  }

  Widget buildFractionWidget() {
    return Container(
        margin: const EdgeInsets.all(10),
        alignment: Alignment.center,
        height: 60,
        child: Semantics(
          identifier: semantic.S.ADD_MEDICATION_TABLET_SWITCH,
          child: AnimatedToggleSwitch<bool>.size(
              key: K.isHalfOption,
              current: _isHalf,
              style: ToggleStyle(
                backgroundColor: Theme.of(context).primaryColor,
                indicatorColor: Theme.of(context).indicatorColor,
                borderColor: Colors.black,
                borderRadius: BorderRadius.circular(10.0),
                indicatorBorderRadius: BorderRadius.zero,
              ),
              values: const [false, true],
              iconOpacity: 1.0,
              height: 45,
              selectedIconScale: 1.0,
              indicatorSize: const Size.fromWidth(50),
              iconAnimationType: AnimationType.onHover,
              styleAnimationType: AnimationType.onHover,
              spacing: 2.0,
              customSeparatorBuilder: (context, local, global) {
                final opacity = ((global.position - local.position).abs() - 0.5)
                    .clamp(0.0, 1.0);
                return VerticalDivider(
                    indent: 10.0,
                    endIndent: 10.0,
                    color: Colors.white38.withOpacity(opacity));
              },
              customIconBuilder: (context, local, global) {
                final text = const ['Full', 'Half'][local.index];
                return Center(
                    child: Semantics(
                        container: true,
                        identifier: (text == "Full")
                            ? semantic.S.ADD_MEDICATION_TABLET_FULL
                            : semantic.S.ADD_MEDICATION_TABLET_HALF,
                        child: Text(
                          text,
                          style: TextStyle(
                            color: Color.lerp(Colors.black, Colors.white,
                                local.animationValue),
                          ),
                        )));
              },
              borderWidth: 0.6,
              onChanged: (i) {
                _isHalf = i;
                setState(() {});
              }),
        ));
  }

  Widget buildDosageWidget() {
    return Container(
        height: MediaQuery.of(context).size.height * 0.2,
        alignment: Alignment.center,
        width: MediaQuery.of(context).size.width * 0.4,
        child: Padding(
            padding: const EdgeInsets.all(5),
            child: Focus(
                focusNode: FocusNodes.dosageAutoSizeTextField,
                child: Semantics(
                  label: semantic.S.ADD_MEDICATION_DRUG_DOSAGE_FIELD,
                  container: true,
                  child: SpinBox(
                    key: K.dosageAutoSizeTextField,
                    decoration: InputDecoration(
                      contentPadding: const EdgeInsets.all(10),
                      label: Text(AppLocalizations.of(context)!.dosage),
                      labelStyle: Theme.of(context).textTheme.titleSmall,
                      errorStyle: const TextStyle(color: Colors.red),
                      errorMaxLines: 2,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10.0),
                      ),
                    ),
                    value: _dosage.toDouble(),
                    min: 1,
                    max: 10,
                    textStyle: Theme.of(context).textTheme.titleSmall,
                    onChanged: (value) {
                      _dosage = value.ceil();
                      setState(() {});
                    },
                    validator: (dosage) {
                      String? isValid;

                      isValid = DosageValidator.isRequired(
                          AppLocalizations.of(context)!.dosage,
                          (dosage == null));

                      if (isValid?.isEmpty ?? true) {
                        var rangeMap = _propertiesMap[
                            EnumToString.convertToString(_preparation,
                                    camelCase: false)
                                .toLowerCase()]!;

                        isValid = DosageValidator.isValid(
                            AppLocalizations.of(context)!.valueRange(
                                AppLocalizations.of(context)!.dosage,
                                rangeMap["min"] as int,
                                rangeMap["max"] as int),
                            dosage!,
                            rangeMap["min"] as int,
                            rangeMap["max"] as int);
                      }
                      return isValid;
                    },
                  ),
                ))));
  }

  buildOptionWidget() {
    return ToggleSwitch(
      key: K.datePicker,
      minWidth: 70.0,
      minHeight: 30.0,
      cornerRadius: 12.0,
      fontSize: 10,
      borderWidth: 2,
      borderColor: [Colors.grey],
      activeFgColor: Colors.white,
      inactiveBgColor: Colors.grey[100],
      inactiveFgColor: Colors.black,
      initialLabelIndex: _status.index,
      labels: [
        EnumToString.convertToString(MedStatus.New),
        EnumToString.convertToString(MedStatus.Continue),
      ],
      activeBgColors: [
        [Theme.of(context).indicatorColor],
        [Theme.of(context).indicatorColor],
      ],
      onToggle: (index) {
        _status = MedStatus.values[index!];
        setState(() {});
      },
    );
  }

  Widget buildDosageCompoundWidget() {
    List<Widget> dosageWidgets = [];

    if (_preparation == Preparation.Tablet) {
      dosageWidgets.add(buildFractionWidget());
    }

    if ((_preparation != Preparation.Tablet || !_isHalf)) {
      dosageWidgets.add(buildDosageWidget());
    }

    return Container(
        height: MediaQuery.of(context).size.height * 0.125,
        padding: const EdgeInsets.all(5),
        child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: dosageWidgets));
  }

  Widget prescInfo() {
    return Visibility(
        visible: _currentPageIndex == 0,
        child: Container(
            key: K.drugInfoSlide,
            height: MediaQuery.of(context).size.height * 0.7,
            width: MediaQuery.of(context).size.width,
            padding: const EdgeInsets.all(5),
            child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  buildPrescInfoHeader(),
                  Expanded(
                      child: Container(
                          margin: const EdgeInsets.only(bottom: 5),
                          decoration: BoxDecoration(
                            borderRadius: const BorderRadius.only(
                                bottomLeft: Radius.circular(8.0),
                                topRight: Radius.circular(8.0),
                                bottomRight: Radius.circular(8.0)),
                            border: Border(
                                top: BorderSide(
                                    color: Theme.of(context).indicatorColor,
                                    width: 0.5),
                                left: BorderSide(
                                    color: Theme.of(context).indicatorColor,
                                    width: 1.5),
                                right: BorderSide(
                                    color: Theme.of(context).indicatorColor,
                                    width: 1.5),
                                bottom: BorderSide(
                                    color: Theme.of(context).indicatorColor,
                                    width: 1.5)),
                          ),
                          padding: const EdgeInsets.all(10),
                          child: Form(
                              key: _drugInfoformKey,
                              child: Column(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceAround,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    buildMedNameWidget(Orientation.portrait),
                                    buildRouteWidget(Orientation.portrait),
                                    buildDosageCompoundWidget(),
                                    buildUnitsWidget(Orientation.portrait),
                                  ]))))
                ])));
  }

  Widget buildPrescInfoHeader() {
    return Container(
        decoration: const BoxDecoration(
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(8),
            topRight: Radius.circular(8),
          ),
          border: Border(
            top: BorderSide(color: Colors.blueGrey, width: 1.5),
            left: BorderSide(color: Colors.blueGrey, width: 1.5),
            right: BorderSide(color: Colors.blueGrey, width: 1.5),
          ),
        ),
        height: 50,
        width: MediaQuery.of(context).size.width * 0.3,
        child: ClipRRect(
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(8),
              topRight: Radius.circular(8),
            ),
            child: Semantics(
              container: true,
              identifier: semantic.S.ADD_MEDICATION_DRUG_TITLE,
              child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  color: Theme.of(context).primaryColor,
                  child: Stack(alignment: Alignment.centerLeft, children: [
                    Icon(MaterialCommunityIcons.pill,
                        size: 25,
                        color: (!_isDrugInfoValid) ? Colors.red : Colors.black),
                    Padding(
                        padding: const EdgeInsets.only(left: 30),
                        child: AutoSizeText(AppLocalizations.of(context)!.drug,
                            style: Theme.of(context).textTheme.titleLarge))
                  ])),
              //state: (_currentPageIndex == 0) ? StepState.editing : StepState.indexed,
              // isActive: (_currentPageIndex == 0) ? true : false,
            )));
  }

  Widget buildSchedule() {
    return Visibility(
        visible: (_currentPageIndex == 1),
        child: Container(
            key: K.scheduleSlide,
            height: MediaQuery.of(context).size.height * 0.7,
            width: MediaQuery.of(context).size.width,
            margin: const EdgeInsets.symmetric(horizontal: 1, vertical: 0),
            padding: const EdgeInsets.all(5),
            child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  buildScheduleWidgetHeader(),
                  Expanded(
                      child: Container(
                          margin: const EdgeInsets.only(bottom: 25),
                          decoration: BoxDecoration(
                            borderRadius: const  BorderRadius.only(
                              bottomLeft: Radius.circular(8.0),
                              topRight: Radius.circular(8.0),
                              bottomRight: Radius.circular(8.0),
                            ),
                            border: Border(
                                top: BorderSide(
                                    color: Theme.of(context).indicatorColor,
                                    width: 0.5),
                                left: BorderSide(
                                    color: Theme.of(context).indicatorColor,
                                    width: 1.5),
                                right: BorderSide(
                                    color: Theme.of(context).indicatorColor,
                                    width: 1.5),
                                bottom: BorderSide(
                                    color: Theme.of(context).indicatorColor,
                                    width: 1.5)),
                          ),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 10),
                          //height: MediaQuery.of(context).size.height * 0.6,
                          child: Form(
                              key: _scheduleformKey,
                              child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceEvenly,
                                  children: [
                                    buildFrequencyWidget(Orientation.portrait),
                                    buildTimeWidget(Orientation.portrait),
                                    buildDurationWidget(Orientation.portrait),
                                    buildDirectionWidget(Orientation.portrait),
                                  ]))))
                ])));
  }

  Widget buildScheduleWidgetHeader() {
    return Container(
        height: 50,
        width: MediaQuery.of(context).size.width * 0.35,
        decoration: BoxDecoration(
          borderRadius:  const BorderRadius.only(
              topLeft: Radius.circular(8.0), topRight: Radius.circular(8.0)),
          border: Border(
            top:
                BorderSide(color: Theme.of(context).indicatorColor, width: 1.5),
            left:
                BorderSide(color: Theme.of(context).indicatorColor, width: 1.5),
            right:
                BorderSide(color: Theme.of(context).indicatorColor, width: 1.5),
          ),
        ),
        child: ClipRRect(
            borderRadius: const  BorderRadius.only(
              topLeft: Radius.circular(8),
              topRight: Radius.circular(8),
            ),
            child: Semantics(
                identifier: semantic.S.ADD_MEDICATION_DRUG_SCHEDULE_TITLE,
                container: true,
                child: Container(
                    color: Theme.of(context).primaryColor,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 15, vertical: 10),
                    child: Stack(alignment: Alignment.centerLeft, children: [
                      Icon(Icons.calendar_today,
                          size: 25,
                          color:
                              (!_isScheduleValid) ? Colors.red : Colors.black),
                      Padding(
                          padding: const EdgeInsets.only(left: 30),
                          child: AutoSizeText(
                              AppLocalizations.of(context)!.schedule,
                              style: Theme.of(context).textTheme.titleLarge))
                    ])))));
  }

  void stepCancel() {
    if (_currentPageIndex - 1 < 0) return;
    setState(() {
      _currentPageIndex -= 1;
    });
  }

  void stepContinue() {
    if (_currentPageIndex + 1 > 1) return;

    if (_currentPageIndex == 0 && _drugInfoformKey.currentState!.validate()) {
      setState(() {
        _currentPageIndex += 1;
      });
    }
  }

  Widget buildStepIndicator() {
    List<Widget> widgets = [];

    if (_currentPageIndex > 0) {
      widgets.add(IconButton(
          icon: const Icon(Icons.arrow_left,
              semanticLabel: semantic.S.ADD_MEDICATION_PREV_BUTTON),
          onPressed: () {
            stepCancel();
          }));
    } else {
      widgets.add(const SizedBox(width: 40));
    }

    widgets.add(DotsIndicator(
        dotsCount: 2,
        position: _currentPageIndex,
        decorator: DotsDecorator(
          size: const Size.square(9.0),
          activeSize: const Size(18.0, 9.0),
          activeShape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(5.0)),
        ),
        onTap: (position) {
          setState(() => _currentPageIndex = position - 1);
        }));

    if (_currentPageIndex < 1) {
      widgets.add(IconButton(
          icon: const Icon(Icons.arrow_right,
              semanticLabel: semantic.S.ADD_MEDICATION_NEXT_BUTTON),
          onPressed: () {
            stepContinue();
          }));
    } else {
      widgets.add(const SizedBox(width: 40));
    }

    return Container(
        padding: const EdgeInsets.all(10),
        child: Row(
            mainAxisAlignment: MainAxisAlignment.center, children: widgets));
  }

  Widget buildHeader() {
    List<Widget> headerWidgets = [];

    if (_currentPageIndex == 0) {
      headerWidgets.add(
        IconButton(
            key: K.closeButton,
            icon: IconTheme(
                data: Theme.of(context).iconTheme,
                child: const Icon(Foundation.x, size:  UI.DIALOG_ACTION_BTN_SIZE)),
            onPressed: () {
              Navigator.of(context).pop();
            }),
      );
    } else {
      headerWidgets.add(
        IconButton(
            key: K.prevStep,
            icon: IconTheme(
                data: Theme.of(context).iconTheme,
                child: const Icon(FontAwesome.chevron_left,
                    size: UI.DIALOG_ACTION_BTN_SIZE,
                    semanticLabel: semantic.S.ADD_MEDICATION_PREV_BUTTON)),
            onPressed: () {
              if (_scheduleformKey.currentState!.validate()) {
                _scheduleformKey.currentState!.save();
                _currentPageIndex = 0;
              } else {
                _isScheduleValid = false;
              }
              setState(() {});
            }),
      );
    }
    headerWidgets.add(
      Container(
          alignment: Alignment.center,
          child: Semantics(
              container: true,
              child: AutoSizeText(
                  " ${AppLocalizations.of(context)!.addMedication}",
                  style: Theme.of(context).textTheme.titleLarge,
                  semanticsLabel: semantic.S.ADD_MEDICATION_TITLE))),
    );

    if (_currentPageIndex == 1) {
      headerWidgets.add(IconButton(
          key: K.checkButton,
          icon: const Icon(
            Foundation.check,
            size: UI.DIALOG_ACTION_BTN_SIZE,
            semanticLabel: semantic.S.ADD_MEDICATION_CHECK_BUTTON,
          ),
          focusNode: FocusNodes.saveMedicatioButton,
          color: Theme.of(context).indicatorColor,
          onPressed: () async {
            MedSchedule medSched;

            bool isValid = _scheduleformKey.currentState!.validate();

            if (isValid) {
              _scheduleformKey.currentState!.save();

              medSched = MedSchedule(_medName, _status, _preparation,
                  dosage: _dosage,
                  unit: _unit,
                  frequencyType: _frequencyType,
                  duration: _duration,
                  durationType: _durationType,
                  direction: _directions,
                  times: _times,
                  isHalfTab: _isHalf);
              navService.goBack(result: medSched);
              //Navigator.pop(context, medSched);
            } else {
              setState(() {});
            }
          }));
    } else {
      headerWidgets.add(
        IconButton(
            key: K.nextStep,
            icon: IconTheme(
                data: Theme.of(context).iconTheme,
                child: const Icon(FontAwesome.chevron_right,
                    size: UI.DIALOG_ACTION_BTN_SIZE,
                    semanticLabel: semantic.S.ADD_MEDICATION_NEXT_BUTTON)),
            onPressed: () {
              if (_drugInfoformKey.currentState!.validate()) {
                _drugInfoformKey.currentState!.save();
                _currentPageIndex = 1;
              } else {
                _isDrugInfoValid = false;
              }
              setState(() {});
            }),
      );
    }
    return SizedBox(
        height: MediaQuery.of(context).size.height * 0.1,
        child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: headerWidgets));
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: MediaQuery.of(context).size.height * 0.9,
      width: MediaQuery.of(context).size.width,
      child: Column(children: [
        buildHeader(),
        SizedBox(
          height: MediaQuery.of(context).size.height * 0.1,
          //padding: const EdgeInsets.all(5),
          child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
            buildOptionWidget(),
          ]),
        ),
        SizedBox(
            height: MediaQuery.of(context).size.height * 0.7,
            child: Stack(
              children: [prescInfo(), buildSchedule()],
            ))
      ]),
    );
  }
}
