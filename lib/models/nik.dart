class NIKS {
  String _personalid = "";
  String _name = "";

  NIKS(this._personalid, this._name);

  NIKS.map(dynamic obj) {
    this._personalid = obj['personalid'] ?? "";
    this._name = obj['name'] ?? "";
  }

  String get personalid => _personalid;
  String get name => _name;

  Map<String, dynamic> toMap() {
    var map = new Map<String, dynamic>();
    map['personalid'] = _personalid;
    map['name'] = _name;

    return map;
  }

  NIKS.fromMap(Map<String, dynamic> map) {
    this._personalid = map['personalid'] ?? "";
    this._name = map['name'] ?? "";
  }
}
