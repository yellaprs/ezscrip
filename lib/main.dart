import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:crypto/crypto.dart';
import 'package:ezscrip/consultation/consultation_routes.dart';
import 'package:ezscrip/consultation/model/durationType.dart';
import 'package:ezscrip/consultation/view/add_consultation_page.dart';
import 'package:ezscrip/consultation/view/add_medicalhistory_page.dart';
import 'package:ezscrip/consultation/view/add_medication_page.dart';
import 'package:ezscrip/consultation/view/add_notes_page.dart';
import 'package:ezscrip/consultation/view/add_parameter_page.dart';
import 'package:ezscrip/consultation/view/add_symptom_page.dart';
import 'package:ezscrip/consultation/view/consultation_page.dart';
import 'package:ezscrip/consultation/view/consultation_search_page.dart';
import 'package:ezscrip/consultation/view/remove_medication_page.dart';
import 'package:ezscrip/home_page.dart';
import 'package:ezscrip/home_page_routes.dart';
import 'package:ezscrip/init_splash_page.dart';
import 'package:ezscrip/login_page.dart';
import 'package:ezscrip/prescription/prescription_routes.dart';
import 'package:ezscrip/prescription/view/prescription_preview_page.dart';
import 'package:ezscrip/security/view/forgot_pin_page.dart';
import 'package:ezscrip/setup/view/onboarding_finish_page.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart'; 
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:ezscrip/profile/profile_routes.dart';
import 'package:ezscrip/settings/view/letterhead_selection_page.dart';
import 'package:ezscrip/profile/view/profile_page.dart';
import 'package:ezscrip/profile/view/view_profile_page.dart';
import 'package:ezscrip/route_constants.dart';
import 'package:ezscrip/settings/settings_routes.dart';
import 'package:ezscrip/settings/view/data_retention_setting_page.dart';
import 'package:ezscrip/setup/setup_routes.dart';
import 'package:ezscrip/util/mode.dart';
import 'package:ezscrip/util/ui_constants.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_localized_locales/flutter_localized_locales.dart';
import 'package:get_it/get_it.dart';
import 'package:global_configuration/global_configuration.dart';
import 'package:newrelic_mobile/config.dart';
import 'package:sembast/sembast.dart';
import 'package:workmanager/workmanager.dart';
import 'package:ezscrip/consultation/model/consultation.dart';
import 'package:ezscrip/consultation/model/consultation_model.dart';
import 'package:ezscrip/consultation/model/diseaseGlossary.dart';
import 'package:ezscrip/consultation/model/medicalDictionary.dart';
import 'package:ezscrip/consultation/model/testParametersGlossary.dart';
import 'package:ezscrip/consultation/repository/consultation_repository.dart';
import 'package:ezscrip/infrastructure/db/app_database.dart';
import 'package:ezscrip/infrastructure/db/encryptedCodec.dart';
import 'package:ezscrip/infrastructure/services/securestorage_service.dart';
import 'package:ezscrip/settings/model/userprefs.dart';
import 'package:ezscrip/setup/model/localemodel.dart';
import 'package:ezscrip/setup/view/initialize_page.dart';
import 'package:ezscrip/util/constants.dart';
import 'package:ezscrip/util/logger.dart';
import 'package:ezscrip/util/utils_service.dart';
import 'package:talker_flutter/talker_flutter.dart';
//import 'package:newrelic_mobile/newrelic_mobile.dart';
import 'package:newrelic_mobile/newrelic_navigation_observer.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:rate_my_app/rate_my_app.dart';
import 'package:no_context_navigation/no_context_navigation.dart';

Future<Map<String, dynamic>> getDeviceInfo() async {
  DeviceInfoPlugin deviceInfoPlugin = DeviceInfoPlugin();

  Map<String, dynamic> deviceInfo = {};

  if (Platform.isAndroid) {
    deviceInfo = (await deviceInfoPlugin.androidInfo).data;
  } else if (Platform.isIOS) {
    deviceInfo = (await deviceInfoPlugin.androidInfo).data;
  }

  return deviceInfo;
}

Uint8List _generateEncryptPassword(String password) {
  var blob = Uint8List.fromList(md5.convert(utf8.encode(password)).bytes);
  assert(blob.length == 16);
  return blob;
}

SembastCodec _getEncryptSembastCodec({required String password}) =>
    SembastCodec(
        signature: "_encryptCodecSignature",
        codec: EncryptCodec(_generateEncryptPassword(password)));

@pragma('vm:entry-point')
Future<void> periodicDataRetentionTask() async {

  int deletedConsultationCount = 0;

  Logger.info("Executing Data Retention Task");

  final StoreRef consultationStore = intMapStoreFactory.store('consultations');

  Workmanager().executeTask((task, inputData) async {

    DurationType durationType =
        await GetIt.instance<UserPrefs>().getDataRetentinDurationType();

    int? dataRetentionPeriod =
        int.parse((await SecureStorageService.get(C.DATA_RETENTION_DURATION))!);

    if (durationType == DurationType.Week) {

       dataRetentionPeriod =  dataRetentionPeriod * 7;

    } else if (durationType == DurationType.Month) {

       dataRetentionPeriod = dataRetentionPeriod * 30;

    } else if (durationType == DurationType.Year) {

       dataRetentionPeriod = dataRetentionPeriod * 365;
    }

    Logger.info("Data Retention period:$dataRetentionPeriod");

    Filter filter = Filter.lessThan(
        "start",
        DateTime.now()
            .subtract(Duration(days: dataRetentionPeriod))
            .millisecondsSinceEpoch);

    Logger.info(filter.toString());

    Database db = await AppDatabase.instance.database;

    Logger.info("Database connection established: ${db != null}");

    final recordSnapshots =
        await consultationStore.find(db, finder: Finder(filter: filter));

    List<Consultation> consultationList = recordSnapshots.map((snapshot) {
      final consultation =
          Consultation.fromMap(snapshot.value as Map<String, dynamic>);
      // consultation.id = snapshot.key;
      return consultation;
    }).toList();

    Logger.info("Query excuted with results: ${consultationList.length}");

    if (consultationList.isNotEmpty) {
      List<int> consultationIds =
          consultationList.map((consultation) => consultation.id!).toList();

      Logger.debug(consultationList.toString());

      final finder = Finder(filter: Filter.inList("id", consultationIds));
      deletedConsultationCount =
          await consultationStore.delete(db, finder: finder);

      Logger.info("Deleted consultation count:$deletedConsultationCount");
    }

    Logger.info("Adding log entries:$deletedConsultationCount");

    bool isNotificationSent = await AwesomeNotifications().createNotification(
      content: NotificationContent(
        id: 1,
        channelKey: 'basic_channel',
        title: 'ezscrip data retention task report',
        body: '$deletedConsultationCount consultations have been deleted.',
        wakeUpScreen: true,
        category: NotificationCategory.Service,
        notificationLayout: NotificationLayout.Default,
        bigPicture: 'asset://assets/images/healthcare-icon.png',
        payload: {'uuid': 'uuid-test'},
        autoDismissible: false,
      ),
    );

    Logger.info("Sent notification");

    return Future.value(isNotificationSent);
  });
}

Future<String> setupDataRetentionTask(String taskName, TimeOfDay time, int interval) async {
  int initialDelay;

  if (DateTime.now().hour > time.hour) {
    initialDelay = (24 - DateTime.now().hour) * 60 -
        (60 - DateTime.now().minute) +
        time.hour * 60 +
        time.minute;
  } else {
    initialDelay = (time.hour - DateTime.now().hour) * 60 - (60 - time.minute);
  }

  Workmanager().registerPeriodicTask(
    taskName,
    taskName,
    constraints: Constraints(
        requiresBatteryNotLow: true,
        requiresDeviceIdle: false,
        requiresStorageNotLow: false,
        networkType: NetworkType.not_required),
    initialDelay: Duration(minutes: initialDelay),
    frequency: Duration(minutes: interval),
  );

  Logger.info(
      "Data Retention task registered with values:initialDelay:$initialDelay");

  return taskName;
}

Config initilaizeNewRelicConfig() {
  var appToken = "";
  if (Platform.isIOS) {
    appToken = '24b445fa6d8a5ae3b5c78c02cfab39acFFFFNRAL';
  } else if (Platform.isAndroid) {
    appToken = '24b445fa6d8a5ae3b5c78c02cfab39acFFFFNRAL';
  }

  return Config(
      accessToken: appToken,

      // Android specific option
      // Optional: Enable or disable collection of event data.
      analyticsEventEnabled: true,

      // iOS specific option
      // Optional: Enable or disable automatic instrumentation of WebViews.
      webViewInstrumentation: true,

      // Optional: Enable or disable reporting successful HTTP requests to the MobileRequest event type.
      networkErrorRequestEnabled: true,

      // Optional: Enable or disable reporting network and HTTP request errors to the MobileRequestError event type.
      networkRequestEnabled: true,

      // Optional: Enable or disable crash reporting.
      crashReportingEnabled: true,

      // Optional: Enable or disable interaction tracing. Trace instrumentation still occurs, but no traces are harvested. This will disable default and custom interactions.
      interactionTracingEnabled: true,

      // Optional: Enable or disable capture of HTTP response bodies for HTTP error traces, and MobileRequestError events.
      httpResponseBodyCaptureEnabled: true,

      // Optional: Enable or disable agent logging.
      loggingEnabled: true,

      // Optional: Enable or disable print statements as Analytics Events.
      printStatementAsEventsEnabled: true,

      // Optional: Enable or disable automatic instrumentation of HTTP requests.
      httpInstrumentationEnabled: true);
}

void main() async {
  // runZonedGuarded(() async {

  List<String> medWords = [];
  List<String> diseaseWords = [];
  List<String> parameterNames = [];

  WidgetsBinding widgetsBinding = WidgetsFlutterBinding.ensureInitialized();

  FlutterNativeSplash.preserve(widgetsBinding: widgetsBinding);

  await GlobalConfiguration().loadFromAsset(C.APP_SETTINGS);

  await GlobalConfiguration().loadFromAsset(C.TEST_DATA);

  final UserPrefs userPrefs = UserPrefs();
  await userPrefs.setTemplate(GlobalConfiguration().get(C.DEFAULT_TEMPLATE));

  final isPrefsSet = await userPrefs.isPreferencesSet();
  final localeModel = LocaleModel(const Locale("en", "US"));

  final talker = TalkerFlutter.init();

  try {
    String medDict =
        await rootBundle.loadString("assets/" + C.MEDICAL_DICIONARY_FILE);
    LineSplitter lineSplitter = const LineSplitter();

    medWords = lineSplitter.convert(medDict);

    String diseaseDict =
        await rootBundle.loadString("assets/" + C.DISEASE_GLOSSARY_FILE);

    diseaseWords = lineSplitter.convert(diseaseDict);

    String testParameterGlossary =
        await rootBundle.loadString("assets/" + C.TEST_PARMETERS_FILE);

    parameterNames = lineSplitter.convert(testParameterGlossary);
  } on FileSystemException catch (exception) {
    throw exception;
  }

  final medicalDictionary = MedicalDictionary(medWords);

  final diseaseGlossary = DiaseaseGlossary(diseaseWords);

  final testParameterGlossary = TestParametersGlossary(parameterNames);

  final consultationRespository = ConsultationRespository();

  final utilsService = UtilsService();

  GetIt.instance.registerLazySingleton<AppDatabase>(() => AppDatabase.instance);
  GetIt.instance.registerLazySingleton<LocaleModel>(() => localeModel);

  GetIt.instance.registerLazySingleton<UtilsService>(() => utilsService);

  GetIt.instance.registerLazySingleton<ConsultationRespository>(
      () => consultationRespository);

  GetIt.instance.registerLazySingleton<UserPrefs>(() => userPrefs);

  GetIt.instance
      .registerLazySingleton<ConsultationModel>(() => ConsultationModel());

  GetIt.instance.registerLazySingleton<Talker>(() => talker);

  GetIt.instance
      .registerLazySingleton<MedicalDictionary>(() => medicalDictionary);

  GetIt.instance.registerLazySingleton<DiaseaseGlossary>(() => diseaseGlossary);

  GetIt.instance.registerLazySingleton<TestParametersGlossary>(
      () => testParameterGlossary);

  //Config config = initilaizeNewRelicConfig();

  AwesomeNotifications().initialize(
      // set the icon to null if you want to use the default app icon
      null,
      [
        NotificationChannel(
            channelGroupKey: 'basic_channel_group',
            channelKey: 'basic_channel',
            channelName: 'Basic notifications',
            channelDescription: 'Notification channel for basic tests',
            defaultColor: const Color(0xFF9D50DD),
            ledColor: Colors.white)
      ],
      // Channel groups are only visual and are not required
      channelGroups: [
        NotificationChannelGroup(
            channelGroupKey: 'basic_channel_group',
            channelGroupName: 'Basic group')
      ],
      debug: true);

  Workmanager().initialize(
    periodicDataRetentionTask,
    isInDebugMode: true,
  );

  final RateMyApp rateMyApp = RateMyApp(
    //preferencesPrefix: 'rateMyApp_',
    minDays: 0, // Show rate popup on first day of install.
    minLaunches:
        2, // Show rate popup after 5 launches of app after minDays is passed.
  );

  rateMyApp.init();

  SystemChrome.setPreferredOrientations(
      [DeviceOrientation.portraitUp, DeviceOrientation.portraitDown]);
 
  FlutterNativeSplash.remove();

   FirebaseApp app = await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(ezscripApp(isPrefsSet));
}

Widget getLandingPage(bool isPrefSet) {
  Widget landingPage;
  if (isPrefSet) {
    landingPage = LoginPage();
  } else {
    landingPage = IntroductionPage();
  }
  return landingPage;
}

@immutable
class ezscripApp extends StatefulWidget {
  late bool isPrefsSet;
  ezscripApp(this.isPrefsSet, {Key? key}) : super(key: key);

  static final navigatorKey = GlobalKey<NavigatorState>();

  _ezscripAppState createState() => _ezscripAppState(this.isPrefsSet);
}

class _ezscripAppState extends State<ezscripApp> {
  late bool isPrefsSet;

  _ezscripAppState(this.isPrefsSet);

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      navigatorKey: NavigationService.navigationKey,
      onGenerateRoute: (RouteSettings settings) {
        switch (settings.name) {
          case Routes.InitSplash:
            InitSplashPageArguments args =
                settings.arguments as InitSplashPageArguments;
            return MaterialPageRoute(
                builder: (context) => InitSplashPage(user: args.user));
          case Routes.OnBoardingFinish:
            return MaterialPageRoute(
                builder: (context) => const OnboardingFinishPage());

          case Routes.Home:
            HomePageArguments args = settings.arguments as HomePageArguments;
            return MaterialPageRoute(
                builder: (context) => HomePage(showDemo: args.showDemo));

          case Routes.Login:
            return MaterialPageRoute(builder: (context) => const LoginPage());

          case Routes.Setup:
            return MaterialPageRoute(
                builder: (context) => const IntroductionPage());

          case Routes.ViewProfile:
            ViewProfilePageArguments args =
                settings.arguments as ViewProfilePageArguments;
            return MaterialPageRoute(
                builder: (context) => ViewProfilePage(user: args.user));

          case Routes.EditProfile:
            ProfilePageArguments args =
                settings.arguments as ProfilePageArguments;
            return MaterialPageRoute(
                builder: (context) => ProfilePage(
                    user: args.user,
                    specialityList: args.specialityList,
                    mode: Mode.Edit));

          case Routes.EditConsultation:
            ConsultationEditPageArguments args =
                settings.arguments as ConsultationEditPageArguments;
            return MaterialPageRoute(
                builder: (context) => ConsultationEditPage(
                    mode: args.mode,
                    consultation: args.consultation,
                    user: args.user,
                    propertiesMap: args.propertiesMap));

          case Routes.ViewConsultation:
            ConsultationPageArguments args =
                settings.arguments as ConsultationPageArguments;
            return MaterialPageRoute(
                builder: (context) => ConsultationPage(
                    consultation: args.consultation,
                    user: args.user,
                    isEditable: args.isEditable,
                    mode: args.mode));

          case Routes.SearchConsultations:
            ConsultationSearchPageArguments args =
                settings.arguments as ConsultationSearchPageArguments;
            return MaterialPageRoute(
                builder: (context) =>
                    ConsultationSearchPage(user: args.user, mode: args.mode));

          case Routes.ViewPrescription:
            PrescriptionPdfViewPageArguments args =
                settings.arguments as PrescriptionPdfViewPageArguments;
            return MaterialPageRoute(
                builder: (context) => PrescriptionPdfViewPage(
                    generatedFile: args.generatedFile,
                    mode: args.mode,
                    status: args.status));
          case Routes.LetterHeadSettings:
            LetterheadSelectionPageArguments args =
                settings.arguments as LetterheadSelectionPageArguments;
            return MaterialPageRoute(
                builder: (context) => LetterheadSelectionPage(
                    mode: args.mode,
                    letterHead: args.letterHead,
                    selectedFormat: args.selectedFormat));
          case Routes.DataRetentionSettings:
            DataRetentionSettingPageArguments args =
                settings.arguments as DataRetentionSettingPageArguments;
            return MaterialPageRoute(
                builder: (context) => DataRetentionSettingPage(
                    mode: args.mode,
                    dataRetentionEnabled: args.dataRetentionEnabled,
                    dataRetentionPeriod: args.dataRetentionPeriod));

          case Routes.AddMedication:
            AddMedicationPageArguments args =
                settings.arguments as AddMedicationPageArguments;
            return MaterialPageRoute(
                builder: (context) => AddMedicationPage(
                    mode: args.mode, propertiesMap: args.propertiesMap));

          case Routes.RemoveMedication:
            return MaterialPageRoute(
                builder: (context) => const RemoveMedicationPage());

          case Routes.AddSymptom:
            // AdddSymtomPageArguments args =
            //     settings.arguments as AdddSymtomPageArguments;
            return MaterialPageRoute(
                builder: (context) => const AddSymptomPage());

          case Routes.AddMedicalHistory:
            AddMedicalHistoryArguments args =
                settings.arguments as AddMedicalHistoryArguments;

            return MaterialPageRoute(
                builder: (context) => const AddMedicalHistoryPage());

          case Routes.EditParameter:
            AddParameterPageArguments args =
                settings.arguments as AddParameterPageArguments;
            return MaterialPageRoute(
                builder: (context) =>
                    AddParameterPage(parameterList: args.parameterList));

          case Routes.AddNotes:
            return MaterialPageRoute(
                builder: (context) => const AddNotesPage());

          case Routes.ResetPassword:
            return MaterialPageRoute(
                builder: (context) => const ForgotPinPage());

          default:
            return null;
        }
      },
      title: 'ezscrip',
      theme: ThemeData(
          primarySwatch: Colors.teal,
          primaryColor: Colors.teal[100],
          indicatorColor: Colors.brown,
          primaryIconTheme: const IconThemeData(
              size: UI.HOME_PAGE_NAVBAR_BTN_SIZE, color: Colors.white),
          iconTheme: const IconThemeData(
              size: UI.HOME_PAGE_NAVBAR_BTN_SIZE, color: Colors.brown),
          buttonBarTheme: const ButtonBarThemeData(),
          textTheme: const TextTheme(
              headlineLarge: TextStyle(
                  fontFamily: C.DEFAULT_FONT,
                  fontSize: 30,
                  fontWeight: FontWeight.bold),
              headlineMedium: TextStyle(
                  fontFamily: C.DEFAULT_FONT,
                  fontSize: 28,
                  fontWeight: FontWeight.bold),
              headlineSmall: TextStyle(
                  fontFamily: C.DEFAULT_FONT,
                  fontSize: 26,
                  fontWeight: FontWeight.bold),
              displayLarge: TextStyle(
                  fontFamily: C.DEFAULT_FONT,
                  fontSize: 24,
                  fontWeight: FontWeight.bold),
              displayMedium: TextStyle(
                fontFamily: C.DEFAULT_FONT,
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
              displaySmall: TextStyle(
                fontFamily: C.DEFAULT_FONT,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
              titleLarge: TextStyle(
                  fontFamily: C.DEFAULT_FONT,
                  fontSize: 16,
                  fontWeight: FontWeight.bold),
              titleMedium: TextStyle(
                  fontFamily: C.DEFAULT_FONT,
                  fontSize: 14,
                  fontWeight: FontWeight.bold),
              titleSmall: TextStyle(
                  fontFamily: C.DEFAULT_FONT,
                  fontSize: 12,
                  fontWeight: FontWeight.bold),
              labelLarge: TextStyle(
                  fontFamily: C.DEFAULT_FONT,
                  fontSize: 14,
                  fontWeight: FontWeight.bold),
              bodyLarge: TextStyle(fontFamily: C.DEFAULT_FONT, fontSize: 15),
              bodyMedium: TextStyle(fontFamily: C.DEFAULT_FONT, fontSize: 12),
              bodySmall: TextStyle(fontFamily: C.DEFAULT_FONT, fontSize: 10),
              labelMedium: TextStyle(
                  fontFamily: C.DEFAULT_FONT,
                  fontSize: 12,
                  color: Colors.white),
              labelSmall: TextStyle(
                  fontFamily: C.DEFAULT_FONT,
                  fontSize: 10,
                  color: Colors.white))),
      supportedLocales: AppLocalizations.supportedLocales,
      locale: GetIt.instance<LocaleModel>().getLocale,
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        LocaleNamesLocalizationsDelegate(),
      ],
      navigatorObservers: [NewRelicNavigationObserver()],
      builder: (BuildContext context, Widget? widget) {
        // Catcher.addDefaultErrorWidget(
        //     showStacktrace: true,
        //     title: "Custom error title",
        //     description: "Custom error description",
        //     maxWidthForSmallMode: 150);

        // return AccessibilityTools(
        //   logLevel: LogLevel.warning,
        //   checkSemanticLabels: true,
        //   checkFontOverflows: true,
        //   child: widget!,
        return widget!;
      },
      home: getLandingPage(isPrefsSet),
    );
  }
}
