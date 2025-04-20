import 'package:enum_to_string/enum_to_string.dart';
import 'package:ezscrip/consultation/model/durationType.dart';
import 'package:ezscrip/profile/model/appUser.dart';
import 'package:ezscrip/infrastructure/services/securestorage_service.dart';
import 'package:ezscrip/profile/model/userType.dart';
import 'package:flutter/material.dart';
import 'package:global_configuration/global_configuration.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:ezscrip/util/constants.dart';

class UserPrefs extends ChangeNotifier {
  late String userName;

  Future<AppUser> getUser() async {
    AppUser user;

    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? firstName = prefs.getString(C.FIRSTNAME);
    String? lastName = prefs.getString(C.LASTNAME);
    String? specialization = prefs.getString(C.SPECIALIZATION);
    String? clinic = prefs.getString(C.CLINIC);
    String? credential = prefs.getString(C.CREDENTIAL);
    Locale? locale = await getLocale();
    String? contactNo = prefs.getString(C.CONTACT_NO);
    String? userType = prefs.getString(C.USER_TYPE);

    user = AppUser.getIntance(
        firstName!,
        lastName!,
        credential!,
        specialization!,
        clinic!,
        locale,
        contactNo!,
        UserType.values.firstWhere(
            (user) => EnumToString.convertToString(user) == userType!));

    return user;
  }

  Future<bool> isPreferencesSet() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? username = prefs.getString(C.FIRSTNAME);
    return (username != null) ? true : false;
  }

  Future<bool> saveUser(AppUser user) async {

    bool isSaved = false;

    SharedPreferences prefs = await SharedPreferences.getInstance();

    isSaved = await prefs.setString(C.FIRSTNAME, user.getFirstName());

    isSaved = await prefs.setString(C.LASTNAME, user.getLastName());

    isSaved = await prefs.setString(C.CREDENTIAL, user.getCredentials());

    isSaved = (isSaved)
        ? await prefs.setString(C.SPECIALIZATION, user.getSpecialization())
        : false;
    isSaved =
        (isSaved) ? await prefs.setString(C.CLINIC, user.getClinic()) : false;

    isSaved = (isSaved)
        ? (await prefs.setString(C.CONTACT_NO, user.getContactNo()))
        : false;

    isSaved = (isSaved) ? (await setLocale(user.getLocale())) : false;

    isSaved = (isSaved)
        ? await prefs.setString(
            C.USER_TYPE, EnumToString.convertToString(user.getUserType()))
        : false;

    notifyListeners();

    return isSaved;
  }

  Future<bool> setTemplate(String template) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return await prefs.setString(C.TEMPLATE, template);
  }

  Future<String?> getTemplate() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString(C.TEMPLATE);
  }

  Future<bool> setFormat(String format) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return await prefs.setString(C.FORMAT, format);
  }

  Future<String?> getFormat() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? format = prefs.getString(C.FORMAT);

    return (format != null) ? format : null;
  }

  Future<bool> setPin(int pin) async {
    return await SecureStorageService.store(C.PIN, pin.toString());
  }

  Future<int> getPin(int pin) async {
    String? pin = await SecureStorageService.get(C.PIN);
    return int.parse(pin!);
  }

  Future<bool> isPinSet() async {
    return (await SecureStorageService.get(C.PIN) != null) ? true : false;
  }

  Future<bool> setReminderDate(DateTime date) async {
    return await SecureStorageService.store(
        C.REMINDER_DATE, DateFormat("yyyy-MM-dd").format(date));
  }

  Future<DateTime> getReminderDate() async {
    String date = await SecureStorageService.get(C.REMINDER_DATE) as String;
    return DateFormat("yyyy-MM-dd").parse(date.trim());
  }

  Future<bool> setDataRetentionPeriod(int dataRetentionPeriod) async {
    return SecureStorageService.store(
        C.DATA_RETENTION_DURATION, dataRetentionPeriod.toString());
  }

  Future<bool> setDataRetentionPeriodType(DurationType durationType) {
    return SecureStorageService.store(C.DATA_RETENTION_DURATION_TYPE,
        EnumToString.convertToString(durationType, camelCase: false));
  }

  Future<DurationType> getDataRetentinDurationType() async {
    String? durationType =
        await SecureStorageService.get(C.DATA_RETENTION_DURATION_TYPE);

    return DurationType.values.firstWhere(
      (element) => (EnumToString.convertToString(element, camelCase: false) ==
          durationType!),
    );
  }

  Future<bool> isDataRetentionEnabled() async {
    String? dataRetentionStr =
        await SecureStorageService.get(C.DATA_RETENTION_DURATION);

    return (dataRetentionStr != null);
  }

  Future<bool> disableDataRetention() async {
    return SecureStorageService.remove(C.DATA_RETENTION_DURATION);
  }

  Future<int> getDataRetentionPeriod() async {
    String? periodStr =
        await SecureStorageService.get(C.DATA_RETENTION_DURATION);
    return int.parse(periodStr!);
  }

  Future<String> getDataRetentionTaskName() async {
    return GlobalConfiguration().get(C.TASK_NAME);
  }

  Future<bool> isDataRetentionTaskSetup() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    bool? isSetup = prefs.getBool(C.IS_DATA_RETENTION_TASK_SET);

    return (isSetup == null) ? false : isSetup;
  }

  Future<String> getDataRetentionScheduleTime() async {
    return GlobalConfiguration().get(C.TASK_SCHEDULED_TIME);
  }

  Future<bool> setDataRetentionScheduleTime(String time) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return await prefs.setString(C.TASK_SCHEDULED_TIME, time);
  }

  Future<bool> saveDataRetentionTask(bool isDataRetentionTask) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.setBool(C.IS_DATA_RETENTION_TASK_SET, isDataRetentionTask);
  }

  Future<bool> verifyPin(int pin) async {
    late int? storedPin;
    SharedPreferences prefs = await SharedPreferences.getInstance();
    if (prefs.getBool("testMode") != null) {
      storedPin = prefs.getInt(C.PIN);
    } else {
      storedPin = int.parse(await SecureStorageService.get(C.PIN) as String);
    }

    return (storedPin == pin);
  }

  Future<bool> setInstallDate(DateTime date) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    return await prefs.setInt(C.INSTALL_DATE, date.millisecondsSinceEpoch);
  }

  Future<DateTime> getInstallDate() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    return DateTime.fromMillisecondsSinceEpoch(prefs.getInt(C.INSTALL_DATE)!);
  }

  Future<bool> setBetaMode(bool isBeta) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return await prefs.setBool(C.IS_BETA, isBeta);
  }

  Future<bool> getBetaMode() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getBool(C.IS_BETA)!;
  }

  Future<bool> resetCounter() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return await prefs.setInt(C.COUNTER, 0);
  }

  Future<bool> incrementCounter() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    int counter = prefs.getInt(C.COUNTER)!;
    counter++;
    return await prefs.setInt(C.COUNTER, counter);
  }

  Future<int> getCounter() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getInt(C.COUNTER)!;
  }

  Future<bool> setCounterResetDate(DateTime date) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return await prefs.setInt(C.RESET_DATE, date.millisecondsSinceEpoch);
  }

  Future<DateTime> getResetDate() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return DateTime.fromMillisecondsSinceEpoch(
        prefs.getInt(C.RESET_DATE)!);
  }

  Future<Locale> getLocale() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String>? localeStr = (prefs.getString(C.LOCALE) != null)
        ? prefs.getString(C.LOCALE)!.split('_')
        : null;
    return Locale.fromSubtags(
        languageCode: localeStr!.first, countryCode: localeStr.elementAt(1));
  }
  
  Future<UserType> getUserType() async{

     SharedPreferences prefs = await SharedPreferences.getInstance();
     return UserType.values.firstWhere((userType) => EnumToString.convertToString(userType) == prefs.getString(C.USER_TYPE));
  }

   Future<bool> setUserType(UserType userType) async {

    SharedPreferences prefs = await SharedPreferences.getInstance();
    return  prefs.setString(C.USER_TYPE,  EnumToString.convertToString(userType) );
  
  }

  Future<bool> setLocale(Locale locale) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.setString(C.LOCALE,
        locale.languageCode.toString() + "_" + locale.countryCode.toString());
  }

  Future<bool> isDemoShown() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    bool? isDemoShown = await prefs.getBool(C.IS_DEMO_SHOWN);
    return (isDemoShown != null) ? isDemoShown : false;
  }

  Future<bool> setDemoShown(bool isDemoShown) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.setBool(C.IS_DEMO_SHOWN, isDemoShown);
  }

  Future<bool> isSignatureEnabled() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    return prefs.getBool(C.IS_SIGNATURE_ENABLED)!;
  }

  Future<bool> setSignatureEnabled(bool enabled) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.setBool(C.IS_SIGNATURE_ENABLED, enabled);
  }

  Future<bool> setSignature(String signature) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.setString(C.SIGNATURE, signature);
  }

  Future<String?> getSignature() async {
    String? signature;
    bool signatureEnabled = await isSignatureEnabled();
    if (signatureEnabled) {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      signature = prefs.getString(C.SIGNATURE)!;
    }
    return (signatureEnabled) ? signature! : null;
  }
}
