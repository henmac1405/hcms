class Config {
  String _config1 = "";
  String _config2 = "";
  String _config3 = "";

  Config(this._config1, this._config2, this._config3);

  Config.map(dynamic obj) {
    this._config1 = obj['config1'] ?? "";
    this._config2 = obj['config2'] ?? "";
    this._config3 = obj['config3'] ?? "";
  }

  String get config1 => _config1;
  String get config2 => _config2;
  String get config3 => _config3;

  Map<String, dynamic> toMap() {
    var map = new Map<String, dynamic>();
    map['config1'] = _config1;
    map['config2'] = _config2;
    map['config3'] = _config3;

    return map;
  }

  Config.fromMap(Map<String, dynamic> map) {
    this._config1 = map['config1'] ?? "";
    this._config2 = map['config2'] ?? "";
    this._config3 = map['config3'] ?? "";
  }
}
