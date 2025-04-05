import 'package:ezscrip/profile/model/appUser.dart';

class AppUserDto {
  late String firstName;
  late String lastName;
  late String credential;
  late String specialization;
  late String clinic;
  late String contactNo;

  AppUserDto();

  static AppUserDto fromUser(AppUser user) {
    AppUserDto appUserDto = AppUserDto();

    appUserDto.firstName = user.getFirstName();
    appUserDto.lastName = user.getLastName();
    appUserDto.credential = user.getCredentials();
    appUserDto.clinic = user.getClinic();
    appUserDto.specialization = user.getSpecialization();
    appUserDto.contactNo = user.getContactNo();

    return appUserDto;
  }
}
