class TestParameter {
  String _name;
  String _value;
  String? unit;

  TestParameter(this._name, this._value, this.unit);

  String getName() => _name;

  String getValue() => _value;

  String? getUnit() => unit;

  factory TestParameter.fromMap(Map<String, dynamic> testParamaterMap) {
    
    String name = testParamaterMap['name']! as String;
    String value = testParamaterMap['value']! as String;
    String? unit = (testParamaterMap['unit'].toString().length > 0)? testParamaterMap['unit'] : null;

    return TestParameter(name, value, unit);
  }

  Map<String, String> toMap() {
    return {"name": _name, "value": _value, "unit": (unit != null) ? unit! : ""};
  }
}
