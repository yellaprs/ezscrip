import 'package:auto_size_text/auto_size_text.dart';
import 'package:ezscrip/resources/resources.dart';
import 'package:ezscrip/route_constants.dart';
import 'package:ezscrip/settings/model/userprefs.dart';
import 'package:ezscrip/util/keys.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:get_it/get_it.dart';
import 'package:no_context_navigation/no_context_navigation.dart';

class OnboardingFinishPage extends StatefulWidget {
  const OnboardingFinishPage({Key? key}) : super(key: key);

  @override
  _OnboardingFinishPageState createState() => _OnboardingFinishPageState();
}

class _OnboardingFinishPageState extends State<OnboardingFinishPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Container(
            alignment: Alignment.center,
            height: MediaQuery.of(context).size.height,
            width: MediaQuery.of(context).size.width,
            color: Theme.of(context).primaryColor,
            child:
                Column(mainAxisAlignment: MainAxisAlignment.center, children: [
              SizedBox(
                height: MediaQuery.of(context).size.height * 0.60,
                child: Column(children: [
                  Image.asset(Images.healthcareIcon, height: 200, width: 150),
                  AutoSizeText(AppLocalizations.of(context)!.ezscrip,
                      style: Theme.of(context).textTheme.headlineSmall),
                ]),
              ),
              Padding(
                  padding: const EdgeInsets.all(10),
                  child: MaterialButton(
                      height: 60,
                      minWidth: 100,
                      key: K.finishSetup,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(18.0)),
                      elevation: 18.0,
                      clipBehavior: Clip.antiAlias, //
                      color: Theme.of(context)!.indicatorColor,
                      onPressed: () async {
                        await GetIt.instance<UserPrefs>().setDemoShown(true);
                        navService.pushReplacementNamed(Routes.Login);
                      },
                      child: AutoSizeText("Done",
                          style: Theme.of(context).textTheme.titleMedium)))
            ])));
  }
}
