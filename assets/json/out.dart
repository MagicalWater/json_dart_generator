class HiRootBean {
  List<HiRootValueBean>? value;

  HiRootBean({this.value});

  HiRootBean.fromJson(List<dynamic> json) {
    value = json.map((e) => HiRootValueBean.fromJson(e)).toList();
  }

  List<dynamic>? toJson() {
    return value?.map((e) => e.toJson()).toList();
  }
}

class HiRootValueBean {
  String? open;
  String? end;

  HiRootValueBean({
    this.open,
    this.end,
  });

  HiRootValueBean.fromJson(Map<String, dynamic> json) {
    open = json['open']?.toString();
    end = json['end']?.toString();
  }

  Map<String, dynamic> toJson() {
    return {
      'open': open,
      'end': end,
    };
  }
}
