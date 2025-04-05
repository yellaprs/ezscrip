import 'package:ezscrip/profile/model/appUser.dart';

class HomePageArguments {
  final bool showDemo;
  final AppUser user;
  final Map<String, dynamic> properties;

  HomePageArguments(
      {required this.user, required this.properties, required this.showDemo});
}
