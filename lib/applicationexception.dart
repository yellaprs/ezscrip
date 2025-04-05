class ApplicationException implements Exception {
  final String _name;
  final String _message;

  String getName() => _name;

  String getMessage() => _message;

  ApplicationException(this._name, this._message);
}
