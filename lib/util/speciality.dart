class Speciality {
  String _title;
  String _icon;

  Speciality(this._title, this._icon);

  String getTitle() => _title;

  String getIcon() => _icon;

  static Speciality fromJson(Map<String, dynamic> json) {
   
    return Speciality(json["title"]! as String, json["icon"]! as String);
  }
}
