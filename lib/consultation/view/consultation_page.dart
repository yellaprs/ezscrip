import 'dart:io';
import 'package:ezscrip/consultation/consultation_routes.dart';
import 'package:ezscrip/home_page.dart';
import 'package:ezscrip/profile/model/userType.dart';
import 'package:ezscrip/util/focus_nodes.dart';
import 'package:flash/flash.dart';
import 'package:flutter/scheduler.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:ezscrip/consultation/model/direction.dart';
import 'package:ezscrip/consultation/model/preparation.dart';
import 'package:ezscrip/consultation/model/time.dart';
import 'package:ezscrip/prescription/prescription_routes.dart';
import 'package:ezscrip/prescription/services/prescription_generator_1.dart';
import 'package:ezscrip/prescription/services/prescription_generator_2.dart';
import 'package:ezscrip/resources/resources.dart';
import 'package:ezscrip/route_constants.dart';
import 'package:ezscrip/settings/model/userprefs.dart';
import 'package:ezscrip/setup/model/localemodel.dart';
import 'package:ezscrip/util/constants.dart';
import 'package:ezscrip/util/keys.dart';
import 'package:ezscrip/profile/model/appUser.dart';
import 'package:ezscrip/util/gender.dart';
import 'package:ezscrip/consultation/model/indicator.dart';
import 'package:ezscrip/consultation/model/status.dart';
import 'package:ezscrip/util/mode.dart';
import 'package:ezscrip/util/ui_constants.dart';
import 'package:ezscrip/util/utils_service.dart';
import 'package:enum_to_string/enum_to_string.dart';

import 'package:ezscrip/consultation/model/consultation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/svg.dart';
import 'package:flutter/material.dart';
import 'package:ezscrip/app_bar.dart';
import 'package:flutter_vector_icons/flutter_vector_icons.dart';
import 'package:global_configuration/global_configuration.dart';
import 'package:intl/intl.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:no_context_navigation/no_context_navigation.dart';
import 'package:path_provider/path_provider.dart';
import 'package:super_tooltip/super_tooltip.dart';
import 'package:watch_it/watch_it.dart';
import '../../util/semantics.dart' as semantic;

import '../model/medStatus.dart';
import '../model/medschedule.dart';

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

class ConsultationPage extends StatefulWidget {
  final Consultation consultation;
  final AppUser user;
  final bool isEditable;
  Mode? mode;

  ConsultationPage(
      {required this.consultation,
      required this.user,
      required this.isEditable,
      this.mode,
      Key key = K.consultationViewPage})
      : super(key: key);

  @override
  ConsultationPageState createState() => ConsultationPageState(
      this.consultation, this.user, this.isEditable, this.mode);
}

class ConsultationPageState extends State<ConsultationPage>
    with TickerProviderStateMixin {
  Consultation _consultation;
  late SuperTooltipController _viewPrescriptionTooltipController,
      _checkButtonTooltipController;
  AppUser _user;
  bool _isEditable;
  Mode? _mode;
  ConsultationPageState(
      this._consultation, this._user, this._isEditable, this._mode);

  @override
  void initState() {
    _viewPrescriptionTooltipController = SuperTooltipController();
    _checkButtonTooltipController = SuperTooltipController();

    if (_mode == Mode.Preview) {
      FocusNodes.prescriptionVieButton
          .addListener(prescriptionViewButtonListener);

      FocusNodes.checkConsultatioButton.addListener(checkButtonListener);

      SchedulerBinding.instance.addPostFrameCallback((Duration _) {
        FocusScope.of(context).requestFocus(FocusNodes.prescriptionVieButton);
      });
    }

    super.initState();
  }

  @override
  void dispose() {
    FocusNodes.prescriptionVieButton
        .removeListener(prescriptionViewButtonListener);
    FocusNodes.checkConsultatioButton.removeListener(checkButtonListener);
    super.dispose();
  }

  void prescriptionViewButtonListener() {
    if (FocusNodes.prescriptionVieButton.hasFocus) {
      _viewPrescriptionTooltipController.showTooltip();
    }
  }

  void checkButtonListener() {
    if (FocusNodes.checkConsultatioButton.hasFocus) {
      _checkButtonTooltipController.showTooltip();
    }
  }

  Widget buildEditAction(Consultation consultation) {
    return IconButton(
      icon: const Icon(Icons.edit, size: 30),
      onPressed: () async {
        AppUser user = await GetIt.instance<UserPrefs>().getUser();
        Map<String, dynamic> propertiesMap =
            await GetIt.instance<UtilsService>().loadProperties();
        navService.pushReplacementNamed(Routes.EditConsultation,
            args: ConsultationEditPageArguments(
                mode: Mode.Edit,
                consultation: consultation,
                user: user,
                propertiesMap: propertiesMap));
      },
    );
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

    IconButton viewPrescriptionButton = IconButton(
        key: K.prescriptionViewButton,
        focusNode: FocusNodes.prescriptionVieButton,
        icon: IconTheme(
            data: Theme.of(context)
                .iconTheme
                .copyWith(size: UI.PAGE_ACTION_BTN_SIZE),
            child: const Icon(FontAwesome5Solid.file_prescription)),
        onPressed: () async {

          pw.Document prescDocument;
          String? template;
          String? format;
          Uint8List byteData;
          String? signatureSvg;

           if ((await GetIt.instance<UserPrefs>().getUserType()) ==  UserType.Basic) {

               int count = await GetIt.instance<UserPrefs>().getCounter();

               if (count >= GlobalConfiguration().get(C.BASIC_PLAN_QUOTA)) {
                  _showMessage(
                      Icons.warning,
                      "Exceeded quota for Basic plan. Upgrade to premium version.",
                     Colors.red);
                  return;
               }
            }
            await GetIt.instance<UserPrefs>().incrementCounter();
            template = await GetIt.instance<UserPrefs>().getTemplate();
            byteData = (await rootBundle.load(template!)).buffer.asUint8List();
            format = await GetIt.instance<UserPrefs>().getFormat();

            bool isPrescriptionSet =
                await GetIt.instance<UserPrefs>().isSignatureEnabled();

            if (isPrescriptionSet) {
              signatureSvg = await GetIt.instance<UserPrefs>().getSignature();
            }
            if (format!.indexOf("1") > 0) {
              prescDocument = await PrescriptionGenerator_1.buildPrescription(
                  _consultation,
                  _user,
                  GetIt.instance<LocaleModel>().getLocale,
                  byteData,
                  isPrescriptionSet,
                  await GetIt.instance<UtilsService>().getTimeIconMap(),
                  GlobalConfiguration().getValue(C.PRESCRIPTION_BLOCK_LENGTH),
                  GlobalConfiguration().getValue(C.PRESCRIPTION_BLOCK_WEIGHT),
                  signatureSvg);
            } else {
              prescDocument = await PrescriptionGenerator_2.buildPrescription(
                  _consultation,
                  _user,
                  GetIt.instance<LocaleModel>().getLocale,
                  byteData,
                  isPrescriptionSet,
                  await GetIt.instance<UtilsService>().getTimeIconMap(),
                  signatureSvg);
            }

            Uint8List pdfData = await prescDocument.save();
            File savedFile = await File(
                    "${(await getApplicationCacheDirectory()).path}/prescription.pdf")
                .create();
            File prescFile = await savedFile.writeAsBytes(pdfData);

            navService.pushNamed(Routes.ViewPrescription,
                args: PrescriptionPdfViewPageArguments(
                    generatedFile: prescFile.path,
                    mode: Mode.View,
                    status: _consultation.getStatus()));
        }
        
    );

    actions.add((_mode == Mode.Preview)
        ? buildTooltipWidget(
            viewPrescriptionButton,
            _viewPrescriptionTooltipController,
            13,
            AppLocalizations.of(context)!.prescription,
            "Preview  prescription",
            FocusNodes.checkConsultatioButton)
        : viewPrescriptionButton);

    if (_isEditable) {
      IconButton checkButton = IconButton(
          key: K.checkButton,
          focusNode: FocusNodes.checkConsultatioButton,
          icon: IconTheme(
              data: Theme.of(context)
                  .iconTheme
                  .copyWith(size: UI.PAGE_ACTION_BTN_SIZE),
              child: const Icon(Foundation.check,
                  size: 30,
                  semanticLabel: semantic.S.CONSULTATION_DONE_BUTTON)),
          onPressed: () async {
            if (_isEditable) {
              navService.pushAndRemoveUntil(
                  MaterialPageRoute(
                      builder: (context) => HomePage(showDemo: false)),
                  predicate: (route) => route.isFirst);
            } else {
              navService.goBack();
            }
          });

      actions.add((_mode == Mode.Preview)
          ? buildTooltipWidget(
              checkButton,
              _checkButtonTooltipController,
              13,
              AppLocalizations.of(context)!.complete,
              "Finish consultation",
              FocusNodes.homeButton)
          : checkButton);
    }

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
        popupDirection: TooltipDirection.down,
        content: Container(
          height: 60,
          width: 150,
          alignment: Alignment.topLeft,
          padding: EdgeInsets.all(2),
          child: AutoSizeText(
            content,
            maxLines: 3,
            minFontSize: 10,
            maxFontSize: 12,
            softWrap: true,
            style: TextStyle(
              color: Theme.of(context).indicatorColor,
            ),
          ),
        ),
        showCloseButton: true,
        closeButtonType: CloseButtonType.inside,
        onHide: () async {
          if (nextFocusNode == FocusNodes.homeButton) {
            navService.pushNamedAndRemoveUntil(Routes.OnBoardingFinish,
                predicate: (route) => route.isFirst);
          } else {
            FocusScope.of(context).requestFocus(nextFocusNode);
          }
        },
        child: targetWidget);
  }

  Widget buildNotesWidget() {
    return Stack(alignment: Alignment.topCenter, children: [
      Container(
          height: 40,
          color: Theme.of(context).primaryColor,
          child:
              Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            Container(
                alignment: Alignment.centerLeft,
                child: Stack(alignment: Alignment.centerLeft, children: [
                  const Padding(
                      padding: EdgeInsets.only(left: 10),
                      child: Icon(Foundation.clipboard_notes,
                          size: 30, color: Colors.black)),
                  Padding(
                      padding: const EdgeInsets.only(left: 50),
                      child: AutoSizeText(AppLocalizations.of(context)!.notes,
                          style: Theme.of(context).textTheme.titleLarge)),
                ])),
            (_consultation.getNotes().isNotEmpty)
                ? Padding(
                    padding: const EdgeInsets.only(left: 5, right: 5),
                    child: CircleAvatar(
                        radius: 10,
                        backgroundColor: Theme.of(context).indicatorColor,
                        child: CircleAvatar(
                            radius: 8,
                            backgroundColor: Theme.of(context).primaryColor,
                            child: AutoSizeText(
                                _consultation.getNotes().length.toString(),
                                style:
                                    Theme.of(context).textTheme.titleMedium))))
                : SizedBox(height: 20, width: 20, child: Container()),
          ])),
      Container(
          margin: const EdgeInsets.only(top: 40),
          decoration: BoxDecoration(
              border: Border.all(
                  color: Theme.of(context).primaryColor, width: 2.5)),
          child: buildNotesContentWidget())
    ]);
  }

  int getNotesListLength() {
    int len = 0;

    _consultation.getNotes().forEach((note) {
      len += (note.length / 30).ceil();
    });

    return len;
  }

  Widget buildNotesContentWidget() {
    return SizedBox(
        height: getNotesListLength() * UI.EXPANSION_TILE_ROW_HEIGHT,
        child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: _consultation
                .getNotes()
                .map((note) => Padding(
                    padding: const EdgeInsets.symmetric(
                        vertical: 10, horizontal: 10),
                    child: Row(children: [
                      CircleAvatar(
                        radius: 5,
                        backgroundColor: Theme.of(context).indicatorColor,
                      ),
                      Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 10),
                          child: AutoSizeText(note,
                              style: Theme.of(context).textTheme.titleSmall))
                    ])))
                .toList()));
  }

  Widget buildSymptonListWidget() {
    List<Widget> symptomChips = _consultation.getSymptoms().map((symptom) {
      return SizedBox(
          height: UI.EXPANSION_TILE_ROW_HEIGHT,
          child: Row(children: [
            Stack(alignment: Alignment.centerLeft, children: [
              CircleAvatar(
                  radius: 5, backgroundColor: Theme.of(context).indicatorColor),
              Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 25),
                  child: AutoSizeText(symptom,
                      style: Theme.of(context).textTheme.bodySmall)),
            ])
          ]));
    }).toList();

    return Container(
        width: MediaQuery.of(context).size.width - 5,
        alignment: Alignment.centerLeft,
        constraints: BoxConstraints(
            minHeight: UI.EXPANSION_TILE_ROW_HEIGHT,
            maxHeight: (_consultation.getSymptoms().length > 0)
                ? UI.EXPANSION_TILE_ROW_HEIGHT *
                    _consultation.getSymptoms().length
                : UI.EXPANSION_TILE_ROW_HEIGHT),
        margin: const EdgeInsets.symmetric(
            horizontal: UI.EXPANSION_TILE_HORIZONTAL_PADDING,
            vertical: UI.EXPANSION_TILE_VERTICAL_PADDING),
        color: Colors.white,
        key: K.symptomsViewList,
        child: Column(children: symptomChips));
  }

  Widget buildSymptomsWidget() {
    return Stack(
      alignment: Alignment.topCenter,
      children: [
        Container(
          height: 40,
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
          child: ClipRRect(
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(8),
              topRight: Radius.circular(8),
            ),
            child: Container(
                color: Theme.of(context).primaryColor,
                alignment: Alignment.centerLeft,
                child: Stack(alignment: Alignment.centerLeft, children: [
                  const Padding(
                      padding: EdgeInsets.only(left: 10),
                      child: Icon(Ionicons.body, size: 30)),
                  Padding(
                      padding: const EdgeInsets.only(left: 50),
                      child: AutoSizeText(
                          AppLocalizations.of(context)!.symptoms,
                          style: Theme.of(context).textTheme.titleLarge)),
                ])),
            // (_consultation.getSymptoms().isNotEmpty)
            //     ? Padding(
            //         padding: const EdgeInsets.only(left: 5, right: 5),
            //         child: CircleAvatar(
            //             radius: 10,
            //             backgroundColor: Theme.of(context).indicatorColor,
            //             child: CircleAvatar(
            //                 radius: 8,
            //                 backgroundColor:
            //                     Theme.of(context).primaryColor,
            //                 child: AutoSizeText(
            //                     _consultation
            //                         .getSymptoms()
            //                         .length
            //                         .toString(),
            //                     style: Theme.of(context)
            //                         .textTheme
            //                         .titleMedium))))
            //     : SizedBox(height: 20, width: 20, child: Container()),
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(top: 40),
          child: Container(
              decoration: const BoxDecoration(
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(8),
                  bottomRight: Radius.circular(8),
                ),
                border: Border(
                  bottom: BorderSide(color: Colors.blueGrey, width: 1.5),
                  left: BorderSide(color: Colors.blueGrey, width: 1.5),
                  right: BorderSide(color: Colors.blueGrey, width: 1.5),
                ),
              ),
              child: buildSymptonListWidget()),
        )
      ],
    );
  }

  Widget buildTestsWidget() {
    return Stack(alignment: Alignment.topCenter, children: [
      Container(
          height: 40,
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
          child: ClipRRect(
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(8),
              topRight: Radius.circular(8),
            ),
            child: Container(
                alignment: Alignment.centerLeft,
                color: Theme.of(context).primaryColor,
                child: Stack(alignment: Alignment.centerLeft, children: [
                  Padding(
                      padding: const EdgeInsets.only(left: 10),
                      child: SvgPicture.asset(Images.tests,
                          width: 25, height: 25)),
                  Padding(
                      padding: const EdgeInsets.only(left: 50),
                      child: AutoSizeText(
                          AppLocalizations.of(context)!.investigations,
                          style: Theme.of(context).textTheme.titleLarge)),
                ])),
          )),
      Padding(
          padding: const EdgeInsets.only(top: 40),
          child: Container(
              decoration: const BoxDecoration(
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(8),
                  bottomRight: Radius.circular(8),
                ),
                border: Border(
                  bottom: BorderSide(color: Colors.blueGrey, width: 1.5),
                  left: BorderSide(color: Colors.blueGrey, width: 1.5),
                  right: BorderSide(color: Colors.blueGrey, width: 1.5),
                ),
              ),
              child: buildTestsListWidget())),
    ]);
  }

  Widget buildMedicalHistoryWidget() {
    return Container(
        child: Stack(children: [
      Container(
        height: 40,
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
        child: ClipRRect(
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(8),
            topRight: Radius.circular(8),
          ),
          child: Container(
              alignment: Alignment.centerLeft,
              color: Theme.of(context).primaryColor,
              child: Stack(alignment: Alignment.centerLeft, children: [
                const Padding(
                  padding: EdgeInsets.only(left: 10),
                  child: Icon(Octicons.file_diff, size: 25),
                ),
                Padding(
                    padding: const EdgeInsets.only(left: 50),
                    child: AutoSizeText(
                        AppLocalizations.of(context)!.medicalHistory,
                        style: Theme.of(context).textTheme.titleLarge)),
              ])),
        ),
      ),
      Padding(
          padding: const EdgeInsets.only(top: 40),
          child: Container(
              decoration: const BoxDecoration(
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(8),
                  bottomRight: Radius.circular(8),
                ),
                border: Border(
                  bottom: BorderSide(color: Colors.blueGrey, width: 1.5),
                  left: BorderSide(color: Colors.blueGrey, width: 1.5),
                  right: BorderSide(color: Colors.blueGrey, width: 1.5),
                ),
              ),
              child: buildMedicalHistoryListWidget())),
    ]));
  }

  Widget buildParameterListTable() {
    List<Widget> parameterListWidget =
        _consultation.getParameters().map((parameter) {
      return SizedBox(
          height: UI.PRESCRIPTION_TILE_ROW_HEIGHT,
          child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Stack(alignment: Alignment.centerLeft, children: [
                  CircleAvatar(
                      backgroundColor: Theme.of(context).indicatorColor,
                      radius: 5),
                  Container(
                      height: UI.EXPANSION_TILE_ROW_HEIGHT,
                      alignment: Alignment.center,
                      padding: const EdgeInsets.symmetric(horizontal: 25),
                      child: Text(parameter.getName(),
                          style: Theme.of(context).textTheme.bodySmall)),
                ]),
                Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Text(
                        "${parameter.getValue()} ${(parameter.getUnit() != null) ? parameter.getUnit() : ''}",
                        style: Theme.of(context).textTheme.bodySmall)),
              ]));
    }).toList();

    return Container(
        key: K.parametersViewList,
        constraints: BoxConstraints(
            minHeight: UI.EXPANSION_TILE_ROW_HEIGHT,
            maxHeight: (_consultation.getParameters().length > 0)
                ? _consultation.getParameters().length *
                    UI.EXPANSION_TILE_ROW_HEIGHT
                : UI.EXPANSION_TILE_ROW_HEIGHT),
        width: MediaQuery.of(context).size.width - 5,
        margin: const EdgeInsets.symmetric(
            horizontal: UI.EXPANSION_TILE_HORIZONTAL_PADDING,
            vertical: UI.EXPANSION_TILE_VERTICAL_PADDING),
        color: Colors.white,
        child: Column(children: parameterListWidget));
  }

  Widget buildTestsListWidget() {
    List<Widget> testChips = _consultation.getTests().map((test) {
      return SizedBox(
          height: UI.EXPANSION_TILE_ROW_HEIGHT,
          child: Row(children: [
            Stack(alignment: Alignment.centerLeft, children: [
              CircleAvatar(
                radius: 5,
                backgroundColor: Theme.of(context).indicatorColor,
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 15),
                child: AutoSizeText(test,
                    style: Theme.of(context).textTheme.bodySmall),
              )
            ])
          ]));
    }).toList();

    return Container(
        color: Colors.white,
        key: K.investgationsViewList,
        margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        width: MediaQuery.of(context).size.width - 5,
        constraints: BoxConstraints(
            minHeight: UI.EXPANSION_TILE_ROW_HEIGHT,
            maxHeight: (_consultation.getTests().length > 0)
                ? _consultation.getTests().length * UI.EXPANSION_TILE_ROW_HEIGHT
                : UI.EXPANSION_TILE_ROW_HEIGHT),
        child: Column(children: testChips));
  }

  Widget buildIndicatorWidget() {
    return Stack(children: [
      Container(
        height: 40,
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
        child: ClipRRect(
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(8),
              topRight: Radius.circular(8),
            ),
            child: Container(
                alignment: Alignment.centerLeft,
                color: Theme.of(context).primaryColor,
                child: Stack(alignment: Alignment.centerLeft, children: [
                  const Padding(
                      padding: EdgeInsets.only(left: 10),
                      child: Icon(Octicons.pulse, size: 25)),
                  Padding(
                      padding: const EdgeInsets.only(left: 50),
                      child: AutoSizeText("Vital Signs",
                          style: Theme.of(context).textTheme.titleLarge)),
                ]))),
      ),
      Padding(
          padding: const EdgeInsets.only(top: 40),
          child: Container(
              width: MediaQuery.of(context).size.width - 10,
              decoration: const BoxDecoration(
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(8),
                  bottomRight: Radius.circular(8),
                ),
                border: Border(
                  bottom: BorderSide(color: Colors.blueGrey, width: 1.5),
                  left: BorderSide(color: Colors.blueGrey, width: 1.5),
                  right: BorderSide(color: Colors.blueGrey, width: 1.5),
                ),
              ),
              child: buildIndicatorsContentWidget()))
    ]);
  }

  Widget buildIndicatorsContentWidget() {
    List<Widget> indicatorWidgets = [];

    indicatorWidgets = _consultation.indicators.map((indicator) {
      switch (indicator.getType()) {
        case IndicatorType.BloodPressure:
          return buildBPIndicatorWidget(indicator);

        case IndicatorType.HeartRate:
          return buildHRWidget(indicator);

        case IndicatorType.Spo2:
          return buildSpo2Widget(indicator);

        case IndicatorType.Temperature:
          return buildTemperatureWidget(indicator);
      }
    }).toList();

    return Container(
        alignment: Alignment.centerLeft,
        constraints: BoxConstraints(
            minHeight: UI.EXPANSION_TILE_ROW_HEIGHT,
            maxHeight: (_consultation.getIndicators().length == 0)
                ? UI.EXPANSION_TILE_ROW_HEIGHT
                : UI.EXPANSION_TILE_ROW_HEIGHT *
                    _consultation.getIndicators().length),
        margin: const EdgeInsets.symmetric(
            horizontal: UI.EXPANSION_TILE_HORIZONTAL_PADDING,
            vertical: UI.EXPANSION_TILE_VERTICAL_PADDING),
        color: Colors.white,
        key: K.vitalSignsViewTile,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.start,
          children: indicatorWidgets
              .map(
                (indicator) => Container(
                  height: UI.EXPANSION_TILE_ROW_HEIGHT,
                  child: indicator,
                ),
              )
              .toList(),
        ));
  }

  Widget buildMedicalHistoryListWidget() {
    List<Widget> conditionsListWidget =
        _consultation.getMedicalHistory().map((disease) {
      return SizedBox(
          height: UI.EXPANSION_TILE_ROW_HEIGHT,
          child:
              Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            Stack(alignment: Alignment.centerLeft, children: [
              CircleAvatar(
                radius: 5,
                backgroundColor: Theme.of(context).indicatorColor,
              ),
              Padding(
                  padding: const EdgeInsets.only(left: 30),
                  child: AutoSizeText(disease.getDiseaseName(),
                      style: Theme.of(context).textTheme.bodySmall)),
            ]),
            Stack(alignment: Alignment.centerLeft, children: [
              const Icon(Icons.timelapse, size: 25),
              Padding(
                  padding: const EdgeInsets.only(left: 30),
                  child: AutoSizeText(
                      "${disease.getDuration().toString()}  ${EnumToString.convertToString(disease.getDurationType())}",
                      style: Theme.of(context).textTheme.bodySmall))
            ])
          ]));
    }).toList();

    return Container(
        key: K.medicaHistoryViewList,
        width: MediaQuery.of(context).size.width - 5,
        constraints: BoxConstraints(
            minHeight: UI.EXPANSION_TILE_ROW_HEIGHT,
            maxHeight: (_consultation.getMedicalHistory().length > 0)
                ? _consultation.getMedicalHistory().length *
                    UI.EXPANSION_TILE_ROW_HEIGHT
                : UI.EXPANSION_TILE_ROW_HEIGHT),
        margin: const EdgeInsets.symmetric(
            horizontal: UI.EXPANSION_TILE_HORIZONTAL_PADDING,
            vertical: UI.EXPANSION_TILE_VERTICAL_PADDING),
        color: Colors.white,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: conditionsListWidget,
        ));
  }

  Widget buildTestParametersWidget() {
    return Container(
        child: Stack(children: [
      Container(
        height: 40,
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
        child: ClipRRect(
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(8),
            topRight: Radius.circular(8),
          ),
          child: Container(
              alignment: Alignment.centerLeft,
              color: Theme.of(context).primaryColor,
              child: Stack(alignment: Alignment.centerLeft, children: [
                Padding(
                  padding: const EdgeInsets.only(left: 10),
                  child: SvgPicture.asset(Images.medicalTest,
                      height: 30, width: 30),
                ),
                Padding(
                    padding: const EdgeInsets.only(left: 50),
                    child: AutoSizeText(
                        AppLocalizations.of(context)!.parameters,
                        style: Theme.of(context).textTheme.titleLarge)),
              ])),
        ),
      ),
      Padding(
          padding: const EdgeInsets.only(top: 40),
          child: Container(
              decoration: const BoxDecoration(
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(8),
                  bottomRight: Radius.circular(8),
                ),
                border: Border(
                  bottom: BorderSide(color: Colors.blueGrey, width: 1.5),
                  left: BorderSide(color: Colors.blueGrey, width: 1.5),
                  right: BorderSide(color: Colors.blueGrey, width: 1.5),
                ),
              ),
              child: buildParameterListTable())),
    ]));
  }

  Widget buildPortraitPatientSummaryWidget() {
    return Stack(alignment: Alignment.topCenter, children: [
      Container(
        height: 40,
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
        child: ClipRRect(
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(8),
              topRight: Radius.circular(8),
            ),
            child: Container(
                alignment: Alignment.centerLeft,
                color: Theme.of(context).primaryColor,
                child: Stack(alignment: Alignment.centerLeft, children: [
                  const Padding(
                      padding: EdgeInsets.only(left: 10),
                      child: Icon(Icons.person)),
                  Padding(
                      padding: const EdgeInsets.only(left: 50),
                      child: AutoSizeText(AppLocalizations.of(context)!.patient,
                          style: Theme.of(context).textTheme.titleLarge)),
                ]))),
      ),
      Padding(
          padding: const EdgeInsets.only(top: 40),
          child: Container(
              decoration: const BoxDecoration(
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(8),
                  bottomRight: Radius.circular(8),
                ),
                border: Border(
                  bottom: BorderSide(color: Colors.blueGrey, width: 1.5),
                  left: BorderSide(color: Colors.blueGrey, width: 1.5),
                  right: BorderSide(color: Colors.blueGrey, width: 1.5),
                ),
              ),
              child: buildPatientDetialsWidget()))
    ]);
  }

  Widget buildPatientDetialsWidget() {
    return Container(
        key: K.patientSummaryViewTile,
        height: UI.EXPANSION_TILE_ROW_HEIGHT * 2,
        margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 0),
        child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(children: [
                SizedBox(
                  width: MediaQuery.of(context).size.width * 0.55,
                  child: Stack(alignment: Alignment.centerLeft, children: [
                    AutoSizeText(AppLocalizations.of(context)!.name,
                        style: Theme.of(context).textTheme.titleMedium),
                    Padding(
                        padding: const EdgeInsets.only(left: 70),
                        child: AutoSizeText(_consultation.getPatientName()))
                  ]),
                ),
                SizedBox(
                    width: MediaQuery.of(context).size.width * 0.3,
                    child: Stack(alignment: Alignment.centerLeft, children: [
                      AutoSizeText(AppLocalizations.of(context)!.age,
                          style: Theme.of(context).textTheme.titleMedium),
                      Padding(
                          padding: const EdgeInsets.only(left: 40),
                          child: AutoSizeText(
                              "${_consultation.getPatientAge().toString()} ${AppLocalizations.of(context)!.years}")),
                    ]))
              ]),
              Row(children: [
                SizedBox(
                  width: MediaQuery.of(context).size.width * 0.5,
                  child: Stack(children: [
                    AutoSizeText(AppLocalizations.of(context)!.gender,
                        style: Theme.of(context).textTheme.titleMedium),
                    Padding(
                        padding: const EdgeInsets.only(left: 70),
                        child: AutoSizeText(GenderHelper.toValue(
                            _consultation.getGender(), context)))
                  ]),
                ),
                SizedBox(
                  width: MediaQuery.of(context).size.width * 0.35,
                  child: Stack(children: [
                    AutoSizeText(AppLocalizations.of(context)!.weight,
                        style: Theme.of(context).textTheme.titleMedium),
                    Padding(
                        padding: const EdgeInsets.only(left: 60),
                        child: AutoSizeText(
                            "${_consultation.getWeight().toString()} ${AppLocalizations.of(context)!.kg}"))
                  ]),
                )
              ])
            ]));
  }

  Widget getTimeIcon(Time time) {
    Icon icon;
    switch (time) {
      case Time.daybreak:
        icon = const Icon(
          key: K.daybreak,
          Feather.sunrise,
          size: 20,
          color: Colors.black,
          semanticLabel: semantic.S.PRESCRIPTION_TILE_TIME_DAYBREAK,
        );
        break;
      case Time.morning:
        icon = const Icon(
          key: K.morning,
          Fontisto.day_sunny,
          size: 20,
          color: Colors.black,
          semanticLabel: semantic.S.PRESCRIPTION_TILE_TIME_MORNING,
        );
        break;
      case Time.afternoon:
        icon = const Icon(
          key: K.afternoon,
          Ionicons.sunny,
          size: 20,
          color: Colors.black,
          semanticLabel: semantic.S.PRESCRIPTION_TILE_TIME_AFTERNOON,
        );
        break;
      case Time.evening:
        icon = const Icon(
          key: K.evening,
          Feather.sunset,
          size: 20,
          color: Colors.black,
          semanticLabel: semantic.S.PRESCRIPTION_TILE_TIME_EVENING,
        );
        break;
      case Time.night:
        icon = const Icon(
          key: K.night,
          Fontisto.night_clear,
          size: 20,
          color: Colors.black,
          semanticLabel: semantic.S.PRESCRIPTION_TILE_TIME_NIGHT,
        );
        break;
    }

    return icon;
  }

  Widget buildPrescriptionDrugInfoContent(MedSchedule prescription) {
    String drugLabelText =
        "${(prescription.getPreparation() == Preparation.Tablet && prescription.isHalfTab!) ? '1/2' : prescription.dosage.toString()} ${EnumToString.convertToString(prescription.unit, camelCase: true).toLowerCase()} ${prescription.getName()}";

    String frequencyLabelText =
        "${prescription.frequencyType.toString().substring(prescription.frequencyType.toString().indexOf(".") + 1, prescription.frequencyType.toString().indexOf("_"))}";

    return SizedBox(
        width: MediaQuery.of(context).size.width * 0.6,
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Padding(
              padding: const EdgeInsets.all(2),
              child: Stack(alignment: Alignment.centerLeft, children: [
                getUnitIcon(prescription.getPreparation()),
                Semantics(
                  identifier: semantic.S.PRESCRIPTION_TILE_MED_QTY,
                  container: true,
                  child: Padding(
                      padding: const EdgeInsets.only(left: 30, right: 2),
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
                      padding: const EdgeInsets.only(left: 50),
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

  Widget buildDisontinuePrescriptionContent(MedSchedule prescription) {
    return Semantics(
        identifier: semantic.S.PRESCRIPTION_TILE,
        container: true,
        child: Container(
          width: MediaQuery.of(context).size.width * 0.875,
          height: UI.EXPANSION_TILE_ROW_HEIGHT,
          foregroundDecoration: StrikeThroughDecoration(),
          alignment: Alignment.centerLeft,
          child: Stack(alignment: Alignment.centerLeft, children: [
            getUnitIcon(prescription.getPreparation()),
            Padding(
                padding: const EdgeInsets.only(left: 30, right: 3),
                child: AutoSizeText(
                    "${prescription.getName()} ${EnumToString.convertToString(prescription.getPreparation(), camelCase: true)}",
                    style: Theme.of(context).textTheme.titleMedium))
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
              width: MediaQuery.of(context).size.width * 0.25,
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

      Card card = Card(
        color: Colors.white,
        margin: const EdgeInsets.all(2),
        elevation: 0,
        borderOnForeground: false,
        child: Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: prescriptionContent),
      );

      prescriptionChips.add(card);
    }

    return Stack(alignment: Alignment.topCenter, children: [
      Container(
          decoration: BoxDecoration(
            color: Theme.of(context).indicatorColor,
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(8),
              topRight: Radius.circular(8),
            ),
            border: const Border(
                top: BorderSide(width: 1.5),
                left: BorderSide(width: 1.5),
                right: BorderSide(width: 1.5),
                bottom: BorderSide(width: 1.5)),
          ),
          child: ClipRRect(
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(8),
                topRight: Radius.circular(8),
              ),
              child: Container(
                  height: 40,
                  alignment: Alignment.centerLeft,
                  color: Theme.of(context).primaryColor,
                  child: Stack(alignment: Alignment.centerLeft, children: [
                    const Padding(
                      padding: EdgeInsets.only(left: 10),
                      child: Icon(MaterialCommunityIcons.pill, size: 30),
                    ),
                    Padding(
                        padding: const EdgeInsets.only(left: 50),
                        child: AutoSizeText(
                            AppLocalizations.of(context)!.medication,
                            style: Theme.of(context).textTheme.titleLarge)),
                  ])))),
      Padding(
          padding: const EdgeInsets.only(top: 40),
          child: Container(
              decoration: const BoxDecoration(
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(8),
                  bottomRight: Radius.circular(8),
                ),
                border: Border(
                  bottom: BorderSide(width: 1.5),
                  left: BorderSide(width: 1.5),
                  right: BorderSide(width: 1.5),
                ),
              ),
              child: Container(
                  margin: const EdgeInsets.all(1),
                  height: (prescriptionChips.isEmpty)
                      ? UI.EXPANSION_TILE_EMPTY_SIZE
                      : prescriptionChips.length * 60,
                  color: Colors.white,
                  child: ListView(
                      key: K.prescriptionViewList,
                      children: prescriptionChips))))
    ]);
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

  Widget buildHeaderWidget() {
    return Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
      Stack(alignment: Alignment.centerLeft, children: [
        const Icon(Icons.calendar_today, size: UI.DIALOG_ACTION_BTN_SIZE),
        Padding(
            padding: const EdgeInsets.only(left: 30),
            child: AutoSizeText(
                DateFormat.yMMMd(Localizations.localeOf(context).languageCode)
                    .format(_consultation.getStart()),
                style: Theme.of(context).textTheme.titleLarge)),
        const Padding(
            padding: EdgeInsets.only(left: 140),
            child: Icon(Icons.timer, size: UI.DIALOG_ACTION_BTN_SIZE)),
        Padding(
            padding: const EdgeInsets.only(left: 170),
            child: AutoSizeText(
                DateFormat.jm(Localizations.localeOf(context).languageCode)
                    .format(_consultation.getStart())))
      ]),
      AutoSizeText(StatusHelper.toValue(_consultation.getStatus(), context),
          style:
              const TextStyle(fontWeight: FontWeight.bold, color: Colors.blue)),
    ]);
  }

  Widget buildTemperatureWidget(Indicator indicator) {
    return Stack(alignment: Alignment.centerLeft, children: [
      CircleAvatar(
          radius: 5, backgroundColor: Theme.of(context).indicatorColor),
      Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: AutoSizeText(
            key: K.tempViewField,
            "${AppLocalizations.of(context)!.temperature} ${indicator.toString().trim()}",
            style: Theme.of(context).textTheme.bodySmall),
      ),
    ]);
  }

  Widget buildSpo2Widget(Indicator indicator) {
    return Stack(alignment: Alignment.centerLeft, children: [
      CircleAvatar(
        radius: 5,
        backgroundColor: Theme.of(context).indicatorColor,
      ),
      Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: AutoSizeText(
              key: K.spo2Field,
              "${AppLocalizations.of(context)!.spo2} ${indicator.toString().trim()}",
              style: Theme.of(context).textTheme.bodySmall)),
    ]);
  }

  Widget buildBPIndicatorWidget(Indicator indicator) {
    return Stack(alignment: Alignment.centerLeft, children: [
      CircleAvatar(
        radius: 5,
        backgroundColor: Theme.of(context).indicatorColor,
      ),
      Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: AutoSizeText(
            key: K.bpViewField,
            "${AppLocalizations.of(context)!.bp} ${indicator.toString().trim()}",
            style: Theme.of(context).textTheme.bodySmall),
      )
    ]);
  }

  Widget buildHRWidget(Indicator indicator) {
    return Stack(alignment: Alignment.centerLeft, children: [
      CircleAvatar(
        radius: 5,
        backgroundColor: Theme.of(context).indicatorColor,
      ),
      Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: AutoSizeText(
            key: K.hrField,
            "${AppLocalizations.of(context)!.hr} ${indicator.toString().trim()}",
            style: Theme.of(context).textTheme.bodySmall),
      )
    ]);
  }

  Widget getUnitIcon(Preparation preparation) {
    Widget icon = const Icon(MaterialCommunityIcons.pill, size: 20);

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

  Widget buildPortraitNotesTileWidget() {
    return Stack(children: [
      Container(
          height: 40,
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
          child: ClipRRect(
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(8),
                topRight: Radius.circular(8),
              ),
              child: Container(
                  alignment: Alignment.centerLeft,
                  color: Theme.of(context).primaryColor,
                  child: Stack(alignment: Alignment.centerLeft, children: [
                    const Padding(
                        padding: EdgeInsets.only(left: 10),
                        child: Icon(Foundation.clipboard_notes,
                            size: 30, color: Colors.black)),
                    Padding(
                        padding: const EdgeInsets.only(left: 50),
                        child: AutoSizeText(AppLocalizations.of(context)!.notes,
                            style: Theme.of(context).textTheme.titleLarge)),
                  ])))),
      Padding(
          padding: const EdgeInsets.only(top: 40),
          child: Container(
              key: K.notesViewList,
              width: MediaQuery.of(context).size.width - 10,
              decoration: const BoxDecoration(
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(8),
                  bottomRight: Radius.circular(8),
                ),
                border: Border(
                  bottom: BorderSide(color: Colors.blueGrey, width: 1.5),
                  left: BorderSide(color: Colors.blueGrey, width: 1.5),
                  right: BorderSide(color: Colors.blueGrey, width: 1.5),
                ),
              ),
              constraints: const BoxConstraints(
                  minHeight: UIConstants.EXPANSION_TILE_EMPTY_SIZE),
              //padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 0),
              child: Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: UI.EXPANSION_TILE_HORIZONTAL_PADDING,
                      vertical: UI.EXPANSION_TILE_VERTICAL_PADDING),
                  child: Column(
                      children: _consultation
                          .getNotes()
                          .map((note) => Container(
                              padding: const EdgeInsets.symmetric(
                                  vertical: UI.EXPANSION_TILE_VERTICAL_PADDING),
                              child: Row(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  children: [
                                    Padding(
                                      padding: const EdgeInsets.only(
                                          left: 4, right: 8),
                                      child: CircleAvatar(
                                          radius: 5,
                                          backgroundColor:
                                              Theme.of(context).indicatorColor),
                                    ),
                                    Expanded(
                                        child: Text(note,
                                            softWrap: true,
                                            overflow: TextOverflow.clip,
                                            maxLines: 4,
                                            style: Theme.of(context)
                                                .textTheme
                                                .bodyMedium)),
                                  ])))
                          .toList()))))
    ]);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBarBuilder.buildAppBar(
            context,
            const Icon(MaterialCommunityIcons.prescription, size: 25),
            "${(_isEditable) ? AppLocalizations.of(context)!.review : AppLocalizations.of(context)!.view} ${AppLocalizations.of(context)!.prescription}",
            buildActions(),
            buildEditAction(_consultation)),
        body: Container(
            height: MediaQuery.of(context).size.height - 5,
            width: MediaQuery.of(context).size.width,
            decoration:
                BoxDecoration(border: Border.all(color: Colors.grey[200]!)),
            child: SingleChildScrollView(
                child: Container(
                    padding: const EdgeInsets.all(5),
                    decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey[300]!)),
                    child: Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          buildHeaderWidget(),
                          const SizedBox(height: 10),
                          buildPortraitPatientSummaryWidget(),
                          const SizedBox(height: 10),
                          buildIndicatorWidget(),
                          const SizedBox(height: 10),
                          buildSymptomsWidget(),
                          const SizedBox(height: 10),
                          buildMedicalHistoryWidget(),
                          const SizedBox(height: 10),
                          buildTestParametersWidget(),
                          const SizedBox(height: 10),
                          buildTestsWidget(),
                          const SizedBox(height: 10),
                          buildPortraitNotesTileWidget(),
                          const SizedBox(height: 10),
                          buildPrescriptionWidget(Orientation.portrait),
                          const SizedBox(height: 10),
                        ])))));
  }
}
