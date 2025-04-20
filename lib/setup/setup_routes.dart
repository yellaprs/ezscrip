import 'package:ezscrip/profile/model/appUser.dart';
import 'package:ezscrip/profile/model/userType.dart';

class IntroductionPageArguments {
  final UserType userType;
  IntroductionPageArguments({required this.userType});
}

class InitSplashPageArguments {
  final AppUser user;

  InitSplashPageArguments({required this.user});
}
