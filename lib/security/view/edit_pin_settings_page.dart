import 'package:ezscrip/app_bar.dart';
import 'package:ezscrip/settings/model/userprefs.dart';
import 'package:ezscrip/setup/model/localemodel.dart';
import 'package:ezscrip/util/focus_nodes.dart';
import 'package:ezscrip/util/keys.dart';
import 'package:ezscrip/profile/model/appUser.dart';
import 'package:flash/flash.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get_it/get_it.dart';
import 'package:no_context_navigation/no_context_navigation.dart';
import 'package:scroll_date_picker/scroll_date_picker.dart';
import 'package:flutter_vector_icons/flutter_vector_icons.dart';
import 'package:intl/intl.dart';
import 'package:pin_code_fields/pin_code_fields.dart';
import 'package:auto_size_text/auto_size_text.dart';

class EditPinSettingsPage extends StatefulWidget {
  final AppUser _user;
  const EditPinSettingsPage(this._user, {Key? key = K.editPinSettingsPage})
      : super(key: key);

  @override
  _EditPinSettingsPageState createState() => _EditPinSettingsPageState(_user);
}

class _EditPinSettingsPageState extends State<EditPinSettingsPage> {
  final AppUser _user;
  late TextEditingController _pinController, _pinConfirmController;
  late int _pin, _confirmPin;
  late DateTime _resetDate;

  final _formKey = GlobalKey<FormState>();

  _EditPinSettingsPageState(this._user);

  @override
  void initState() {
    _pinController = TextEditingController();
    _pinConfirmController = TextEditingController();
    _pin = 0;
    _confirmPin = 0;
    _resetDate = DateTime.now();

    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitDown,
      DeviceOrientation.portraitUp,
    ]);

    super.initState();
  }

  void _showMessage(IconData icon, String message, Color color) {
    showFlash(
        context: context,
        duration: const Duration(seconds: 3),
        builder: (_, controller) {
          return Flash(
            controller: controller,
            position: FlashPosition.bottom,
            child: FlashBar(
              controller: controller,
              icon: Icon(
                icon,
                size: 36.0,
                color: color,
              ),
              content: AutoSizeText(message),
            ),
          );
        });
  }

  Widget buildPinResetWidget() {
    return Stack(
      key: K.pinResetReminder,
      alignment: Alignment.topCenter,
      children: [
        AutoSizeText("Choose a date you remember(e.g Birthday). ",
            style: Theme.of(context).textTheme.titleLarge),
        Padding(
            padding: const EdgeInsets.only(top: 30),
            child: AutoSizeText(
                DateFormat.yMMMd(
                        GetIt.instance<LocaleModel>().getLocale.languageCode)
                    .format(_resetDate),
                style: Theme.of(context).textTheme.titleMedium)),
        Container(
            width: MediaQuery.of(context).size.width - 100,
            padding: const EdgeInsets.only(top: 30),
            child: ScrollDatePicker(
              key: K.pinResetDatePicker,
              selectedDate: _resetDate,
              maximumDate: DateTime.now(),
              minimumDate: DateTime(1900, 1, 1),
              locale: GetIt.instance<LocaleModel>().getLocale,
              onDateTimeChanged: (DateTime date) {
                _resetDate = date;
                setState(() {});
              },
              options: const DatePickerOptions(isLoop: false),
              scrollViewOptions: const DatePickerScrollViewOptions(),
            ))
      ],
    );
  }

  Widget buildPinWidget() {
    return Stack(children: [
      AutoSizeText("Pin", style: Theme.of(context).textTheme.titleLarge),
      Padding(
          padding: const EdgeInsets.only(top: 30),
          child: PinCodeTextField(
              key: K.confirmPinField,
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
                  fieldHeight: 50,
                  fieldWidth: 40,
                  activeFillColor: Colors.teal[100],
                  inactiveColor: Colors.white,
                  inactiveFillColor: Colors.white),
              cursorColor: Colors.black,
              animationDuration: const Duration(milliseconds: 300),
              enableActiveFill: true,
              controller: _pinController,
              textInputAction: TextInputAction.go,
              keyboardType: TextInputType.number,
              textCapitalization: TextCapitalization.characters,
              onChanged: (val) {},
              onCompleted: (pin) async {
                if (pin.trim().length < 4) {
                } else {
                  _pin = int.parse(pin);
                }
                setState(() {});
              }))
    ]);
  }

  Widget buildPinConfirmWidget() {
    return Stack(children: [
      AutoSizeText("Confirm Pin",
          style: Theme.of(context).textTheme.titleLarge),
      Padding(
          padding: const EdgeInsets.only(top: 40),
          child: PinCodeTextField(
            key: K.confirmPinField,
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
                fieldHeight: 50,
                fieldWidth: 40,
                activeFillColor: Colors.teal[100],
                inactiveColor: Colors.white),
            cursorColor: Colors.black,
            animationDuration: const Duration(milliseconds: 300),
            enableActiveFill: true,
            controller: _pinController,
            textInputAction: TextInputAction.go,
            keyboardType: TextInputType.number,
            textCapitalization: TextCapitalization.characters,
            onChanged: (val) {},
            onCompleted: (pin) {
              if (pin.trim().length < 4) {
              } else {
                _confirmPin = int.parse(pin);
              }
              setState(() {});
            },
          ))
    ]);
  }

  List<IconButton> buildActions() {
    List<IconButton> actions = [];

    actions.add(IconButton(
      key: K.checkButton,
      focusNode: FocusNodes.savePiButton,
      icon: const Icon(Foundation.check, size: 25),
      onPressed: () {
        if (_formKey.currentState!.validate()) {
          _formKey.currentState!.save();

          if (_pin != _confirmPin)
            _showMessage(
                Icons.warning, "Pin and Confirm Pin do not match", Colors.red);
          else {
            GetIt.instance<UserPrefs>().setPin(_pin);

            GetIt.instance<UserPrefs>().setReminderDate(_resetDate);

            navService.goBack();
            // Navigator.pop(context);
          }
        }
      },
    ));

    return actions;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBarBuilder.buildAppBar(
            context, const Icon(Icons.pin, size: 25),  "Security Settings", buildActions()),
        body: Container(
            height: MediaQuery.of(context).size.height - 50,
            width: MediaQuery.of(context).size.width - 20,
            margin: const EdgeInsets.all(20),
            padding: const EdgeInsets.all(10),
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
            child: SingleChildScrollView(
                child: Form(
                    key: _formKey,
                    child: Column(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          Container(
                              alignment: Alignment.center,
                              child: Column(
                                children: [
                                  buildPinWidget(),
                                  const SizedBox(height: 30),
                                  buildPinConfirmWidget(),
                                ],
                              )),
                          const SizedBox(height: 40),
                          Container(
                              alignment: Alignment.center,
                              child: buildPinResetWidget())
                        ])))));
  }
}
