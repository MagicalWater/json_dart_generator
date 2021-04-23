class HiRootBean {
  List<HiRootAaBean> aa;

  HiRootBean({
    this.aa,
  });

  HiRootBean.fromJson(Map<String, dynamic> json) {
    if (json['aa'] != null) {
      aa = (json['aa'] as List).map((e) => HiRootAaBean.fromJson(e)).toList();
    }
  }

  Map<String, dynamic> toJson() {
    return {
      'aa': aa.map((e) => e.toJson()).toList(),
    };
  }
}

class HiRootAaBean {
  List<HiRootAaBbBean> bb;

  HiRootAaBean({
    this.bb,
  });

  HiRootAaBean.fromJson(Map<String, dynamic> json) {
    if (json['bb'] != null) {
      bb = (json['bb'] as List).map((e) => HiRootAaBbBean.fromJson(e)).toList();
    }
  }

  Map<String, dynamic> toJson() {
    return {
      'bb': bb.map((e) => e.toJson()).toList(),
    };
  }
}

class HiRootAaBbBean {
  int cc;

  HiRootAaBbBean({
    this.cc,
  });

  HiRootAaBbBean.fromJson(Map<String, dynamic> json) {
    cc = json['cc'];
  }

  Map<String, dynamic> toJson() {
    return {
      'cc': cc,
    };
  }
}
