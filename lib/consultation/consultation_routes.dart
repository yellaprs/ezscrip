import 'package:ezscrip/consultation/model/consultation.dart';
import 'package:ezscrip/consultation/model/medicalHistory.dart';
import 'package:ezscrip/consultation/model/testParameter.dart';
import 'package:ezscrip/profile/model/appUser.dart';
import 'package:ezscrip/util/mode.dart';

class AdddSymtomPageArguments {
  final List<String> symptomList;

  AdddSymtomPageArguments(this.symptomList);
}

class AddMedicalHistoryArguments {
  final List<MedicalHistory> medicalHistory;

  AddMedicalHistoryArguments(this.medicalHistory);
}

class AddMedicalHistoryPageArguments {
  List<MedicalHistory> medicalHistoryList;

  AddMedicalHistoryPageArguments(this.medicalHistoryList);
}

class AddMedicationPageArguments {
  int pageIndex;
  Mode mode;
  Map<String, dynamic> propertiesMap;

  AddMedicationPageArguments(this.pageIndex, this.mode, this.propertiesMap);
}

class AddParameterPageArguments {
  List<TestParameter> parameterList;

  AddParameterPageArguments(this.parameterList);
}

class AddTestsPageArguments {
  List<String> testList;

  AddTestsPageArguments(this.testList);
}

class ConsultationEditPageArguments {
  final Mode mode;
  final Consultation consultation;
  final AppUser user;
  final Map<String, dynamic> propertiesMap;

  ConsultationEditPageArguments(
      {required this.mode,
      required this.consultation,
      required this.user,
      required this.propertiesMap});
}

class ConsultationPageArguments {
  Consultation consultation;
  AppUser user;
  bool isEditable;
  Mode? mode;
  ConsultationPageArguments(
      {required this.consultation,
      required this.user,
      required this.isEditable,
      this.mode});
}

class ConsultationSearchPageArguments {
  AppUser user;
  Mode mode;

  ConsultationSearchPageArguments({required this.user, required this.mode});
}

class SelectDatePageArguments {
  DateTime selectedDate;

  SelectDatePageArguments(this.selectedDate);
}
