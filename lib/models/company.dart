class Company {
  String _listcompany_id = "";
  String _company_id = "";
  String _company_name = "";
  String _office_id = "";
  String _office_name = "";
  String _listcompany_remark = "";

  Company(this._listcompany_id, this._company_id, this._company_name,
      this._office_id, this._office_name, this._listcompany_remark);

  Company.map(dynamic obj) {
    this._listcompany_id = obj['listcompany_id'] ?? "";
    this._company_id = obj['company_id'] ?? "";
    this._company_name = obj['company_name'] ?? "";
    this._office_id = obj['office_id'] ?? "";
    this._office_name = obj['office_name'] ?? "";
    this._listcompany_remark = obj['listcompany_remark'] ?? "";
  }

  String get listcompany_id => _listcompany_id;
  String get company_id => _company_id;
  String get company_name => _company_name;
  String get office_id => _office_id;
  String get office_name => _office_name;
  String get listcompany_remark => _listcompany_remark;

  Map<String, dynamic> toMap() {
    var map = new Map<String, dynamic>();
    map['listcompany_id'] = _listcompany_id;
    map['company_id'] = _company_id;
    map['company_name'] = _company_name;
    map['office_id'] = _office_id;
    map['office_name'] = _office_name;
    map['listcompany_remark'] = _listcompany_remark;

    return map;
  }

  Company.fromMap(Map<String, dynamic> map) {
    this._listcompany_id = map['listcompany_id'] ?? "";
    this._company_id = map['company_id'] ?? "";
    this._company_name = map['company_name'] ?? "";
    this._office_id = map['office_id'] ?? "";
    this._office_name = map['office_name'] ?? "";
    this._listcompany_remark = map['listcompany_remark'] ?? "";
  }
}
