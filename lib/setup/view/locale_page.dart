import 'package:ezscrip/profile/model/userType.dart';
import 'package:ezscrip/route_constants.dart';
import 'package:ezscrip/settings/model/userprefs.dart';
import 'package:ezscrip/setup/model/localemodel.dart';
import 'package:ezscrip/setup/setup_routes.dart';
import 'package:ezscrip/util/keys.dart';
import 'package:ezscrip/util/locale_service.dart';
import 'package:flutter_vector_icons/flutter_vector_icons.dart';
import 'package:get_it/get_it.dart';
import 'package:global_configuration/global_configuration.dart';
import 'package:no_context_navigation/no_context_navigation.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter/material.dart';
import 'package:ezscrip/util/constants.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:auto_size_text/auto_size_text.dart';

enum LocalePageMark {
  localeListBox,
}

class LocalePage extends StatefulWidget {
  const LocalePage({Key key = K.localePage}) : super(key: key);

  @override
  LocalePageState createState() => LocalePageState();
}

class LocaleObj {
  final Locale _locale;
  final String _localeName;
  final String _nativeName;

  LocaleObj(this._locale, this._localeName, this._nativeName);
}

class LocalePageState extends State<LocalePage> {
  late String _localeCode;
  late LocaleObj _selectedLocaleObj;

  LocalePageState();

  @override
  void initState() {
    _selectedLocaleObj =
        LocaleObj(const Locale("en", "US"), "English", "English");
    _localeCode = _selectedLocaleObj._locale.languageCode;
    super.initState();
  }

  void setSelectedLocale(LocaleObj val) {
    _selectedLocaleObj = val;
  }

  Future<List<LocaleObj>> getLocales() async {
    List<Locale> locales = await LocaleService.getLocales();
    Map<String, String> localeNames = await LocaleService.getLocaleNames();
    return locales
        .map((e) =>
            LocaleObj(e, e.languageCode, localeNames[e.languageCode] as String))
        .toList();
  }

  List<LocaleObj> getMatchingLocales(String filter, List<LocaleObj> locales) {
    List<LocaleObj> localeList = [];
    locales.forEach((element) {
      if (element._nativeName == filter) localeList.add(element);
    });
    return localeList;
  }

  Future<String> getStorageDirectory() async {
    PermissionStatus permission = await Permission.storage.request();
    if (permission != PermissionStatus.granted &&
        permission != PermissionStatus.restricted) {
      return "";
    } else {
      return (await getApplicationSupportDirectory()).path;
    }
  }

  LocaleObj getSelectedLocaleObj(List<LocaleObj> locales) {
    Locale selectedLocale = Locale.fromSubtags(
        languageCode: Localizations.localeOf(context).languageCode,
        countryCode: Localizations.localeOf(context).countryCode);
    LocaleObj localeObj = locales.firstWhere((element) =>
        element._locale.languageCode == selectedLocale.languageCode);
    return localeObj;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Center(
            child: Container(
                margin: const EdgeInsets.only(
                    top: 50, bottom: 50, left: 20, right: 20),
                padding: const EdgeInsets.all(10),
                alignment: Alignment.topCenter,
                decoration: BoxDecoration(
                  color: Theme.of(context).primaryColor,
                  borderRadius: BorderRadius.circular(40),
                  boxShadow: [
                    BoxShadow(
                        color: Theme.of(context).primaryColor.withOpacity(1),
                        offset: const Offset(0, 30),
                        blurRadius: 3,
                        spreadRadius: -10)
                  ],
                ),
                child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      const Icon(Fontisto.doctor, size: 150),
                      AutoSizeText(AppLocalizations.of(context)!.ezscrip,
                          style: Theme.of(context).textTheme.headlineMedium),
                      Padding(
                          padding: const EdgeInsets.all(10),
                          child: Padding(
                              padding: const EdgeInsets.all(10),
                              child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceAround,
                                  children: [
                                    const Icon(Icons.language),
                                    FutureBuilder<List<LocaleObj>>(
                                        future: getLocales(),
                                        builder: (BuildContext context,
                                            localeSnapshot) {
                                          if (localeSnapshot.hasError) {
                                            return Center(
                                                child: AutoSizeText(
                                                    localeSnapshot.error
                                                        .toString()));
                                          } else if (localeSnapshot.hasData) {
                                            return const SizedBox(
                                              width: 200,
                                            );
                                          } else {
                                            return const SpinKitThreeBounce(
                                                color: Colors.red, size: 30);
                                          }
                                        })
                                  ]))),
                      CircleAvatar(
                          backgroundColor: Theme.of(context).primaryColor,
                          child: IconButton(
                              tooltip: 'Set Locale',
                              key: K.setLocaleButton,
                              icon: IconTheme(
                                  data: Theme.of(context).copyWith().iconTheme,
                                  child: const Icon(Icons.forward)),
                              onPressed: () async {
                                Locale selectedLocale =
                                    _selectedLocaleObj._locale;
                                GetIt.instance<LocaleModel>()
                                    .changelocale(selectedLocale);
                                GetIt.instance<UserPrefs>()
                                    .setLocale(selectedLocale);
                                await GlobalConfiguration()
                                    .loadFromAsset(C.APP_SETTINGS);

                                navService.pushNamed(Routes.Demo,
                                    args: IntroductionPageArguments(userType: UserType.Basic));

                                // Navigator.push(
                                //     context,
                                //     MaterialPageRoute(
                                //         builder: (context) =>
                                //             IntroductionPage(specailityList)));
                              }))
                    ]))));
  }
}
