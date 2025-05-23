import 'package:ezscrip/profile/model/appUserDto.dart';
import 'package:ezscrip/profile/model/userType.dart';
import 'package:flutter/rendering.dart';

class AppUser {
  UserType _userType;
  String _firstName;
  String _lastName;
  String _credentials;
  String _specialization;
  String _clinic;
  Locale _locale;
  String _contactNo;

  AppUser(
      this._firstName,
      this._lastName,
      this._credentials,
      this._specialization,
      this._clinic,
      this._locale,
      this._contactNo,
      this._userType);

  String getFirstName() => _firstName;

  String getLastName() => _lastName;

  String getCredentials() => _credentials;

  String getSpecialization() => _specialization;

  String getClinic() => _clinic;

  Locale getLocale() => _locale;

  String getContactNo() => _contactNo;

  void setFirstName(String firstName) {
    _firstName = firstName;
  }

  void setLastName(String userName) {
    _lastName = userName;
  }

  void setCredentials(String credentials) {
    _credentials = credentials;
  }

  void setSpecialization(String specialization) {
    _specialization = specialization;
  }

  void setClinic(String clinic) {
    _clinic = clinic;
  }

  void setLocale(Locale locale) {
    _locale = locale;
  }

  void setContactNo(String contactNo) {
    _contactNo = contactNo;
  }

  void setUserType(UserType userType) {
    _userType = userType;
  }

  UserType getUserType() {
    return _userType;
  }

  factory AppUser.getIntance(
      String firstName,
      String lastName,
      String credential,
      String specialization,
      String clinic,
      Locale locale,
      String contactNo,
      UserType userType) {
    return AppUser(firstName, lastName, credential, specialization, clinic,
        locale, contactNo, userType);
  }
  AppUserDto toDto() {
    return AppUserDto.fromUser(this);
  }
}
