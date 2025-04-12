import 'package:auto_size_text/auto_size_text.dart';
import 'package:dots_indicator/dots_indicator.dart';
import 'package:ezscrip/util/keys.dart';
import 'package:ezscrip/util/ui_constants.dart';
import 'package:flutter/material.dart';
import 'package:flutter_vector_icons/flutter_vector_icons.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class SurveyPage extends StatefulWidget {
  const SurveyPage({super.key});

  @override
  State<SurveyPage> createState() => _SurveyPageState();
}

class _SurveyPageState extends State<SurveyPage> {
  late int _currentPageIndex;

  @override
  void initState() {
    _currentPageIndex = 0;

    super.initState();
  }

  void stepCancel() {
    if (_currentPageIndex - 1 < 0) return;
    setState(() {
      _currentPageIndex -= 1;
    });
  }

  void stepContinue() {
    if (_currentPageIndex + 1 > 1) return;
    if (_currentPageIndex == 0) {
      setState(() {
        _currentPageIndex += 1;
      });
    }
  }

  Widget buildStepIndicator() {
    List<Widget> widgets = [];
    if (_currentPageIndex > 0) {
      widgets.add(IconButton(
          icon: const Icon(Icons.arrow_left),
          onPressed: () {
            stepCancel();
          }));
    } else {
      widgets.add(const SizedBox(width: 40));
    }
    widgets.add(DotsIndicator(
        dotsCount: 2,
        position: _currentPageIndex,
        decorator: DotsDecorator(
          size: const Size.square(9.0),
          activeSize: const Size(18.0, 9.0),
          activeShape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(5.0)),
        ),
        onTap: (position) {
          setState(() => _currentPageIndex = position - 1);
        }));
    if (_currentPageIndex < 1) {
      widgets.add(IconButton(
          icon: const Icon(Icons.arrow_right),
          onPressed: () {
            stepContinue();
          }));
    } else {
      widgets.add(const SizedBox(width: 40));
    }
    return Container(
        padding: const EdgeInsets.all(10),
        child: Row(
            mainAxisAlignment: MainAxisAlignment.center, children: widgets));
  }

  Widget buildHeader() {
    List<Widget> headerWidgets = [];
    if (_currentPageIndex == 0) {
      headerWidgets.add(
        IconButton(
            key: K.closeButton,
            icon: IconTheme(
                data: Theme.of(context).iconTheme,
                child: const Icon(Foundation.x)),
            onPressed: () {
              Navigator.of(context).pop();
            }),
      );
    } else {
      headerWidgets.add(
        IconButton(
            key: K.prevStep,
            icon: IconTheme(
                data: Theme.of(context).iconTheme,
                child: const Icon(FontAwesome.chevron_left,
                    size: UI.DIALOG_ACTION_BTN_SIZE)),
            onPressed: () {
              setState(() {});
            }),
      );
    }
    headerWidgets.add(
      Container(
          alignment: Alignment.center,
          child: Semantics(
              container: true,
              child: AutoSizeText(
                  " ${AppLocalizations.of(context)!.addMedication}",
                  style: Theme.of(context).textTheme.titleLarge))),
    );
    if (_currentPageIndex == 1) {
      headerWidgets.add(IconButton(
          key: K.checkButton,
          icon: const Icon(
            Foundation.check,
            size: UI.DIALOG_ACTION_BTN_SIZE,
          ),
          //focusNode: FocusNodes.saveMedicatioButton,
          color: Theme.of(context).indicatorColor,
          onPressed: () async {
            //Navigator.pop(context, medSched);

            setState(() {});
          }));
    } else {
      headerWidgets.add(
        IconButton(
            key: K.nextStep,
            icon: IconTheme(
                data: Theme.of(context).iconTheme,
                child: const Icon(FontAwesome.chevron_right,
                    size: UI.DIALOG_ACTION_BTN_SIZE)),
            onPressed: () {
              setState(() {});
            }),
      );
    }
    return SizedBox(
        height: MediaQuery.of(context).size.height * 0.1,
        child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: headerWidgets));
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.9,
      width: MediaQuery.of(context).size.width,
      child: Column(children: [
        buildHeader(),
        SizedBox(
            height: MediaQuery.of(context).size.height * 0.7,
            child: Stack(
              children: [],
            ))
      ]),
    );
  }
}
