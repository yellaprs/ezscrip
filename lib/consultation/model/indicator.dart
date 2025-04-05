enum IndicatorType { BloodPressure, HeartRate, Temperature, Spo2 }

class Indicator {
  IndicatorType _type;
  dynamic _value;
  

  Indicator(this._type, this._value);

  IndicatorType getType() => _type;

  dynamic getValue() => _value;

  Map<String, dynamic> toMap() {
    return {
      'indicator':
          _type.toString().substring(_type.toString().indexOf(".") + 1),
      'value': _value,
      
    };
  }

  factory Indicator.fromMap(Map<String, dynamic> mapEntry) {
    IndicatorType type = IndicatorType.values.firstWhere(
      (element) =>
          element.toString().substring(element.toString().indexOf(".") + 1) ==
          mapEntry['indicator'],
    );
    return Indicator(type, mapEntry['value']);
  }

   String getUnits() {
    switch (_type) {
      case IndicatorType.BloodPressure:
        return "mm/hg";
      case IndicatorType.HeartRate:
        return "/min";
      case IndicatorType.Temperature:
        return "F";
      case IndicatorType.Spo2:
        return "%";
    }
  }

  @override
  String toString() {
    return "${_value.toString()} ${getUnits()}";
  }
}
