class Root {
  List<List<RootValue>> value;

  Root({this.value});

  Root.fromJson(List<dynamic> json) {
    value = json
        .map((e) => (e as List).map((e) => RootValue.fromJson(e)).toList())
        .toList();
  }

  List<dynamic> toJson() {
    return value.map((e) => e.map((e) => e.toJson()).toList()).toList();
  }
}

class RootValue {
  String aa;
  bool bb;
  RootValueCc cc;

  RootValue({
    this.aa,
    this.bb,
    this.cc,
  });

  RootValue.fromJson(Map<String, dynamic> json) {
    aa = json['aa']?.toString();
    bb = json['bb'];
    cc = json['cc'] != null ? RootValueCc.fromJson(json['cc']) : null;
  }

  Map<String, dynamic> toJson() {
    return {
      'aa': aa,
      'bb': bb,
      'cc': cc?.toJson(),
    };
  }
}

class RootValueCc {
  List<double> ilis;

  RootValueCc({
    this.ilis,
  });

  RootValueCc.fromJson(Map<String, dynamic> json) {
    if (json['ilis'] != null) {
      ilis = (json['ilis'] as List).map((e) => e.toDouble()).toList();
    }
  }

  Map<String, dynamic> toJson() {
    return {
      'ilis': ilis,
    };
  }
}
