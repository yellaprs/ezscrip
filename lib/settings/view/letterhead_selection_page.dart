import 'dart:async';
import 'dart:convert';
import 'package:ezscrip/resources/resources.dart';
import 'package:ezscrip/settings/model/userprefs.dart';
import 'package:ezscrip/util/ui_constants.dart';
import 'package:flutter_carousel_widget/flutter_carousel_widget.dart';
import 'package:ezscrip/app_bar.dart';
import 'package:ezscrip/util/focus_nodes.dart';
import 'package:ezscrip/util/keys.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get_it/get_it.dart';
import 'package:no_context_navigation/no_context_navigation.dart';
import '../../util/semantics.dart' as semantic;
import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter_vector_icons/flutter_vector_icons.dart';
import '../../util/mode.dart';
import 'package:shimmer/shimmer.dart';

class LetterheadSelectionPage extends StatefulWidget {
  final Mode mode;
  final String letterHead;
  final String selectedFormat;

  const LetterheadSelectionPage(
      {required this.mode,
      required this.letterHead,
      required this.selectedFormat,
      Key? key})
      : super(key: key);

  @override
  _LetterheadSelectionPageState createState() =>
      _LetterheadSelectionPageState(mode, letterHead, selectedFormat);
}

class _LetterheadSelectionPageState extends State<LetterheadSelectionPage> {
  Mode _mode;
  String _selectedTemplate;
  String _selectedFormat;

  late String imageFile;

  _LetterheadSelectionPageState(
      this._mode, this._selectedTemplate, this._selectedFormat);

  @override
  void initState() {
    super.initState();
  }

  List<Widget> buildActions() {
    List<Widget> actions = [];

    actions.add(Semantics(
        identifier: semantic.S.PREFERNCES_BTN_CHECK,
        child: IconButton(
          key: K.checkButton,
          focusNode: FocusNodes.savePrescriptionSettings,
          icon: Icon(
            Foundation.check,
            size: UI.PAGE_ACTION_BTN_SIZE,
            key: K.saveLetterHeadSelectionButton,
            color: Theme.of(context).indicatorColor,
          ),
          onPressed: (_mode == Mode.Preview)
              ? null
              : () async {
                  await GetIt.instance<UserPrefs>().setFormat(_selectedFormat!);
                  navService.goBack();
                  // Navigator.pop(context);
                },
        )));

    return actions;
  }

  Future<List<String>> getTemplateList() async {
    List<String> fileList = [];

    final manifestContent = await rootBundle.loadString('AssetManifest.json');

    Map<String, dynamic> manifestMap = json.decode(manifestContent);
    var filtered = manifestMap.keys
        .where((file) => file.startsWith('assets/images/templates'))
        .toList();

    filtered.forEach((file) {
      fileList.add(file);
    });

    return fileList;
  }

  Future<List<String>> getFormatList() async {
    List<String> fileList = [];

    final manifestContent = await rootBundle.loadString('AssetManifest.json');

    Map<String, dynamic> manifestMap = json.decode(manifestContent);
    fileList = manifestMap.keys
        .where((file) => file.startsWith('assets/images/formats'))
        .toList();

    return fileList;
  }

  Widget buildFormatCoursel(Orientation orrientation) {
    return Column(mainAxisAlignment: MainAxisAlignment.center, children: [
      Padding(
          padding: const EdgeInsets.all(5),
          child: Semantics(
            identifier: semantic.S.PREFERCNES_SELECT_TEMPLATE_TITLE,
            child: AutoSizeText(
                AppLocalizations.of(context)!.selectPrescriptionTemplate,
                style: Theme.of(context).textTheme.bodyLarge),
          )),
      SizedBox(
          height: MediaQuery.of(context).size.height * 0.65,
          child: FutureBuilder<List<String>>(
              future: getFormatList(),
              builder: (context, fileList) {
                if (fileList.hasData) {
                  return FlutterCarousel(
                      key: K.letterHeadSelectionCoursel,
                      options: CarouselOptions(
                          height: MediaQuery.of(context).size.height * 0.65,
                          viewportFraction: 1.0,
                          indicatorMargin: 0,
                          showIndicator: true,
                          slideIndicator: CircularSlideIndicator(
                            slideIndicatorOptions: SlideIndicatorOptions(
                              itemSpacing: 15,
                              indicatorRadius: 6,
                              indicatorBackgroundColor:
                                  Theme.of(context).primaryColor,
                              currentIndicatorColor:
                                  Theme.of(context).indicatorColor,
                            ),
                          )),
                      items: fileList.data!.map((element) {
                        return Builder(builder: (BuildContext context) {
                          return GestureDetector(
                              onTap: () {
                                setState(() {
                                  _selectedFormat = element;
                                });
                              },
                              child: Semantics(
                                identifier:
                                    "${element.substring(element.lastIndexOf("/") + 1)}",
                                child: Stack(
                                    alignment: Alignment.center,
                                    children: [
                                      SizedBox(
                                        height:
                                            MediaQuery.of(context).size.height *
                                                0.6,
                                        child: Card(
                                          elevation: 4.0,
                                          child: Image.asset(
                                              key: Key(element.substring(
                                                  element.lastIndexOf("/") + 1,
                                                  element.indexOf("."))),
                                              element,
                                              width: MediaQuery.of(context)
                                                  .size
                                                  .width,
                                              height: MediaQuery.of(context)
                                                  .size
                                                  .height,
                                              fit: BoxFit.fill),
                                        ),
                                      ),
                                      Align(
                                        alignment: Alignment.bottomRight,
                                        child: Container(
                                            margin: const EdgeInsets.only(
                                                bottom: 30, right: 15),
                                            child: (element.trim() ==
                                                    _selectedFormat.trim())
                                                ? const Icon(Icons.check_circle,
                                                    key: Key("Checked"),
                                                    size: 25)
                                                : const Icon(
                                                    Icons.circle_outlined,
                                                    key: Key("Unchecked"),
                                                    size: 25)),
                                      )
                                    ]),
                              ));
                        });
                      }).toList());
                } else {
                  return Shimmer.fromColors(
                      baseColor: Colors.grey,
                      highlightColor: Theme.of(context).primaryColor,
                      child: const SizedBox(height: 40));
                  // return const Center(
                  //     child: SpinKitThreeBounce(color: Colors.red, size: 30));
                }
              }))
    ]);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBarBuilder.buildAppBar(
            context, 
             SvgPicture.asset(Images.userPreferences,
                 height: 25,
                 width:  25,
                semanticsLabel: semantic.S.HOME_APPBAR_PREFERNCES_BUTTON),
            AppLocalizations.of(context)!.preferences,
            buildActions()),
        body: Container(
            alignment: Alignment.center,
            height: MediaQuery.of(context).size.height * 0.8,
            width: MediaQuery.of(context).size.width * 0.9,
            margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
            padding: const EdgeInsets.all(10),
            // decoration: BoxDecoration(
            //   color: Theme.of(context).primaryColor,
            //   borderRadius: BorderRadius.circular(40),
            //   boxShadow: [
            //     BoxShadow(
            //         color: Theme.of(context).primaryColor.withOpacity(1),
            //         offset: const Offset(0, 30),
            //         blurRadius: 3,
            //         spreadRadius: -10)
            //   ],
            // ),
            child: OrientationBuilder(builder: (context, orientation) {
              return Align(
                  alignment: Alignment.center,
                  child: Focus(
                      focusNode: FocusNodes.selectFormat,
                      child: buildFormatCoursel(orientation)));
            })));
  }
}
