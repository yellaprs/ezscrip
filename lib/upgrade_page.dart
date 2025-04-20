import 'dart:io';

import 'package:auto_size_text/auto_size_text.dart';
import 'package:ezscrip/resources/resources.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class UpgradePage extends StatefulWidget {

  final int prescCount;
  const UpgradePage(this.prescCount, {Key? key}) : super(key: key);

  @override
  _UpgradePageState createState() => _UpgradePageState(this.prescCount);
}

class _UpgradePageState extends State<UpgradePage> {

  int _prescCount;

  _UpgradePageState(this._prescCount);

  @override
  void initState(){
    
   super.initState();

  }
  Widget buildMessageWidget() {
    return Padding(
        padding: const EdgeInsets.all(5),
        child: Stack(children: [
          const Icon(Icons.warning, size: 35, color: Colors.red),
          Padding(
              padding: const EdgeInsets.only(left: 40),
              child: AutoSizeText(
                  "Reached quota  of ${_prescCount.toString()} for prescription generation for this month in the basic version of ezscrip.  The Quota will be available after ${ DateTime(DateTime.now().year, DateTime.now().month + 1, 0).difference(DateTime.now()).inDays} days.",
                  style: Theme.of(context).textTheme.headlineSmall))
        ])
     );
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
        onPopInvoked: (shoudlPop) => exit(0),
        child: Scaffold(
            body: SafeArea(
                child: Center(
                    child: Container(
                        color: Theme.of(context).primaryColor,
                        child: ListView(children: [
                          SizedBox(
                              width: MediaQuery.of(context).size.width * 0.85,
                              height: MediaQuery.of(context).size.height * 0.9,
                              child: Column(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceEvenly,
                                  children: [
                                    SizedBox(
                                        height:
                                            MediaQuery.of(context).size.height *
                                                0.35,
                                        child: Stack(
                                          alignment: Alignment.bottomCenter,
                                          children: [
                                            Image.asset(Images.healthcareIcon,
                                                height: 200, width: 150),
                                            Container(
                                                alignment: Alignment.center,
                                                padding: const EdgeInsets.only(
                                                    top: 30),
                                                height: 60,
                                                child: AutoSizeText(
                                                    AppLocalizations.of(
                                                            context)!
                                                        .ezscrip,
                                                    minFontSize: 30,
                                                    textAlign: TextAlign.center,
                                                    style: Theme.of(context)
                                                        .textTheme
                                                        .headlineMedium)),
                                          ],
                                        )),
                                    SizedBox(
                                        height:
                                            MediaQuery.of(context).size.height *
                                                0.35,
                                        child: buildMessageWidget())
                                  ]))
                        ]))))));
  }
}
