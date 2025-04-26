import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:ezscrip/consultation/consultation_routes.dart';
import 'package:ezscrip/consultation/model/consultation_model.dart';
import 'package:ezscrip/consultation/model/direction.dart';
import 'package:ezscrip/consultation/model/durationType.dart';
import 'package:ezscrip/consultation/model/medicalDictionary.dart';
import 'package:ezscrip/consultation/model/medicalHistory.dart';
import 'package:ezscrip/consultation/model/preparation.dart';
import 'package:ezscrip/consultation/model/testParameter.dart';
import 'package:ezscrip/consultation/model/time.dart';
import 'package:ezscrip/consultation/view/add_medication_page.dart';
import 'package:ezscrip/consultation/view/add_parameter_page.dart';
import 'package:ezscrip/consultation/view/add_tests_page.dart';
import 'package:ezscrip/consultation/view/remove_medication_page.dart';
import 'package:ezscrip/route_constants.dart';
import 'package:ezscrip/settings/model/userprefs.dart';
import 'package:ezscrip/setup/model/localemodel.dart';
import 'package:ezscrip/util/focus_nodes.dart';
import 'package:ezscrip/util/keys.dart';
import 'package:ezscrip/prescription/services/prescription_generator_1.dart';
import 'package:ezscrip/util/ui_constants.dart';
import 'package:ezscrip/util/utils_service.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_vector_icons/flutter_vector_icons.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:ezscrip/profile/model/appUser.dart';
import 'package:ezscrip/consultation/model/indicator.dart';
import 'package:flutter/services.dart';
import 'package:ezscrip/util/gender.dart';
import 'package:ezscrip/util/semantics.dart' as semantic;
import 'package:ezscrip/util/mode.dart';
import 'package:ezscrip/consultation/model/consultation.dart';
import 'package:flutter_advanced_switch/flutter_advanced_switch.dart';
import 'package:ezscrip/consultation/model/medschedule.dart';
import 'package:ezscrip/consultation/model/status.dart';
import 'package:enum_to_string/enum_to_string.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:ezscrip/prescription/services/prescription_generator_2.dart';
import 'package:get_it/get_it.dart';
import 'package:global_configuration/global_configuration.dart';
import 'package:ezscrip/util/constants.dart';
import 'package:intl/intl.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:flash/flash.dart';
import 'package:no_context_navigation/no_context_navigation.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:super_tooltip/super_tooltip.dart';
import 'package:toggle_switch/toggle_switch.dart';
import 'package:validatorless/validatorless.dart';
import 'package:eva_icons_flutter/eva_icons_flutter.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:ezscrip/resources/resources.dart';
import '../model/medStatus.dart';
import 'add_medicalhistory_page.dart';
import 'add_notes_page.dart';
import 'add_symptom_page.dart';

class StrikeThroughDecoration extends Decoration {
  @override
  BoxPainter createBoxPainter([VoidCallback? onChanged]) {
    return _StrikeThroughPainter();
  }
}

class _StrikeThroughPainter extends BoxPainter {
  @override
  void paint(Canvas canvas, Offset offset, ImageConfiguration configuration) {
    final paint = Paint()
      ..strokeWidth = 1.0
      ..color = Colors.black
      ..style = PaintingStyle.fill;

    final rect = offset & configuration.size!;
    canvas.drawLine(Offset(rect.left, rect.top + rect.height / 2),
        Offset(rect.right, rect.top + rect.height / 2), paint);
    canvas.restore();
  }
}

class ConsultationEditPage extends StatefulWidget {
  final Mode mode;
  final Consultation consultation;
  final AppUser user;
  final Map<String, dynamic> propertiesMap;

  const ConsultationEditPage(
      {required this.mode,
      required this.consultation,
      required this.user,
      required this.propertiesMap,
      Key key = K.addConsultationPage})
      : super(key: key);
  @override
  _ConsultationEditPageState createState() => _ConsultationEditPageState(
      this.mode, this.consultation, this.user, this.propertiesMap);
}

class _ConsultationEditPageState extends State<ConsultationEditPage>
    with TickerProviderStateMixin, WidgetsBindingObserver {
  Mode _mode;
  Consultation _consultation;
  AppUser _user;
  Map<String, dynamic> _propertiesMap;

  late String errorMessage;
  late TabController tabController;

  final _formKey = GlobalKey<FormState>();
  final _addSymptomFormKey = GlobalKey<FormState>();
  final _addMedicalConditionFormKey = GlobalKey<FormState>();

  late ExpansionTileController _patientSummaryTileController,
      _symptomsTileController,
      _indicatorsTileController,
      _medicalHistoryTileController,
      _investigationsTileController,
      _notesTileController,
      _prescriptionTileController,
      _parametersTileController;

  //PatientProfile
  late Gender _gender;
  double? _weight;
  late TextEditingController _ageController,
      _patientNameController,
      _weightController;

  // Vital Signs
  int? _systolic, _diastolic, _pulseRate, _spo2;
  double? _temp;

  late TextEditingController _systolicController,
      _diastolicController,
      _pulserateController,
      _tempController,
      _notesController,
      _spo2Controller;

  late ValueNotifier<bool> _bpEnabled,
      _heartrateEnabled,
      _temperatureEnabled,
      _spo2Enabled;

  late ScrollController _notesScrollController;

  late bool _isPatientSummaryExpanded,
      _isConditionsExpanded,
      _isSymptomsExpanded,
      _isInvestigationsExpanded,
      _isNotesExpanded,
      _isPrescriptionExpanded,
      _isVitalsExpanded,
      _isSymptomsLimitExceeded,
      _isParametersLimitExceeded,
      _isParametersExpanded,
      _isMedicalHistoryLimitExceeded,
      _isInvestigationsLimitExceeded,
      _isNotesLimitExceeded,
      _isPrescriptionLimitExceeded;

  late ScrollController _symptomsScrollController,
      _medicalHistoryScrollController;

  //Symptoms
  late TextEditingController _symptomController, _testController;
  late List<String> _symptoms;

  //MedicalHitory
  late TextEditingController _conditionsTextController;
  late TextEditingController _conditionDurationController;
  late int _conditionDuration;
  late DurationType _conditionDurationType;
  late List<String> _medicalHistory;

  // Medication

  late TextEditingController _medicineController, _instructionsController;

  late String _medName;

  //Notes

  late String _notesText;
  late List<String> _medWords;
  late FocusNode _focusNode;
  late ScrollController scrollController;

  final _symptomTextFieldKey = GlobalKey();
  final _medicalHistoryFieldKey = GlobalKey();

  late FocusNode _patientNameFocusNode,
      _patientAgeFocusNode,
      _weigthFocusNode,
      _systolicFocusNode,
      _diastolicFocusNode,
      _hrFocusNode,
      _tempFocusNode,
      _spo2FocusNode,
      _notesFocusNode,
      _addSymptomFocusNode,
      _addMedicalHistoryFocusNode,
      _addMedicationFocusNode;

  //Errors
  String? _patientNameError;
  String? _patientAgeError;

  String? _testName;

  late SuperTooltipController _medicalHistoryTooltipController;

  late SuperTooltipController _paramtersTooltipController;

  late SuperTooltipController _symptomsTooltipController;

  late SuperTooltipController _indicatorsTooltipController;

  late SuperTooltipController _patientProfileTooltipController;

  late SuperTooltipController _prescriptionTooltipController;

  late SuperTooltipController _investigationsTooltipController;

  late SuperTooltipController _notesTooltipController;

  late SuperTooltipController _saveButtonTooltipController;

  late SuperTooltipController _checkButtonTooltipController;

  late List listeners;

  _ConsultationEditPageState(
      this._mode, this._consultation, this._user, this._propertiesMap);

  void initState() {
    _medName = "";
    _testName = "";
    _patientNameFocusNode = FocusNode();
    _patientAgeFocusNode = FocusNode();
    _weigthFocusNode = FocusNode();
    _systolicFocusNode = FocusNode();
    _diastolicFocusNode = FocusNode();
    _hrFocusNode = FocusNode();
    _tempFocusNode = FocusNode();
    _spo2FocusNode = FocusNode();
    _notesFocusNode = FocusNode();
    _addSymptomFocusNode = FocusNode();
    _addMedicalHistoryFocusNode = FocusNode();
    _addMedicationFocusNode = FocusNode();

    _symptomController = TextEditingController();
    _conditionsTextController = TextEditingController();
    _medicineController = TextEditingController();
    _symptomController.text = "";
    _conditionsTextController.text = "";

    _conditionDurationController = TextEditingController();
    _conditionDurationController.text = "";

    //_pageController = PageController();
    _ageController = TextEditingController();
    _weightController = TextEditingController();

    _patientNameController = TextEditingController();
    _gender = _consultation.getGender();
    _weight = _consultation.getWeight();
    _notesController = TextEditingController();
    //notesController.AutoSizeText = (mode == Mode.Add) ? "" : consultation.notes;

    _ageController.text = (_consultation.getPatientAge() == -1)
        ? "0"
        : _consultation.getPatientAge().toString();

    _weightController.text = _weight.toString();

    _patientSummaryTileController = ExpansionTileController();
    _symptomsTileController = ExpansionTileController();
    _indicatorsTileController = ExpansionTileController();
    _medicalHistoryTileController = ExpansionTileController();
    _investigationsTileController = ExpansionTileController();
    _notesTileController = ExpansionTileController();
    _prescriptionTileController = ExpansionTileController();
    _parametersTileController = ExpansionTileController();
    _notesScrollController = ScrollController();
    _systolicController = TextEditingController();
    _diastolicController = TextEditingController();
    _pulserateController = TextEditingController();
    _tempController = TextEditingController();
    _spo2Controller = TextEditingController();
    _testController = TextEditingController();

    _symptoms = [];

    _medicalHistory = [];

    _isPatientSummaryExpanded = true;
    _isConditionsExpanded = true;
    _isSymptomsExpanded = true;
    _isInvestigationsExpanded = true;
    _isNotesExpanded = true;
    _isVitalsExpanded = true;
    _isPrescriptionExpanded = true;
    _isParametersExpanded = true;

    _isSymptomsLimitExceeded = false;
    _isMedicalHistoryLimitExceeded = false;
    _isInvestigationsLimitExceeded = false;
    _isNotesLimitExceeded = false;
    _isPrescriptionLimitExceeded = false;
    _isParametersLimitExceeded = false;

    _bpEnabled = ValueNotifier<bool>(false);
    _heartrateEnabled = ValueNotifier<bool>(false);
    _temperatureEnabled = ValueNotifier<bool>(false);
    _spo2Enabled = ValueNotifier<bool>(false);

    _bpEnabled.addListener(() {
      setState(() {});
    });

    _heartrateEnabled.addListener(() {
      setState(() {});
    });

    _temperatureEnabled.addListener(() {
      setState(() {});
    });

    _spo2Enabled.addListener(() {
      setState(() {});
    });

    // _duration = 0;
    _conditionDurationType = DurationType.Month;
    scrollController = ScrollController();

    _symptomsScrollController = ScrollController();
    _medicalHistoryScrollController = ScrollController();

    if (_consultation.indicators.isNotEmpty) {
      for (var indicator in _consultation.getIndicators()) {
        if (indicator.getType() == IndicatorType.BloodPressure) {
          _bpEnabled = ValueNotifier<bool>(true);
          _systolic = int.parse(indicator
              .getValue()
              .toString()
              .substring(0, indicator.getValue().toString().indexOf("/")));
          _diastolic = int.parse(indicator
              .getValue()
              .toString()
              .substring(indicator.getValue().toString().indexOf("/") + 1));

          _systolicController.text = _systolic.toString();
          _diastolicController.text = _diastolic.toString();
        }

        if (indicator.getType() == IndicatorType.HeartRate) {
          _heartrateEnabled = ValueNotifier<bool>(true);
          _pulseRate = int.parse(indicator.getValue().toString());
          _pulserateController.text = _pulseRate.toString();
        }
        if (indicator.getType() == IndicatorType.Temperature) {
          _temperatureEnabled = ValueNotifier<bool>(true);
          _temp = double.parse(indicator.getValue().toString());
        }
        if (indicator.getType() == IndicatorType.Spo2) {
          _spo2Enabled = ValueNotifier<bool>(true);
          _spo2 = int.parse(indicator.getValue().toString());
        }
      }
    }

    _medicineController = TextEditingController();
    _medicineController.text = (_mode == Mode.Add) ? "" : _medName;
    _instructionsController = TextEditingController();
    _instructionsController.text = "";

    _patientNameController.text =
        (_mode == Mode.Add) ? "" : _consultation.getPatientName();

    errorMessage = "";
    tabController = TabController(vsync: this, length: 7);

    if (!_temperatureEnabled.value) {
      _temp = 98.6;
    }

    if (!_spo2Enabled.value) {
      _spo2 = 90;
    }

    if (this._mode == Mode.Preview) {
      listeners = [];
      _patientProfileTooltipController = SuperTooltipController();
      _indicatorsTooltipController = SuperTooltipController();
      _symptomsTooltipController = SuperTooltipController();
      _investigationsTooltipController = SuperTooltipController();
      _paramtersTooltipController = SuperTooltipController();
      _medicalHistoryTooltipController = SuperTooltipController();
      _notesTooltipController = SuperTooltipController();
      _prescriptionTooltipController = SuperTooltipController();
      _saveButtonTooltipController = SuperTooltipController();
      _checkButtonTooltipController = SuperTooltipController();

      FocusNodes.patientSummaryTile.addListener(patientSummaryTileListener);

      FocusNodes.vitalSignsTile.addListener(vitalSignsTileListener);

      FocusNodes.medicalHistoryTile.addListener(medicalHistoryTileListener);

      FocusNodes.symptomsTile.addListener(symptomsTileListener);

      FocusNodes.testsTile.addListener(testsTileListener);

      FocusNodes.testParametersTile.addListener(parametersTileListener);

      FocusNodes.notesTile.addListener(notesTileListener);

      FocusNodes.presciptionTile.addListener(prescriptionTileListener);

      FocusNodes.checkConsultatioButton.addListener(checkButtonListener);
      SchedulerBinding.instance.addPostFrameCallback((Duration _) {
        FocusScope.of(context).requestFocus(FocusNodes.patientSummaryTile);
      });
    }

    super.initState();
  }

  void patientSummaryTileListener() {
    if (FocusNodes.patientSummaryTile.hasFocus) {
      _patientSummaryTileController.expand();
      _patientProfileTooltipController.showTooltip();
    }
  }

  void vitalSignsTileListener() {
    if (FocusNodes.vitalSignsTile.hasFocus) {
      _patientSummaryTileController.collapse();
      _indicatorsTileController.expand();
      _indicatorsTooltipController.showTooltip();
    }
  }

  void medicalHistoryTileListener() {
    if (FocusNodes.medicalHistoryTile.hasFocus) {
      _parametersTileController.collapse();
      _medicalHistoryTileController.expand();
      _medicalHistoryTooltipController.showTooltip();
    }
  }

  void symptomsTileListener() {
    if (FocusNodes.symptomsTile.hasFocus) {
      _indicatorsTileController.collapse();
      _symptomsTileController.expand();
      _symptomsTooltipController.showTooltip();
    }
  }

  void testsTileListener() {
    if (FocusNodes.testsTile.hasFocus) {
      _medicalHistoryTileController.collapse();
      _investigationsTileController.expand();
      _investigationsTooltipController.showTooltip();
    }
  }

  void notesTileListener() {
    if (FocusNodes.notesTile.hasFocus) {
      _parametersTileController.collapse();
      _notesTileController.expand();
      _notesTooltipController.showTooltip();
    }
  }

  void parametersTileListener() {
    if (FocusNodes.testParametersTile.hasFocus) {
      _symptomsTileController.collapse();
      _parametersTileController.expand();
      _paramtersTooltipController.showTooltip();
    }
  }

  void prescriptionTileListener() {
    if (FocusNodes.presciptionTile.hasFocus) {
      _notesTileController.collapse();
      _prescriptionTileController.expand();
      _prescriptionTooltipController.showTooltip();
    }
  }

  void checkButtonListener() {
    if (FocusNodes.checkConsultatioButton.hasFocus) {
      _checkButtonTooltipController.showTooltip();
    }
  }

  @override
  void dispose() {
    if (this._mode == Mode.Preview) {
      FocusNodes.patientSummaryTile.removeListener(patientSummaryTileListener);
      FocusNodes.vitalSignsTile.removeListener(vitalSignsTileListener);
      FocusNodes.medicalHistoryTile.removeListener(medicalHistoryTileListener);
      FocusNodes.symptomsTile.removeListener(symptomsTileListener);
      FocusNodes.testsTile.removeListener(testsTileListener);
      FocusNodes.testParametersTile.removeListener(parametersTileListener);
      FocusNodes.presciptionTile.removeListener(prescriptionTileListener);
    }
    super.dispose();
  }

  dynamic getPropertyValue(String name, String type) {
    var property = (_propertiesMap[name]!);

    return property[type];
  }

  void _showMessage(IconData icon, String message, Color color) {
    showFlash(
        context: context,
        duration: const Duration(seconds: 3),
        builder: (_, controller) {
          return Flash(
            controller: controller,
            position: FlashPosition.bottom,
            child: FlashBar(
              controller: controller,
              icon: Icon(
                icon,
                size: 36.0,
                color: color,
              ),
              content: Text(message),
            ),
          );
        });
  }

  List<Widget> buildActions() {
    List<Widget> actions = [];

    IconButton saveButton = IconButton(
        key: K.saveButton,
        focusNode: FocusNodes.saveConsultatioButton,
        icon: IconTheme(
          data: Theme.of(context)
              .iconTheme
              .copyWith(size: UI.PAGE_ACTION_BTN_SIZE),
          child: const Icon(
            Foundation.save,
            size: 25,
            semanticLabel: semantic.S.CONSULTATION_SAVE_BUTTON,
          ),
        ),
        onPressed: (_mode == Mode.Preview)
            ? null
            : () async {
                _consultation.setStatus(Status.InProgress);
                Consultation? insertedConsultation = await submit(_mode);
                if (insertedConsultation != null) {
                  _showMessage(Icons.info, "Consultation Saved", Colors.blue);
                } else {
                  _showMessage(
                      Icons.warning, "Consultation is not Saved", Colors.red);
                }
              },
        color: Colors.white);

    actions.add((_mode == Mode.Preview)
        ? buildTooltipWidget(
            saveButton,
            _saveButtonTooltipController,
            11,
            AppLocalizations.of(context)!.save,
            "Save consultation",
            FocusNodes.checkConsultatioButton)
        : saveButton);

    IconButton checkButton = IconButton(
        key: K.checkButton,
        focusNode: FocusNodes.checkConsultatioButton,
        icon: IconTheme(
            data: Theme.of(context)
                .iconTheme
                .copyWith(size: UI.PAGE_ACTION_BTN_SIZE),
            child: const Icon(Foundation.check,
                size: 25, semanticLabel: semantic.S.CONSULTATION_DONE_BUTTON)),
        onPressed: () async {
          if (_mode != Mode.Preview) {
            _consultation.setStatus(Status.Complete);

            Consultation? updatedConsultation = await submit(_mode);

            if (updatedConsultation == null) {
              _showMessage(
                  Icons.warning,
                  AppLocalizations.of(context)!.saveConsultationFailed,
                  Colors.red);
              return;
            }
            navService.pushNamed(Routes.ViewConsultation,
                args: ConsultationPageArguments(
                    consultation: updatedConsultation,
                    user: _user,
                    isEditable: true));
          }
        });

    actions.add((_mode == Mode.Preview)
        ? buildTooltipWidget(
            checkButton,
            _checkButtonTooltipController,
            13,
            AppLocalizations.of(context)!.complete,
            "Complete Consultation",
            FocusNodes.prescriptionVieButton)
        : checkButton);
    return actions;
  }

  Widget buildTooltipWidget(
      Widget targetWidget,
      SuperTooltipController controller,
      int index,
      String title,
      String content,
      FocusNode nextFocusNode) {
    return SuperTooltip(
        showBarrier: true,
        controller: controller,
        popupDirection: (title != AppLocalizations.of(context)!.prescription &&
                title != AppLocalizations.of(context)!.notes)
            ? TooltipDirection.down
            : TooltipDirection.up,
        content: Container(
          height: 60,
          width: 150,
          alignment: Alignment.topLeft,
          padding: const EdgeInsets.all(2),
          child: AutoSizeText(
            content,
            maxLines: 3,
            minFontSize: 12,
            maxFontSize: 14,
            softWrap: true,
            style: TextStyle(
              color: Theme.of(context).indicatorColor,
            ),
          ),
        ),
        showCloseButton: true,
        closeButtonType: CloseButtonType.inside,
        onHide: () async {
          if (nextFocusNode == FocusNodes.prescriptionVieButton) {

            String testDataFile = GlobalConfiguration().getValue(C.DEMO_DATA);
            Map<String, dynamic> testDataJson = await rootBundle.loadStructuredData(testDataFile, (data) async { return  await json.decode(data);});
            Consultation consultation = Consultation.fromMap(testDataJson[C.DEMO_DATA]);
            AppUser user = await GetIt.instance<UserPrefs>().getUser();
            navService.pushNamed(Routes.ViewConsultation,
                args: ConsultationPageArguments(
                    consultation: consultation,
                    user: user,
                    isEditable: true,
                    mode: Mode.Preview));
          } else {
            FocusScope.of(context).requestFocus(nextFocusNode);
          }
        },
        child: targetWidget);
  }

  Widget buildGenderWidget(Gender gender, Orientation orientation) {
    Widget genderWidget = Semantics(
        identifier: semantic.S.PATIENT_GENDER_SWITCH,
        child: ToggleSwitch(
          key: K.genderField,
          minWidth: 75.0,
          minHeight: 40.0,
          cornerRadius: 12.0,
          fontSize: 10,
          activeFgColor: Colors.white,
          inactiveBgColor: Colors.grey[100],
          inactiveFgColor: Colors.black,
          initialLabelIndex: Gender.values
              .firstWhere((gender) => (gender.index == gender.index))
              .index,
          labels: [
            GenderHelper.toValue(Gender.values[0], context),
            GenderHelper.toValue(Gender.values[1], context),
            GenderHelper.toValue(Gender.values[2], context)
          ],
          icons: const [
            FontAwesomeIcons.mars,
            FontAwesomeIcons.venus,
            FontAwesomeIcons.transgender
          ],
          iconSize: 15.0,
          activeBgColors: [
            [Theme.of(context).indicatorColor],
            [Theme.of(context).indicatorColor],
            [Theme.of(context).indicatorColor]
          ],
          onToggle: (_mode == Mode.Preview)
              ? null
              : (index) {
                  _consultation.setGender(Gender.values[index!]);
                },
        ));

    return Padding(
        padding: const EdgeInsets.all(5),
        child: SizedBox(
            height: MediaQuery.of(context).size.height * 0.1,
            width: MediaQuery.of(context).size.width * 0.75,
            child: InputDecorator(
                decoration: InputDecoration(
                    labelText: 'Gender',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10.0),
                      //gapPadding: 2.0),
                    )),
                child: genderWidget)));
  }

  Widget buildSymptomsWidget() {
    List<Row> symptomList = [];

    symptomList = _consultation.getSymptoms().map((symptom) {
      return Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Semantics(
              identifier: semantic.S.CONSULTATION_SYMPTOM_LABEL,
              container: true,
              child: Stack(alignment: Alignment.centerLeft, children: [
                CircleAvatar(
                    radius: 5,
                    backgroundColor: Theme.of(context).indicatorColor),
                Padding(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 25, vertical: 0),
                    child: AutoSizeText(symptom,
                        style: Theme.of(context).textTheme.bodyMedium)),
              ])),
          SizedBox(
              width: MediaQuery.of(context).size.width * 0.08,
              child: IconButton(
                  icon: Icon(EvaIcons.closeCircleOutline,
                      color: Theme.of(context).indicatorColor, size: 20),
                  onPressed: () {
                    setState(() {
                      _consultation.removeSymptom(symptom);

                      _isSymptomsLimitExceeded =
                          (_consultation.getSymptoms().length >
                              int.parse(GlobalConfiguration()
                                  .getValue(C.MAX_SYMPTOMS)
                                  .toString()));
                    });
                  }))
        ],
      );
    }).toList();

    return Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        constraints:
            const BoxConstraints(minHeight: UI.EXPANSION_TILE_EMPTY_SIZE),
        color: Colors.white,
        child: ListView(
            key: K.symptomsList,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            scrollDirection: Axis.vertical,
            children: symptomList));
  }

  Widget buildTestsWidget() {
    List<Row> testChips = [];

    testChips = _consultation.getTests().map((test) {
      return Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
        Semantics(
            identifier: semantic.S.CONSULTATION_INVESTIGATION_LABEL,
            container: true,
            child: Stack(alignment: Alignment.centerLeft, children: [
              CircleAvatar(
                  radius: 5, backgroundColor: Theme.of(context).indicatorColor),
              Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 25, vertical: 0),
                  child: AutoSizeText(test,
                      style: Theme.of(context).textTheme.bodySmall)),
            ])),
        SizedBox(
            width: MediaQuery.of(context).size.width * 0.08,
            child: IconButton(
                icon: const Icon(EvaIcons.closeCircleOutline,
                    size: UI.DELETE_TILE_ACTION_BTN_SIZE),
                onPressed: () {
                  setState(() {
                    _consultation.removeInvestigation(test);
                    _isInvestigationsLimitExceeded =
                        _consultation.getTests().length >
                            int.parse(GlobalConfiguration()
                                .getValue(C.MAX_INVESTIGATIONS)
                                .toString());
                  });
                }))
      ]);
    }).toList();

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 5),
      constraints:
          const BoxConstraints(minHeight: UI.EXPANSION_TILE_EMPTY_SIZE),
      color: Colors.white,
      child: ListView(
          key: K.testsList,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          scrollDirection: Axis.vertical,
          children: [Wrap(spacing: 5.0, runSpacing: 5.0, children: testChips)]),
    );
  }

  Widget buildConsultationWidget(BuildContext context) {
    return Column(crossAxisAlignment: CrossAxisAlignment.center, children: [
      Container(
          child: SingleChildScrollView(
              physics: const ScrollPhysics(),
              child: Container(
                  padding: const EdgeInsets.all(5),
                  height: 100,
                  decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey[100]!)),
                  child: TextField(
                    controller: _notesController,
                    keyboardType: TextInputType.multiline,
                    minLines: 5,
                    decoration: const InputDecoration(
                        border: UnderlineInputBorder(
                      borderSide: BorderSide(color: Colors.grey, width: 2.0),
                    )),
                    maxLines: 10,
                    onChanged: (val) {
                      _notesText = val;
                    },
                  )))),
      Expanded(
          child: ListView(
              children: _consultation
                  .getNotes()
                  .map((note) => Card(
                      elevation: 0,
                      margin: const EdgeInsets.only(
                          left: 8, right: 8, top: 2, bottom: 2),
                      child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Padding(
                                padding: const EdgeInsets.all(5),
                                child: Flexible(
                                    child: AutoSizeText(note, softWrap: true))),
                            IconButton(
                                icon: Icon(EvaIcons.closeCircleOutline,
                                    color: Theme.of(context).indicatorColor),
                                onPressed: () {
                                  setState(() {
                                    _consultation.removeNote(note);
                                  });
                                })
                          ])))
                  .toList()))
    ]);
  }

  Widget getTimeIcon(Time time) {
    Icon icon;
    switch (time) {
      case Time.daybreak:
        icon = const Icon(
          Feather.sunrise,
          size: 20,
          color: Colors.black,
          semanticLabel: semantic.S.PRESCRIPTION_TILE_TIME_DAYBREAK,
        );
        break;
      case Time.morning:
        icon = const Icon(
          Fontisto.day_sunny,
          size: 20,
          color: Colors.black,
          semanticLabel: semantic.S.PRESCRIPTION_TILE_TIME_MORNING,
        );
        break;
      case Time.afternoon:
        icon = const Icon(
          Ionicons.sunny,
          size: 20,
          color: Colors.black,
          semanticLabel: semantic.S.PRESCRIPTION_TILE_TIME_AFTERNOON,
        );
        break;
      case Time.evening:
        icon = const Icon(
          Feather.sunset,
          size: 20,
          color: Colors.black,
          semanticLabel: semantic.S.PRESCRIPTION_TILE_TIME_EVENING,
        );
        break;
      case Time.night:
        icon = const Icon(
          Fontisto.night_clear,
          size: 20,
          color: Colors.black,
          semanticLabel: semantic.S.PRESCRIPTION_TILE_TIME_NIGHT,
        );
        break;
    }

    return icon;
  }

  Widget getStatusIcon(MedStatus status) {
    Widget statusWidget;

    switch (status) {
      case MedStatus.New:
        statusWidget =
            const CircleAvatar(radius: 5, backgroundColor: Colors.green);
        break;

      case MedStatus.Continue:
        statusWidget =
            const CircleAvatar(radius: 5, backgroundColor: Colors.yellow);
        break;

      case MedStatus.Discontinue:
        statusWidget =
            const CircleAvatar(radius: 5, backgroundColor: Colors.red);
        break;
    }

    return statusWidget;
  }

  Widget buildPrescriptionDrugInfoContent(MedSchedule prescription) {
    String drugLabelText =
        "${(prescription.getPreparation() == Preparation.Tablet && prescription.isHalfTab!) ? '1/2' : prescription.dosage.toString()} ${EnumToString.convertToString(prescription.unit, camelCase: true).toLowerCase()} ${prescription.getName()}";

    String frequencyLabelText =
        "${prescription.frequencyType.toString().substring(prescription.frequencyType.toString().indexOf(".") + 1, prescription.frequencyType.toString().indexOf("_"))}";

    return SizedBox(
        width: MediaQuery.of(context).size.width * 0.5,
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Padding(
              padding: EdgeInsets.all(2),
              child: Stack(alignment: Alignment.centerLeft, children: [
                getUnitIcon(prescription.getPreparation()),
                Semantics(
                  identifier: semantic.S.PRESCRIPTION_TILE_MED_QTY,
                  container: true,
                  child: Padding(
                      padding: const EdgeInsets.only(left: 25, right: 2),
                      child: AutoSizeText(drugLabelText,
                          style: Theme.of(context).textTheme.titleMedium)),
                ),
              ])),
          Padding(
              padding: const EdgeInsets.all(2),
              child: Stack(alignment: Alignment.centerLeft, children: [
                const Align(
                    alignment: Alignment.centerLeft,
                    child: Icon(Icons.timer, size: 20)),
                Align(
                    alignment: Alignment.centerRight,
                    child: Padding(
                      padding: EdgeInsets.only(left: 70),
                      child: (prescription.times != null)
                          ? LimitedBox(
                              maxWidth: 100,
                              maxHeight: 30,
                              child: ListView(
                                  key: K.timesIconList,
                                  scrollDirection: Axis.horizontal,
                                  padding: const EdgeInsets.all(5),
                                  children: prescription.times!
                                      .map((e) => getTimeIcon(e))
                                      .toList()))
                          : const SizedBox(width: 30, height: 30),
                    )),
                Padding(
                  padding: const EdgeInsets.only(left: 30),
                  child: Semantics(
                      identifier: semantic.S.PRESCRIPTION_TILE_SCHEDULE,
                      container: true,
                      child: AutoSizeText(frequencyLabelText,
                          style: Theme.of(context).textTheme.bodyMedium)),
                )
              ]))
        ]));
  }

  Widget buildDurationPrescriptionContent(MedSchedule prescription) {
    return SizedBox(
        width: MediaQuery.of(context).size.width * 0.25,
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Stack(alignment: Alignment.centerLeft, children: [
            const Icon(Icons.timelapse, size: 20),
            Padding(
                padding: const EdgeInsets.only(left: 25),
                child: AutoSizeText(
                  prescription.duration.toString() +
                      " " +
                      EnumToString.convertToString(prescription.durationType,
                          camelCase: true),
                  minFontSize: 8,
                  maxFontSize: 14,
                ))
          ]),
          buildDirectionWidget(prescription.direction)
        ]));
  }

  Widget buildDisontinuePrescriptionContent(MedSchedule prescription) {
    return Semantics(
        identifier: semantic.S.PRESCRIPTION_TILE,
        container: true,
        child: Container(
          foregroundDecoration: StrikeThroughDecoration(),
          child: Row(children: [
            getUnitIcon(prescription.getPreparation()),
            SizedBox(
                width: MediaQuery.of(context).size.width * 0.45,
                child: Padding(
                    padding: const EdgeInsets.only(left: 3, right: 3),
                    child: AutoSizeText(prescription.getName(),
                        style: Theme.of(context).textTheme.titleMedium))),
            SizedBox(
                width: MediaQuery.of(context).size.width * 0.2,
                child: Padding(
                    padding: const EdgeInsets.only(left: 3, right: 3),
                    child: AutoSizeText(
                        EnumToString.convertToString(
                            prescription.getPreparation(),
                            camelCase: true),
                        style: Theme.of(context).textTheme.titleMedium))),
          ]),
        ));
  }

  Widget buildDirectionWidget(Direction? direction) {
    Widget directionWidget;

    directionWidget = Stack(alignment: Alignment.centerLeft, children: [
      const Icon(Icons.comment, size: 20),
      Semantics(
          identifier: semantic.S.PRESCRIPTION_TILE_DIRECTIONS,
          container: true,
          child: Container(
              alignment: Alignment.center,
              width: MediaQuery.of(context).size.width * 0.225,
              height: 30,
              padding: const EdgeInsets.only(left: 25, right: 2),
              child: (direction != Direction.NotApplicable)
                  ? AutoSizeText(
                      EnumToString.convertToString(direction, camelCase: true),
                      minFontSize: 8,
                      maxFontSize: 14,
                    )
                  : const AutoSizeText("")))
    ]);

    return directionWidget;
  }

  Widget buildRemovePresciptionWidget(MedSchedule prescription) {
    return SizedBox(
        width: MediaQuery.of(context).size.width * 0.1,
        child: IconButton(
          key: K.removeMedicationButton,
          icon: Icon(EvaIcons.closeCircleOutline,
              size: 20, color: Theme.of(context).indicatorColor),
          onPressed: () {
            _consultation.prescription.remove(prescription);
            setState(() {});
          },
        ));
  }

  Widget buildPrescriptionWidget(Orientation orientation) {
    List<Card> prescriptionChips = [];

    for (var prescription in _consultation.prescription) {
      List<Widget> prescriptionContent = [];

      Widget statusWidget = SizedBox(
          width: MediaQuery.of(context).size.width * 0.05,
          child: getStatusIcon(prescription.getStatus()));

      prescriptionContent.add(statusWidget);

      if (prescription.getStatus() != MedStatus.Discontinue) {
        prescriptionContent.add(buildPrescriptionDrugInfoContent(prescription));

        prescriptionContent.add(buildDurationPrescriptionContent(prescription));
      } else {
        prescriptionContent
            .add(buildDisontinuePrescriptionContent(prescription));
      }

      prescriptionContent.add(buildRemovePresciptionWidget(prescription));

      Card card = Card(
          color: Colors.white,
          margin: const EdgeInsets.all(2),
          borderOnForeground: false,
          elevation: 0,
          child: SizedBox(
              height: UI.EXPANSION_TILE_CONTENT_ROW_HEIGHT,
              child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: prescriptionContent)));

      prescriptionChips.add(card);
    }

    return Container(
        height: (prescriptionChips.isEmpty)
            ? UI.EXPANSION_TILE_EMPTY_SIZE
            : prescriptionChips.length * UI.EXPANSION_TILE_CONTENT_ROW_HEIGHT,
        color: Colors.white,
        padding: const EdgeInsets.all(1),
        child: ListView(key: K.prescriptionList, children: prescriptionChips));
  }

  List<String> getMedicalDict(String searchStr) {
    List<String> medWords = GetIt.instance<MedicalDictionary>().words;
    medWords.retainWhere((element) => element.startsWith(searchStr));
    return medWords;
  }

  Widget buildSymptomsDialogWidget(Locale locale) {
    return Dialog(
        child: Stack(alignment: Alignment.center, children: [
      SingleChildScrollView(
          controller: scrollController,
          child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              mainAxisSize: MainAxisSize.max,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                buildPortraitHeaderWidget(),
                const SizedBox(height: 15),
                buildPotraitPatientSummaryWidget(),
                const SizedBox(height: 10),
                buildSymtomsExtensionTileWidget(),
                const SizedBox(height: 10),
                buildIndicatorsWidget(),
                const SizedBox(height: 10),
                buildTestParameterWidget(),
                const SizedBox(height: 10),
                buildMedicalHistoryExtensionTileWidget(),
                const SizedBox(height: 10),
                buildTestsExtensionTileWidget(),
                const SizedBox(height: 10),
                buildPortraitNotesTileWidget(),
                const SizedBox(height: 10),
                buildPrescriptionExtensionTileWidget(),
              ])),
    ]));
  }

  Widget buildMedicalHistoryWidget() {
    List<Row> conditionsListWidget =
        _consultation.getMedicalHistory().map((medicalHistory) {
      return Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
        SizedBox(
          width: MediaQuery.of(context).size.width * 0.52,
          child: Semantics(
            identifier: semantic.S.CONSULTATION_MEDICAL_HISTORY_LABEL,
            child: Stack(alignment: Alignment.centerLeft, children: [
              CircleAvatar(
                  radius: 5, backgroundColor: Theme.of(context).indicatorColor),
              Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 25, vertical: 0),
                  child: AutoSizeText(medicalHistory.getDiseaseName(),
                      style: Theme.of(context).textTheme.bodySmall)),
            ]),
          ),
        ),
        SizedBox(
          width: MediaQuery.of(context).size.width * 0.3,
          child: Padding(
              padding: const EdgeInsets.only(left: 0, right: 10),
              child: Stack(alignment: Alignment.centerLeft, children: [
                const Icon(Icons.timer, size: 15),
                Padding(
                    padding: const EdgeInsets.only(left: 15),
                    child: AutoSizeText(
                        "${medicalHistory.getDuration().toString()} ${EnumToString.convertToString(medicalHistory.getDurationType())}",
                        style: Theme.of(context).textTheme.bodySmall))
              ])),
        ),
        SizedBox(
          width: MediaQuery.of(context).size.width * 0.08,
          child: IconButton(
            icon: Icon(EvaIcons.closeCircleOutline,
                size: UI.DELETE_TILE_ACTION_BTN_SIZE,
                color: Theme.of(context).indicatorColor),
            onPressed: () {
              setState(() {
                _consultation.removeFromMedicalHistory(medicalHistory);
                _isMedicalHistoryLimitExceeded =
                    _consultation.getMedicalHistory().length >
                        int.parse(GlobalConfiguration()
                            .getValue(C.MAX_MEDICAL_HISTORY)
                            .toString());
              });
            },
          ),
        )
      ]);
    }).toList();

    return Container(
        constraints:
            const BoxConstraints(minHeight: UI.EXPANSION_TILE_EMPTY_SIZE),
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
        color: Colors.white,
        child: ListView(
            key: K.medicalHistoryList,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            scrollDirection: Axis.vertical,
            children: conditionsListWidget));
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
                                  print("saved:" + _systolic.toString());
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

                              print("saved:" + _diastolic.toString());
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
                            borderRadius:
                                const BorderRadius.all(Radius.circular(21)),
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

  Widget buildPortraitNotesTileWidget() {
    Widget notesWidget = Focus(
        focusNode: FocusNodes.notesTile,
        child: Card(
          
            elevation: 0,
            shape: RoundedRectangleBorder(
              side: BorderSide(
                  color: Theme.of(context).indicatorColor, width: 1.5),
              borderRadius: BorderRadius.circular(8),
            ),
            // shape: RoundedRectangleBorder(
            //   side: BorderSide(
            //       color: (_isNotesLimitExceeded)
            //           ? Colors.red
            //           : Colors.transparent),
            //   borderRadius: BorderRadius.circular(8),
            // ),
            clipBehavior: Clip.antiAlias,
            margin: const EdgeInsets.all(0),
            color: Theme.of(context).primaryColor,
            child: ExpansionTile(
                key: K.notesTile,
                initiallyExpanded:
                    (_mode == Mode.Preview) ? false : _isNotesExpanded,
                onExpansionChanged: (isExpanded) {
                  _isNotesExpanded = isExpanded;
                  setState(() {});
                },
                controller: _notesTileController,
                leading: const Icon(Foundation.clipboard_notes,
                    size: 30, color: Colors.black),
                title: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Semantics(
                          identifier: semantic.S.CONSULTATION_NOTES_TILE_TITLE,
                          container: true,
                          child: AutoSizeText(
                              AppLocalizations.of(context)!.notes,
                              style: Theme.of(context).textTheme.titleLarge)),
                      (_isNotesLimitExceeded)
                          ? AutoSizeText(
                              "maximum is ${GlobalConfiguration().getValue(C.MAX_NOTES).toString()}",
                              style: const TextStyle(color: Colors.red))
                          : const SizedBox(width: 20),
                    ]),
                trailing: Stack(alignment: Alignment.centerLeft, children: [
                  (_consultation.getNotes().isNotEmpty && _isNotesLimitExceeded)
                      ? CircleAvatar(
                          radius: 10,
                          backgroundColor: (_isNotesLimitExceeded)
                              ? Colors.red
                              : Theme.of(context).indicatorColor,
                          child: CircleAvatar(
                              radius: 8,
                              backgroundColor: (_isNotesLimitExceeded)
                                  ? Colors.red
                                  : Theme.of(context).primaryColor,
                              child: AutoSizeText(
                                  _consultation.getNotes().length.toString(),
                                  style: (_isNotesLimitExceeded)
                                      ? const TextStyle(color: Colors.white)
                                      : Theme.of(context)
                                          .textTheme
                                          .titleMedium)))
                      : SizedBox(height: 5, width: 5),
                  Semantics(
                      identifier: _isNotesExpanded
                          ? semantic.S.NOTES_EXPANDED_LABEL
                          : semantic.S.NOTES_COLLAPSED_LABEL,
                      container: true,
                      child: SizedBox(
                          key: (_isNotesExpanded)
                              ? K.tileStatusExpanded
                              : K.tileStatusCollapsed,
                          height: 20,
                          width: 20)),
                  (!_isNotesLimitExceeded)
                      ? SizedBox(
                          width: 100,
                          child: ButtonBar(children: [
                            SizedBox(
                              width: 30,
                              child: IconButton(
                                  key: K.addToNotesButton,
                                  icon: IconTheme(
                                      data: Theme.of(context).iconTheme,
                                      child: const Icon(Icons.add,
                                          size:
                                              UI.EXPANSION_TILE_ACTION_BTN_SIZE,
                                          semanticLabel: semantic
                                              .S.NOTE_ADD_DIALOG_BUTTON)),
                                  onPressed: (_mode == Mode.Preview)
                                      ? null
                                      : () async {
                                          String? note =
                                              await showModalBottomSheet(
                                            context: context,
                                            isScrollControlled: true,
                                            shape: const RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.vertical(
                                                top: Radius.circular(20),
                                              ),
                                            ),
                                            builder: (context) =>
                                                const AddNotesPage(),
                                          );

                                          if (note != null) {
                                            _consultation.addNote(note);
                                            if (_consultation
                                                    .getNotes()
                                                    .length >
                                                int.parse(GlobalConfiguration()
                                                    .getValue(C.MAX_NOTES)
                                                    .toString())) {
                                              _isNotesLimitExceeded = true;
                                            } else {
                                              _isNotesLimitExceeded = false;
                                            }
                                            setState(() {});
                                          }
                                        },
                                  color: Theme.of(context).indicatorColor),
                            ),
                          ]))
                      : const SizedBox(height: 5, width: 5)
                ]),
                children: <Widget>[
                  Container(
                      decoration: BoxDecoration(
                          border: Border.all(
                              color: Theme.of(context).primaryColor,
                              width: 2.5)),
                      child: Container(
                        color: Colors.white,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 5, vertical: 0),
                        child: (_consultation.getNotes().isNotEmpty)
                            ? Column(
                                key: K.notlesList,
                                children: _consultation
                                    .getNotes()
                                    .map((note) => Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.start,
                                            children: [
                                              Padding(
                                                padding: const EdgeInsets.only(
                                                    left: 4, right: 8),
                                                child: CircleAvatar(
                                                    radius: 5,
                                                    backgroundColor:
                                                        Theme.of(context)
                                                            .indicatorColor),
                                              ),
                                              Expanded(
                                                  child: Text(note,
                                                      softWrap: true,
                                                      overflow:
                                                          TextOverflow.clip,
                                                      maxLines: 4,
                                                      style: Theme.of(context)
                                                          .textTheme
                                                          .bodyMedium)),
                                              Padding(
                                                  padding:
                                                      const EdgeInsets.all(4),
                                                  child: IconButton(
                                                      icon: const Icon(
                                                          EvaIcons
                                                              .closeCircleOutline,
                                                          size: UI
                                                              .DELETE_TILE_ACTION_BTN_SIZE),
                                                      onPressed: () {
                                                        setState(() =>
                                                            _consultation
                                                                .removeNote(
                                                                    note));
                                                        _isNotesLimitExceeded =
                                                            _consultation
                                                                    .getNotes()
                                                                    .length >
                                                                int.parse(GlobalConfiguration()
                                                                    .getValue(C
                                                                        .MAX_NOTES)
                                                                    .toString());
                                                      }))
                                            ]))
                                    .toList())
                            : SizedBox(
                                height: UI.EXPANSION_TILE_EMPTY_SIZE,
                                child: Container(color: Colors.white)),
                      ))
                ])));

    return (_mode == Mode.Preview)
        ? buildTooltipWidget(
            notesWidget,
            _notesTooltipController,
            5,
            AppLocalizations.of(context)!.notes,
            "Enter consultation notes here.",
            FocusNodes.presciptionTile)
        : notesWidget;
  }

  Widget buildIndicatorsWidget() {
    Widget indicatorsWidget = Focus(
        focusNode: FocusNodes.vitalSignsTile,
        child: Card(
            elevation: 0,
            margin: const EdgeInsets.all(0),
            shape: RoundedRectangleBorder(
              side: BorderSide(
                  color: Theme.of(context).indicatorColor, width: 1.5),
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

    return (_mode == Mode.Preview)
        ? buildTooltipWidget(
            indicatorsWidget,
            _indicatorsTooltipController,
            5,
            AppLocalizations.of(context)!.vitals,
            "Enter patient vital signs like BP, Heart Rate, Temperatuer, Spo2",
            FocusNodes.symptomsTile)
        : indicatorsWidget;
  }

  Widget buildParameterListTable() {
    List<Widget> parameterListWidget =
        _consultation.getParameters().map((parameter) {
      return Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
        SizedBox(
            width: MediaQuery.of(context).size.width * 0.525,
            child: Stack(alignment: Alignment.centerLeft, children: [
              Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  child: CircleAvatar(
                      backgroundColor: Theme.of(context).indicatorColor,
                      radius: 5)),
              Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 25),
                  child: Text(parameter.getName(),
                      style: Theme.of(context).textTheme.bodySmall)),
            ])),
        SizedBox(
          width: MediaQuery.of(context).size.width * 0.325,
          child: Padding(
              padding: const EdgeInsets.only(right: 10),
              child: AutoSizeText(
                  "${parameter.getValue()} ${(parameter.getUnit() != null) ? parameter.getUnit() : ''}",
                  style: Theme.of(context).textTheme.bodySmall)),
        ),
        SizedBox(
            width: MediaQuery.of(context).size.width * 0.1,
            child: IconButton(
                icon: const Icon(EvaIcons.closeCircleOutline,
                    size: UI.DELETE_TILE_ACTION_BTN_SIZE),
                onPressed: () {
                  setState(() {
                    _consultation.removeParameter(parameter);
                    _isParametersLimitExceeded =
                        (_consultation.getParameters().length >
                            int.parse(GlobalConfiguration()
                                .getValue(C.MAX_PARAMETERS)
                                .toString()));
                  });
                }))
      ]);
    }).toList();

    return Container(
        constraints:
            const BoxConstraints(minHeight: UI.EXPANSION_TILE_EMPTY_SIZE),
        color: Colors.white,
        child: ListView(
            key: K.parameterList,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            scrollDirection: Axis.vertical,
            children: parameterListWidget));
  }

  Widget buildTestParameterWidget() {
    Widget testPaameterWidget = Focus(
        focusNode: FocusNodes.testParametersTile,
        child: Card(
            elevation: 0,
            margin: const EdgeInsets.all(0),
            shape: RoundedRectangleBorder(
              side: BorderSide(
                  color: Theme.of(context).indicatorColor, width: 1.5),
              borderRadius: BorderRadius.circular(8),
            ),
            color: Theme.of(context).primaryColor,
            clipBehavior: Clip.antiAlias,
            child: ExpansionTile(
                key: K.parametersTile,
                backgroundColor: Theme.of(context).primaryColor,
                initiallyExpanded:
                    (_mode == Mode.Preview) ? false : _isParametersExpanded,
                onExpansionChanged: (isExpanded) {
                  _isParametersExpanded = isExpanded;
                  setState(() {});
                },
                controller: _parametersTileController,
                leading:
                    SvgPicture.asset(Images.medicalTest, height: 30, width: 30),
                title: Semantics(
                  identifier: semantic.S.PARAMETER_TILE_LABEL,
                  container: true,
                  child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        AutoSizeText(AppLocalizations.of(context)!.parameters,
                            style: Theme.of(context).textTheme.titleLarge),
                        (_isParametersLimitExceeded)
                            ? AutoSizeText(
                                "maximum is ${GlobalConfiguration().getValue(C.MAX_PARAMETERS).toString()}",
                                style: const TextStyle(color: Colors.red))
                            : const SizedBox(width: 20)
                      ]),
                ),
                trailing: Stack(alignment: Alignment.centerLeft, children: [
                  (_consultation.getParameters().isNotEmpty &&
                          _consultation.getParameters().length > 0 &&
                          _isParametersLimitExceeded)
                      ? CircleAvatar(
                          radius: 10,
                          backgroundColor: (_isParametersLimitExceeded)
                              ? Colors.red
                              : Theme.of(context).indicatorColor,
                          child: CircleAvatar(
                              radius: 8,
                              backgroundColor: (_isParametersLimitExceeded)
                                  ? Colors.red
                                  : Theme.of(context).primaryColor,
                              child: AutoSizeText(
                                  _consultation
                                      .getParameters()
                                      .length
                                      .toString(),
                                  style: (_isParametersLimitExceeded)
                                      ? const TextStyle(color: Colors.white)
                                      : Theme.of(context)
                                          .textTheme
                                          .titleMedium)))
                      : const SizedBox(height: 5, width: 5),
                  Semantics(
                      identifier: (_isParametersExpanded)
                          ? semantic.S.PARAMETER_EXPANDED_LABEL
                          : semantic.S.PARAMETER_COLLAPSED_LABEL,
                      container: true,
                      child: SizedBox(
                          key: (_isParametersExpanded)
                              ? K.tileStatusExpanded
                              : K.tileStatusCollapsed,
                          height: 20,
                          width: 20,
                          child: Container())),
                  (!_isParametersLimitExceeded)
                      ? SizedBox(
                          width: 100,
                          child: ButtonBar(children: [
                            SizedBox(
                              width: 35,
                              child: IconButton(
                                  key: K.addParameterButton,
                                  icon: IconTheme(
                                      data: Theme.of(context).iconTheme,
                                      child: const Icon(Icons.add,
                                          size:
                                              UI.EXPANSION_TILE_ACTION_BTN_SIZE,
                                          semanticLabel: semantic
                                              .S.SYMPTOMS_SHOW_DIALOG_BUTTON)),
                                  onPressed: (_mode == Mode.Preview)
                                      ? null
                                      : () async {
                                          List<TestParameter> parameterList =
                                              _consultation.getParameters();

                                          TestParameter? newParameter =
                                              await showModalBottomSheet(
                                            context: context,
                                            isScrollControlled: true,
                                            shape: const RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.vertical(
                                                top: Radius.circular(20),
                                              ),
                                            ),
                                            builder: (context) =>
                                                AddParameterPage(
                                                    parameterList:
                                                        parameterList),
                                          );

                                          bool isNewParameterEmpty =
                                              (newParameter == null);

                                          if (!isNewParameterEmpty) {
                                            parameterList.add(newParameter);

                                            setState(() {
                                              if (parameterList.length >
                                                  int.parse(
                                                      GlobalConfiguration()
                                                          .getValue(
                                                              C.MAX_PARAMETERS)
                                                          .toString())) {
                                                _isParametersLimitExceeded =
                                                    true;
                                              } else {
                                                _isParametersLimitExceeded =
                                                    false;
                                              }

                                              _consultation
                                                  .setParameters(parameterList);
                                            });
                                          }
                                        },
                                  color: Theme.of(context).indicatorColor),
                            ),
                          ]))
                      : const SizedBox(width: 5, height: 5)
                ]),
                children: [
                  Container(
                      decoration: BoxDecoration(
                          border: Border.all(
                              color: Theme.of(context).primaryColor,
                              width: 2.5)),
                      child: Container(
                          color: Colors.white,
                          child: buildParameterListTable()))
                ])));

    return (_mode == Mode.Preview)
        ? buildTooltipWidget(
            testPaameterWidget,
            _paramtersTooltipController,
            5,
            AppLocalizations.of(context)!.parameters,
            "Enter values of parameters from investagation reports here.",
            FocusNodes.medicalHistoryTile)
        : testPaameterWidget;
  }

  Future<File> generatePrescription(String outputFilePath) async {
    String? format = await GetIt.instance<UserPrefs>().getFormat();
    String? template = await GetIt.instance<UserPrefs>().getTemplate();
    pw.Document prescDocument;
    Uint8List byteData;

    String? signatureSvg;

    byteData = File(template!).readAsBytesSync();

    bool isPrescriptionEnabled =
        await GetIt.instance<UserPrefs>().isSignatureEnabled();

    Map<String, String> timeIconsMap =
        await GetIt.instance<UtilsService>().getTimeIconMap();

    int prescriptionBlockLength =
        GlobalConfiguration().get(C.PRESCRIPTION_BLOCK_LENGTH) as int;

    int prescriptionBlockWeight =
        GlobalConfiguration().get(C.PRESCRIPTION_BLOCK_WEIGHT) as int;

    if (isPrescriptionEnabled) {
      signatureSvg = await GetIt.instance<UserPrefs>().getSignature();
    }

    if (format == 1) {
      prescDocument = await PrescriptionGenerator_1.buildPrescription(
          _consultation,
          _user,
          GetIt.instance<LocaleModel>().getLocale,
          byteData,
          isPrescriptionEnabled,
          timeIconsMap,
          prescriptionBlockLength,
          prescriptionBlockWeight,
          signatureSvg);
    } else {
      prescDocument = await PrescriptionGenerator_2.buildPrescription(
          _consultation,
          _user,
          await GetIt.instance<LocaleModel>().getLocale,
          byteData,
          isPrescriptionEnabled,
          timeIconsMap,
          signatureSvg);
    }

    Uint8List pdfData = await prescDocument.save();
    File savedFile = await File(outputFilePath).create();
    File prescFile = await savedFile.writeAsBytes(pdfData);

    return prescFile;
  }

  Future<Consultation?> submit(Mode mode) async {
    int consultationId = -1;

    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();

      if (_consultation.getSymptoms().length <
              getPropertyValue("symptoms", "min") ||
          _consultation.getSymptoms().length >
              getPropertyValue("symptoms", "max")) {
        _showMessage(
            Icons.warning,
            AppLocalizations.of(context)!.range(
                AppLocalizations.of(context)!.symptoms,
                getPropertyValue("symptoms", "min"),
                getPropertyValue("symptoms", "max")),
            Colors.red);
      } else if (_consultation.prescription.isEmpty) {
        _showMessage(
            Icons.warning,
            AppLocalizations.of(context)!
                .isRequired(AppLocalizations.of(context)!.prescription),
            Colors.red);
      } else if (_consultation.getMedicalHistory().length >
          getPropertyValue("medicalhistory", "max")) {
        _showMessage(
            Icons.warning,
            AppLocalizations.of(context)!.range(
                AppLocalizations.of(context)!.prescription,
                0,
                getPropertyValue("medicalhistory", "max")),
            Colors.red);
      } else if (_bpEnabled.value &&
          _systolic != null &&
          _diastolic != null &&
          _systolic! <= _diastolic!) {
        _showMessage(
            Icons.warning,
            "${AppLocalizations.of(context)!.systolic} is less than ${AppLocalizations.of(context)!.diastolic}",
            Colors.red);
      } else {
        List<Indicator> indicators = [];

        // print("_bpEnabled" + _bpEnabled.value.toString());
        // print("_systolic" + _systolic.toString());
        // print("_diastolic" + _diastolic.toString());

        if (_bpEnabled.value && _systolic != null && _diastolic != null) {
          indicators.add(Indicator(
              IndicatorType.BloodPressure, "${_systolic}/${_diastolic}"));
        }

        // print("_heartrateEnabled" + _heartrateEnabled.value.toString());
        // print("_heartrateEnabled" + _pulseRate.toString());

        if (_heartrateEnabled.value && _pulseRate != null) {
          indicators.add(Indicator(IndicatorType.HeartRate, "${_pulseRate}"));
        }

        // print("_heartrateEnabled" + _heartrateEnabled.value.toString());
        // print("_heartrateEnabled" + _pulseRate.toString());

        if (_temperatureEnabled.value && _temp != null) {
          indicators.add(Indicator(IndicatorType.Temperature, _temp));
        }
        // print("indicatorS:" + indicators.length.toString());

        if (_spo2Enabled.value && _spo2 != null) {
          indicators.add(Indicator(IndicatorType.Spo2, _spo2));
        }

        // print("indicatorS:" + indicators.length.toString());

        _consultation.indicators = indicators;
        var id = _consultation.id ??= 0;

        if (mode == Mode.Add && id == 0) {
          consultationId =
              await GetIt.instance<ConsultationModel>().insert(_consultation);

          _consultation.id = consultationId;
        } else {
          consultationId =
              await GetIt.instance<ConsultationModel>().update(_consultation);
        }
      }
    }
    return (consultationId != -1) ? _consultation : null;
  }

  Widget buildTestsExtensionTileWidget() {
    Widget investigationsWidget = Focus(
        focusNode: FocusNodes.testsTile,
        child: Card(
            elevation: 0,
            shape: RoundedRectangleBorder(
              side: BorderSide(
                  color: Theme.of(context).indicatorColor, width: 1.5),
              borderRadius: BorderRadius.circular(8),
            ),
            clipBehavior: Clip.antiAlias,
            color: Theme.of(context).primaryColor,
            margin: const EdgeInsets.all(0),
            child: ExpansionTile(
                key: K.testsTile,
                initiallyExpanded:
                    (_mode == Mode.Preview) ? false : _isInvestigationsExpanded,
                onExpansionChanged: (isExpanded) {
                  _isInvestigationsExpanded = isExpanded;
                  setState(() {});
                },
                controller: _investigationsTileController,
                leading: SvgPicture.asset(Images.tests, width: 25, height: 25),
                title: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Semantics(
                        identifier:
                            semantic.S.CONSULTATION_INVESTIGATIONS_TILE_TITLE,
                        container: true,
                        child: AutoSizeText(
                            AppLocalizations.of(context)!.investigations,
                            style: Theme.of(context).textTheme.titleLarge),
                      ),
                      (_isInvestigationsLimitExceeded)
                          ? AutoSizeText(
                              "maximum is ${GlobalConfiguration().getValue(C.MAX_INVESTIGATIONS).toString()}",
                              style: const TextStyle(color: Colors.red))
                          : const SizedBox(width: 20),
                    ]),
                trailing: Stack(alignment: Alignment.centerLeft, children: [
                  (_consultation.getTests().isNotEmpty &&
                          _consultation.getTests().length > 0 &&
                          _isInvestigationsLimitExceeded)
                      ? CircleAvatar(
                          radius: 10,
                          backgroundColor: (_isInvestigationsLimitExceeded)
                              ? Colors.red
                              : Theme.of(context).indicatorColor,
                          child: CircleAvatar(
                              radius: 8,
                              backgroundColor: (_isInvestigationsLimitExceeded)
                                  ? Colors.red
                                  : Theme.of(context).primaryColor,
                              child: AutoSizeText(
                                  _consultation.getTests().length.toString(),
                                  style: (_isInvestigationsLimitExceeded)
                                      ? const TextStyle(color: Colors.white)
                                      : Theme.of(context)
                                          .textTheme
                                          .titleMedium)))
                      : const SizedBox(height: 5, width: 5),
                  Semantics(
                      identifier: (_isInvestigationsExpanded)
                          ? semantic.S.INVESTIGATION_EXPANDED_LABEL
                          : semantic.S.INVESTIGATION_COLLAPSED_LABEL,
                      container: true,
                      child: SizedBox(
                          key: (_isInvestigationsExpanded)
                              ? K.tileStatusExpanded
                              : K.tileStatusCollapsed,
                          height: 20,
                          width: 20,
                          child: Container())),
                  (!_isInvestigationsLimitExceeded)
                      ? SizedBox(
                          width: 100,
                          child: Padding(
                            padding: const EdgeInsets.all(5),
                            child: ButtonBar(
                                alignment: MainAxisAlignment.end,
                                children: [
                                  SizedBox(
                                    width: 30,
                                    child: IconButton(
                                        key: K.addTestButton,
                                        icon: IconTheme(
                                            data: Theme.of(context).iconTheme,
                                            child: const Icon(Icons.add,
                                                size: UI
                                                    .EXPANSION_TILE_ACTION_BTN_SIZE,
                                                semanticLabel: semantic.S
                                                    .INVESTIGATIONS_SHOW_DIALOG_BUTTON)),
                                        onPressed: (_mode == Mode.Preview)
                                            ? null
                                            : () async {
                                                List<String> investigationList;
                                                String? investigationName =
                                                    await showModalBottomSheet(
                                                  context: context,
                                                  isScrollControlled: true,
                                                  shape:
                                                      const RoundedRectangleBorder(
                                                    borderRadius:
                                                        BorderRadius.vertical(
                                                      top: Radius.circular(20),
                                                    ),
                                                  ),
                                                  builder: (context) =>
                                                      const AddTestsPage(),
                                                );

                                                if (_consultation
                                                    .getTests()
                                                    .isNotEmpty) {
                                                  investigationList =
                                                      _consultation.getTests();
                                                } else {
                                                  investigationList = [];
                                                }

                                                bool investigatioNameIsEmpty =
                                                    (investigationName ??= "")
                                                            .length ==
                                                        0;

                                                if (!investigatioNameIsEmpty) {
                                                  setState(() {
                                                    if (investigationList
                                                            .length >
                                                        int.parse(
                                                            GlobalConfiguration()
                                                                .getValue(C
                                                                    .MAX_INVESTIGATIONS)
                                                                .toString())) {
                                                      _isInvestigationsLimitExceeded =
                                                          true;
                                                    } else {
                                                      _isInvestigationsLimitExceeded =
                                                          false;
                                                    }
                                                    investigationList.add(
                                                        investigationName!);
                                                    _consultation
                                                        .setInvestigations(
                                                            investigationList);
                                                  });
                                                }
                                              },
                                        color:
                                            Theme.of(context).indicatorColor),
                                  ),
                                ]),
                          ),
                        )
                      : const SizedBox(height: 5, width: 5),
                ]),
                children: <Widget>[
                  Container(
                      decoration: BoxDecoration(
                          border: Border.all(
                              color: Theme.of(context).primaryColor, width: 4)),
                      child: Container(
                          color: Colors.white, child: buildTestsWidget()))
                ])));

    return (_mode == Mode.Preview)
        ? buildTooltipWidget(
            investigationsWidget,
            _investigationsTooltipController,
            5,
            AppLocalizations.of(context)!.investigations,
            "Enter prescribed investigations here.",
            FocusNodes.notesTile)
        : investigationsWidget;
  }

  Widget buildSymtomsExtensionTileWidget() {
    Widget symptomsWidget = Focus(
        focusNode: FocusNodes.symtomsList,
        child: Card(
            elevation: 0,
            shape: RoundedRectangleBorder(
              side: BorderSide(
                  color: Theme.of(context).indicatorColor, width: 1.5),
              borderRadius: BorderRadius.circular(8),
            ),
            clipBehavior: Clip.antiAlias,
            color: Theme.of(context).primaryColor,
            margin: const EdgeInsets.all(0),
            child: ExpansionTile(
                key: K.symptomsTile,
                initiallyExpanded:
                    (_mode == Mode.Preview) ? false : _isSymptomsExpanded,
                onExpansionChanged: (isExpanded) {
                  _isSymptomsExpanded = isExpanded;
                  setState(() {});
                },
                controller: _symptomsTileController,
                leading: const Icon(Ionicons.body, size: 35),
                title: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Semantics(
                          identifier:
                              semantic.S.CONSULTATION_PATIENT_TILE_TITLE,
                          container: true,
                          child: AutoSizeText(
                              AppLocalizations.of(context)!.symptoms,
                              style: Theme.of(context).textTheme.titleLarge)),
                      (_isSymptomsLimitExceeded)
                          ? AutoSizeText(
                              "maximum is ${GlobalConfiguration().getValue(C.MAX_SYMPTOMS).toString()}",
                              style: TextStyle(color: Colors.red))
                          : const SizedBox(width: 20),
                    ]),
                trailing: Stack(alignment: Alignment.centerLeft, children: [
                  (_consultation.getSymptoms().isNotEmpty &&
                          _consultation.getSymptoms().length > 0 &&
                          _isSymptomsLimitExceeded)
                      ? CircleAvatar(
                          radius: 10,
                          backgroundColor: (_isSymptomsLimitExceeded)
                              ? Colors.red
                              : Theme.of(context).indicatorColor,
                          child: CircleAvatar(
                              radius: 8,
                              backgroundColor: (_isSymptomsLimitExceeded)
                                  ? Colors.red
                                  : Theme.of(context).primaryColor,
                              child: AutoSizeText(
                                  _consultation.getSymptoms().length.toString(),
                                  style: (_isSymptomsLimitExceeded)
                                      ? const TextStyle(color: Colors.white)
                                      : Theme.of(context).textTheme.bodySmall)))
                      : const SizedBox(height: 5, width: 5),
                  Semantics(
                      identifier: (_isSymptomsExpanded)
                          ? semantic.S.SYMPTOM_EXPANDED_LABEL
                          : semantic.S.SYMPTOM_COLLAPSED_LABEL,
                      container: true,
                      child: const SizedBox(height: 20, width: 20)),
                  (!_isSymptomsLimitExceeded)
                      ? SizedBox(
                          width: 100,
                          child: ButtonBar(children: [
                            SizedBox(
                              width: 35,
                              child: IconButton(
                                  key: K.addSymptomButton,
                                  icon: IconTheme(
                                      data: Theme.of(context).iconTheme,
                                      child: const Icon(Icons.add,
                                          size:
                                              UI.EXPANSION_TILE_ACTION_BTN_SIZE,
                                          semanticLabel: semantic
                                              .S.SYMPTOMS_SHOW_DIALOG_BUTTON)),
                                  onPressed: (_mode == Mode.Preview)
                                      ? null
                                      : () async {
                                          List<String> symptomList = [];
                                          bool newSyptomIsEmpty;
                                          String? newSymptom =
                                              await showModalBottomSheet(
                                                  context: context,
                                                  isScrollControlled: true,
                                                  shape:
                                                      const RoundedRectangleBorder(
                                                    borderRadius:
                                                        BorderRadius.vertical(
                                                      top: Radius.circular(20),
                                                    ),
                                                  ),
                                                  builder: (context) =>
                                                      AddSymptomPage());

                                          if (!_consultation
                                              .getSymptoms()
                                              .isEmpty) {
                                            symptomList =
                                                _consultation.getSymptoms();
                                          } else {
                                            symptomList = [];
                                          }

                                          newSyptomIsEmpty =
                                              (newSymptom ??= "").length == 0;

                                          if (!newSyptomIsEmpty) {
                                            symptomList.add(newSymptom);
                                          }

                                          setState(() {
                                            if (symptomList.length >
                                                int.parse(GlobalConfiguration()
                                                    .getValue(C.MAX_SYMPTOMS)
                                                    .toString())) {
                                              _isSymptomsLimitExceeded = true;
                                            } else {
                                              _isSymptomsLimitExceeded = false;
                                            }
                                            _consultation
                                                .setSymptoms(symptomList);
                                          });
                                        },
                                  color: Theme.of(context).indicatorColor),
                            ),
                          ]))
                      : SizedBox(width: 5, height: 5)
                ]),
                children: <Widget>[
                  Container(
                      decoration: BoxDecoration(
                          border: Border.all(
                              color: Theme.of(context).primaryColor,
                              width: 2.5)),
                      child: Container(
                          color: Colors.white, child: buildSymptomsWidget()))
                ])));

    return (_mode == Mode.Preview)
        ? buildTooltipWidget(
            symptomsWidget,
            _symptomsTooltipController,
            5,
            AppLocalizations.of(context)!.vitals,
            "Enter observed patient symptoms here.",
            FocusNodes.testParametersTile)
        : symptomsWidget;
  }

  Widget buildMedicalHistoryExtensionTileWidget() {
    Widget medicalHistoryWidget = Focus(
        focusNode: FocusNodes.medicalHistoryTile,
        child: Card(
            elevation: 0,
            shape: RoundedRectangleBorder(
              side: BorderSide(
                  color: Theme.of(context).indicatorColor, width: 1.5),
              borderRadius: BorderRadius.circular(8),
            ),
            clipBehavior: Clip.antiAlias,
            color: Theme.of(context).primaryColor,
            margin: const EdgeInsets.all(0),
            child: ExpansionTile(
                key: K.medicalHistoryTile,
                onExpansionChanged: (isExpanded) {
                  _isConditionsExpanded = isExpanded;
                  setState(() {});
                },
                controller: _medicalHistoryTileController,
                initiallyExpanded:
                    (_mode == Mode.Preview) ? false : _isConditionsExpanded,
                leading: const Icon(Octicons.file_diff, size: 30),
                title: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Semantics(
                          identifier: semantic
                              .S.CONSULTATION_MEDICAL_HISTORY_TILE_TITLE,
                          container: true,
                          child: AutoSizeText(
                              AppLocalizations.of(context)!.medicalHistory,
                              style: Theme.of(context).textTheme.titleLarge)),
                      (_isMedicalHistoryLimitExceeded)
                          ? AutoSizeText(
                              "maximum is ${GlobalConfiguration().getValue(C.MAX_MEDICAL_HISTORY).toString()}",
                              style: const TextStyle(color: Colors.red))
                          : const SizedBox(width: 20),
                    ]),
                trailing: Stack(alignment: Alignment.centerLeft, children: [
                  (_isMedicalHistoryLimitExceeded)
                      ? CircleAvatar(
                          radius: 10,
                          backgroundColor: Colors.red,
                          child: CircleAvatar(
                              radius: 8,
                              backgroundColor: (_isMedicalHistoryLimitExceeded)
                                  ? Colors.red
                                  : Theme.of(context).primaryColor,
                              child: AutoSizeText(
                                  _consultation
                                      .getMedicalHistory()
                                      .length
                                      .toString(),
                                  style: (_isMedicalHistoryLimitExceeded)
                                      ? const TextStyle(color: Colors.white)
                                      : Theme.of(context)
                                          .textTheme
                                          .titleMedium)))
                      : const SizedBox(height: 5, width: 5),
                  Semantics(
                      identifier: (_isConditionsExpanded)
                          ? semantic.S.MEDICAL_HISTORY_EXPANDED_LABEL
                          : semantic.S.MEDICAL_HISTORY_COLLAPSED_LABEL,
                      container: true,
                      child: SizedBox(
                          key: (_isConditionsExpanded)
                              ? K.tileStatusExpanded
                              : K.tileStatusCollapsed,
                          height: 20,
                          width: 20,
                          child: Container())),
                  (!_isMedicalHistoryLimitExceeded)
                      ? SizedBox(
                          width: 100,
                          child: Padding(
                              padding: const EdgeInsets.all(5),
                              child: ButtonBar(children: [
                                SizedBox(
                                  width: 30,
                                  child: IconButton(
                                      key: K.addMedicalHistory,
                                      icon: IconTheme(
                                          data: Theme.of(context).iconTheme,
                                          child: const Icon(
                                            Icons.add,
                                            size: UI
                                                .EXPANSION_TILE_ACTION_BTN_SIZE,
                                            semanticLabel: semantic.S
                                                .MEDICAL_HISTORY_ADD_DIALOG_BUTTON,
                                          )),
                                      onPressed: (_mode == Mode.Preview)
                                          ? null
                                          : () async {
                                              MedicalHistory? medicalHistory =
                                                  await showModalBottomSheet(
                                                context: context,
                                                isScrollControlled: true,
                                                shape:
                                                    const RoundedRectangleBorder(
                                                  borderRadius:
                                                      BorderRadius.vertical(
                                                    top: Radius.circular(20),
                                                  ),
                                                ),
                                                builder:
                                                    (ContextMenuButtonItem) =>
                                                        AddMedicalHistoryPage(),
                                              );

                                              if (medicalHistory != null) {
                                                List<MedicalHistory>
                                                    medicalHistoryList =
                                                    _consultation
                                                        .getMedicalHistory();
                                                medicalHistoryList
                                                    .add(medicalHistory);

                                                setState(() {
                                                  if (medicalHistoryList
                                                          .length >
                                                      int.parse(
                                                          GlobalConfiguration()
                                                              .getValue(C
                                                                  .MAX_MEDICAL_HISTORY)
                                                              .toString())) {
                                                    _isMedicalHistoryLimitExceeded =
                                                        true;
                                                  } else {
                                                    _isMedicalHistoryLimitExceeded =
                                                        false;
                                                  }
                                                  _consultation
                                                      .setMedicalHistory(
                                                          medicalHistoryList);
                                                });
                                              }
                                            },
                                      color: Theme.of(context).indicatorColor),
                                ),
                              ])))
                      : const SizedBox(height: 5, width: 5)
                ]),
                children: <Widget>[
                  Container(
                    decoration: BoxDecoration(
                        border: Border.all(
                            color: Theme.of(context).primaryColor, width: 2.5)),
                    child: Container(
                        color: Colors.white,
                        child: buildMedicalHistoryWidget()),
                  )
                ])));
    return (_mode == Mode.Preview)
        ? buildTooltipWidget(
            medicalHistoryWidget,
            _medicalHistoryTooltipController,
            5,
            AppLocalizations.of(context)!.medicalHistory,
            "Enter patient vital indicators like BP, Heart Rate, Temperatuer, Spo2",
            FocusNodes.testsTile)
        : medicalHistoryWidget;
  }

  Widget buildPrescriptionExtensionTileWidget() {
    Widget prescriptionWidget = Focus(
        focusNode: FocusNodes.presciptionTile,
        child: Card(
            elevation: 0,
            shape: RoundedRectangleBorder(
              side: BorderSide(
                  color: Theme.of(context).indicatorColor, width: 1.5),
              borderRadius: BorderRadius.circular(8),
            ),
            color: Theme.of(context).primaryColor,
            clipBehavior: Clip.antiAlias,
            margin: const EdgeInsets.all(0),
            child: ExpansionTile(
                key: K.presciptionTile,
                initiallyExpanded:
                    (_mode == Mode.Preview) ? false : _isPrescriptionExpanded,
                onExpansionChanged: (isExpanded) {
                  _isPrescriptionExpanded = isExpanded;
                  setState(() {});
                },
                controller: _prescriptionTileController,
                leading:
                    const Icon(MaterialCommunityIcons.prescription, size: 30),
                title: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Semantics(
                          identifier:
                              semantic.S.CONSULTATION_PRESCRIPTION_TILE_TITLE,
                          container: true,
                          child: AutoSizeText(
                              AppLocalizations.of(context)!.prescription,
                              style: Theme.of(context).textTheme.titleLarge)),
                      (_isPrescriptionLimitExceeded)
                          ? AutoSizeText(
                              "maximum is ${GlobalConfiguration().getValue(C.MAX_PRESCRIPTION).toString()}",
                              style: const TextStyle(color: Colors.red))
                          : const SizedBox(width: 20),
                    ]),
                trailing: Stack(alignment: Alignment.centerLeft, children: [
                  (_consultation.prescription.isNotEmpty &&
                          _isPrescriptionLimitExceeded)
                      ? CircleAvatar(
                          radius: 10,
                          backgroundColor: (_isPrescriptionLimitExceeded)
                              ? Colors.red
                              : Theme.of(context).indicatorColor,
                          child: CircleAvatar(
                              radius: 8,
                              backgroundColor: (_isPrescriptionLimitExceeded)
                                  ? Colors.red
                                  : Theme.of(context).primaryColor,
                              child: AutoSizeText(
                                  _consultation.prescription.length.toString(),
                                  style: (_isPrescriptionLimitExceeded)
                                      ? const TextStyle(color: Colors.white)
                                      : Theme.of(context)
                                          .textTheme
                                          .titleMedium)))
                      : const SizedBox(height: 5, width: 5),
                  Semantics(
                      identifier: (_isPrescriptionExpanded)
                          ? semantic.S.PRESCRIPTION_EXPANDED_LABEL
                          : semantic.S.PRESCRIPTION_COLLAPSED_LABEL,
                      container: true,
                      child: SizedBox(
                          key: (_isPrescriptionExpanded)
                              ? K.tileStatusExpanded
                              : K.tileStatusCollapsed,
                          height: 20,
                          width: 20)),
                  (!_isPrescriptionLimitExceeded)
                      ? SizedBox(
                          width: (UI.EXPANSION_TILE_ACTION_BTN_SIZE * 3) +
                              (UI.EXPANSION_TILE_ACTION_BTN_PADDING * 3) +
                              50,
                          child: Padding(
                              padding: const EdgeInsets.only(left: 20),
                              child: ButtonBar(
                                  alignment: MainAxisAlignment.end,
                                  buttonPadding: const EdgeInsets.all(
                                      UI.EXPANSION_TILE_ACTION_BTN_PADDING + 2),
                                  buttonMinWidth:
                                      UI.EXPANSION_TILE_ACTION_BTN_SIZE,
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    SizedBox(
                                      width: UI.EXPANSION_TILE_ACTION_BTN_SIZE +
                                          UI.EXPANSION_TILE_ACTION_BTN_PADDING,
                                      child: IconButton(
                                          key: K.deleteMedicationButton,
                                          padding: const EdgeInsets.all(2),
                                          iconSize:
                                              UI.DELETE_TILE_ACTION_BTN_SIZE,
                                          icon: IconTheme(
                                            data: Theme.of(context).iconTheme,
                                            child: const Icon(Icons.remove,
                                                size: UI
                                                    .EXPANSION_TILE_ACTION_BTN_SIZE),
                                          ),
                                          onPressed: () async {
                                            MedSchedule? medSchedule =
                                                await showModalBottomSheet(
                                                    context: context,
                                                    isScrollControlled: true,
                                                    isDismissible: false,
                                                    shape:
                                                        const RoundedRectangleBorder(
                                                      borderRadius:
                                                          BorderRadius.vertical(
                                                        top:
                                                            Radius.circular(20),
                                                      ),
                                                    ),
                                                    builder: (context) =>
                                                        const RemoveMedicationPage());

                                            if (medSchedule != null) {
                                              _consultation.prescription = [
                                                ..._consultation.prescription,
                                                medSchedule
                                              ];

                                              if (_consultation
                                                      .prescription.length >
                                                  int.parse(
                                                      GlobalConfiguration()
                                                          .getValue(C
                                                              .MAX_PRESCRIPTION)
                                                          .toString())) {
                                                _isPrescriptionLimitExceeded =
                                                    true;
                                              } else {
                                                _isPrescriptionLimitExceeded =
                                                    false;
                                              }

                                              setState(() {});
                                            }
                                          }),
                                    ),
                                    SizedBox(
                                      width: (UI
                                              .EXPANSION_TILE_ACTION_BTN_SIZE +
                                          UI.EXPANSION_TILE_ACTION_BTN_PADDING),
                                      child: IconButton(
                                          key: K.addMedicatioButton,
                                          padding: const EdgeInsets.all(2),
                                          iconSize:
                                              UI.EXPANSION_TILE_ACTION_BTN_SIZE,
                                          icon: IconTheme(
                                            data: Theme.of(context).iconTheme,
                                            child: const Icon(Icons.add,
                                                size: UI
                                                    .EXPANSION_TILE_ACTION_BTN_SIZE,
                                                semanticLabel: semantic.S
                                                    .PRESCRIPTION_ADD_DIALOG_BUTTON),
                                          ),
                                          onPressed: () async {
                                            Map<String, dynamic> propertiesMap =
                                                await GetIt.instance<
                                                        UtilsService>()
                                                    .loadProperties();
                                            MedSchedule? medSchedule =
                                                await showModalBottomSheet(
                                                    context: context,
                                                    isScrollControlled: true,
                                                    isDismissible: false,
                                                    shape:
                                                        const RoundedRectangleBorder(
                                                      borderRadius:
                                                          BorderRadius.vertical(
                                                        top:
                                                            Radius.circular(20),
                                                      ),
                                                    ),
                                                    builder: (context) =>
                                                        AddMedicationPage(
                                                            mode: Mode.Edit,
                                                            propertiesMap:
                                                                propertiesMap));

                                            if (medSchedule != null) {
                                              _consultation.prescription = [
                                                ..._consultation.prescription,
                                                medSchedule
                                              ];
                                              if (_consultation
                                                      .prescription.length >
                                                  int.parse(
                                                      GlobalConfiguration()
                                                          .getValue(C
                                                              .MAX_PRESCRIPTION)
                                                          .toString())) {
                                                _isPrescriptionLimitExceeded =
                                                    true;
                                              } else {
                                                _isPrescriptionLimitExceeded =
                                                    false;
                                              }
                                              setState(() {});
                                            }
                                          }),
                                    ),
                                  ])))
                      : const SizedBox(height: 5, width: 5),
                ]),
                children: <Widget>[
                  Container(
                      decoration: BoxDecoration(
                        border: Border.all(
                            color: Theme.of(context).primaryColor, width: 4),
                      ),
                      child: buildPrescriptionWidget(Orientation.portrait))
                ])));

    return (_mode == Mode.Preview)
        ? buildTooltipWidget(
            prescriptionWidget,
            _prescriptionTooltipController,
            10,
            AppLocalizations.of(context)!.prescription,
            "Enter prescribes medication here with preparation, unit, frequency, duration, schedule , directions.",
            FocusNodes.checkConsultatioButton)
        : prescriptionWidget;
  }

  Widget buildWeightWidget() {
    Widget weightWidget;

    weightWidget = Container(
        height: 60,
        width: 100,
        padding: const EdgeInsets.all(5),
        child: Semantics(
            //identifier: semantic.S.PATIENT_AGE_FLD,
            child: TextFormField(
                key: K.patientWeightTextField,
                focusNode: _weigthFocusNode,
                controller: _weightController,
                enabled: (_mode == Mode.Preview) ? false : true,
                autovalidateMode: AutovalidateMode.disabled,
                decoration: InputDecoration(
                  hintText: AppLocalizations.of(context)!.weight,
                  labelText: AppLocalizations.of(context)!.weight,
                  contentPadding: const EdgeInsets.all(10),
                  errorBorder: UnderlineInputBorder(
                      borderSide: BorderSide(color: Colors.red[100]!),
                      //gapPadding: 2.0,
                      borderRadius: BorderRadius.circular(9)),
                  errorStyle: const TextStyle(
                      height: 1.0, fontSize: 8, color: Colors.red),
                  errorMaxLines: 2,
                  border: UnderlineInputBorder(
                      borderSide: BorderSide(color: Colors.lightBlue[100]!),
                      borderRadius: BorderRadius.circular(9)),
                ),
                keyboardType: const TextInputType.numberWithOptions(signed: false, decimal: true),
                inputFormatters: [
                  FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,1}')),
                ],
                onChanged: (val) {
                  if (val.isNotEmpty) {
                    _weight = double.parse(val.trim());
                  }
                },
                onFieldSubmitted: (val) {
                  FocusScope.of(context).requestFocus();
                },
                onSaved: (val) {
                  if (val!.isNotEmpty) {
                    _consultation.setWeight(double.parse(val.trim()));
                  }
                },
                validator: Validatorless.multiple([
                  Validatorless.required(AppLocalizations.of(context)!
                      .isRequired(AppLocalizations.of(context)!.weight)),
                  Validatorless.numbersBetweenInterval(
                      0.0,
                      200.0,
                      AppLocalizations.of(context)!
                          .valueRangeWithoutField(0.0, 200)),
                ]))));
    return Container(
        margin: const EdgeInsets.all(5),
        width: MediaQuery.of(context).size.width * 0.4,
        child: Row(children: [
          weightWidget,
          Padding(
              padding: const EdgeInsets.only(left: 10),
              child: AutoSizeText(AppLocalizations.of(context)!.kg))
        ]));
  }

  Widget buildAgeWidget() {
    Widget ageWidget;

    ageWidget = Container(
        height: 60,
        width: 100,
        padding: const EdgeInsets.all(5),
        child: Semantics(
            identifier: semantic.S.PATIENT_AGE_FLD,
            child: TextFormField(
                key: K.patientAgeAutoSizeTextField,
                focusNode: _patientAgeFocusNode,
                enabled: (_mode == Mode.Preview) ? false : true,
                autovalidateMode: AutovalidateMode.disabled,
                decoration: InputDecoration(
                  hintText: AppLocalizations.of(context)!.age,
                  labelText: AppLocalizations.of(context)!.age,
                  contentPadding: const EdgeInsets.all(10),
                  errorBorder: UnderlineInputBorder(
                      borderSide: BorderSide(color: Colors.red[100]!),
                      //gapPadding: 2.0,
                      borderRadius: BorderRadius.circular(9)),
                  errorStyle: const TextStyle(
                      height: 1.0, fontSize: 8, color: Colors.red),
                  errorMaxLines: 2,
                  border: UnderlineInputBorder(
                      borderSide: BorderSide(color: Colors.lightBlue[100]!),
                      borderRadius: BorderRadius.circular(9)),
                ),
                keyboardType: const TextInputType.numberWithOptions(signed: false, decimal:false),
                controller: _ageController,
                onChanged: (val) {
                  if (val.isNotEmpty) {
                    _consultation.setPatientAge(int.parse(val.trim()));
                  }
                },
                onFieldSubmitted: (val) {
                  FocusScope.of(context).requestFocus();
                },
                onSaved: (val) {
                  if (val!.isNotEmpty) {
                    _consultation.setPatientAge(int.parse(val.trim()));
                  }
                },
                validator: Validatorless.multiple([
                  Validatorless.required(AppLocalizations.of(context)!
                      .isRequired(AppLocalizations.of(context)!.age)),
                  Validatorless.numbersBetweenInterval(
                      1.0,
                      120.0,
                      AppLocalizations.of(context)!
                          .valueRangeWithoutField(1, 120)),
                ]))));
    return Container(
        margin: const EdgeInsets.all(5),
        width: MediaQuery.of(context).size.width * 0.4,
        child: Row(children: [
          ageWidget,
          Padding(
              padding: const EdgeInsets.only(left: 10),
              child: AutoSizeText(AppLocalizations.of(context)!.year))
        ]));
  }

  Widget buildPortraitHeaderWidget() {
    return Container(
        child: Stack(alignment: Alignment.centerLeft, children: [
      Align(
        alignment: Alignment.centerRight,
        child: Container(
            child: AutoSizeText(
                StatusHelper.toValue(_consultation.getStatus(), context),
                style: const TextStyle(
                    fontWeight: FontWeight.bold, color: Colors.blue))),
      ),
      Row(children: [
        Container(
            child: Stack(alignment: Alignment.centerLeft, children: [
          const Icon(MaterialCommunityIcons.calendar_today, size: 25),
          Padding(
              padding: const EdgeInsets.only(left: 30),
              child: AutoSizeText(
                  DateFormat.yMMMd(Localizations.localeOf(context).languageCode)
                      .format(_consultation.getStart()),
                  style: Theme.of(context).textTheme.titleLarge,
                  semanticsLabel: semantic.S.CONSULTATION_DATE_TITLE)),
        ])),
        Container(
            child: Stack(alignment: Alignment.centerLeft, children: [
          const Icon(
            MaterialCommunityIcons.timer,
            size: 25,
            semanticLabel: semantic.S.CONSULTATION_TIME_TITLE,
          ),
          Padding(
              padding: const EdgeInsets.only(left: 30),
              child: AutoSizeText(
                  DateFormat.jm(Localizations.localeOf(context).languageCode)
                      .format(_consultation.getStart()),
                  style: Theme.of(context).textTheme.titleLarge))
        ])),
      ])
      //Padding(padding: const EdgeInsets.only(top:40), child:  buildAddToScheduleWidget(),)
    ]));
  }

  Widget getUnitIcon(Preparation preparation) {
    Widget icon = const Icon(Fontisto.pills, size: 20);

    switch (preparation) {
      case Preparation.Capsule:
        icon = const Icon(MaterialCommunityIcons.pill, size: 20);
        break;
      case Preparation.Tablet:
        icon = const Icon(MaterialCommunityIcons.pill, size: 20);
        break;
      case Preparation.InjectionIm:
        icon = const Icon(Fontisto.injection_syringe, size: 20);
        break;
      case Preparation.InjectionIv:
        icon = const Icon(Fontisto.injection_syringe, size: 20);
        break;
      case Preparation.EarDrops:
        icon = const Icon(FontAwesome.eyedropper, size: 20);
        break;
      case Preparation.EyeDrops:
        icon = const Icon(FontAwesome.eyedropper, size: 20);
        break;
      case Preparation.NasalDrops:
        icon = const Icon(FontAwesome.eyedropper, size: 15);
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

  Widget buildPatientName() {
    return Container(
        margin: const EdgeInsets.all(5),
        padding: const EdgeInsets.all(5),
        height: 60,
        child: Semantics(
          identifier: semantic.S.PATIENT_NAME_FLD,
          child: TextFormField(
            key: K.patientNameAutoSizeTextField,
            enabled: (_mode == Mode.Preview) ? false : true,
            //autofocus: (_mode != Mode.Preview) ? true : false,
            focusNode: _patientNameFocusNode,
            controller: _patientNameController,
            autovalidateMode: AutovalidateMode.onUserInteraction,
            decoration: InputDecoration(
              labelText: AppLocalizations.of(context)!.name,
              hintText: AppLocalizations.of(context)!.name,
              errorStyle: const TextStyle(height: 0.5, fontSize: 8),
              errorMaxLines: 2,
              border: UnderlineInputBorder(
                  borderSide: const BorderSide(),
                  borderRadius: BorderRadius.circular(9)),
              labelStyle: Theme.of(context).textTheme.bodyMedium,
            ),
            onChanged: (val) {
              _consultation.setPatientName(val);
            },
            onSaved: (val) {
              _consultation.setPatientName(val!);
            },
            onFieldSubmitted: (val) {
              FocusScope.of(context).requestFocus(_patientAgeFocusNode);
            },
            validator: Validatorless.multiple([
              Validatorless.max(
                  30,
                  AppLocalizations.of(context)!
                      .maxLength(AppLocalizations.of(context)!.name, 30)),
              Validatorless.required(AppLocalizations.of(context)!
                  .isRequired(AppLocalizations.of(context)!.name))
            ]),
          ),
        ));
  }

  Widget buildPatientDetailsWidget(Orientation orientation) {
    return Container(
        decoration: BoxDecoration(
            border:
                Border.all(color: Theme.of(context).primaryColor, width: 4.0)),
        width: MediaQuery.of(context).size.width,
        child: Container(
            padding: const EdgeInsets.all(10),
            color: Colors.white,
            child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  buildPatientName(),
                  buildGenderWidget(_consultation.getGender(), orientation),
                  Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [buildAgeWidget(), buildWeightWidget()]),
                ])));
  }

  Widget buildPotraitPatientSummaryWidget() {
    Widget patientSummaryWidget = Focus(
        focusNode: FocusNodes.patientSummaryTile,
        child: Card(
            elevation: 0,
            shape: RoundedRectangleBorder(
              side: BorderSide(
                  color: Theme.of(context).indicatorColor, width: 1.5),
              borderRadius: BorderRadius.circular(8),
            ),
            color: Theme.of(context).primaryColor,
            clipBehavior: Clip.antiAlias,
            margin: const EdgeInsets.all(0),
            child: ExpansionTile(
                key: K.patientSummaryTile,
                initiallyExpanded:
                    (_mode == Mode.Preview) ? false : _isPatientSummaryExpanded,
                controller: _patientSummaryTileController,
                onExpansionChanged: (isExpanded) {
                  _isPatientSummaryExpanded = isExpanded;
                  setState(() {});
                },
                leading:
                    const Icon(Ionicons.person, size: 30, color: Colors.black),
                title: Semantics(
                  identifier: semantic.S.CONSULTATION_PATIENT_TILE_TITLE,
                  container: true,
                  child: AutoSizeText(
                    AppLocalizations.of(context)!.patient,
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                ),
                trailing: Semantics(
                    identifier: (_isPatientSummaryExpanded)
                        ? semantic.S.PATIENT_EXPANDED_LABEL
                        : semantic.S.PATIENT_COLLAPSED_LABEL,
                    container: true,
                    child: SizedBox(
                        key: (_isPatientSummaryExpanded)
                            ? K.tileStatusExpanded
                            : K.tileStatusCollapsed,
                        height: 25,
                        width: 25)),
                children: [buildPatientDetailsWidget(Orientation.portrait)])));

    return (_mode == Mode.Preview)
        ? buildTooltipWidget(
            patientSummaryWidget,
            _patientProfileTooltipController,
            4,
            AppLocalizations.of(context)!.patient,
            "Enter patient profile information",
            FocusNodes.vitalSignsTile)
        : patientSummaryWidget;
  }

  String getConsultationDateTime() {
    return DateFormat.yMMMd(Localizations.localeOf(context).languageCode)
        .format((_consultation.getStart()));
  }

  PreferredSizeWidget buildAppBar(BuildContext context, List<Widget> actions) {
    Widget leftNavButton = IconButton(
        key: K.backNavButton,
        focusNode: FocusNodes.backNavButton,
        icon: IconTheme(
            data: Theme.of(context).iconTheme,
            child: const Icon(FontAwesome.chevron_left,
                size: 25, semanticLabel: semantic.S.BACK_BTN)),
        onPressed: () async {
          navService.goBack();
        });

    return PreferredSize(
        preferredSize: const Size.fromHeight(60),
        child: AppBar(
          elevation: 0,
          leading:
              Container(margin: const EdgeInsets.all(4), child: leftNavButton),
          bottom: const PreferredSize(
              preferredSize: Size.fromHeight(6), child: SizedBox(height: 4)),
          backgroundColor: Theme.of(context).primaryColor,
          automaticallyImplyLeading:
              (ModalRoute.of(context)!.settings.name == "/Home") ? false : true,
          title: Center(
              child: Stack(alignment: Alignment.centerLeft, children: [
            const Icon(MaterialCommunityIcons.prescription, size: 25),
            Padding(
                padding: const EdgeInsets.only(left: 30),
                child: AutoSizeText("Edit Prescription",
                    style: Theme.of(context).textTheme.displayMedium))
          ])),
          actions: [
            ButtonBar(
                alignment: MainAxisAlignment.end,
                buttonPadding: const EdgeInsets.all(4),
                children: actions)
          ],
        ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: buildAppBar(context, buildActions()),
        resizeToAvoidBottomInset: false,
        body: Container(
          height: MediaQuery.of(context).size.height - 5,
          width: MediaQuery.of(context).size.width - 5,
          margin: const EdgeInsets.all(5),
          child: Form(
              key: _formKey,
              child: Stack(alignment: Alignment.center, children: [
                SingleChildScrollView(
                    controller: scrollController,
                    child: Column(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        mainAxisSize: MainAxisSize.max,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: <Widget>[
                          buildPortraitHeaderWidget(),
                          const SizedBox(height: 15),
                          buildPotraitPatientSummaryWidget(),
                          const SizedBox(height: 10),
                          buildIndicatorsWidget(),
                          const SizedBox(height: 10),
                          buildSymtomsExtensionTileWidget(),
                          const SizedBox(height: 10),
                          buildTestParameterWidget(),
                          const SizedBox(height: 10),
                          buildMedicalHistoryExtensionTileWidget(),
                          const SizedBox(height: 10),
                          buildTestsExtensionTileWidget(),
                          const SizedBox(height: 10),
                          buildPortraitNotesTileWidget(),
                          const SizedBox(height: 10),
                          buildPrescriptionExtensionTileWidget(),
                          const SizedBox(height: 15),
                        ])),
              ])),
        ));
  }
}
