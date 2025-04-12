import 'package:animated_custom_dropdown/custom_dropdown.dart';
import 'package:ezscrip/settings/model/userprefs.dart';
import 'package:ezscrip/util/keys.dart';
import 'package:ezscrip/profile/model/appUser.dart';
import 'package:ezscrip/util/speciality.dart';
import 'package:ezscrip/util/ui_constants.dart';
import 'package:flutter/material.dart';
import 'package:ezscrip/app_bar.dart';
import 'package:flutter_multi_formatter/formatters/phone_input_formatter.dart';
import 'package:flutter_multi_formatter/widgets/country_dropdown.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:flutter_svg/svg.dart';
import 'package:flutter_vector_icons/flutter_vector_icons.dart';
import 'package:get_it/get_it.dart';
import 'package:no_context_navigation/no_context_navigation.dart';
import '../../util/semantics.dart' as semantic;
import 'package:country_calling_code_picker/picker.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:validatorless/validatorless.dart';
import 'package:ezscrip/util/mode.dart';
import 'package:auto_size_text/auto_size_text.dart';
import '../../util/focus_nodes.dart';

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

class ProfilePage extends StatefulWidget {
  final AppUser user;
  final List<Speciality> specialityList;
  final Mode mode;

  const ProfilePage(
      {required this.user,
      required this.specialityList,
      required this.mode,
      Key key = const Key("profileEditPage")})
      : super(key: key);
  _ProfilePageState createState() =>
      _ProfilePageState(user, specialityList, mode);
}

class _ProfilePageState extends State<ProfilePage> {
  AppUser _user;
  List<Speciality> _specialityList;
  Mode _mode;
  late Speciality _speciality;

  late List<SpecialityListFiter> _specialityFilterList;
  late SpecialityListFiter _selectedSpeciality;

  late TextEditingController _firstnameController,
      _lastnameController,
      _speciallizationController,
      _clinicController,
      _contactNoController;

  late String _countryCode, _contactNo;
  late FocusNode _firstNameFocusNode,
      _lastNameFocusNode,
      _specializationFocusNode,
      _clinicFocusNode,
      _contactNoFocusNode,
      _credentialFocusNode;

  final _formKey = GlobalKey<FormState>();

  _ProfilePageState(this._user, this._specialityList, this._mode);

  @override
  void initState() {
    _firstnameController = TextEditingController();
    _lastnameController = TextEditingController();
    _speciallizationController = TextEditingController();
    _clinicController = TextEditingController();
    _contactNoController = TextEditingController();

    _specialityFilterList =
        _specialityList.map((e) => SpecialityListFiter(e)).toList();

    _speciality = _specialityList.firstWhere((element) =>
        element.getTitle().toLowerCase() ==
        _user.getSpecialization().toLowerCase());

    _selectedSpeciality = _specialityFilterList.firstWhere(
        (element) => element.speciality.getTitle() == _speciality.getTitle());

    _firstnameController.text = _user.getFirstName();
    _lastnameController.text = _user.getLastName();
    _speciallizationController.text = _user.getCredentials();

    _clinicController.text = _user.getClinic();
    _countryCode = _user.getContactNo().substring(
        _user.getContactNo().indexOf("(") + 1,
        _user.getContactNo().indexOf(")"));

    _contactNo =
        _user.getContactNo().substring(_user.getContactNo().indexOf(")") + 1);
    _contactNoController.text = _contactNo;
    _firstNameFocusNode = FocusNode();
    _lastNameFocusNode = FocusNode();
    _specializationFocusNode = FocusNode();
    _clinicFocusNode = FocusNode();
    _contactNoFocusNode = FocusNode();
    _credentialFocusNode = FocusNode();

    super.initState();
  }

  List<IconButton> buildActions() {
    List<IconButton> actions = [];

    if (_mode == Mode.Edit) {
      actions.add(IconButton(
        key: K.saveButton,
        tooltip: "Save Profile",
        icon: const Icon(Foundation.check,
            size: UI.DIALOG_ACTION_BTN_SIZE,
            color: Colors.white,
            semanticLabel: semantic.S.EDIT_PROFILE_DONE_BTN),
        onPressed: () async {
          if (_formKey.currentState!.validate()) {
            _formKey.currentState!.save();

            _user.setSpecialization(_specialityList
                .firstWhere(
                    (element) => element.getTitle() == _speciality.getTitle())
                .getTitle());

            await GetIt.instance<UserPrefs>().saveUser(_user);

            navService.goBack(result: _user);
            // Navigator.pop(context, _user);
          }
        },
      ));
    } else {
      actions.add(IconButton(
          key: K.saveButton,
          focusNode: FocusNodes.editProfileKey,
          tooltip: "Edit Profile",
          icon: Icon(Icons.edit,
              size: UI.DIALOG_ACTION_BTN_SIZE,
              color: Theme.of(context).indicatorColor),
          onPressed: (_mode == Mode.Preview)
              ? null
              : () async {
                  setState(() {
                    _mode = Mode.Edit;
                  });
                }));
    }

    return actions;
  }

  Widget buildFirstNameWidget() {
    return Semantics(
        identifier: semantic.S.EDIT_PROFILE_NAME,
        child: SizedBox(
            height: MediaQuery.of(context).size.height * 0.15,
            width: MediaQuery.of(context).size.width * 0.375,
            child: TextFormField(
              key: K.firstNameTextField,
              autofocus: true,
              readOnly: (_mode == Mode.View) ? true : false,
              focusNode: _firstNameFocusNode,
              controller: _firstnameController,
              onSaved: (val) {
                _user.setFirstName(val!);
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
                FocusScope.of(context).requestFocus(_lastNameFocusNode);
              },
              decoration: InputDecoration(
                icon: const Icon(Icons.person),
                hintText:
                    "${AppLocalizations.of(context)!.first} ${AppLocalizations.of(context)!.name}",
                labelText:
                    "${AppLocalizations.of(context)!.first} ${AppLocalizations.of(context)!.name}",
                contentPadding: const EdgeInsets.all(10),
                errorBorder: UnderlineInputBorder(
                    borderSide: const BorderSide(color: Colors.red),
                    //gapPadding: 2.0,
                    borderRadius: BorderRadius.circular(9)),
                errorStyle: const TextStyle(
                    height: 1.0, fontSize: 8, color: Colors.red),
                errorMaxLines: 2,
                border: UnderlineInputBorder(
                    borderSide: BorderSide(color: Colors.lightBlue[100]!),
                    borderRadius: BorderRadius.circular(9)),
              ),
              style: Theme.of(context).textTheme.bodyMedium,
            )));
  }

  Widget buildLastNameWidget() {
    return Semantics(
        identifier: semantic.S.EDIT_PROFILE_NAME,
        child: SizedBox(
            height: MediaQuery.of(context).size.height * 0.15,
            width: MediaQuery.of(context).size.width * 0.375,
            child: TextFormField(
              key: K.lastNameTextField,
              autofocus: true,
              readOnly: (_mode == Mode.View) ? true : false,
              focusNode: _lastNameFocusNode,
              controller: _lastnameController,
              onSaved: (val) {
                _user.setLastName(val!);
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
              decoration: InputDecoration(
                hintText:
                    "${AppLocalizations.of(context)!.last} ${AppLocalizations.of(context)!.name}",
                labelText:
                    "${AppLocalizations.of(context)!.last} ${AppLocalizations.of(context)!.name}",
                contentPadding: const EdgeInsets.all(10),
                errorBorder: UnderlineInputBorder(
                    borderSide: const BorderSide(color: Colors.red),
                    //gapPadding: 2.0,
                    borderRadius: BorderRadius.circular(9)),
                errorStyle: const TextStyle(
                    height: 1.0, fontSize: 8, color: Colors.red),
                errorMaxLines: 2,
                border: UnderlineInputBorder(
                    borderSide: BorderSide(color: Colors.lightBlue[100]!),
                    borderRadius: BorderRadius.circular(9)),
              ),
              style: Theme.of(context).textTheme.bodyMedium,
            )));
  }

  Widget buildSpecializationWidget() {
    return SizedBox(
        height: MediaQuery.of(context).size.height * 0.15,
        width: MediaQuery.of(context).size.width * 0.7,
        child: Stack(alignment: Alignment.centerLeft, children: [
          const Icon(FontAwesome5Solid.book_medical, size: 25),
          Padding(
              padding: const EdgeInsets.only(left: 40),
              child: Semantics(
                  identifier:
                      semantic.S.INITIALIZE_PROFILE_SPECIALIZATION_DROPDOWN,
                  child: CustomDropdown<SpecialityListFiter>.search(
                    hintText: AppLocalizations.of(context)!.specialization,
                    key: K.specializationDropDown,
                    decoration: CustomDropdownDecoration(
                        closedFillColor: Theme.of(context).primaryColor,
                        closedBorder: Border.all(color: Colors.black),
                        expandedFillColor: Theme.of(context).primaryColor,
                        headerStyle: Theme.of(context).textTheme.titleSmall,
                        closedErrorBorder: Border.all(color: Colors.red)),
                    initialItem: _selectedSpeciality,
                    headerBuilder: (context, speciality, displayHeader) {
                      return SizedBox(
                          height: 40,
                          child: Stack(
                            alignment: Alignment.centerLeft,
                            children: [
                              SvgPicture.asset(speciality.speciality.getIcon(),
                                  width: 25),
                              Padding(
                                  padding: const EdgeInsets.only(left: 30),
                                  child: AutoSizeText(
                                      speciality.speciality.getTitle()))
                            ],
                          ));
                    },
                    items: _specialityFilterList,
                    listItemBuilder: (context, speciality, selected, onTap) {
                      return Semantics(
                          identifier: semantic
                              .S.INITIALIZE_PROFILE_SPECIALIZATION_OPTION,
                          child: Container(
                              height: MediaQuery.of(context).size.height * 0.15,
                              padding: const EdgeInsets.all(2),
                              child: Stack(
                                  alignment: Alignment.centerLeft,
                                  children: [
                                    SvgPicture.asset(
                                        speciality.speciality.getIcon(),
                                        height: 30,
                                        width: 30),
                                    Padding(
                                        padding:
                                            const EdgeInsets.only(left: 40),
                                        child: AutoSizeText(
                                            speciality.speciality.getTitle()))
                                  ])));
                    },
                    onChanged: (value) {
                      setState(() {
                        _speciality = value!.speciality;
                      });
                    },
                  )))
        ]));
  }

  Widget buildCredentialsWidget() {
    return Semantics(
        identifier: semantic.S.EDIT_PROFILE_CREDENTIALS,
        child: SizedBox(
            height: MediaQuery.of(context).size.height * 0.15,
            child: TextFormField(
              key: K.credentialTextField,
              controller: _speciallizationController,
              focusNode: _credentialFocusNode,
              readOnly: (_mode == Mode.Preview) ? true : false,
              onSaved: (val) {
                _user.setSpecialization(val!);
              },
              validator: Validatorless.multiple([
                Validatorless.max(
                    30,
                    AppLocalizations.of(context)!.maxLength(
                        AppLocalizations.of(context)!.specialization, 30)),
                Validatorless.required(AppLocalizations.of(context)!.isRequired(
                    AppLocalizations.of(context)!.specializtionCredentials))
              ]),
              onFieldSubmitted: (value) {
                FocusScope.of(context).requestFocus(_clinicFocusNode);
              },
              decoration: InputDecoration(
                icon: const Icon(Icons.contact_mail_sharp),
                hintText:
                    AppLocalizations.of(context)!.specializtionCredentials,
                labelText:
                    AppLocalizations.of(context)!.specializtionCredentials,
                contentPadding: const EdgeInsets.all(10),
                errorBorder: UnderlineInputBorder(
                    borderSide: const BorderSide(color: Colors.red),
                    //gapPadding: 2.0,
                    borderRadius: BorderRadius.circular(9)),
                errorStyle: const TextStyle(
                    height: 1.0, fontSize: 8, color: Colors.red),
                errorMaxLines: 2,
                border: UnderlineInputBorder(
                    borderSide: BorderSide(color: Colors.lightBlue[100]!),
                    borderRadius: BorderRadius.circular(9)),
              ),
              style: Theme.of(context).textTheme.bodyMedium,
            )));
  }

  Widget buildLocationWidget() {
    return Semantics(
        identifier: semantic.S.EDIT_PROFILE_CLINIC,
        child: SizedBox(
            height: MediaQuery.of(context).size.height * 0.15,
            child: TextFormField(
              key: K.clinicTextField,
              focusNode: _clinicFocusNode,
              controller: _clinicController,
              readOnly: (_mode == Mode.View) ? true : false,
              onSaved: (val) {
                _user.setClinic(val!);
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
              decoration: InputDecoration(
                icon: const Icon(Icons.contact_mail_sharp),
                hintText: AppLocalizations.of(context)!.clinic,
                labelText: AppLocalizations.of(context)!.clinic,
                contentPadding: const EdgeInsets.all(10),
                errorBorder: UnderlineInputBorder(
                    borderSide: const BorderSide(color: Colors.red),
                    //gapPadding: 2.0,
                    borderRadius: BorderRadius.circular(9)),
                errorStyle: const TextStyle(
                    height: 1.0, fontSize: 8, color: Colors.red),
                errorMaxLines: 2,
                border: UnderlineInputBorder(
                    borderSide: BorderSide(color: Colors.lightBlue[100]!),
                    borderRadius: BorderRadius.circular(9)),
              ),
              style: Theme.of(context).textTheme.bodyMedium,
            )));
  }

  Widget buildContactNoWidget() {
    return SizedBox(
        height: MediaQuery.of(context).size.height * 0.15,
        child: Stack(alignment: Alignment.centerLeft, children: [
          const Icon(Icons.phone, size: 30),
          Container(
              width: MediaQuery.of(context).size.width * 0.85,
              height: MediaQuery.of(context).size.width * 0.125,
              padding: const EdgeInsets.only(left: 30),
              child: FutureBuilder<List<Country>>(
                  future: getCountries(context),
                  builder: (BuildContext context, countryList) {
                    if (countryList.hasData) {
                      Country country = countryList.data!.firstWhere(
                          (country) =>
                              country.callingCode ==
                              ("+" + _countryCode.trim()));

                      return Row(children: [
                        SizedBox(
                            width: MediaQuery.of(context).size.width * 0.35,
                            child: Padding(
                                padding: EdgeInsets.symmetric(
                                    horizontal: 10, vertical: 0),
                                child: CountryDropdown(
                                  printCountryName: true,
                                  initialCountryData: PhoneCodes
                                      .getPhoneCountryDataByCountryCode(
                                          country.countryCode),
                                  onCountrySelected:
                                      (PhoneCountryData countryData) {
                                    setState(() {
                                      _countryCode = countryData.phoneCode!;
                                    });
                                  },
                                ))),
                        SizedBox(
                            width: MediaQuery.of(context).size.width * 0.35,
                            child: Padding(
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 5),
                                child: Semantics(
                                    identifier:
                                        semantic.S.EDIT_PROFILE_CONTACTNO,
                                    child: TextFormField(
                                      key: K.contactNoField,
                                      readOnly:
                                          (_mode == Mode.View) ? false : true,
                                      controller: _contactNoController,
                                      decoration: InputDecoration(
                                        hintText: AppLocalizations.of(context)!
                                            .contactNo,
                                        labelText: AppLocalizations.of(context)!
                                            .contactNo,
                                        contentPadding:
                                            const EdgeInsets.all(10),
                                        errorBorder: UnderlineInputBorder(
                                            borderSide: const BorderSide(
                                                color: Colors.red),
                                            //gapPadding: 2.0,
                                            borderRadius:
                                                BorderRadius.circular(9)),
                                        errorStyle: const TextStyle(
                                            height: 1.0,
                                            fontSize: 8,
                                            color: Colors.red),
                                        errorMaxLines: 2,
                                        border: UnderlineInputBorder(
                                            borderSide: BorderSide(
                                                color: Colors.lightBlue[100]!),
                                            borderRadius:
                                                BorderRadius.circular(9)),
                                      ),
                                      validator: (number) {
                                        Validatorless.multiple([
                                          Validatorless.max(
                                              30,
                                              AppLocalizations.of(context)!
                                                  .maxLength(
                                                      AppLocalizations.of(
                                                              context)!
                                                          .name,
                                                      30)),
                                          Validatorless.required(
                                              AppLocalizations.of(context)!
                                                  .isRequired(
                                                      AppLocalizations.of(
                                                              context)!
                                                          .contactNo))
                                        ]);
                                        return null;
                                      },
                                      onSaved: (phone) {
                                        setState(() {
                                          _contactNo = phone!;
                                        });
                                      },
                                    ))))
                      ]);
                    } else {
                      return const SpinKitThreeBounce(
                          color: Colors.red, size: 30);
                    }
                  })),
        ]));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBarBuilder.buildAppBar(
            context,
            const Icon(Icons.person, size: 25),
            ((_mode == Mode.View)
                ? AppLocalizations.of(context)!.profile
                : "Edit ${AppLocalizations.of(context)!.profile}"),
            buildActions()),
        resizeToAvoidBottomInset: true,
        body: SafeArea(
            minimum: EdgeInsets.symmetric(
                horizontal: MediaQuery.of(context).size.width * 0.1,
                vertical: MediaQuery.of(context).size.width * 0.175),
            child: Form(
              key: _formKey,
              child: ListView(children: [
                Row(children: [
                  buildFirstNameWidget(),
                  SizedBox(width: 5),
                  buildLastNameWidget()
                ]),
                buildCredentialsWidget(),
                buildSpecializationWidget(),
                buildLocationWidget(),
                buildContactNoWidget()
              ]),
            )));
  }
}
