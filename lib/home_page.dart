import 'dart:convert';

import 'package:ezscrip/consultation/consultation_routes.dart';
import 'package:ezscrip/consultation/model/consultation_model.dart';
import 'package:ezscrip/profile/profile_routes.dart';
import 'package:ezscrip/resources/resources.dart';
import 'package:ezscrip/route_constants.dart';
import 'package:ezscrip/settings/model/userprefs.dart';
import 'package:ezscrip/settings/settings_routes.dart';
import 'package:ezscrip/setup/model/localemodel.dart';
import 'package:ezscrip/util/constants.dart';
import 'package:flutter/scheduler.dart';
import 'package:ezscrip/util/keys.dart';
import 'package:ezscrip/profile/model/appUser.dart';
import 'package:ezscrip/consultation/model/consultation.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:ezscrip/util/mode.dart';
import 'package:ezscrip/util/speciality.dart';
import 'package:ezscrip/util/ui_constants.dart';
import 'package:ezscrip/util/utils_service.dart';
import 'package:flutter/services.dart';
import 'package:flutter_vector_icons/flutter_vector_icons.dart';
import 'package:get_it/get_it.dart';
import 'package:global_configuration/global_configuration.dart';

import 'package:jiffy/jiffy.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:intl/intl.dart';
import 'package:no_context_navigation/no_context_navigation.dart';
import 'package:super_tooltip/super_tooltip.dart';
// import 'package:rate_my_app/rate_my_app.dart';
import 'daytilebuilder.dart';
import 'util/focus_nodes.dart';
import 'package:scrollview_observer/scrollview_observer.dart';
//import 'package:in_app_review/in_app_review.dart';
import 'package:ezscrip/util/logger.dart' as logger;
import 'package:ezscrip/util/semantics.dart' as semantic;
import 'package:double_back_to_close_app/double_back_to_close_app.dart';
import 'package:shimmer/shimmer.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

enum CalendarScrollDirection { Forward, Reverse }

class HomePage extends StatefulWidget {
  bool showDemo;

  HomePage({required this.showDemo, Key key = K.homePage}) : super(key: key);
  @override
  _HomePageState createState() => _HomePageState(this.showDemo);
}

class _HomePageState extends State<HomePage> with TickerProviderStateMixin {
  late DateTime _today;
  late ValueNotifier<DateTime> _focussedDate;
  late ScrollController _timeLineScrollController;
  late GlobalKey _todayTileKey;
  late ListObserverController observerController;
  //final InAppReview inAppReview = InAppReview.instance;
  final bool showDemo;
  late int initialScrollOffset;

  late SuperTooltipController _profileTooltipController,
      _preferencesTooltipController,
      _settingsTooltipController,
      _searchTooltipController,
      _fabButtonTooltipController;

  _HomePageState(this.showDemo);

  @override
  void initState() {
    _today = DateTime(
        DateTime.now().year, DateTime.now().month, DateTime.now().day, 0, 0);

    _timeLineScrollController = ScrollController();

    _focussedDate = ValueNotifier<DateTime>(_today);

    _todayTileKey =
        GlobalKey(debugLabel: DateFormat("ddMMMyyyy").format(_today));

    observerController = ListObserverController(
        controller: _timeLineScrollController)
      ..initialIndex =
          new DateTime(_today.year, _today.month, 1).difference(_today).inDays;

    if (this.showDemo) {
      _profileTooltipController = SuperTooltipController();
      _preferencesTooltipController = SuperTooltipController();
      _settingsTooltipController = SuperTooltipController();
      _searchTooltipController = SuperTooltipController();
      _fabButtonTooltipController = SuperTooltipController();

      FocusNodes.profileNavigationButton.addListener(() {
        if (FocusNodes.profileNavigationButton.hasFocus) {
          _profileTooltipController.showTooltip();
        }
      });

      FocusNodes.letterHeadNavigationButton.addListener(() {
        if (FocusNodes.letterHeadNavigationButton.hasFocus) {
          _preferencesTooltipController.showTooltip();
        }
      });

      FocusNodes.settingsNavButton.addListener(() {
        if (FocusNodes.settingsNavButton.hasFocus) {
          _settingsTooltipController.showTooltip();
        }
      });
      FocusNodes.consultationSearchNavButton.addListener(() {
        if (FocusNodes.consultationSearchNavButton.hasFocus) {
          _searchTooltipController.showTooltip();
        }
      });

      FocusNodes.consultFabButton.addListener(() {
        if (FocusNodes.consultFabButton.hasFocus) {
          _fabButtonTooltipController.showTooltip();
        }
      });

      SchedulerBinding.instance.addPostFrameCallback((Duration _) {
        FocusScope.of(context).requestFocus(FocusNodes.profileNavigationButton);
      });
    }

    super.initState();
  }

  Color getAutoSizeTextColor(DateTime date, bool isLeading) {
    Color color;

    if (date.isBefore(DateTime(_today.year, _today.month, 1)) ||
        date.isAfter(DateTime(
            _today.year, _today.month, Jiffy.now().daysInMonth, 23, 59))) {
      color = Colors.black;
    } else if (DateFormat("ddMMMyyyy").format(date) ==
        DateFormat("ddMMMyyyy").format(DateTime.now())) {
      color = (isLeading) ? Colors.red : Colors.white;
    } else {
      color = Theme.of(context).primaryColorDark.withOpacity(1.0);
    }

    return color;
  }

  PreferredSize buildAppBarHeaderWidget() {
    List<Widget> actions = [];

    Widget preferencesButton = IconButton(
      tooltip: "Select Template",
      key: K.letterHeadNavigationButton,
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
      constraints: const BoxConstraints(),
      icon: Focus(
        focusNode: FocusNodes.letterHeadNavigationButton,
        child: IconTheme(
            data: Theme.of(context).iconTheme,
            child: SvgPicture.asset(Images.userPreferences,
                height: UI.HOME_PAGE_NAVBAR_BTN_SIZE,
                width: UI.HOME_PAGE_NAVBAR_BTN_SIZE,
                semanticsLabel: semantic.S.HOME_APPBAR_PREFERNCES_BUTTON)),
      ),
      onPressed: () async {
        String? letterTemplate;
        String? format;

        letterTemplate = await GetIt.instance<UserPrefs>().getTemplate();
        format = await GetIt.instance<UserPrefs>().getFormat();

        navService.pushNamed(Routes.LetterHeadSettings,
            args: LetterheadSelectionPageArguments(
                mode: Mode.Edit,
                letterHead: letterTemplate!,
                selectedFormat: format!));
      },
    );

    Widget settingsButton = IconButton(
        tooltip: 'Settings',
        key: K.settingsButton,
        icon: Focus(
          focusNode: FocusNodes.settingsNavButton,
          child: IconTheme(
              data: Theme.of(context).iconTheme,
              child: const Icon(Ionicons.settings,
                  size: UI.HOME_PAGE_NAVBAR_BTN_SIZE,
                  semanticLabel: semantic.S.HOME_APPBAR_SETTINGS_BUTTON)),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 2, vertical: 4),
        constraints: const BoxConstraints(),
        onPressed: () async {
          int? dataRetentionPeriod;
          bool? isDataRetentionEnabled =
              await GetIt.instance<UserPrefs>().isDataRetentionEnabled();

          if (!isDataRetentionEnabled) {
            navService.pushNamed(Routes.DataRetentionSettings,
                args: DataRetentionSettingPageArguments(
                    mode: Mode.Edit,
                    dataRetentionEnabled: isDataRetentionEnabled));
          } else {
            dataRetentionPeriod =
                await GetIt.instance<UserPrefs>().getDataRetentionPeriod();

            navService.pushNamed(Routes.DataRetentionSettings,
                args: DataRetentionSettingPageArguments(
                    mode: Mode.Edit,
                    dataRetentionEnabled: isDataRetentionEnabled,
                    dataRetentionPeriod: dataRetentionPeriod));
          }
        });

    Widget searchButton = IconButton(
        tooltip: 'Consultation Search',
        key: K.consultationSearchNButton,
        constraints: const BoxConstraints(),
        padding: const EdgeInsets.symmetric(horizontal: 2, vertical: 4),
        icon: Focus(
            focusNode: FocusNodes.consultationSearchNavButton,
            child: IconTheme(
                data: Theme.of(context).iconTheme,
                child: const Icon(MaterialCommunityIcons.note_search_outline,
                    size: UI.HOME_PAGE_NAVBAR_BTN_SIZE,
                    semanticLabel: semantic.S.HOME_APPBAR_SEARCH_BUTTON))),
        onPressed: () async {
          AppUser user = await GetIt.instance<UserPrefs>().getUser();

          navService.pushNamed(Routes.SearchConsultations,
              args:
                  ConsultationSearchPageArguments(user: user, mode: Mode.Edit));
        });

    if (this.showDemo) {
      actions.add(buildPreferencesTooltipWidget(preferencesButton));
      actions.add(buildSettingsTooltipWidget(settingsButton));
      actions.add(buildSearchTooltipWidget(searchButton));
    } else {
      actions.add(preferencesButton);
      actions.add(settingsButton);
      actions.add(searchButton);
    }

    actions.add(IconButton(
      tooltip: 'Logout',
      key: K.logoutButton,
      constraints: const BoxConstraints(),
      icon: Focus(
        focusNode: FocusNodes.logout,
        child: IconTheme(
            data: Theme.of(context).iconTheme,
            child: const Icon(
              MaterialCommunityIcons.logout,
              size: UI.HOME_PAGE_NAVBAR_BTN_SIZE,
              semanticLabel: semantic.S.HOME_APPBAR_SECURITY_BUTTON,
            )),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 2, vertical: 4),
      onPressed: () async {
        navService.pushNamedAndRemoveUntil(Routes.Login,
            predicate: (route) => false);
      },
    ));

    return PreferredSize(
        preferredSize:
            Size.fromHeight(MediaQuery.of(context).size.height * 0.10),
        child: Focus(
          focusNode: FocusNodes.homeButton,
          child: Card(
              elevation: 5,
              margin: EdgeInsets.zero,
              shape: const RoundedRectangleBorder(
                  borderRadius: BorderRadius.all(Radius.circular(1)),
                  side: BorderSide(color: Colors.black12, width: 2.5)),
              borderOnForeground: true,
              child: Container(
                  padding: EdgeInsets.zero,
                  margin: EdgeInsets.zero,
                  color: Theme.of(context).primaryColor,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      buildGreetingWidget(),
                      Container(
                        margin: const EdgeInsets.all(2),
                        child: Semantics(
                            identifier: semantic.S.HOME_ACTION_BAR,
                            child: ButtonBar(
                                buttonPadding: const EdgeInsets.all(
                                    UI.HOME_PAGE_NAVBAR_BTN_PADDING),
                                alignment: MainAxisAlignment.center,
                                children: actions
                                    .map((action) => Container(
                                        padding: const EdgeInsets.only(
                                            left: 2, right: 2),
                                        child: action))
                                    .toList())),
                      )
                    ],
                  ))),
        ));
  }

  Key dateToKey(DateTime date, {String prefix = ''}) {
    return Key('$prefix${date.year}-${date.month}-${date.day}');
  }

  Widget buildTimeLineDayWidget(DateTime date) {
    return FutureBuilder<bool>(
        future: GetIt.instance<ConsultationModel>().loadConsultations(date),
        builder: (context, consultationListSnapshot) {
          if (consultationListSnapshot.hasData) {
            if (consultationListSnapshot.data!) {
              logger.Logger.debug(
                  "Date:${DateFormat('ddMMMyyyy').format(date)}");

              return Container(
                  key: (DateFormat("ddMMMyyyy").format(date) ==
                          DateFormat("ddMMMyyyy").format(_today))
                      ? _todayTileKey
                      : GlobalKey(
                          debugLabel: DateFormat("ddMMMyyyy").format(date)),
                  child: DaytileBuilder(date));
            } else {
              return SpinKitFadingCircle(color: Colors.grey[100], size: 25);
            }
          } else {
            return SpinKitFadingCircle(color: Colors.grey[100], size: 25);
          }
        });
  }

  Widget _buildTimeLineWidget(
      DateTime start, DateTime end, DateTime focussedDate) {
    return ListViewObserver(
        controller: observerController,
        child: ListView.separated(
          padding: const EdgeInsets.all(5),
          itemCount: end.difference(start).inDays,
          controller: _timeLineScrollController,
          itemBuilder: (context, index) {
            DateTime date = start.add(Duration(days: index));

            if (date.isAfter(start)) {
              return buildTimeLineDayWidget(date);
            } else {
              return Container();
            }
          },
          separatorBuilder: (context, index) {
            DateTime date = start.add(Duration(days: index));

            return date.day == 1
                ? Align(
                    alignment: Alignment.topLeft,
                    child: Stack(alignment: Alignment.centerLeft, children: [
                      Container(
                          padding: const EdgeInsets.all(10),
                          alignment: Alignment.centerLeft,
                          width: 60,
                          child: Column(children: [
                            AutoSizeText(
                                DateFormat.MMM(GetIt.instance<LocaleModel>()
                                        .getLocale
                                        .languageCode)
                                    .format(date),
                                style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                    color: Theme.of(context).indicatorColor)),
                            (date.month == 1 || date.month == start.month)
                                ? AutoSizeText(
                                    DateFormat.y(GetIt.instance<LocaleModel>()
                                            .getLocale
                                            .languageCode)
                                        .format(date),
                                    style:
                                        Theme.of(context).textTheme.titleMedium)
                                : Container(),
                          ])),
                      const Padding(
                          padding: EdgeInsets.only(left: 60),
                          child: Divider(thickness: 1.5)),
                      buildTimeLineDayWidget(date)
                    ]))
                : Container();
          },
        ));
    //);
  }

  Widget buildFabButtonTooltipWidget(Widget targetWidget) {
    return SuperTooltip(
        showBarrier: true,
        controller: _fabButtonTooltipController,
        popupDirection: TooltipDirection.up,
        content: Container(
          height: 70,
          width: 150,
          alignment: Alignment.topLeft,
          padding: const EdgeInsets.all(2),
          child: AutoSizeText(
            " Consultation notes and prescription generation.",
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
          String demoDataFile = GlobalConfiguration().getValue(C.DEMO_DATA);

          print("demoData : " + demoDataFile);

          Map<String, dynamic> testDataJson =
              await rootBundle.loadStructuredData(demoDataFile, (value) async {
            return await json.decode(value)!;
          });

          Consultation consultation =
              Consultation.fromMap(testDataJson[C.DEMO_DATA]);

          AppUser user = await GetIt.instance<UserPrefs>().getUser();
          Map<String, dynamic> propertiesMap =
              await GetIt.instance<UtilsService>().loadProperties();
          navService.pushNamed('/edit_consultation',
              args: ConsultationEditPageArguments(
                  mode: Mode.Preview,
                  consultation: consultation,
                  user: user,
                  propertiesMap: propertiesMap));
        },
        child: targetWidget);
  }

  Widget buildSearchTooltipWidget(Widget targetWidget) {
    return SuperTooltip(
      showBarrier: true,
      controller: _searchTooltipController,
      content: Container(
        height: 70,
        width: 150,
        alignment: Alignment.topLeft,
        padding: EdgeInsets.all(2),
        child: AutoSizeText(
          " Search consultation by patient name and date of consultaion.",
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
      onHide: () {
        FocusScope.of(context).requestFocus(FocusNodes.consultFabButton);
      },
      child: Container(
          width: UI.HOME_PAGE_NAVBAR_BTN_SIZE,
          height: UI.HOME_PAGE_NAVBAR_BTN_SIZE,
          child: targetWidget),
    );
  }

  Widget buildSettingsTooltipWidget(Widget targetWidget) {
    return SuperTooltip(
      showBarrier: true,
      controller: _settingsTooltipController,
      content: Container(
        height: 70,
        width: 150,
        alignment: Alignment.topLeft,
        padding: EdgeInsets.all(2),
        child: AutoSizeText(
          " Set Data Retention duration time policy.",
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
      onHide: () {
        FocusScope.of(context)
            .requestFocus(FocusNodes.consultationSearchNavButton);
      },
      child: Container(
          width: UI.HOME_PAGE_NAVBAR_BTN_SIZE,
          height: UI.HOME_PAGE_NAVBAR_BTN_SIZE,
          child: targetWidget),
    );
  }

  Widget buildPreferencesTooltipWidget(Widget targetWidget) {
    return SuperTooltip(
      showBarrier: true,
      controller: _preferencesTooltipController,
      content: Container(
        height: 70,
        width: 150,
        alignment: Alignment.topLeft,
        padding: EdgeInsets.all(2),
        child: AutoSizeText(
          " Select prescription template.",
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
      onHide: () {
        FocusScope.of(context).requestFocus(FocusNodes.settingsNavButton);
      },
      child: Container(
          width: UI.HOME_PAGE_NAVBAR_BTN_SIZE + 2,
          height: UI.HOME_PAGE_NAVBAR_BTN_SIZE + 2,
          child: targetWidget),
    );
  }

  Widget buildProfileTooltipWidget(Widget targetWidget) {
    return SuperTooltip(
      showBarrier: true,
      controller: _profileTooltipController,
      content: Container(
        width: MediaQuery.of(context).size.width * 0.35,
        height: 80,
        padding: EdgeInsets.all(2),
        child: AutoSizeText(
          " View and Edit doctor's profile.",
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
      onHide: () {
        FocusScope.of(context)
            .requestFocus(FocusNodes.letterHeadNavigationButton);
      },
      child: Container(
          width: MediaQuery.of(context).size.width * 0.35 + 10,
          height: 60,
          child: targetWidget),
    );
  }

  Widget buildGreetingWidget() {
    Widget greetingWidget = Container(
        key: K.profileNavigationButton,
        width: MediaQuery.of(context).size.width * 0.35,
        margin: const EdgeInsets.all(8),
        padding: const EdgeInsets.all(2),
        decoration: BoxDecoration(
            border: Border.all(color: Colors.black),
            borderRadius: BorderRadius.circular(10),
            color: Theme.of(context).indicatorColor),
        child: Focus(
            focusNode: FocusNodes.profileNavigationButton,
            child: FutureBuilder<AppUser>(
                future: GetIt.instance<UserPrefs>().getUser(),
                builder: (BuildContext context, user) {
                  if (user.hasData) {
                    return MaterialButton(
                        minWidth: MediaQuery.of(context).size.width * 0.35,
                        elevation: 4,
                        onPressed: () {
                          navService.pushNamed(Routes.ViewProfile,
                              args: ViewProfilePageArguments(user: user.data!));
                        },
                        //shape: const RoundedRectangleBorder(side: BorderSide()),
                        child: Semantics(
                            identifier:
                                semantic.S.HOME_APPBAR_PROFILE_VIEW_BUTTON,
                            child: Stack(
                                alignment: Alignment.centerLeft,
                                children: [
                                  SizedBox(
                                      height: 30,
                                      width: 30,
                                      child: FutureBuilder<List<Speciality>>(
                                          future: GetIt.instance<UtilsService>()
                                              .loadSpecialities(),
                                          builder:
                                              (context, specialitiesSnapshot) {
                                            if (specialitiesSnapshot.hasData) {
                                              return SvgPicture.asset(
                                                  specialitiesSnapshot.data!
                                                      .firstWhere((element) =>
                                                          element.getTitle() ==
                                                          user.data!
                                                              .getSpecialization())
                                                      .getIcon(),
                                                  height: 25,
                                                  width: 25,
                                                  color: Colors.white);
                                            } else {
                                              return CircularProgressIndicator();
                                            }
                                          })),
                                  SizedBox(
                                      width: 150,
                                      height: 50,
                                      child: Padding(
                                          padding:
                                              const EdgeInsets.only(left: 35),
                                          child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              mainAxisAlignment:
                                                  MainAxisAlignment.center,
                                              children: [
                                                AutoSizeText(
                                                  user.data!.getFirstName(),
                                                  minFontSize: 8,
                                                  maxFontSize: 12,
                                                  softWrap: true,
                                                  maxLines: 1,
                                                  style: Theme.of(context)
                                                      .textTheme
                                                      .labelMedium,
                                                  semanticsLabel: semantic.S
                                                      .HOME_APPBAR_PROFILE_VIEW_BUTTON,
                                                ),
                                                AutoSizeText(
                                                  user.data!.getLastName(),
                                                  minFontSize: 8,
                                                  maxFontSize: 12,
                                                  softWrap: true,
                                                  maxLines: 1,
                                                  style: Theme.of(context)
                                                      .textTheme
                                                      .labelMedium,
                                                  semanticsLabel: semantic.S
                                                      .HOME_APPBAR_PROFILE_VIEW_BUTTON,
                                                )
                                              ]))),
                                ])));
                  } else {
                    return Shimmer.fromColors(
                        baseColor: Colors.grey,
                        highlightColor: Theme.of(context).primaryColor,
                        child: SizedBox(height: 40));
                  }
                })));

    return (this.showDemo)
        ? buildProfileTooltipWidget(greetingWidget)
        : greetingWidget;
  }

  Widget buildConsultFloatingActionButton() {
    Widget fabButton = Semantics(
        identifier: semantic.S.HOME_FAB_CONSULTATION_BUTTON,
        child: FloatingActionButton(
            tooltip: " Consultation",
            key: K.consultFabButton,
            focusNode: FocusNodes.consultFabButton,
            backgroundColor: Theme.of(context).indicatorColor,
            shape: const RoundedRectangleBorder(
                borderRadius: BorderRadius.all(Radius.circular(15.0))),
            child: SvgPicture.asset(
              Images.prescription,
              height: UI.CONSULTATION_FAB_BUTTON_SIZE,
              width: UI.CONSULTATION_FAB_BUTTON_SIZE,
              color: Colors.white,
            ),
            onPressed: () async {
              Consultation consultation = Consultation.newConsultation();
              AppUser user = await GetIt.instance<UserPrefs>().getUser();
              Map<String, dynamic> propertiesMap =
                  await GetIt.instance<UtilsService>().loadProperties();

              navService.pushNamed('/edit_consultation',
                  args: ConsultationEditPageArguments(
                      mode: Mode.Add,
                      consultation: consultation,
                      user: user,
                      propertiesMap: propertiesMap));

              setState(() {});
            }));

    return (this.showDemo) ? buildFabButtonTooltipWidget(fabButton) : fabButton;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: DoubleBackToCloseApp(
          snackBar: const SnackBar(
            content: Text('Tap back again to exit'),
          ),
          child: Container(
              margin: EdgeInsets.only(top: MediaQuery.of(context).padding.top),
              height: MediaQuery.of(context).size.height,
              width: MediaQuery.of(context).size.width,
              padding: EdgeInsets.only(
                  top: 1, bottom: MediaQuery.of(context).viewInsets.bottom),
              child: OrientationBuilder(builder: (context, orientation) {
                return Column(children: [
                  Expanded(
                      child: Scaffold(
                          appBar: buildAppBarHeaderWidget(),
                          extendBodyBehindAppBar: true,
                          body: Container(
                              key: K.timeLineKey,
                              padding: EdgeInsets.only(top: 35, bottom: 20),
                              child: Focus(
                                  focusNode: FocusNodes.timeline,
                                  child: FutureBuilder<DateTime>(
                                    future: GetIt.instance<ConsultationModel>()
                                        .getMinDate(),
                                    builder: (context, resultSnapshot) {
                                      if (resultSnapshot.hasData) {
                                        return _buildTimeLineWidget(
                                            DateTime(resultSnapshot.data!.year,
                                                resultSnapshot.data!.month, 1),
                                            DateTime(DateTime.now().year,
                                                    DateTime.now().month + 1, 0)
                                                .add(Duration(days: 1)),
                                            _focussedDate.value);
                                      } else {
                                        return CircularProgressIndicator();
                                      }
                                    },
                                  )))))
                ]);
              }))),
      resizeToAvoidBottomInset: true,
      floatingActionButton: buildConsultFloatingActionButton(),
    );
    //);
  }
}
