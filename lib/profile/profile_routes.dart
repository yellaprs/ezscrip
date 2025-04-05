import 'package:ezscrip/profile/model/appUser.dart';
import 'package:ezscrip/util/mode.dart';
import 'package:ezscrip/util/speciality.dart';

class LetterheadSelectionPageArguments {
  final Mode mode;
  final String letterHead;
  final String selectedFormat;

  LetterheadSelectionPageArguments(
      {required this.mode,
      required this.letterHead,
      required this.selectedFormat});
}

class ProfilePageArguments {
  final AppUser user;
  final List<Speciality> specialityList;
  final Mode mode;

  ProfilePageArguments(
      {required this.user, required this.specialityList, required this.mode});
}

class ViewProfilePageArguments {
  final AppUser user;

  ViewProfilePageArguments({required this.user});
}
