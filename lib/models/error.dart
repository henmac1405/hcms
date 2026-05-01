class Error {
  String _Error1 = "";
  String _Error2 = "";
  String _ErrorDate = "";

  Error(this._Error1, this._Error2, this._ErrorDate);

  Error.map(dynamic obj) {
    this._Error1 = obj['Error1'] ?? "";
    this._Error2 = obj['Error2'] ?? "";
    this._ErrorDate = obj['ErrorDate'] ?? "";
  }

  String get Error1 => _Error1;
  String get Error2 => _Error2;
  String get ErrorDate => _ErrorDate;

  Map<String, dynamic> toMap() {
    var map = new Map<String, dynamic>();
    map['Error1'] = _Error1;
    map['Error2'] = _Error2;
    map['ErrorDate'] = _ErrorDate;

    return map;
  }

  Error.fromMap(Map<String, dynamic> map) {
    this._Error1 = map['Error1'] ?? "";
    this._Error2 = map['Error2'] ?? "";
    this._ErrorDate = map['ErrorDate'] ?? "";
  }
}
