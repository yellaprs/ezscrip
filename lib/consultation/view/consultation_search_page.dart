import 'dart:async';
import 'dart:io';
import 'package:ezscrip/consultation/consultation_routes.dart';
import 'package:ezscrip/consultation/repository/consultation_repository.dart';
import 'package:ezscrip/consultation/view/select_date_page.dart';
import 'package:ezscrip/prescription/prescription_routes.dart';
import 'package:ezscrip/route_constants.dart';
import 'package:ezscrip/settings/model/userprefs.dart';
import 'package:ezscrip/setup/model/localemodel.dart';
import 'package:ezscrip/util/constants.dart';
import 'package:ezscrip/util/focus_nodes.dart';
import 'package:ezscrip/util/keys.dart';
import 'package:ezscrip/profile/model/appUser.dart';
import 'package:ezscrip/prescription/services/prescription_generator_1.dart';
import 'package:ezscrip/prescription/services/prescription_generator_2.dart';
import 'package:ezscrip/util/search_option.dart';
import 'package:ezscrip/consultation/model/consultation.dart';
import 'package:ezscrip/util/semantics.dart' as semantic;
import 'package:ezscrip/util/mode.dart';
import 'package:ezscrip/consultation/model/status.dart';

import 'package:ezscrip/util/utils_service.dart';
import 'package:enum_to_string/enum_to_string.dart';
import 'package:flutter/services.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:ezscrip/app_bar.dart';
import 'package:flutter_vector_icons/flutter_vector_icons.dart';
import 'package:get_it/get_it.dart';
import 'package:global_configuration/global_configuration.dart';
import 'package:intl/intl.dart';
import 'package:no_context_navigation/no_context_navigation.dart';
import 'package:path_provider/path_provider.dart';
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

import 'package:pdf/widgets.dart' as pw;
import 'package:toggle_switch/toggle_switch.dart';
import 'package:flutter_expanded_tile/flutter_expanded_tile.dart';
import 'package:auto_size_text/auto_size_text.dart';

enum SearchMode { search, result }

enum DateOption { Before, After, Between }

class ConsultationSearchPage extends StatefulWidget {
  final AppUser user;
  final Mode mode;
  const ConsultationSearchPage(
      {required this.user,
      required this.mode,
      Key key = K.consultationSearchPage})
      : super(key: key);
  @override
  ConsultationSearchPageState createState() =>
      ConsultationSearchPageState(user, mode);
}

class ConsultationSearchPageState extends State<ConsultationSearchPage> {
  late String _searchText;
  late bool _dateFilter;
  late DateOption _dateOption;
  late DateTime _startDate, _endDate;
  late SearchOption _searchOption;
  late SearchMode _searchMode;
  late ItemScrollController _itemScrollController;
  late ItemPositionsListener _itemPositionsListener;
  late int _scollIndex;
  late double _consultationTileHeight;
  late List<int> _visibleIndices;
  late ExpandedTileController _startController, _endController;
  late TextEditingController _searchTextController;
  late bool _invalidDates;
  AppUser _user;
  Mode _mode;

  ConsultationSearchPageState(this._user, this._mode);

  void initState() {
    _visibleIndices = [];
    _scollIndex = 0;
    _dateFilter = false;

    _searchText = "";
    _searchOption = SearchOption.SearchByName;
    _dateOption = DateOption.Before;

    _itemScrollController = ItemScrollController();
    _itemPositionsListener = ItemPositionsListener.create();
    _itemPositionsListener.itemPositions.addListener(() {
      _visibleIndices = getPpositionsView();

      setState(() {});
    });

    _searchMode = SearchMode.search;
    _searchTextController = TextEditingController();
    _startController = ExpandedTileController();
    _endController = ExpandedTileController();
    _searchTextController.text = _searchText;
    _consultationTileHeight = 70;

    _endDate = DateTime(
        DateTime.now().year, DateTime.now().month, DateTime.now().day, 23, 59);
    _startDate =
        DateTime(_endDate.year - 1, _endDate.month, _endDate.day, 0, 0);

    _invalidDates = false;

    super.initState();
  }

  List<int> getPpositionsView() {
    List<int> itemPostions = _itemPositionsListener.itemPositions.value
        .where((item) {
          final isTopVisible = item.itemLeadingEdge > 0;
          final isBottomVisible = item.itemTrailingEdge <= 1;
          return isTopVisible && isBottomVisible;
        })
        .map((item) => item.index)
        .toList();

    return itemPostions;
  }

  Future<List<Consultation>> searchConsultations(
      String searchStr,
      SearchOption option,
      bool dateFilter,
      String dateOption,
      DateTime? start,
      DateTime? end) async {
    List<Consultation> consultations = [];

    if (dateFilter) {
      if (dateOption == "Before") {
        consultations = await GetIt.instance<ConsultationRespository>()
            .seacrhBy(option, searchStr, end: start);
      }
      if (dateOption == "After") {
        consultations = await GetIt.instance<ConsultationRespository>()
            .seacrhBy(option, searchStr, start: end);
      }
      if (dateOption == "Between") {
        consultations = await GetIt.instance<ConsultationRespository>()
            .seacrhBy(option, searchStr, start: start, end: end);
      }
    } else {
      consultations = await GetIt.instance<ConsultationRespository>()
          .seacrhBy(option, searchStr);
    }

    return consultations;
  }

  void scrollToIndex() {
    _itemScrollController.scrollTo(
        index: _scollIndex, duration: const Duration(seconds: 1));
  }

  Widget buildDateFilterWidgets(Orientation orientation) {
    List<Widget> rowWidgets = [];

    List<Widget> filterWidgets = [];

    filterWidgets.add(Container(
        alignment: Alignment.center,
        margin: const EdgeInsets.all(2),
        child: SizedBox(
            width: MediaQuery.of(context).size.width * 0.4,
            key: K.datePicker,
            child: Stack(alignment: Alignment.centerLeft, children: [
              Align(
                alignment: Alignment.centerRight,
                child: IconButton(
                  key: K.selectDateLeftButton,
                  padding: const EdgeInsets.all(2),
                  icon: const Icon(Icons.edit,
                      size: 20, semanticLabel: semantic.S.START_DATE_BUTTON),
                  onPressed: () async {
                    var datePicked = await showModalBottomSheet(
                      context: context,
                      isScrollControlled: true,
                      shape: const RoundedRectangleBorder(
                        borderRadius: BorderRadius.vertical(
                          top: Radius.circular(20),
                        ),
                      ),
                      builder: (context) =>
                          SelectDatePage(selectedDate: _startDate),
                    );

                    if (datePicked != null) {
                      if (_dateOption == DateOption.After) {
                        _startDate = DateTime(datePicked.year, datePicked.month,
                            datePicked.day, 23, 59);
                      } else if (_dateOption == DateOption.Before) {
                        _endDate = DateTime(datePicked.year, datePicked.month,
                            datePicked.day, 0, 0);
                      } else {
                        _startDate = DateTime(datePicked.year, datePicked.month,
                            datePicked.day, 0, 0);
                      }

                      if (_startDate.isAfter(_endDate)) {
                        _invalidDates = true;
                      } else {
                        setState(() {});
                      }
                    }
                  },
                ),
              ),
              AutoSizeText(DateFormat("dd MMM yyyy").format(_startDate),
                  style: (!_invalidDates)
                      ? Theme.of(context).textTheme.labelLarge
                      : Theme.of(context)
                          .textTheme
                          .labelLarge!
                          .copyWith(color: Colors.red),
                  key: K.date1ValueLabel1),
            ]))));

    filterWidgets.add(Visibility(
        visible: _dateOption == DateOption.Between,
        child: Container(
            alignment: Alignment.center,
            margin: const EdgeInsets.all(2),
            child: SizedBox(
                width: MediaQuery.of(context).size.width * 0.4,
                key: K.datePicker,
                child: Stack(alignment: Alignment.centerLeft, children: [
                  AutoSizeText(DateFormat("dd MMM yyyy").format(_endDate),
                      key: K.date1ValueLabel2,
                      style: (!_invalidDates)
                          ? Theme.of(context).textTheme.labelLarge
                          : Theme.of(context)
                              .textTheme
                              .labelLarge!
                              .copyWith(color: Colors.red)),
                  Align(
                    alignment: Alignment.centerRight,
                    child: IconButton(
                      key: K.selectDateRightButton,
                      padding: const EdgeInsets.all(2),
                      icon: const Icon(Icons.edit,
                          size: 20, semanticLabel: semantic.S.END_DATE_BUTTON),
                      onPressed: () async {
                        var datePicked = await showModalBottomSheet(
                          context: context,
                          isScrollControlled: true,
                          shape: const RoundedRectangleBorder(
                            borderRadius: BorderRadius.vertical(
                              top: Radius.circular(20),
                            ),
                          ),
                          builder: (context) => SelectDatePage(
                              selectedDate: _endDate, initialDate: _startDate),
                        );

                        if (_dateOption == DateOption.Between &&
                            datePicked != null) {
                          if (_startDate.isBefore(_endDate)) {
                            _endDate = DateTime(datePicked.year,
                                datePicked.month, datePicked.day, 23, 59);
                          } else {
                            _invalidDates = true;
                          }

                          setState(() {});
                        }
                      },
                    ),
                  )
                ])))));

    rowWidgets.add(Expanded(
        flex: 1,
        child: Container(
            margin: const EdgeInsets.only(top: 5, left: 5, right: 5, bottom: 5),
            padding: const EdgeInsets.all(5),
            child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: filterWidgets))));

    return Container(
        alignment: Alignment.centerLeft,
        padding: const EdgeInsets.only(top: 5, left: 5, right: 5, bottom: 5),
        height: MediaQuery.of(context).size.height *
            ((orientation == Orientation.portrait) ? 0.125 : 0.4) *
            ((_startController.isExpanded || _endController.isExpanded)
                ? 1
                : 0.6),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.all(Radius.circular(8.0)),
          border: Border(
              top:
                  BorderSide(color: Theme.of(context).indicatorColor, width: 1),
              left:
                  BorderSide(color: Theme.of(context).indicatorColor, width: 1),
              right:
                  BorderSide(color: Theme.of(context).indicatorColor, width: 1),
              bottom: BorderSide(
                  color: Theme.of(context).indicatorColor, width: 1)),
        ),
        child: Row(
            mainAxisAlignment: MainAxisAlignment.start, children: rowWidgets));
  }

  CustomSlidableAction buildPrescriptionAction(Consultation consultation) {
    return CustomSlidableAction(
        key: K.prescriptionViewButton,
        backgroundColor: Theme.of(context).indicatorColor,
        padding: const EdgeInsets.all(2),
        child: SizedBox(
            child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
              const Icon(FontAwesome5Solid.file_prescription,
                  size: 25,
                  semanticLabel: semantic.S.HOME_VIEW_PRESCRIPTION_BUTTON),
              AutoSizeText(AppLocalizations.of(context)!.prescription,
                  minFontSize: 8),
            ])),
        onPressed: (context) async {
          Uint8List byteData;
          pw.Document prescDocument;
          String? letterHead;
          String? format;
          String? signatureSvg;

          Map<String, String> timeIconsMap =
              await GetIt.instance<UtilsService>().getTimeIconMap();

          int prescriptionBlockLength =
              GlobalConfiguration().get(C.PRESCRIPTION_BLOCK_LENGTH) as int;

          int prescriptionBlockWeight =
              GlobalConfiguration().get(C.PRESCRIPTION_BLOCK_WEIGHT) as int;

          if (consultation != null) {
            letterHead = await GetIt.instance<UserPrefs>().getTemplate();
            format = await GetIt.instance<UserPrefs>().getFormat();
            byteData =
                (await rootBundle.load(letterHead!)).buffer.asUint8List();

            bool isPrescriptionEnabled =
                await GetIt.instance<UserPrefs>().isSignatureEnabled();

            if (isPrescriptionEnabled) {
              signatureSvg = await GetIt.instance<UserPrefs>().getSignature();
            }
            if (format == 1) {
              prescDocument = await PrescriptionGenerator_1.buildPrescription(
                  consultation,
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
                  consultation,
                  _user,
                  GetIt.instance<LocaleModel>().getLocale,
                  byteData,
                  isPrescriptionEnabled,
                  timeIconsMap,
                  signatureSvg);
            }

            Uint8List pdfData = await prescDocument.save();
            File savedFile = await File(
                    (await getApplicationSupportDirectory()).path +
                        "/prescription.pdf")
                .create();

            File prescFile = await savedFile.writeAsBytes(pdfData);

            navService.pushNamed(Routes.ViewPrescription,
                args: PrescriptionPdfViewPageArguments(
                    generatedFile: prescFile.path,
                    mode: Mode.View,
                    status: consultation.getStatus()));
          }
        });
  }

  CustomSlidableAction buildViewConsultationAction(Consultation consultation) {
    return CustomSlidableAction(
      key: K.consultationViewButton,
      autoClose: true,
      padding: const EdgeInsets.all(2),
      backgroundColor: Theme.of(context).indicatorColor,
      child: SizedBox(
        child:
            Column(mainAxisAlignment: MainAxisAlignment.spaceAround, children: [
          const Icon(FontAwesome5Solid.notes_medical,
              size: 25,
              semanticLabel: semantic.S.HOME_VIEW_CONSULTATION_BUTTON),
          AutoSizeText(
            AppLocalizations.of(context)!.view,
            minFontSize: 8,
          )
        ]),
      ),
      onPressed: (context) async {
        AppUser user = await GetIt.instance<UserPrefs>().getUser();

        navService.pushNamed(Routes.ViewConsultation,
            args: ConsultationPageArguments(
                consultation: consultation, user: user, isEditable: false));
      },
    );
  }

  CustomSlidableAction buildEditConsultationAction(
      Consultation consultation, Mode mode) {
    return CustomSlidableAction(
      backgroundColor: Theme.of(context).indicatorColor,
      autoClose: true,
      padding: const EdgeInsets.all(2),
      key: Key("${consultation.id.toString()}editConsultatio.labelMedium"),
      onPressed: (context) async {
        AppUser user = await GetIt.instance<UserPrefs>().getUser();
        Map<String, dynamic> propertiesMap =
            await GetIt.instance<UtilsService>().loadProperties();

        navService.pushNamed(Routes.EditConsultation,
            args: ConsultationEditPageArguments(
                mode: mode,
                consultation: consultation,
                user: user,
                propertiesMap: propertiesMap));
      },
      child: SizedBox(
          width: 50,
          child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                const Icon(Icons.edit,
                    size: 25,
                    semanticLabel: semantic.S.HOME_EDIT_CONSULTATION_BUTTON),
                Padding(
                  padding: const EdgeInsets.all(2),
                  child: AutoSizeText(AppLocalizations.of(context)!.edit,
                      minFontSize: 6, softWrap: true),
                ),
              ])),
    );
  }

  List<CustomSlidableAction> consultationActions(Consultation consultation) {
    List<CustomSlidableAction> actions = [];

    if (consultation.getStatus() == Status.Complete) {
      actions.add(buildPrescriptionAction(consultation));
    } else {
      actions.add(buildEditConsultationAction(consultation, Mode.Edit));
    }
    actions.add(buildViewConsultationAction(consultation));

    return actions;
  }

  Widget buildConsultationTile(Consultation consultation) {
    Widget leadingWidget = Stack(alignment: Alignment.centerLeft, children: [
      Stack(alignment: Alignment.center, children: [
        VerticalDivider(
          width: 15.0,
          thickness: 3.0,
          color: Theme.of(context).indicatorColor,
        ),
      ]),
      Stack(alignment: Alignment.topLeft, children: [
        Stack(alignment: Alignment.centerLeft, children: [
          const Padding(
              padding: EdgeInsets.only(left: 15),
              child: Icon(Icons.calendar_today, size: 15)),
          Padding(
              padding: const EdgeInsets.only(left: 35),
              child: AutoSizeText(
                  DateFormat.yMMMd(Localizations.localeOf(context).languageCode)
                      .format(consultation.getStart())))
        ]),
        Padding(
            padding: const EdgeInsets.only(top: 20),
            child: Stack(alignment: Alignment.centerLeft, children: [
              const Padding(
                  padding: EdgeInsets.only(left: 15),
                  child: Icon(Icons.timer, size: 15)),
              Padding(
                  padding: const EdgeInsets.only(left: 35),
                  child: AutoSizeText(DateFormat.jm(
                          Localizations.localeOf(context).languageCode)
                      .format(consultation.getStart())))
            ]))
      ])
    ]);

    Card consultationCard = Card(
        key: const Key("consultationTile"),
        //margin: const EdgeInsets.all(2),
        color: Theme.of(context).primaryColor,
        child: SizedBox(
            height: 80,
            child: Stack(alignment: Alignment.center, children: [
              Align(alignment: Alignment.centerLeft, child: leadingWidget),
              AutoSizeText(consultation.getPatientName()),
            ])));
    return Slidable(
        key: Key("${consultation.id}Slidable"),
        startActionPane: ActionPane(
          motion: const ScrollMotion(),
          children: consultationActions(consultation),
        ),
        child: Builder(
            builder: (BuildContext context) => InkWell(
                onTap: () {
                  final controller = Slidable.of(context);

                  (controller?.actionPaneType.value == ActionPaneType.none)
                      ? controller?.openStartActionPane(
                          duration: const Duration(milliseconds: 500),
                          curve: Curves.decelerate)
                      : controller?.close();
                },
                child: consultationCard)));
  }

  Color getIndicatorColor(Consultation consultation, BuildContext context) {
    Color color = Colors.white;
    DateTime today = DateTime.now();

    if (consultation.getStatus() == Status.Complete) {
      color = Colors.green[100]!;
    } else if (DateFormat("ddMMMyyyy").format(consultation.getStart()) ==
        DateFormat("ddMMMyyyy").format(today)) {
      color = Colors.yellow[100]!;
    } else if (today.day != consultation.getStart().day) {
      color = Colors.red[100]!;
    }
    return color;
  }

  Widget buildScrollNavigation(int length) {
    List<IconButton> navButtons = [];
    if (_visibleIndices != null &&
        _visibleIndices.isNotEmpty &&
        _visibleIndices.length < length &&
        _visibleIndices[_visibleIndices.length - 1] < (length - 1)) {
      navButtons.add(IconButton(
        padding: const EdgeInsets.all(0),
        constraints: const BoxConstraints(),
        iconSize: 15,
        icon: const Icon(Icons.arrow_downward),
        onPressed: () {
          _itemScrollController.scrollTo(
              index: (_visibleIndices[_visibleIndices.length - 1] +
                  _visibleIndices.length),
              duration: const Duration(seconds: 1));
        },
      ));
    }
    if (_visibleIndices != null &&
        _visibleIndices.isNotEmpty &&
        _visibleIndices.length < length &&
        _visibleIndices[0] > 1) {
      navButtons.add(IconButton(
        padding: const EdgeInsets.all(0),
        iconSize: 15,
        icon: const Icon(Icons.arrow_upward),
        onPressed: () {
          _itemScrollController.scrollTo(
              index: ((_visibleIndices[0] - _visibleIndices.length) < 0
                  ? 0
                  : (_visibleIndices[0] - _visibleIndices.length)),
              duration: const Duration(seconds: 1));
        },
      ));
    }
    return ButtonBar(
        alignment: MainAxisAlignment.end,
        mainAxisSize: MainAxisSize.min,
        buttonMinWidth: 5,
        buttonHeight: 10,
        buttonPadding: const EdgeInsets.all(0),
        children: navButtons);
  }

  Widget consultationSearchResults(List<Consultation> consultations) {
    return Stack(children: [
      Container(
        height: 45,
        padding: const EdgeInsets.only(top: 5, left: 5, right: 5, bottom: 5),
        child: Align(
            alignment: Alignment.topRight,
            child: (consultations.isNotEmpty)
                ? Padding(
                    padding: const EdgeInsets.only(top: 5, bottom: 10),
                    child: Stack(alignment: Alignment.centerRight, children: [
                      Visibility(
                          visible: consultations.isNotEmpty,
                          child: Padding(
                              padding: const EdgeInsets.only(right: 10),
                              child:
                                  buildScrollNavigation(consultations.length))),
                      CircleAvatar(
                          radius: 12,
                          backgroundColor: Theme.of(context).indicatorColor,
                          child: CircleAvatar(
                              radius: 8,
                              backgroundColor: Colors.white,
                              child: AutoSizeText(
                                  consultations.length.toString(),
                                  style: const TextStyle(
                                      color: Colors.black,
                                      fontWeight: FontWeight.bold))))
                    ]))
                : SizedBox(height: 10, width: 10, child: Container())),
      ),
      Padding(
          padding: const EdgeInsets.only(top: 35),
          child: Container(
              margin: const EdgeInsets.only(bottom: 10),
              decoration: BoxDecoration(
                borderRadius: const BorderRadius.all(Radius.circular(15)),
                border: Border(
                    top: BorderSide(
                        color: Theme.of(context).indicatorColor, width: 0.5),
                    left: BorderSide(
                        color: Theme.of(context).indicatorColor, width: 0.5),
                    right: BorderSide(
                        color: Theme.of(context).indicatorColor, width: 0.5),
                    bottom: BorderSide(
                        color: Theme.of(context).indicatorColor, width: 0.5)),
              ),
              child: Semantics(
                  identifier: semantic.S.SEARCH_RESULT_LIST,
                  child: ScrollablePositionedList.builder(
                      key: K.consultationSearchList,
                      itemCount: consultations.length,
                      itemBuilder: (context, index) {
                        return buildConsultationTile(
                            consultations.elementAt(index));
                      },
                      itemScrollController: _itemScrollController,
                      itemPositionsListener: _itemPositionsListener))))
    ]);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBarBuilder.buildAppBar(
            context, const Icon(MaterialCommunityIcons.note_search_outline, size: 25), 
            AppLocalizations.of(context)!.search, []),
        body: Container(
            margin: const EdgeInsets.only(top: 30),
            height: MediaQuery.of(context).size.height,
            width: MediaQuery.of(context).size.width,
            child: Container(
              height: MediaQuery.of(context).size.height - 5,
              width: MediaQuery.of(context).size.width - 5,
              padding: const EdgeInsets.all(10.0),
              alignment: Alignment.topCenter,
              child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  mainAxisSize: MainAxisSize.max,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Padding(
                        padding:
                            const EdgeInsets.only(left: 2, right: 2, top: 10),
                        child: SizedBox(
                            height: 60,
                            child: Semantics(
                                identifier: semantic.S.SEARCH_QUERY_FIELD,
                                child: TextField(
                                  key: K.patientNameSearchAutoSizeTextField,
                                  focusNode: FocusNodes
                                      .patientNameSearchAutoSizeTextField,

                                  readOnly:
                                      (_mode == Mode.Preview) ? true : false,
                                  controller: _searchTextController,
                                  textInputAction: TextInputAction.send,
                                  decoration: InputDecoration(
                                    labelText:
                                        "${AppLocalizations.of(context)!.search} by name",
                                    prefixIcon: const Icon(Icons.search),
                                    border: UnderlineInputBorder(
                                        borderSide: BorderSide(
                                            color: Colors.lightBlue[100]!),
                                        borderRadius: BorderRadius.circular(9)),
                                    hintText: AppLocalizations.of(context)!
                                        .fieldLabelMessage(
                                            AppLocalizations.of(context)!
                                                .search),
                                    hintStyle:
                                        const TextStyle(color: Colors.grey),
                                  ),
                                  style: Theme.of(context).textTheme.bodyMedium,
                                  onChanged: (val) {
                                    _searchText = val.trim();
                                  },
                                  onSubmitted: (val) {
                                    setState(() {
                                      _searchText = _searchTextController.text;
                                    });
                                  },
                                  //onEditingComplete: () {},
                                )))),
                    Container(
                        height: MediaQuery.of(context).size.height * 0.065,
                        margin: const EdgeInsets.only(top: 10),
                        decoration: BoxDecoration(
                          borderRadius: const BorderRadius.all(Radius.circular(8.0)),
                          border: Border(
                              top: BorderSide(
                                  color: Theme.of(context).indicatorColor,
                                  width: 1.0),
                              left: BorderSide(
                                  color: Theme.of(context).indicatorColor,
                                  width: 1.0),
                              right: BorderSide(
                                  color: Theme.of(context).indicatorColor,
                                  width: 1.0),
                              bottom: BorderSide(
                                  color: Theme.of(context).indicatorColor,
                                  width: 1.0)),
                        ),
                        padding: const EdgeInsets.all(3),
                        child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              AutoSizeText(AppLocalizations.of(context)!.date,
                                  style:
                                      Theme.of(context).textTheme.titleLarge),
                              Visibility(
                                visible: _dateFilter,
                                child: Semantics(
                                  identifier: semantic.S.SELECT_DATE_SWITCH,
                                  child: ToggleSwitch(
                                    key: K.dateOptionSwitch,
                                    minWidth: 70.0,
                                    minHeight: 30.0,
                                    cornerRadius: 12.0,
                                    fontSize: 10,
                                    borderWidth: 1.0,
                                    borderColor: [
                                      Theme.of(context).indicatorColor
                                    ],
                                    activeFgColor: Colors.white,
                                    inactiveBgColor: Colors.white,
                                    inactiveFgColor: Colors.black,
                                    initialLabelIndex: _dateOption.index,
                                    labels: DateOption.values
                                        .map((e) =>
                                            EnumToString.convertToString(e))
                                        .toList(),
                                    activeBgColors: [
                                      [Theme.of(context).indicatorColor],
                                      [Theme.of(context).indicatorColor],
                                      [Theme.of(context).indicatorColor]
                                    ],
                                    onToggle: (index) {
                                      _dateOption = DateOption.values[index!];
                                      setState(() {});
                                    },
                                  ),
                                ),
                              ),
                              Focus(
                                  focusNode: FocusNodes.dateFilterDropDown,
                                  child: Switch.adaptive(
                                      key: K.dateFilterSwitch,
                                      activeTrackColor:
                                          Theme.of(context).primaryColor,
                                      thumbColor: MaterialStateProperty.all(
                                          Theme.of(context).indicatorColor),
                                      trackOutlineColor:
                                          MaterialStateProperty.all(
                                              Theme.of(context).indicatorColor),
                                      inactiveTrackColor: Colors.white,
                                      inactiveThumbColor: Colors.grey.shade500,
                                      value: _dateFilter,
                                      onChanged: (_mode == Mode.Preview)
                                          ? null
                                          : (value) {
                                              setState(() {
                                                _dateFilter = value;
                                              });
                                            })),
                            ])),
                    const SizedBox(height: 5),
                    (_dateFilter)
                        ? buildDateFilterWidgets(Orientation.portrait)
                        : Container(),
                    Expanded(
                        child: FutureBuilder<List<Consultation>>(
                            future: searchConsultations(
                                _searchText,
                                _searchOption,
                                _dateFilter,
                                EnumToString.convertToString(_dateOption),
                                _startDate,
                                _endDate),
                            builder: (BuildContext context, eventSanpshot) {
                              if (eventSanpshot.hasError) {
                                return Center(
                                    child: AutoSizeText(
                                        eventSanpshot.error.toString()));
                              } else if (eventSanpshot.hasData) {
                                return consultationSearchResults(
                                    eventSanpshot.data!);
                              } else {
                                return const Center(
                                    child: SpinKitThreeBounce(
                                        color: Colors.red, size: 30));
                              }
                            })),
                  ]),
            )));
  }
}
