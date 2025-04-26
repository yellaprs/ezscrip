import 'dart:io';
import 'package:ezscrip/infrastructure/services/securestorage_service.dart';
import 'package:ezscrip/profile/model/userType.dart';
import 'package:ezscrip/resources/resources.dart';
import 'package:ezscrip/route_constants.dart';
import 'package:ezscrip/settings/model/userprefs.dart';
import 'package:ezscrip/setup/model/localemodel.dart';
import 'package:ezscrip/setup/setup_routes.dart';
import 'package:ezscrip/util/constants.dart';
import 'package:ezscrip/util/keys.dart';
import 'package:ezscrip/profile/model/appUser.dart';
import 'package:ezscrip/util/speciality.dart';
import 'package:ezscrip/util/utils_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_holo_date_picker/date_picker_theme.dart';
import 'package:flutter_holo_date_picker/i18n/date_picker_i18n.dart';
import 'package:flutter_holo_date_picker/widget/date_picker_widget.dart';
import 'package:flutter_multi_formatter/formatters/phone_input_formatter.dart';
import 'package:flutter_multi_formatter/widgets/country_dropdown.dart';
import 'package:flutter_svg/svg.dart';
import 'package:flutter_vector_icons/flutter_vector_icons.dart';
import 'package:animated_custom_dropdown/custom_dropdown.dart';
import 'package:get_it/get_it.dart';
import 'package:global_configuration/global_configuration.dart';
import 'package:no_context_navigation/no_context_navigation.dart';
//import 'package:pin_code_fields/pin_code_fields.dart';
import 'package:ezscrip/widgets/pin_text_field.dart';
import 'package:swipe_to/swipe_to.dart';
import 'package:validatorless/validatorless.dart';
import 'package:ezscrip/util/semantics.dart' as Semantic;
import 'package:dots_indicator/dots_indicator.dart';
import 'package:auto_size_text/auto_size_text.dart';

class SpecialityListFiter with CustomDropdownListFilter {
  final Speciality speciality;

  const SpecialityListFiter(this.speciality);

  @override
  String toString() {
    return speciality.toString();
  }

  @override
  bool filter(String query) {
    return speciality.getTitle().toLowerCase().contains(query.toLowerCase());
  }
}

class IntroductionPage extends StatefulWidget {
  final UserType userType;

  const IntroductionPage({ required this.userType,
      Key? key = K.introductionPage, Object? specailityList})
      : super(key: key);

  @override
  IntroductionPageState createState() => IntroductionPageState(this.userType);
}

class IntroductionPageState extends State<IntroductionPage> {
  final formKey = GlobalKey<FormState>();
  UserType _userType;
  late int _currentStep;
  String? _firstName;
  String? _lastName;
  Speciality? _specialization;
  String? _credential;
  String? _contactNo;
  String? _clinic;

  late DateTime resetDate;

  late TextEditingController firstnameController,
      lastnameController,
      phoneCodeController,
      speciallizationController,
      clinicController,
      contactNoController,
      pinController,
      securityPinController,
      errorController;

  late String _countryCode;
  late int _fileEncryptionPin;
  // late String _speciality;

  late FocusNode _firstNameFocusNode,
      _lastNameFocusNode,
      _clinicFocusNode,
      _credentialFocusNode,
      _contactNoFocusNode;

  IntroductionPageState(this._userType);

  @override
  void initState() {
    phoneCodeController = TextEditingController();
    firstnameController = TextEditingController();
    lastnameController = TextEditingController();
    contactNoController = TextEditingController();
    contactNoController.text = "";
    speciallizationController = TextEditingController();

    pinController = TextEditingController();
    securityPinController = TextEditingController();

    pinController.text = '';
    securityPinController.text = '';
    clinicController = TextEditingController();
    firstnameController.text = '';
    lastnameController.text = '';
    speciallizationController.text = '';
    clinicController.text = '';

    _currentStep = 0;
    _fileEncryptionPin = -1;

    //_specialization = Speciality("Cardiology", "/")
    _firstName = "";
    _lastName = "";
    _credential = "";
    _clinic = "";

    _contactNo = "";
    resetDate = DateTime.now();
    _firstNameFocusNode = FocusNode();
    _lastNameFocusNode = FocusNode();
    _clinicFocusNode = FocusNode();
    _contactNoFocusNode = FocusNode();
    _credentialFocusNode = FocusNode();

    super.initState();

    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitDown,
      DeviceOrientation.portraitUp,
    ]);
  }

  @override
  void dispose() {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeRight,
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    super.dispose();
  }

  Step buildPotraitIntroSlide(BuildContext context) {
    return Step(
      title: Semantics(
        identifier: Semantic.S.INTIALIZE_STEP_1,
        child: const Icon(Icons.info, size: 25),
      ),
      state: (_currentStep == 0) ? StepState.editing : StepState.indexed,
      isActive: (_currentStep == 0) ? true : false,
      content: Container(
          key: K.informationSlideKey,
          color: Theme.of(context).primaryColor,
          alignment: Alignment.topCenter,
          height: MediaQuery.of(context).size.height * 0.78,
          child: Semantics(
              identifier: Semantic.S.INITIALIZE_INTRO_SLIDE,
              container: true,
              child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Image.asset(Images.healthcareIcon, height: 150, width: 150),
                    SizedBox(height: MediaQuery.of(context).size.height * 0.01),
                    Container(
                      alignment: Alignment.center,
                      height: MediaQuery.of(context).size.height * 0.2,
                      child: Semantics(
                          identifier: Semantic.S.INITIALIZE_INTRODUCTION_HEADER,
                          container: true,
                          child: AutoSizeText(
                            AppLocalizations.of(context)!.ezscrip,
                            textAlign: TextAlign.center,
                            style: Theme.of(context).textTheme.headlineMedium,
                          )),
                    ),
                    SizedBox(height: MediaQuery.of(context).size.height * 0.05),
                    Container(
                        padding: const EdgeInsets.all(10),
                        child: AutoSizeText(
                          AppLocalizations.of(context)!.ezscripSummary1,
                          style: Theme.of(context).textTheme.bodyLarge,
                        )),
                    // Container(
                    // padding: const EdgeInsets.all(10),
                    // child: Stack(alignment: Alignment.topLeft, children: [
                    // Semantics(
                    // identifier: Semantic
                    // .S.INITIALIZE_INTRODUCTION_CONSULTATION_TITLE,
                    // container: true,
                    // child: AutoSizeText(
                    // AppLocalizations.of(context)!.consultation,
                    // style: Theme.of(context).textTheme.titleLarge,
                    // )),
                    // Padding(
                    // padding: const EdgeInsets.only(top: 20),
                    // child: Semantics(
                    // identifier: Semantic.S
                    // .INITIALIZE_INTRODUCTION_CONSULTATION_BODY,
                    // container: true,
                    // child: AutoSizeText(
                    // AppLocalizations.of(context)!
                    // .ezscrip_Summary2,
                    // style:
                    // Theme.of(context).textTheme.bodyMedium,
                    // ))) //"Create consulting appointments and track and maintain doctor's consulting schedule",
                    // ])),
                    // Container(
                    // padding: const EdgeInsets.all(10),
                    // child: Stack(alignment: Alignment.topLeft, children: [
                    // Semantics(
                    // identifier: Semantic
                    // .S.INITIALIZE_INTRODUCTION_PRESCRIPTION_TITLE,
                    // child: AutoSizeText(
                    // AppLocalizations.of(context)!.prescription,
                    // style: Theme.of(context).textTheme.titleLarge,
                    // )),
                    // Padding(
                    // padding:
                    // const EdgeInsets.only(top: 20, bottom: 5),
                    // child: Semantics(
                    // identifier: Semantic.S
                    // .INITIALIZE_INTRODUCTION_PRESCRIPTION_BODY,
                    // child: AutoSizeText(
                    // AppLocalizations.of(context)!
                    // .ezscrip_Summary3,
                    // style:
                    // Theme.of(context).textTheme.bodyMedium,
                    // )))
                    // ])),
                  ]))),
    );
  }

  Widget buildFirstNameWidget() {
    return SizedBox(
        width: MediaQuery.of(context).size.width * 0.35,
        child: Semantics(
            identifier: Semantic.SemanticLabels.INITIALIZE_PROFILE_NAME_FIELD,
            child: TextFormField(
              key: K.firstNameTextField,
              controller: firstnameController,
              focusNode: _firstNameFocusNode,
              onSaved: (val) {
                _firstName = val!;
              },
              validator: Validatorless.multiple([
                Validatorless.max(
                    30,
                    AppLocalizations.of(context)!
                        .maxLength(AppLocalizations.of(context)!.name, 30)),
                Validatorless.required(AppLocalizations.of(context)!
                    .isRequired(AppLocalizations.of(context)!.name))
              ]),
              onFieldSubmitted: (value) {
                FocusScope.of(context).requestFocus(_credentialFocusNode);
              },
              autovalidateMode: AutovalidateMode.onUserInteraction,
              decoration: InputDecoration(
                icon: const Icon(Icons.person),
                hintText:
                    "${AppLocalizations.of(context)!.first} ${AppLocalizations.of(context)!.name}",
                labelText:
                    "${AppLocalizations.of(context)!.first} ${AppLocalizations.of(context)!.name}",
                contentPadding: const EdgeInsets.all(10),
                errorBorder: const UnderlineInputBorder(
                    borderSide: BorderSide(color: Colors.red),
                    //gapPadding: 2.0,
                    borderRadius: BorderRadius.all(Radius.circular(9))),
                errorStyle: const TextStyle(
                    height: 1.0, fontSize: 8, color: Colors.red),
                errorMaxLines: 2,
                border: const UnderlineInputBorder(
                    borderSide: BorderSide(color: Colors.red),
                    borderRadius: BorderRadius.all(Radius.circular(9))),
              ),
              style: Theme.of(context).textTheme.bodyMedium,
            )));
  }

  Widget buildLastNameWidget() {
    return SizedBox(
        width: MediaQuery.of(context).size.width * 0.35,
        child: Semantics(
            identifier: Semantic.SemanticLabels.INITIALIZE_PROFILE_NAME_FIELD,
            child: TextFormField(
              key: K.lastNameTextField,
              controller: lastnameController,
              focusNode: _lastNameFocusNode,
              onSaved: (val) {
                _lastName = val!;
              },
              validator: Validatorless.multiple([
                Validatorless.max(
                    30,
                    AppLocalizations.of(context)!
                        .maxLength(AppLocalizations.of(context)!.name, 30)),
                Validatorless.required(AppLocalizations.of(context)!
                    .isRequired(AppLocalizations.of(context)!.name))
              ]),
              onFieldSubmitted: (value) {
                FocusScope.of(context).requestFocus(_credentialFocusNode);
              },
              autovalidateMode: AutovalidateMode.onUserInteraction,
              decoration: InputDecoration(
                hintText:
                    "${AppLocalizations.of(context)!.last} ${AppLocalizations.of(context)!.name}",
                labelText:
                    "${AppLocalizations.of(context)!.last} ${AppLocalizations.of(context)!.name}",
                contentPadding: const EdgeInsets.all(10),
                errorBorder: const UnderlineInputBorder(
                    borderSide: BorderSide(color: Colors.red),
                    //gapPadding: 2.0,
                    borderRadius: BorderRadius.all(Radius.circular(9))),
                errorStyle: const TextStyle(
                    height: 1.0, fontSize: 8, color: Colors.red),
                errorMaxLines: 2,
                border: const UnderlineInputBorder(
                    borderSide: BorderSide(color: Colors.red),
                    borderRadius: BorderRadius.all(Radius.circular(9))),
              ),
              style: Theme.of(context).textTheme.bodyMedium,
            )));
  }

  Widget buildCredentialWidget() {
    return SizedBox(
        width: MediaQuery.of(context).size.width - 100,
        child: Semantics(
            identifier: Semantic.S.INITIALIZE_PROFILE_CREDENTIALS_FIELD,
            child: TextFormField(
              key: K.credentialTextField,
              focusNode: _credentialFocusNode,
              controller: speciallizationController,
              onSaved: (val) {
                _credential = val!;
              },
              validator: Validatorless.multiple([
                Validatorless.max(
                    30,
                    AppLocalizations.of(context)!.maxLength(
                        AppLocalizations.of(context)!.specialization, 30)),
                Validatorless.required(AppLocalizations.of(context)!
                    .isRequired(AppLocalizations.of(context)!.specialization))
              ]),
              onFieldSubmitted: (value) {
                FocusScope.of(context).requestFocus(_clinicFocusNode);
              },
              autovalidateMode: AutovalidateMode.onUserInteraction,
              decoration: InputDecoration(
                icon: const Icon(Icons.contact_mail_sharp),
                hintText:
                    AppLocalizations.of(context)!.specializtionCredentials,
                labelText:
                    AppLocalizations.of(context)!.specializtionCredentials,
                contentPadding: const EdgeInsets.all(10),
                errorBorder: const UnderlineInputBorder(
                    borderSide: BorderSide(color: Colors.red),
                    borderRadius: BorderRadius.all(Radius.circular(9))),
                errorStyle: const TextStyle(
                    height: 1.0, fontSize: 8, color: Colors.red),
                errorMaxLines: 2,
                border: UnderlineInputBorder(
                    borderRadius: BorderRadius.circular(9)),
              ),
              style: Theme.of(context).textTheme.bodyMedium,
            )));
  }

  Widget buildSpecializationWidget() {
    return SizedBox(
        height: 60,
        width: MediaQuery.of(context).size.width - 100,
        child: Stack(alignment: Alignment.centerLeft, children: [
          const Icon(FontAwesome5Solid.book_medical, size: 25),
          Padding(
              padding: const EdgeInsets.only(left: 35),
              child: FutureBuilder<List<Speciality>>(
                  future: GetIt.instance<UtilsService>().loadSpecialities(),
                  builder:
                      (context, AsyncSnapshot<List<Speciality>> speciliaties) {
                    if (speciliaties.hasData) {
                      List<SpecialityListFiter> specialityListFilter =
                          speciliaties
                              .data!
                              .map((speciality) =>
                                  SpecialityListFiter(speciality))
                              .toList();

                      return Semantics(
                          identifier: Semantic.SemanticLabels
                              .INITIALIZE_PROFILE_SPECIALIZATION_DROPDOWN,
                          child: CustomDropdown<SpecialityListFiter>.search(
                            hintText:
                                AppLocalizations.of(context)!.specialization,
                            key: K.specializationDropDown,
                            decoration: CustomDropdownDecoration(
                                closedFillColor: Theme.of(context).primaryColor,
                                closedBorder: Border.all(color: Colors.black),
                                expandedFillColor:
                                    Theme.of(context).primaryColor,
                                headerStyle:
                                    Theme.of(context).textTheme.titleSmall,
                                closedErrorBorder:
                                    Border.all(color: Colors.red)),
                            headerBuilder:
                                (context, speciality, displayHeader) {
                              return SizedBox(
                                  height: 40,
                                  child: Stack(
                                    alignment: Alignment.centerLeft,
                                    children: [
                                      SvgPicture.asset(
                                          speciality.speciality.getIcon(),
                                          width: 25),
                                      Padding(
                                          padding:
                                              const EdgeInsets.only(left: 30),
                                          child: AutoSizeText(
                                              speciality.speciality.getTitle()))
                                    ],
                                  ));
                            },
                            items: specialityListFilter,
                            listItemBuilder:
                                (context, speciality, selected, onTap) {
                              return Semantics(
                                  identifier: speciality.speciality.getTitle(),
                                  child: Container(
                                      height: 40,
                                      padding: const EdgeInsets.all(2),
                                      child: Stack(
                                          alignment: Alignment.centerLeft,
                                          children: [
                                            SvgPicture.asset(
                                                speciality.speciality.getIcon(),
                                                height: 30,
                                                width: 30),
                                            Padding(
                                                padding: const EdgeInsets.only(
                                                    left: 40),
                                                child: AutoSizeText(
                                                    speciality.speciality
                                                        .getTitle(),
                                                    semanticsLabel: speciality
                                                        .speciality
                                                        .getTitle()))
                                          ])));
                            },
                            onChanged: (value) {
                              setState(() {
                                _specialization = value!.speciality;
                              });
                            },
                          ));
                    } else {
                      return CircularProgressIndicator();
                    }
                  }))
        ]));
  }

  Widget buildClinicWidget() {
    return SizedBox(
        width: MediaQuery.of(context).size.width - 100,
        child: Semantics(
            identifier: Semantic.S.INITIALIZE_PROFILE_CLINIC_FIELD,
            child: TextFormField(
              key: K.clinicTextField,
              focusNode: _clinicFocusNode,
              controller: clinicController,
              onSaved: (val) {
                _clinic = val!;
              },
              validator: Validatorless.multiple([
                Validatorless.max(
                    30,
                    AppLocalizations.of(context)!
                        .maxLength(AppLocalizations.of(context)!.clinic, 30)),
                Validatorless.required(AppLocalizations.of(context)!
                    .isRequired(AppLocalizations.of(context)!.clinic))
              ]),
              onFieldSubmitted: (value) {
                FocusScope.of(context).requestFocus(_contactNoFocusNode);
              },
              autovalidateMode: AutovalidateMode.onUserInteraction,
              decoration: InputDecoration(
                icon: const Icon(Icons.contact_mail_sharp),
                hintText: AppLocalizations.of(context)!.clinic,
                labelText: AppLocalizations.of(context)!.clinic,
                contentPadding: const EdgeInsets.all(10),
                errorBorder: const UnderlineInputBorder(
                    borderSide: BorderSide(color: Colors.red),
                    //gapPadding: 2.0,
                    borderRadius: BorderRadius.all(Radius.circular(9))),
                errorStyle: const TextStyle(
                    height: 1.0, fontSize: 8, color: Colors.red),
                errorMaxLines: 2,
                border: UnderlineInputBorder(
                    borderSide: const BorderSide(color: Colors.red),
                    borderRadius: BorderRadius.circular(9)),
              ),
              style: Theme.of(context).textTheme.bodyMedium,
            )));
  }

  Widget buildContactNoWidget() {
    return Stack(alignment: Alignment.centerLeft, children: [
      const Icon(Icons.phone, size: 25),
      Container(
          key: K.contactNoField,
          width: MediaQuery.of(context).size.width,
          padding: const EdgeInsets.only(left: 30),
          child: Row(children: [
            SizedBox(
                width: MediaQuery.of(context).size.width * 0.25,
                child: CountryDropdown(
                  printCountryName: true,
                  menuMaxHeight: 250,
                  iconSize: 20,
                  initialCountryData:
                      PhoneCodes.getPhoneCountryDataByCountryCode('IN'),
                  onCountrySelected: (PhoneCountryData countryData) {
                    setState(() {
                      _countryCode = countryData.phoneCode!;
                    });
                  },
                )),
            Padding(
                padding:
                    const EdgeInsets.symmetric(vertical: 10, horizontal: 10),
                child: SizedBox(
                    width: MediaQuery.of(context).size.width * 0.375,
                    child: Semantics(
                      identifier: Semantic.S.INITIALIZE_PROFILE_CONTACTNO_FIELD,
                      child: TextFormField(
                        decoration: InputDecoration(
                          hintText: AppLocalizations.of(context)!.contactNo,
                          labelText: AppLocalizations.of(context)!.contactNo,
                          contentPadding: const EdgeInsets.all(10),
                          errorBorder: UnderlineInputBorder(
                              borderSide: const BorderSide(color: Colors.red),
                              //gapPadding: 2.0,
                              borderRadius: BorderRadius.circular(9)),
                          errorStyle: const TextStyle(
                              height: 1.0, fontSize: 8, color: Colors.red),
                          errorMaxLines: 2,
                          border: UnderlineInputBorder(
                              borderSide:
                                  BorderSide(color: Colors.lightBlue[100]!),
                              borderRadius: BorderRadius.circular(9)),
                        ),
                        maxLength: 10,
                        validator: (number) {
                          Validatorless.multiple([
                            Validatorless.max(
                                30,
                                AppLocalizations.of(context)!.maxLength(
                                    AppLocalizations.of(context)!.name, 30)),
                            Validatorless.required(AppLocalizations.of(context)!
                                .isRequired(
                                    AppLocalizations.of(context)!.contactNo))
                          ]);
                          return null;
                        },
                        onSaved: (phone) {
                          setState(() {
                            _contactNo = "(" +
                                _countryCode.toString() +
                                ")" +
                                phone.toString();
                          });
                        },
                      ),
                    )))
          ])),
    ]);
  }

  Step buildPotraitDoctorProfileSlide(BuildContext context) {
    return Step(
        title: Semantics(
            identifier: Semantic.S.INTIALIZE_STEP_2,
            child: const Icon(Icons.person, size: 25)),
        state: (_currentStep == 1) ? StepState.editing : StepState.indexed,
        isActive: (_currentStep == 1) ? true : false,
        content: Container(
          height: MediaQuery.of(context).size.height * 0.8,
          //width: MediaQuery.of(context).size.width,
          color: Theme.of(context).primaryColor,
          padding: const EdgeInsets.all(5),
          key: K.doctorsProfileSlideKey,
          alignment: Alignment.topCenter,
          child: Semantics(
              identifier: Semantic.S.INITIALIZE_PROFILE_SLIDE,
              container: true,
              child: Column(children: [
                Expanded(
                  child: Container(
                    child: Stack(
                      alignment: Alignment.topCenter,
                      children: [
                        Padding(
                            padding: const EdgeInsets.all(10),
                            child: SizedBox(
                                height: 40,
                                child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Semantics(
                                        identifier: Semantic
                                            .S.INITIALIZE_PROFILE_HEADER,
                                        container: true,
                                        child: AutoSizeText(
                                          AppLocalizations.of(context)!.profile,
                                          textAlign: TextAlign.center,
                                          style: Theme.of(context)
                                              .textTheme
                                              .displayMedium,
                                        ),
                                      )
                                    ]))),
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 30),
                          child: Container(
                              margin: const EdgeInsets.symmetric(
                                  horizontal: 10, vertical: 10),
                              alignment: Alignment.center,
                              child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceEvenly,
                                  mainAxisSize: MainAxisSize.max,
                                  children: [
                                    Row(children: [
                                      buildFirstNameWidget(),
                                      const SizedBox(width: 10),
                                      buildLastNameWidget()
                                    ]),
                                    buildCredentialWidget(),
                                    buildSpecializationWidget(),
                                    buildClinicWidget(),
                                    buildContactNoWidget()
                                  ])),
                        )
                      ],
                    ),
                  ),
                )
              ])),
        ));
  }

  Widget buildPortraitPinResetWidget() {
    return Container(
        alignment: Alignment.center,
        height: MediaQuery.of(context).size.height * 0.45,
        width: MediaQuery.of(context).size.width * 0.6,
        margin: const EdgeInsets.all(5),
        child: Column(mainAxisAlignment: MainAxisAlignment.start, children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 0, vertical: 25),
            child: Semantics(
              identifier: Semantic.S.PIN_RESET_SECRET,
              child: AutoSizeText(
                  AppLocalizations.of(context)!.selectPinResetMsg,
                  style: Theme.of(context).textTheme.bodyLarge),
            ),
          ),
          Semantics(
              identifier: Semantic.S.PIN_RESET_SECRET_FIELD,
              child: DatePickerWidget(
                  key: K.datePicker,
                  looping: false, // default is not looping
                  firstDate: DateTime(1900, 1, 1), //DateTime(1960)
                  initialDate: DateTime.now(), // DateTime(1994),
                  dateFormat: "dd-MMM-yyyy",
                  locale: DateTimePickerLocale.values.firstWhere(
                      (locale) =>
                          locale.name ==
                          GetIt.instance<LocaleModel>().getLocale.languageCode,
                      orElse: () => DATETIME_PICKER_LOCALE_DEFAULT),
                  onChange: (DateTime date, _) {
                    resetDate = date;
                    setState(() {});
                  },
                  pickerTheme: DateTimePickerTheme(
                      backgroundColor: Theme.of(context).primaryColor,
                      itemHeight: 60,
                      itemTextStyle: TextStyle(
                          color: Theme.of(context).indicatorColor,
                          fontSize: 18),
                      dividerColor: Colors.grey[400]
                      //dividerColor: Theme.of(context).indicatorColor
                      ))),
        ]));
  }

  Widget buildPinWidget(BuildContext context) {
    return Semantics(
        identifier: Semantic.S.INITIALIZE_SETTINGS_SLIDE,
        container: true,
        child: ConstrainedBox(
            constraints: BoxConstraints(
                maxHeight: MediaQuery.of(context).size.height * 0.3,
                // maxWidth: MediaQuery.of(context).size.width * 0.75,
                minWidth: 45,
                minHeight: 50),
            child:
                Column(mainAxisAlignment: MainAxisAlignment.center, children: [
              Padding(
                  padding: const EdgeInsets.all(25),
                  child: Semantics(
                    identifier:
                        Semantic.S.INITIALIZE_SETTINGS_ENCRYPTION_PIN_TITLE,
                    container: true,
                    child: AutoSizeText(
                        "${AppLocalizations.of(context)!.set} ${AppLocalizations.of(context)!.data.toLowerCase()} ${AppLocalizations.of(context)!.encryption.toLowerCase()}  & ${AppLocalizations.of(context)!.security.toLowerCase()} ${AppLocalizations.of(context)!.pin.toLowerCase()}",
                        style: Theme.of(context).textTheme.bodyLarge),
                  )),
              Semantics(
                  label: Semantic.S.INTIALIZE_SETTINGS_ENCRYPTION_PIN_FIELD,
                  child: PinEntryTextField(
                    key: K.pinTextField,
                    onSubmit: (pin) {
                      if (pin.trim().length < 4) {
                      } else {
                        _fileEncryptionPin = int.parse(pin);
                      }
                      setState(() {});
                    },
                  )),
            ])));
    //));
  }

  Step buildPortraitSecuritySlide(BuildContext context) {
    return Step(
        title: Semantics(
            identifier: Semantic.S.INITALIZE_STEP_4,
            child: const Icon(Icons.security, size: 25)),
        state: (_currentStep == 2) ? StepState.editing : StepState.indexed,
        isActive: (_currentStep == 2) ? true : false,
        content: Container(
            height: MediaQuery.of(context).size.height * 0.75,
            key: K.securitySettingsSlideKey,
            color: Theme.of(context).primaryColor,
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 15),
            child: Stack(alignment: Alignment.center, children: [
              Align(
                  alignment: Alignment.topCenter,
                  child: Container(
                    height: MediaQuery.of(context).size.height * 0.15,
                    padding: EdgeInsets.all(25),
                    child: Semantics(
                        identifier: Semantic.S.SECURITY_SETTINGS_HEADER,
                        child: AutoSizeText(
                            AppLocalizations.of(context)!.securitySettings,
                            style: Theme.of(context).textTheme.displayMedium)),
                  )),
              Container(
                  height: MediaQuery.of(context).size.height * 0.6,
                  //alignment: Alignment.center,
                  child: SingleChildScrollView(
                      child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                        buildPinWidget(context),
                        buildPortraitPinResetWidget()
                      ])))
            ])));
  }

  Widget buildStepIndicator() {
    List<Widget> widgets = [];
    if (_currentStep > 0) {
      widgets.add(IconButton(
          key: K.prevStep,
          icon: Icon(Icons.arrow_left,
              color: Theme.of(context).indicatorColor, size: 30),
          onPressed: () {
            StepCancel();
          }));
    } else {
      widgets.add(const SizedBox(width: 40));
    }

    widgets.add(
      DotsIndicator(
          dotsCount: 3,
          position: _currentStep,
          decorator: DotsDecorator(
            size: const Size.square(9.0),
            activeSize: const Size(20.0, 9.0),
            activeShape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(5.0)),
            activeColor: Theme.of(context).indicatorColor,
          ),
          onTap: (position) {
            setState(() => _currentStep = position - 1);
          }),
    );

    if (_currentStep < 2) {
      widgets.add(IconButton(
          key: K.nextStep,
          icon: Icon(Icons.arrow_right,
              color: Theme.of(context).indicatorColor,
              size: 30,
              semanticLabel: Semantic.S.SECURITY_SETTINGS_NEXT_BUTTON),
          onPressed: () {
            StepContinue();
          }));
    } else {
      widgets.add(IconButton(
          key: K.checkButton,
          icon: Icon(Foundation.check,
              size: 30,
              color: Theme.of(context).indicatorColor,
              semanticLabel: Semantic.S.SECURITY_SETTINGS_DONE_BUTTON),
          onPressed: () async {
            Locale locale = GetIt.instance<LocaleModel>().getLocale;

            if (formKey.currentState!.validate()) {
              formKey.currentState!.save();

              AppUser user = AppUser(
                  _firstName!,
                  _lastName!,
                  _credential!,
                  _specialization!.getTitle(),
                  _clinic!,
                  locale,
                  _contactNo!,
                  _userType);

              bool isSuccess = await submit(_userType);

              if (isSuccess) {
                navService.pushReplacementNamed(Routes.InitSplash,
                    args: InitSplashPageArguments(user: user));
              }
            }
          }));
    }

    return Container(
        color: Theme.of(context).primaryColor,
        height: MediaQuery.of(context).size.height * 0.08,
        child: Padding(
            padding: const EdgeInsets.all(2),
            child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: widgets)));
  }

  void StepContinue() {
    if (_currentStep < 2) {
      if (_currentStep == 1) formKey.currentState!.validate();

      setState(() {
        _currentStep += 1;
        //if (_currentStep == 2) FocusNodes.securityPinField.requestFocus();
      });
    }
  }

  void StepCancel() {
    if (_currentStep >= 1) {
      setState(() {
        _currentStep -= 1;
      });
    }
  }

  Future<bool> submit(UserType userType) async {
    bool isSuccess = false;
  

    isSuccess = await SecureStorageService.store(
        "storagePin", _fileEncryptionPin.toString());

    isSuccess = await GetIt.instance<UserPrefs>().setPin(_fileEncryptionPin);
    isSuccess = await GetIt.instance<UserPrefs>().setReminderDate(resetDate);

    if (userType != UserType.Beta) {
      isSuccess =
          await GetIt.instance<UserPrefs>().setInstallDate(DateTime.now());
      isSuccess =
          await GetIt.instance<UserPrefs>().setCounterResetDate(DateTime.now());

      isSuccess = await GetIt.instance<UserPrefs>().resetCounter();
    }
    return isSuccess;
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
        onPopInvoked: (shoudlPop) => exit(0),
        child: Scaffold(
            backgroundColor: Theme.of(context).primaryColor,
            body: SafeArea(
                minimum: const EdgeInsets.only(top: 0, bottom: 0),
                child: Form(
                    key: formKey,
                    child: Center(
                        child: Stack(children: [
                      Align(
                        alignment: Alignment.bottomCenter,
                        child: buildStepIndicator(),
                      ),
                      SwipeTo(
                          onRightSwipe: (dragDetails) {
                            StepCancel();
                          },
                          onLeftSwipe: (dragDetails) {
                            StepContinue();
                          },
                          child: Container(
                            height: MediaQuery.of(context).size.height * 0.85,
                            width: MediaQuery.of(context).size.width,
                            color: Theme.of(context).primaryColor,
                            child: Stepper(
                              key: K.pageStepper,
                              onStepTapped: (index) {
                                setState(() {
                                  _currentStep = index;
                                });
                              },
                              type: StepperType.horizontal,
                              controlsBuilder: (context, controlsBuilder) {
                                return Container();
                              },
                              onStepContinue: () => StepContinue(),
                              onStepCancel: () => StepCancel(),
                              currentStep: _currentStep,
                              steps: [
                                buildPotraitIntroSlide(context),
                                buildPotraitDoctorProfileSlide(context),
                                buildPortraitSecuritySlide(context)
                              ],
                            ),
                          )),
                    ]))))));
  }
}
