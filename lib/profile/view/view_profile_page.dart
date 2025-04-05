import 'package:ezscrip/profile/profile_routes.dart';
import 'package:ezscrip/route_constants.dart';
import 'package:ezscrip/util/keys.dart';
import 'package:ezscrip/profile/model/appUser.dart';
import 'package:ezscrip/util/speciality.dart';
import 'package:ezscrip/util/utils_service.dart';
import 'package:flutter/material.dart';
import 'package:ezscrip/app_bar.dart';
import 'package:get_it/get_it.dart';
import 'package:no_context_navigation/no_context_navigation.dart';
import '../../util/semantics.dart' as semantic;
import 'package:flutter_vector_icons/flutter_vector_icons.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:ezscrip/util/mode.dart';
import 'package:auto_size_text/auto_size_text.dart';
import '../../util/focus_nodes.dart';

class ViewProfilePage extends StatefulWidget {
  final AppUser user;

  const ViewProfilePage(
      {required this.user, Key key = const Key("profileEditPage")})
      : super(key: key);

  _ViewProfilePageState createState() => _ViewProfilePageState(user);
}

class _ViewProfilePageState extends State<ViewProfilePage> {
  final AppUser _user;

  _ViewProfilePageState(this._user);

  @override
  void initState() {
    super.initState();
  }

  List<IconButton> buildActions() {
    List<IconButton> actions = [];

    actions.add(IconButton(
        key: K.editProfileButtonKey,
        focusNode: FocusNodes.editProfileKey,
        tooltip: "Edit Profile",
        icon: Icon(Icons.edit,
            size: 30,
            semanticLabel: semantic.S.PROFILE_EDIT_BTN,
            color: Theme.of(context).indicatorColor),
        onPressed: () async {
          List<Speciality> specialityList =
              await GetIt.instance<UtilsService>().loadSpecialities();
          navService.pushNamed(Routes.EditProfile,
              args: ProfilePageArguments(
                  user: _user,
                  specialityList: specialityList,
                  mode: Mode.Edit));
        }));

    return actions;
  }

  Widget buildNameWidget() {
    return SizedBox(
        width: MediaQuery.of(context).size.width - 100,
        height: 60,
        child: Stack(alignment: Alignment.centerLeft, children: [
          const Icon(Icons.person),
          Focus(
              focusNode: FocusNodes.nameLabelViewKey,
              child: Padding(
                  padding: const EdgeInsets.only(left: 40),
                  child: InputDecorator(
                      decoration: InputDecoration(
                        labelText: "${AppLocalizations.of(context)!.name}",
                        border: UnderlineInputBorder(
                          borderRadius: BorderRadius.circular(10.0),
                          //gapPadding: 1.0,
                        ),
                      ),
                      child: Semantics(
                          identifier: semantic.S.PROFILE_NAME_TITLE,
                          child: SizedBox(
                              width: MediaQuery.of(context).size.width * 0.35,
                              child: AutoSizeText(
                                "${_user.getFirstName()} ${_user.getLastName()}",
                                key: K.nameLabelKey,
                                style: Theme.of(context).textTheme.bodyMedium,
                              ))))))
        ]));
  }

  Widget buildSpecializationWidget() {
    return SizedBox(
        width: MediaQuery.of(context).size.width * 0.75,
        height: 60,
        child: Stack(alignment: Alignment.centerLeft, children: [
          const Icon(FontAwesome5Solid.book_medical, size: 30),
          Focus(
              focusNode: FocusNodes.specializationViewLabelKey,
              child: Padding(
                  padding: const EdgeInsets.only(left: 40),
                  child: InputDecorator(
                      decoration: InputDecoration(
                        labelText: AppLocalizations.of(context)!.specialization,
                        border: UnderlineInputBorder(
                          borderRadius: BorderRadius.circular(10.0),
                          //gapPadding: 1.0,
                        ),
                      ),
                      child: Semantics(
                          identifier: semantic.S.PROFILE_SPECIALIZATION_TITLE,
                          child: SizedBox(
                              width: MediaQuery.of(context).size.width * 0.6,
                              child: AutoSizeText(_user.getSpecialization(),
                                  key: K.specializationLabelKey,
                                  style: Theme.of(context)
                                      .textTheme
                                      .bodyMedium))))))
        ]));
  }

  Widget buildCredentialsWidget() {
    return SizedBox(
        width: MediaQuery.of(context).size.width * 0.75,
        height: 60,
        child: Stack(alignment: Alignment.centerLeft, children: [
          const Icon(Icons.contact_mail_sharp),
          Focus(
              focusNode: FocusNodes.credentialLabelVieewKey,
              child: Padding(
                  padding: const EdgeInsets.only(left: 40),
                  child: InputDecorator(
                      decoration: InputDecoration(
                        labelText: AppLocalizations.of(context)!.specialization,
                        border: UnderlineInputBorder(
                          borderRadius: BorderRadius.circular(10.0),
                          //gapPadding: 1.0,
                        ),
                      ),
                      child: Semantics(
                          identifier: semantic.S.PROFILE_CREDENTIALS_TITLE,
                          child: SizedBox(
                              width: MediaQuery.of(context).size.width * 0.6,
                              child: AutoSizeText(_user.getCredentials(),
                                  key: K.credentialLabelKey,
                                  style: Theme.of(context)
                                      .textTheme
                                      .bodyMedium))))))
        ]));
  }

  Widget buildLocationWidget() {
    return SizedBox(
        width: MediaQuery.of(context).size.width * 0.75,
        height: 60,
        child: Stack(alignment: Alignment.centerLeft, children: [
          const Icon(Icons.contact_mail_sharp),
          Focus(
              focusNode: FocusNodes.credentialLabelVieewKey,
              child: Padding(
                  padding: const EdgeInsets.only(left: 40),
                  child: InputDecorator(
                      decoration: InputDecoration(
                        labelText: AppLocalizations.of(context)!.clinic,
                        border: UnderlineInputBorder(
                          borderRadius: BorderRadius.circular(10.0),
                          //gapPadding: 1.0,
                        ),
                      ),
                      child: Semantics(
                          identifier: semantic.S.PROFILE_CLINIC_TITLE,
                          child: SizedBox(
                              width: MediaQuery.of(context).size.width * 0.6,
                              child: AutoSizeText(_user.getClinic(),
                                  style: Theme.of(context)
                                      .textTheme
                                      .bodyMedium))))))
        ]));
  }

  Widget buildContactNoWidget() {
    return SizedBox(
        width: MediaQuery.of(context).size.width * 0.75,
        height: 60,
        child: Stack(alignment: Alignment.centerLeft, children: [
          const Icon(Icons.phone),
          Focus(
              focusNode: FocusNodes.contactNoLabelKey,
              child: Padding(
                  padding: const EdgeInsets.only(left: 40),
                  child: InputDecorator(
                      decoration: InputDecoration(
                        labelText: AppLocalizations.of(context)!.contactNo,
                        border: UnderlineInputBorder(
                          borderRadius: BorderRadius.circular(10.0),
                          //gapPadding: 1.0,
                        ),
                      ),
                      child: Semantics(
                          identifier: semantic.S.PROFILE_CONTACTNO_TITLE,
                          child: SizedBox(
                              width: MediaQuery.of(context).size.width * 0.6,
                              child: AutoSizeText(_user.getContactNo(),
                                  style: Theme.of(context)
                                      .textTheme
                                      .bodyMedium))))))
        ]));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBarBuilder.buildAppBar(
            context, AppLocalizations.of(context)!.profile, buildActions()),
        resizeToAvoidBottomInset: false,
        body: Container(
            margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
            child: Container(
              height: MediaQuery.of(context).size.height * 0.8,
              width: MediaQuery.of(context).size.width * 0.9,
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
              alignment: Alignment.center,
              child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    buildNameWidget(),
                    buildCredentialsWidget(),
                    buildSpecializationWidget(),
                    buildLocationWidget(),
                    buildContactNoWidget()
                  ]),
            )));
  }
}
