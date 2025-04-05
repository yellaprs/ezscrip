import 'dart:async';
import 'dart:io';
import 'package:ezscrip/home_page.dart';
import 'package:ezscrip/resources/resources.dart';
import 'package:ezscrip/route_constants.dart';
import 'package:ezscrip/settings/model/userprefs.dart';
import 'package:ezscrip/util/keys.dart';
import 'package:ezscrip/widgets/pin_Text_field.dart';
import 'package:ezscrip/util/ui_constants.dart';
import 'package:flutter/material.dart';
import 'package:flutter_vector_icons/flutter_vector_icons.dart';
import 'package:get_it/get_it.dart';
import 'package:no_context_navigation/no_context_navigation.dart';
import '../../util/semantics.dart' as semantic;
import 'package:pin_code_fields/pin_code_fields.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:double_back_to_close_app/double_back_to_close_app.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({Key? key}) : super(key: key);

  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  var pinController;
  final formKey = GlobalKey<FormState>();
  late bool _isVerified;
  late StreamController<ErrorAnimationType> errorController;
  late int _pin;
  late bool _isCompleted;

  @override
  void initState() {
    _isVerified = true;
    pinController = TextEditingController();
    pinController.text = "";
    _isCompleted = false;
    errorController = StreamController<ErrorAnimationType>();
    _pin = -1;
    super.initState();
  }

  Widget buildPinWidget(Orientation orientation) {
    return Container(
      alignment: Alignment.centerLeft,
      padding: const EdgeInsets.all(10),
      width: (orientation == Orientation.portrait)
          ? MediaQuery.of(context).size.width * 0.8
          : MediaQuery.of(context).size.width * 0.45,
      height: (orientation == Orientation.portrait)
          ? MediaQuery.of(context).size.height * 0.35
          : MediaQuery.of(context).size.height * 0.5,
      child: Stack(alignment: Alignment.center, children: [
        Align(
            alignment: Alignment.centerRight,
            child: Padding(
                padding: const EdgeInsets.only(left: 10),
                child: IconButton(
                    icon: const Icon(FontAwesome5Solid.backspace, size: 20),
                    onPressed: () {
                      if (pinController.text.toString().isNotEmpty) {
                        setState(() {
                          pinController.text = pinController.text
                              .toString()
                              .trim()
                              .substring(
                                  0, pinController.text.toString().length - 1);
                        });
                      }
                    }))),
        Align(
            alignment: Alignment.bottomCenter,
            child: Padding(
              padding: const EdgeInsets.only(top: 10, bottom: 10),
              child: IconButton(
                key: K.loginButton,
                icon: const Icon(Icons.login,
                    size: UI.PAGE_ACTION_BTN_SIZE,
                    semanticLabel: semantic.S.LOGIN_BTN),
                onPressed: () async {

                  if (_isCompleted) {
                  
                    bool isSuccess = await GetIt.instance<UserPrefs>().verifyPin(_pin);

                    if (isSuccess) {
                    
                      navService.pushAndRemoveUntil(
                          MaterialPageRoute(builder: (context) => HomePage(showDemo:false)),
                          predicate: (route) => route.isFirst);
                    
                    } else {
                      errorController.add(ErrorAnimationType.shake);
                      setState(() {
                        _isVerified = isSuccess;
                      });
                    }

                  }
                },
              ),
            )),
        ConstrainedBox(
            constraints: BoxConstraints(
                maxHeight:
                     MediaQuery.of(context).size.height * 0.1,   
                maxWidth:
                    MediaQuery.of(context).size.width * 0.5,
                   
                minWidth: 45,
                minHeight: 50),
            child: Semantics(
                identifier: semantic.S.LOGIN_PIN_FLD,
                child: PinEntryTextField(
                  
                  key: K.pinTextField,
                
                  onSubmit: (pin) {
                    if (pin.trim().isNotEmpty && pin.trim().length == 4) {
                      _pin = int.parse(pin);
                      setState(() {
                        _isCompleted = true;
                      });
                    }
                    setState(() {});
                  },
                ))
                // child: PinCodeTextField(
                //   //key: K.pinTextField,
                //   appContext: context,
                //   autoFocus: true,
                //   pastedTextStyle: TextStyle(
                //     color: Colors.green.shade600,
                //     fontWeight: FontWeight.bold,
                //   ),
                //   length: 4,
                //   obscureText: true,
                //   obscuringCharacter: '*',
                //   blinkWhenObscuring: true,
                //   animationType: AnimationType.fade,
                //   pinTheme: PinTheme(
                //       shape: PinCodeFieldShape.box,
                //       borderRadius: BorderRadius.circular(5),
                //       borderWidth: 2.0,
                //       fieldOuterPadding: const EdgeInsets.all(2),
                //       fieldHeight: 50,
                //       fieldWidth: 40,
                //       disabledColor: Colors.white70,
                //       activeFillColor: Colors.teal[100],
                //       inactiveColor: Theme.of(context).primaryColor,
                //       inactiveFillColor: Colors.white),
                //   cursorColor: Colors.black,
                //   animationDuration: const Duration(milliseconds: 300),
                //   enableActiveFill: true,
                //   controller: pinController,
                //   errorAnimationController: errorController,
                //   textInputAction: TextInputAction.go,
                //   keyboardType: TextInputType.number,
                //   textCapitalization: TextCapitalization.characters,
                //   onCompleted: (pin) async {
                //     if (pin.trim().isNotEmpty && pin.trim().length == 4) {
                //       _pin = int.parse(pin);
                //       setState(() {
                //         _isCompleted = true;
                //       });
                //     }
                //   },
                //   onChanged: (pin) {
                //     debugPrint('onChanged execute. pin:$pin');
                //   },
                // )
            )])
      );
  }

  Widget buildForgotPinWidget() {
    return Padding(
        padding: const EdgeInsets.all(5),
        child: IconButton(
          key: K.forgotPinButton,
          icon: const Icon(
            Icons.lock_reset,
            size: UI.PAGE_ACTION_BTN_SIZE,
            semanticLabel: semantic.S.LOGIN_FORGOT_PIN_BTN,
          ),
          onPressed: () {
            navService.pushNamed(Routes.ResetPassword);
            // Navigator.push(context,
            //     MaterialPageRoute(builder: (context) => const ForgotPinPage()));
          },
        ));
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
        onPopInvoked: (shoudlPop) => exit(0),
        child: Scaffold(
            body: SafeArea(
                child: Form(
                    key: formKey,
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
                                        height: MediaQuery.of(context).size.height * 0.35,
                                        child:Stack(
                                          alignment:Alignment.bottomCenter,
                                          children: [
                                              Semantics(
                                                identifier:
                                                    semantic.S.LOGIN_ezscrip_LOGO,
                                                child: Image.asset(
                                                    Images.healthcareIcon,
                                                    height: 200,
                                                    width: 150)),
                                              Container(
                                                alignment: Alignment.center,
                                                padding: EdgeInsets.only(top: 30),
                                                height: 60,
                                                child: Semantics(
                                                    identifier: semantic
                                                        .S.LOGIN_DOCSRIBE_TITLE,
                                                    child: AutoSizeText(
                                                        AppLocalizations.of(context)!
                                                            .ezscrip,
                                                        minFontSize: 30,
                                                        textAlign: TextAlign.center,
                                                        style: Theme.of(context)
                                                            .textTheme
                                                            .headlineMedium)),
                                            ),
                                          ],) 
                                       ),
                                       SizedBox(
                                            width: MediaQuery.of(context)
                                                    .size
                                                    .width *
                                                0.8,
                                            height: MediaQuery.of(context)
                                                    .size
                                                    .height *
                                                0.5,
                                            child: Column(
                                                mainAxisAlignment:
                                                    MainAxisAlignment
                                                        .spaceEvenly,
                                                children: [
                                                  buildPinWidget(
                                                      Orientation.portrait),
                                                  Visibility(
                                                      visible: !_isVerified,
                                                      child: AutoSizeText(
                                                        AppLocalizations.of(
                                                                context)!
                                                            .pinVerificationFailed,
                                                        style: const TextStyle(
                                                          color: Colors.red,
                                                          fontSize: 16,
                                                        ),
                                                      )),
                                                  (MediaQuery.of(context)
                                                              .viewInsets
                                                              .bottom ==
                                                          0)
                                                      ? buildForgotPinWidget()
                                                      : const SizedBox(
                                                          height: 5,
                                                        )
                                                ])),
                                      ])),
                              
                            ])
                  ))
        ))
    ));
  }
}
