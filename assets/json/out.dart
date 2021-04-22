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
  int aa;

  HiRootAaBean({
    this.aa,
  });

  HiRootAaBean.fromJson(Map<String, dynamic> json) {
    aa = json['aa'];
  }

  Map<String, dynamic> toJson() {
    return {
      'aa': aa,
    };
  }
}
