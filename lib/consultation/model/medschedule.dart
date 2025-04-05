import 'package:ezscrip/consultation/model/durationType.dart';
import 'package:ezscrip/consultation/model/frequencyType.dart';
import 'package:ezscrip/consultation/model/direction.dart';
import 'package:ezscrip/consultation/model/preparation.dart';
import 'package:ezscrip/consultation/model/time.dart';
import 'package:ezscrip/consultation/model/unit.dart';
import 'package:enum_to_string/enum_to_string.dart';
import 'medStatus.dart';

class MedSchedule {
  String _name;
  MedStatus _status;
  Preparation _preparation;
  int? dosage;
  Unit? unit;
  bool? isHalfTab;
  FrequencyType? frequencyType;
  DurationType? durationType;
  int? duration;

  Direction? direction;
  String? instructions;
  List<Time>? times;

  String getName() => _name;
  Preparation getPreparation() => _preparation;

  int getDosage() => dosage!;

  Unit? getUnit() => unit;

  Direction? getDirection() => direction;

  String? getInstructions() => instructions;

  List<Time> getTimes() => times!;

  MedStatus getStatus() => _status;

  FrequencyType? getFrequencyType() => frequencyType;

  DurationType? getDurationType() => durationType;

  int? getDuration() => duration;

  MedSchedule(this._name, this._status, this._preparation,
      {this.dosage,
      this.unit,
      this.frequencyType,
      this.duration,
      this.durationType,
      this.direction,
      this.instructions,
      this.times,
      this.isHalfTab});

  Map<String, dynamic> toMap() {
    return {
      'status':
          _status.toString().substring(_status.toString().indexOf(".") + 1),
      'name': _name,
      'dosage': dosage,
      'unit': unit.toString().substring(unit.toString().indexOf(".") + 1),
      'preparation': _preparation
          .toString()
          .substring(_preparation.toString().indexOf(".") + 1),
      'frequency_type': frequencyType
          .toString()
          .substring(frequencyType.toString().indexOf(".") + 1),
      'duration_type': durationType
          .toString()
          .substring(durationType.toString().indexOf(".") + 1),
      'duration': duration,
      'direction': (direction != null)
          ? EnumToString.convertToString(direction, camelCase: true)
              .toLowerCase()
          : "",
      'times': (times != null)
          ? times!
              .map((e) => e.toString().substring(e.toString().indexOf(".") + 1))
              .toList()
          : "",
      'isHalf': isHalfTab
    };
  }

  factory MedSchedule.fromMap(Map<String, dynamic> map) {
    bool isHalfTab = false;
    String dosageStr;
    int dosage;
    Unit unit;
    FrequencyType frequencyType;
    DurationType durationType;
    int duration;
    Direction? direction;
    String? instructions;
    List<dynamic> timesJson;
    List<Time> times;

    MedSchedule medSchedule;

    String medStatusStr = map['status'];

    MedStatus status = MedStatus.values.firstWhere((element) =>
        element.toString().substring(element.toString().indexOf(".") + 1) ==
        medStatusStr);
    String name = map['name'] as String;

    Preparation preparation = Preparation.values.firstWhere((element) =>
        element.toString().substring(element.toString().indexOf(".") + 1) ==
        map['preparation']);

    if (status != MedStatus.Discontinue) {
      if (preparation == Preparation.Tablet) {
        isHalfTab = (map['isHalf'].toString().toLowerCase() == "true");
      }

      dosage = map['dosage'];

      unit = Unit.values.firstWhere((element) =>
          element.toString().substring(element.toString().indexOf(".") + 1) ==
          map['unit']);

      frequencyType = FrequencyType.values.firstWhere((element) =>
          element.toString().substring(element.toString().indexOf(".") + 1) ==
          map['frequency_type']);
      durationType = DurationType.values.firstWhere((element) =>
          element.toString().substring(element.toString().indexOf(".") + 1) ==
          map['duration_type']);

      duration = map['duration'];

      direction = (map['direction'] != null &&
              (map['direction'] as String).trim().isNotEmpty)
          ? Direction.values.firstWhere((direction) =>
              EnumToString.convertToString(direction, camelCase: true)
                  .toLowerCase() ==
              map['direction'] as String)
          : null;
      instructions =
          (map['instructions'] != null) ? map['instructions'] as String : "";

      timesJson = (map['times'] != null) ? map['times'] : [];

      times = (timesJson.length > 0)
          ? timesJson
              .map((element) => Time.values.firstWhere((time) =>
                  time.toString().substring(time.toString().indexOf(".") + 1) ==
                  (element as String).trim()))
              .toList()
          : [];

      medSchedule = MedSchedule(name, status, preparation,
          dosage: dosage,
          unit: unit,
          frequencyType: frequencyType,
          duration: duration,
          durationType: durationType,
          direction: direction,
          instructions: instructions,
          times: times,
          isHalfTab: isHalfTab);
    } else {
      medSchedule = MedSchedule(name, status, preparation);
    }

    return medSchedule;
  }
}
