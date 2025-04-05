import 'package:ezscrip/consultation/model/durationType.dart';
import 'package:enum_to_string/enum_to_string.dart';

class MedicalHistory {
  final String _disease;
  final int _duration;
  final DurationType _durationType;

  MedicalHistory(this._disease, this._duration, this._durationType);

  getDiseaseName() => _disease;

  getDuration() => _duration;

  getDurationType() => _durationType;

  factory MedicalHistory.fromMap(Map<String, dynamic> map) {
    String diseaseName = map['name'];

    int duration = map['duration'];

    DurationType durationType = DurationType.values.firstWhere((element) =>
        element.toString().substring(element.toString().indexOf(".") + 1) ==
        map['durationType']);

    return MedicalHistory(diseaseName, duration, durationType);
  }

  Map<String, dynamic> toMap() {
    return {
      'name': _disease,
      'duration': _duration,
      'durationType': EnumToString.convertToString(_durationType)
    };
  }
}
