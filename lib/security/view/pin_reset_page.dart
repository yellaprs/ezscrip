import 'dart:async';
import 'package:ezscrip/settings/model/userprefs.dart';
import 'package:ezscrip/util/keys.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:ezscrip/app_bar.dart';
import 'package:ezscrip/util/focus_nodes.dart';
import 'package:flutter/material.dart';
import 'package:flutter_vector_icons/flutter_vector_icons.dart';
import 'package:get_it/get_it.dart';
import 'package:no_context_navigation/no_context_navigation.dart';
import 'package:pin_code_fields/pin_code_fields.dart';
import 'package:auto_size_text/auto_size_text.dart';
import '../../util/mode.dart';

class PinResetPage extends StatefulWidget {
  final Mode _mode;
  const PinResetPage(this._mode, {Key? key}) : super(key: key);

  @override
  _PinResetPageState createState() => _PinResetPageState(this._mode);
}

class _PinResetPageState extends State<PinResetPage> {
  final Mode _mode;
  late int _pin;
  late TextEditingController _pinController,
      _PinController,
      _confirmPinController;
  late StreamController<ErrorAnimationType> _errorController;
  late bool _isPinVerified;
  late bool _pinVerificationResult;
  late int _confirmPin;
  late int _Pin;

  _PinResetPageState(this._mode);

  void initState() {
    _pinVerificationResult = true;
    _pinController = TextEditingController();
    _PinController = TextEditingController();
    _errorController = StreamController<ErrorAnimationType>();
    _isPinVerified = false;
    super.initState();
  }

  List<IconButton> actions() {
    List<IconButton> actions = [];

    actions.add(IconButton(
      color: Theme.of(context).indicatorColor,
      icon: const Icon(Foundation.check, size: 30),
      onPressed: () {
        GetIt.instance<UserPrefs>().setPin(_Pin);
        navService.goBack();
        //Navigator.pop(context);
      },
    ));

    return actions;
  }

  Widget builPinResetWidget(Orientation orientation) {
    return Focus(
        focusNode: FocusNodes.pinField,
        child: Container(
          height: (orientation == Orientation.portrait)
              ? (MediaQuery.of(context).size.height * 0.75)
              : (MediaQuery.of(context).size.height * 0.4),
          alignment: Alignment.center,
          child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Container(
                    alignment: Alignment.center,
                    child: AutoSizeText("enter new pin",
                        style: Theme.of(context).textTheme.displaySmall)),
                ClipRRect(
                    borderRadius: BorderRadius.circular(25),
                    child: Container(
                        height: MediaQuery.of(context).size.height * 0.3,
                        color: Theme.of(context).primaryColor,
                        padding: const EdgeInsets.all(10),
                        child: Stack(alignment: Alignment.center, children: [
                          Align(
                              alignment: Alignment.centerRight,
                              child: Padding(
                                  padding: const EdgeInsets.only(left: 10),
                                  child: IconButton(
                                      icon: const Icon(
                                          FontAwesome5Solid.backspace,
                                          size: 20),
                                      onPressed: () {
                                        if (_PinController.text.isNotEmpty) {
                                          setState(() {
                                            _PinController.text = _PinController
                                                .text
                                                .toString()
                                                .trim()
                                                .substring(
                                                    0,
                                                    _PinController.text
                                                            .toString()
                                                            .length -
                                                        1);
                                          });
                                        }
                                      }))),
                          ConstrainedBox(
                              constraints: BoxConstraints(
                                  maxHeight:
                                      (orientation == Orientation.portrait)
                                          ? MediaQuery.of(context).size.height *
                                              0.15
                                          : MediaQuery.of(context).size.height *
                                              0.2,
                                  maxWidth: (orientation ==
                                          Orientation.portrait)
                                      ? MediaQuery.of(context).size.width * 0.55
                                      : MediaQuery.of(context).size.width * 0.3,
                                  minWidth: 80,
                                  minHeight: 60),
                              //alignment: Alignment.center,
                              child: PinCodeTextField(
                                key: K.pinTextField,
                                appContext: context,
                                pastedTextStyle: TextStyle(
                                  color: Colors.green.shade600,
                                  fontWeight: FontWeight.bold,
                                ),
                                length: 4,
                                obscureText: true,
                                obscuringCharacter: '*',
                                blinkWhenObscuring: true,
                                animationType: AnimationType.fade,
                                pinTheme: PinTheme(
                                    shape: PinCodeFieldShape.box,
                                    borderRadius: BorderRadius.circular(5),
                                    borderWidth: 1.0,
                                    fieldHeight: 50,
                                    fieldWidth: 40,
                                    activeFillColor: Colors.teal[100],
                                    inactiveColor: Colors.teal,
                                    fieldOuterPadding: const EdgeInsets.all(5),
                                    inactiveFillColor: Colors.white),
                                cursorColor: Colors.black,
                                animationDuration:
                                    const Duration(milliseconds: 300),
                                enableActiveFill: true,
                                controller: _PinController,
                                textInputAction: TextInputAction.go,
                                keyboardType: TextInputType.number,
                                textCapitalization:
                                    TextCapitalization.characters,
                                onChanged: (val) {},
                                onCompleted: (pin) async {
                                  if (pin.trim().length < 4) {
                                  } else {
                                    _Pin = int.parse(pin);
                                  }
                                  setState(() {});
                                },
                              ))
                        ])))
              ]),
        ));
  }

  Widget buildPinWidget(Orientation orientation) {
    return Focus(
        focusNode: FocusNodes.pinField,
        child: Container(
            width: (orientation == Orientation.portrait)
                ? MediaQuery.of(context).size.width * 0.8
                : MediaQuery.of(context).size.width * 0.65,
            alignment: Alignment.center,
            child:
                Column(mainAxisAlignment: MainAxisAlignment.center, children: [
              AutoSizeText("enter pin",
                  style: Theme.of(context).textTheme.displaySmall),
              const SizedBox(height: 10),
              ClipRRect(
                borderRadius: BorderRadius.circular(25),
                child: Container(
                    color: Theme.of(context).primaryColor,
                    width: (orientation == Orientation.portrait)
                        ? MediaQuery.of(context).size.width * 0.8
                        : MediaQuery.of(context).size.width * 0.55,
                    height: MediaQuery.of(context).size.height * 0.3,
                    child: Stack(alignment: Alignment.center, children: [
                      ConstrainedBox(
                          constraints: BoxConstraints(
                              maxHeight: (orientation == Orientation.portrait)
                                  ? MediaQuery.of(context).size.height * 0.15
                                  : MediaQuery.of(context).size.height * 0.2,
                              maxWidth: (orientation == Orientation.portrait)
                                  ? MediaQuery.of(context).size.width * 0.55
                                  : MediaQuery.of(context).size.width * 0.3,
                              minWidth: 80,
                              minHeight: 60),
                          child: PinCodeTextField(
                            // key: K.PinAutoSizeTextField,
                            appContext: context,
                            pastedTextStyle: TextStyle(
                              color: Colors.green.shade600,
                              fontWeight: FontWeight.bold,
                            ),
                            length: 4,
                            obscureText: true,
                            obscuringCharacter: '*',
                            blinkWhenObscuring: true,
                            animationType: AnimationType.fade,
                            pinTheme: PinTheme(
                                shape: PinCodeFieldShape.box,
                                borderRadius: BorderRadius.circular(5),
                                borderWidth: 1.0,
                                fieldHeight: 50,
                                fieldWidth: 40,
                                activeFillColor: Colors.teal[100],
                                inactiveColor: Colors.teal,
                                fieldOuterPadding: const EdgeInsets.all(5),
                                inactiveFillColor: Colors.white),
                            cursorColor: Colors.black,
                            animationDuration:
                                const Duration(milliseconds: 300),
                            enableActiveFill: true,
                            errorAnimationController: _errorController,
                            controller: _pinController,
                            textInputAction: TextInputAction.go,
                            keyboardType: TextInputType.number,
                            textCapitalization: TextCapitalization.characters,
                            onChanged: (val) {},
                            onCompleted: (_mode == Mode.Preview)
                                ? null
                                : (pin) async {
                                    if (pin.trim().length < 4) {
                                    } else {
                                      _pin = int.parse(pin);
                                    }
                                    bool verifiedPin =
                                        await GetIt.instance<UserPrefs>()
                                            .verifyPin(_pin);

                                    if (!verifiedPin) {
                                      _errorController
                                          .add(ErrorAnimationType.shake);
                                    }
                                    setState(() {
                                      _isPinVerified = verifiedPin;
                                    });
                                  },
                          )),
                      Align(
                        alignment: Alignment.centerRight,
                        child: Container(
                            margin: const EdgeInsets.only(left: 20, right: 0),
                            child: IconButton(
                                icon: const Icon(FontAwesome5Solid.backspace,
                                    size: 20),
                                onPressed: (_mode == Mode.Preview)
                                    ? null
                                    : () {
                                        setState(() {
                                          _pinController.text = _pinController
                                              .text
                                              .toString()
                                              .trim()
                                              .substring(
                                                  0,
                                                  _pinController.text
                                                          .toString()
                                                          .length -
                                                      1);
                                        });
                                      })),
                      ),
                    ])),
              ),
              Visibility(
                  visible: !_pinVerificationResult,
                  child: const AutoSizeText(
                    "Pin verification failed",
                    style: TextStyle(
                      color: Colors.red,
                      fontSize: 16,
                    ),
                  )),
            ])));
  }

  @override
  Widget build(BuildContext context) {
    return OrientationBuilder(builder: (context, orientation) {
      return Scaffold(
          appBar: AppBarBuilder.buildAppBar(
              context,
              AppLocalizations.of(context)!.changePin,
              (_isPinVerified) ? actions() : []),
          body: Container(
              height: MediaQuery.of(context).size.height * 0.8,
              width: MediaQuery.of(context).size.width * 0.9,
              margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
              padding: const EdgeInsets.all(10),
              child: Center(
                  child: ConstrainedBox(
                      constraints: BoxConstraints(
                        minWidth: (orientation == Orientation.portrait)
                            ? (MediaQuery.of(context).size.width * 0.4)
                            : (MediaQuery.of(context).size.width * 0.5),
                        minHeight: (orientation == Orientation.portrait)
                            ? (MediaQuery.of(context).size.height * 0.4)
                            : (MediaQuery.of(context).size.height * 0.5),
                        maxWidth: (orientation == Orientation.portrait)
                            ? (MediaQuery.of(context).size.width * 0.75)
                            : (MediaQuery.of(context).size.width * 0.65),
                        maxHeight: (orientation == Orientation.portrait)
                            ? (MediaQuery.of(context).size.height * 0.5)
                            : (MediaQuery.of(context).size.height * 0.75),
                      ),
                      child: (_isPinVerified || _mode == Mode.View)
                          ? builPinResetWidget(orientation)
                          : buildPinWidget(orientation)))));
    });
  }
}
