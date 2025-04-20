import 'package:ezscrip/resources/resources.dart';
import 'package:ezscrip/settings/model/userprefs.dart';
import 'package:ezscrip/setup/model/localemodel.dart';
import 'package:ezscrip/util/keys.dart';
import 'package:ezscrip/widgets/pin_text_field.dart';
import 'package:flutter/material.dart';
import 'package:flutter_holo_date_picker/date_picker_theme.dart';
import 'package:flutter_holo_date_picker/i18n/date_picker_i18n.dart';
import 'package:get_it/get_it.dart';
import 'package:intl/intl.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:no_context_navigation/no_context_navigation.dart';
import 'package:flutter_holo_date_picker/widget/date_picker_widget.dart';
import 'package:auto_size_text/auto_size_text.dart';
import '../../util/semantics.dart' as semantic;

enum Resetmode { Unverified, Verified, Failed, Set }

class ForgotPinPage extends StatefulWidget {
  const ForgotPinPage({Key? key = K.forgotPinPage}) : super(key: key);

  @override
  _ForgotPinPageState createState() => _ForgotPinPageState();
}

class _ForgotPinPageState extends State<ForgotPinPage> {
  late TextEditingController _PinController;
  late int _pin;
  late DateTime _resetDate;

  late Resetmode mode;

  String? _verficationFailedMsg;

  @override
  void initState() {
    _PinController = TextEditingController();
    _PinController.text = "";
    _resetDate = DateTime.now();
    mode = Resetmode.Unverified;
    _pin = -1;
    _verficationFailedMsg = "Secret date for pin reset is invalid.";
    super.initState();
  }

  Widget showErrorWidget() {
    return AutoSizeText(_verficationFailedMsg!,
        style: Theme.of(context).textTheme.labelMedium);
  }

  Widget buildChallengeWidget(Orientation orientation) {
    return Stack(alignment: Alignment.center, children: [
      Align(
        alignment: Alignment.topCenter,
        child: AutoSizeText(AppLocalizations.of(context)!.enterPinReminderMsg,
            style: Theme.of(context).textTheme.bodyLarge),
      ),
      Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ClipRRect(
              borderRadius: const BorderRadius.all(Radius.circular(16.0)),
              child: Container(
                key: K.pinResetReminder,
                alignment: Alignment.center,
                margin: const EdgeInsets.only(top: 5),
                padding: const EdgeInsets.all(5),
                width: MediaQuery.of(context).size.width * 0.9,
                child: Container(
                    padding: const EdgeInsets.only(top: 5, bottom: 5),
                    margin: const EdgeInsets.all(5),
                    child: ConstrainedBox(
                        constraints: BoxConstraints(
                            maxWidth: MediaQuery.of(context).size.width * 0.65),
                        child: Semantics(
                          identifier: semantic.S.PIN_RESET_CHALLENGE_FIELD,
                          child: DatePickerWidget(
                            key: K.datePicker,
                            looping: false, // default is not looping
                            firstDate: DateTime(1900, 1, 1), //DateTime(1960)
                            initialDate: DateTime.now(), // DateTime(1994),
                            dateFormat: "dd-MMM-yyyy",
                            locale: DateTimePickerLocale.values.firstWhere(
                                (locale) =>
                                    locale.name ==
                                    GetIt.instance<LocaleModel>()
                                        .getLocale
                                        .languageCode,
                                orElse: () => DATETIME_PICKER_LOCALE_DEFAULT),
                            onChange: (DateTime date, _) {
                              _resetDate = date;
                              setState(() {});
                            },
                            pickerTheme: DateTimePickerTheme(
                                backgroundColor: Colors.transparent,
                                itemHeight: 60,
                                itemTextStyle: TextStyle(
                                    color: Theme.of(context).indicatorColor,
                                    fontSize: 18),
                                dividerColor: Colors.grey[400]),
                          ),
                        ))),
              ),
            ),
            Visibility(
                visible: mode == Resetmode.Failed,
                child: Padding(
                    padding: const EdgeInsets.only(top: 20),
                    child: AutoSizeText(
                      _verficationFailedMsg!,
                      style: const TextStyle(
                        color: Colors.red,
                        fontSize: 16,
                      ),
                    ))),
          ])
    ]);
  }

  Widget builPinResetWidget(Orientation orientation) {
    return Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          AutoSizeText("enter new pin",
              style: Theme.of(context).textTheme.bodyLarge),
          ConstrainedBox(
              constraints: BoxConstraints(
                  maxHeight: (orientation == Orientation.portrait)
                      ? MediaQuery.of(context).size.height * 0.1
                      : MediaQuery.of(context).size.height * 0.2,
                  maxWidth: (orientation == Orientation.portrait)
                      ? MediaQuery.of(context).size.width * 0.5
                      : MediaQuery.of(context).size.width * 0.3,
                  minWidth: 45,
                  minHeight: 50),
              child: Semantics(
                  identifier: semantic.S.PIN_RESET_NEW_PIN_FIELD,
                  child: PinEntryTextField(
                    key: K.pinTextField,
                    onSubmit: (pin) {
                      if (pin.trim().isNotEmpty && pin.trim().length == 4) {
                        _pin = int.parse(pin);
                      }
                    },
                  )))
        ]);
  }

  @override
  void dispose() {
    super.dispose();
  }

  Widget buildHomeNavWidget() {
    return IconButton(
        icon: const Icon(
          key: K.homeButton,
          Icons.home_filled,
          size: 30,
          semanticLabel: semantic.SemanticLabels.PIN_REST_FORWARD_BUTTON,
        ),
        onPressed: () async {
          navService.goBack();
        });
  }

  Widget buildNavigationWidget() {
    Widget widget;

    if (mode == Resetmode.Unverified) {
      widget = IconButton(
          key: K.nextButton,
          icon: const Icon(
            Icons.forward,
            size: 30, color: Colors.white,
            semanticLabel: semantic.SemanticLabels.PIN_RESET_SET_BUTTON,
          ),
          onPressed: () async {
            DateTime storedDate =
                await GetIt.instance<UserPrefs>().getReminderDate();
            if (DateFormat("ddMMyyyy").format(_resetDate) !=
                DateFormat("ddMMyyyy").format(storedDate)) {
              mode = Resetmode.Failed;
            } else {
              mode = Resetmode.Verified;
            }
            setState(() {});
          });
    } else if (mode == Resetmode.Verified) {
      widget = IconButton(
          key: K.checkButton,
          icon: const Icon(
            Icons.check,
            size: 30, color: Colors.white,
            semanticLabel: semantic.SemanticLabels.PIN_RESET_SET_BUTTON,
          ),
          onPressed: () async {
            if (_pin.toString().length == 4) {
              GetIt.instance<UserPrefs>().setPin(_pin);
              navService.goBack();
            }
          });
    } else {
      widget = IconButton(
          key: K.nextButton,
          icon: const Icon(
            Icons.forward,
            size: 30,
            semanticLabel: semantic.SemanticLabels.PIN_RESET_SET_BUTTON,
          ),
          onPressed: () async {
            DateTime storedDate =
                await GetIt.instance<UserPrefs>().getReminderDate();
            if (DateFormat("ddMMyyyy").format(_resetDate) !=
                DateFormat("ddMMyyyy").format(storedDate)) {
              mode = Resetmode.Failed;
            } else {
              mode = Resetmode.Verified;
            }
            setState(() {});
          });
    }

    return widget;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: SafeArea(
            child: Center(
                child: Container(
                    height: MediaQuery.of(context).size.height * 0.85,
                    width: MediaQuery.of(context).size.width * 0.9,
                    decoration: BoxDecoration(
                      color: Theme.of(context).primaryColor,
                      borderRadius: BorderRadius.circular(40),
                      boxShadow: [
                        BoxShadow(
                            color:
                                Theme.of(context).primaryColor.withOpacity(1),
                            offset: const Offset(0, 30),
                            blurRadius: 3,
                            spreadRadius: -10)
                      ],
                    ),
                    child: Column(children: [
                      SizedBox(
                          height: MediaQuery.of(context).size.height * 0.35,
                          child: Semantics(
                              identifier: semantic.S.LOGIN_EZSCRIP_LOGO,
                              child: Image.asset(Images.healthcareIcon,
                                  height: 200, width: 150))),
                      SizedBox(
                          height: MediaQuery.of(context).size.height * 0.3,
                          child: (mode == Resetmode.Verified)
                              ? builPinResetWidget(Orientation.portrait)
                              : buildChallengeWidget(Orientation.portrait)),
                      SizedBox(
                          height: MediaQuery.of(context).size.width * 0.35,
                          child: Column(
                              mainAxisAlignment: MainAxisAlignment.spaceAround,
                              children: [
                                buildNavigationWidget(),
                                buildHomeNavWidget()
                              ]))
                    ])))));
  }
}
