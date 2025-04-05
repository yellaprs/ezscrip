import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:ezscrip/infrastructure/db/app_database.dart';
import 'package:ezscrip/infrastructure/services/securestorage_service.dart';
import 'package:ezscrip/resources/resources.dart';
import 'package:ezscrip/route_constants.dart';
import 'package:ezscrip/settings/model/userprefs.dart';
import 'package:ezscrip/util/keys.dart';
import 'package:ezscrip/profile/model/appUser.dart';
import 'package:ezscrip/home_page.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:flutter/services.dart';
import 'package:get_it/get_it.dart';
import 'package:global_configuration/global_configuration.dart';
import 'package:no_context_navigation/no_context_navigation.dart';
import 'package:path_provider/path_provider.dart';
import 'package:ezscrip/util/constants.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:ezscrip/util/semantics.dart' as semantic;

class InitSplashPage extends StatefulWidget {
  final AppUser user;

  InitSplashPage({required this.user, key = K.introductionSplashPage})
      : super(key: key);

  @override
  _InitSplashPageState createState() => _InitSplashPageState(this.user);
}

class _InitSplashPageState extends State<InitSplashPage> {
  final AppUser _user;
  // final _formKey = GlobalKey<FormState>();
  late StreamController<double> _setupController;
  late StreamController<String> _setupMsgController;
  late StreamController<String> _copyMsgController;

  _InitSplashPageState(this._user);

  void initState() {
    _setupController = StreamController<double>();
    _setupMsgController = StreamController<String>();
    _copyMsgController = StreamController<String>();

    super.initState();
  }

  Future<void> closeStreams() async {
    await _setupController.close();
    await _setupMsgController.close();
    await _copyMsgController.close();
    return;
  }

  Future<bool> applyDefaultSettings() async {
    final manifestContent = await rootBundle.loadString('AssetManifest.json');

    Map<String, dynamic> manifestMap = json.decode(manifestContent);
    var templateList = manifestMap.keys
        .where((file) => file.startsWith('assets/images/templates'))
        .toList();

    String defaultTemplate = templateList.firstWhere(
        (element) => element.endsWith("letterhead_blank.jpg"),
        orElse: () => templateList.elementAt(0));

    bool isDefaultTemplateSet =
        await GetIt.instance<UserPrefs>().setTemplate(defaultTemplate);

    var formatList = manifestMap.keys
        .where((file) => file.startsWith('assets/images/formats'))
        .toList();

    String defaultFormat = formatList.firstWhere(
        (element) => element.endsWith(Images.format1),
        orElse: () => formatList.elementAt(0));

    bool isDefaultFormatSet =
        await GetIt.instance<UserPrefs>().setFormat(defaultFormat);

    await GetIt.instance<UserPrefs>().setDemoShown(false);
    await GetIt.instance<UserPrefs>()
        .setSignatureEnabled(GlobalConfiguration().get(C.IS_SIGNATURE_ENABLED));

    return (isDefaultTemplateSet && isDefaultFormatSet);
  }

  Future<String> copyFile(String input, String output) async {
    var bytes = await rootBundle.load(input);

    File outFile = File(output);

    await outFile.create();

    outFile = await outFile.writeAsBytes(
        bytes.buffer
            .asInt8List(bytes.offsetInBytes, bytes.buffer.lengthInBytes),
        flush: true);

    return outFile.path;
  }

  Future<bool> initialize() async {
    bool dbCreated = false;
    bool isDefaultsSet = false;
    bool isUserSaved = false;

    _setupMsgController.sink.add("Starting Setup");

    SecureStorageService.store(C.DB_NAME, GlobalConfiguration().get(C.DB_NAME));

    _setupController.sink.add(0.25);

    _setupMsgController.sink
        .add(AppLocalizations.of(context)!.allocatingStorage);
    dbCreated = await Future.delayed(const Duration(seconds: 1),
        () => GetIt.instance<AppDatabase>().refreshDB());

    _setupMsgController.sink.add("copying prescription format template");
    isDefaultsSet = await Future.delayed(
        const Duration(seconds: 1), () => applyDefaultSettings());
    _setupController.sink.add(0.5);

    String outFile = (await getApplicationSupportDirectory()).path +
        "/" +
        C.PRESCRIPTION_FORMAT_DEMO_FILE;

    _setupMsgController.sink.add("copying demo files");

    await Future.delayed(
        const Duration(seconds: 1),
        () => copyFile(
            "assets/demo/" + C.PRESCRIPTION_FORMAT_DEMO_FILE, outFile));

    _setupController.sink.add(0.75);

    _setupMsgController.sink.add("Saving profile and settings");

    isUserSaved = await Future.delayed(const Duration(seconds: 1),
        () => GetIt.instance<UserPrefs>().saveUser(_user));

    _setupController.sink.add(1.0);
    _setupMsgController.sink.add("Completed setup");

    await GetIt.instance<UserPrefs>().setInstallDate(DateTime.now());

    return (dbCreated && isUserSaved && isDefaultsSet);
  }

  @override
  void dispose() async {
    super.dispose();
  }

  Widget buildLoadingWaitWidget(BuildContext context) {
    return Column(mainAxisAlignment: MainAxisAlignment.center, children: [
      Image.asset(Images.healthcareIcon, height: 150, width: 120),
      const SizedBox(height: 20),
      Padding(
          padding: const EdgeInsets.only(top: 5, bottom: 5),
          child: StreamBuilder<String>(
              stream: _copyMsgController.stream,
              initialData: "",
              builder: (BuildContext context, AsyncSnapshot<String> snapshot) {
                if (snapshot.hasData) {
                  return AutoSizeText(snapshot.data!,
                      style: Theme.of(context).textTheme.titleMedium);
                } else {
                  return const AutoSizeText("");
                }
              })),
      SizedBox(
        width: 250,
        child: StreamBuilder<double>(
            stream: _setupController.stream,
            initialData: 0,
            builder: (BuildContext context, AsyncSnapshot<double> snapshot) {
              if (snapshot.hasData) {
                return LinearProgressIndicator(
                  value: snapshot.data!,
                  backgroundColor: Colors.grey[400],
                  valueColor: const AlwaysStoppedAnimation<Color>(Colors.red),
                );
              } else {
                return const SpinKitThreeBounce(color: Colors.red, size: 30);
              }
            }),
      ),
      Padding(
          padding: const EdgeInsets.only(top: 4, bottom: 4),
          child: StreamBuilder<String>(
              stream: _setupMsgController.stream,
              initialData: "",
              builder: (BuildContext context, AsyncSnapshot<String> snapshot) {
                if (snapshot.hasData) {
                  return AutoSizeText(snapshot.data!,
                      style: Theme.of(context).textTheme.titleMedium);
                } else {
                  return const CircularProgressIndicator();
                }
              }))
    ]);
  }

  Widget buildLoadingErrorWidget(AsyncSnapshot resultSnapshot) {
    return Column(mainAxisAlignment: MainAxisAlignment.center, children: [
      Image.asset(Images.healthcareIcon, height: 150, width: 120),
      Stack(
        alignment: Alignment.topCenter,
        children: [AutoSizeText(resultSnapshot.error.toString())],
      ),
    ]);
  }

  Widget buildStartTourWidget(BuildContext context) {
    return Material(
        //Wrap with Material
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(18.0)),
        elevation: 18.0,
        color: Theme.of(context).indicatorColor,
        clipBehavior: Clip.antiAlias, // Add This
        child: MaterialButton(
            key: K.startTourButton,
            child: AutoSizeText(
              AppLocalizations.of(context)!.demo,
              style: const TextStyle(fontSize: 20, color: Colors.white),
            ),
            onPressed: () async {
              await closeStreams();

              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => HomePage(showDemo: true)));
            }));
  }

  Widget onBoardingWidget(BuildContext context) {
    return Container(
        alignment: Alignment.center,
        height: MediaQuery.of(context).size.height,
        width: MediaQuery.of(context).size.width,
        color: Theme.of(context).primaryColor,
        child: Stack(alignment: Alignment.center, children: [
          SizedBox(
            height: MediaQuery.of(context).size.height * 0.60,
            child: Column(children: [
              Image.asset(Images.healthcareIcon, height: 200, width: 150),
              AutoSizeText(AppLocalizations.of(context)!.ezscrip,
                  style: Theme.of(context).textTheme.headlineSmall),
            ]),
          ),
          Align(
              alignment: Alignment.bottomCenter,
              child: SizedBox(
                  height: MediaQuery.of(context).size.height * 0.15,
                  child: Column(children: [
                    buildStartTourWidget(context),
                    Padding(
                        padding: const EdgeInsets.all(10),
                        child: InkWell(
                            key: K.skipBuutton,
                            onTap: () async {
                              await closeStreams();
                              await GetIt.instance<UserPrefs>()
                                  .setDemoShown(true);
                              await closeStreams();
                              navService.pushReplacementNamed(Routes.Login);
                            },
                            child: Semantics(
                                identifier: semantic.S.INITIAL_SPLASH_SKIP_BTN,
                                child: AutoSizeText("Skip",
                                    style: Theme.of(context)
                                        .textTheme
                                        .titleMedium))))
                  ]))),
        ]));
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
        canPop: false,
        child: Scaffold(
            body: Container(
                alignment: Alignment.center,
                child: FutureBuilder<bool>(
                  future: initialize(),
                  builder: (context, resultSnapshot) {
                    if (resultSnapshot.hasError) {
                      return buildLoadingErrorWidget(resultSnapshot);
                    } else if (resultSnapshot.hasData) {
                      if (resultSnapshot.data!) {
                        return onBoardingWidget(context);
                      } else {
                        return buildLoadingErrorWidget(resultSnapshot);
                      }
                    } else {
                      return buildLoadingWaitWidget(context);
                    }
                  },
                ))));
  }
}
