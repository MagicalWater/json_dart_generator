import 'dart:convert';

import 'class_type.dart';
import 'extension.dart';

typedef ClassNamePrefixSuffixBuilder = String Function(
  String name,
  bool isPrefix,
);

/// json資料的定義與結構
class JsonDef {
  /// source 轉換而成的 json 資料
  final dynamic jsonData;

  /// json 整體結構資料
  ValueDef _jsonStruct;

  /// json 結構總結
  ValueDef _summarizeStruct;

  // 取得所有需要自定義的class
  List<ValueDef> get allCustomObject => _summarizeStruct.customObjects;

  JsonDef({
    String rootClassName,
    this.jsonData,
    bool rootClassNameWithPrefixSuffix,
    ClassNamePrefixSuffixBuilder classNamePrefixSuffixBuilder,
  }) {
    _jsonStruct = ValueDef(
      rootClassName: rootClassName,
      rootClassNameWithPrefixSuffix: rootClassNameWithPrefixSuffix,
      value: jsonData,
      classNamePrefixSuffixBuilder: classNamePrefixSuffixBuilder,
    );
    _summarizeStruct = _jsonStruct.summarize();
  }

  /// json 結構字串
  String get structString {
    return _jsonStruct.structString;
  }

  /// json 總結結構字串
  String get summarizeString {
    return _summarizeStruct.structString;
  }

  /// json 所有自定義的物件字串
  String get customObjectString {
    return _summarizeStruct.customObjectString;
  }

  /// 輸出 code
  String get classCode {
    var code = '';
    code += _summarizeStruct.classCode;
    code += allCustomObject.map((e) => e.classCode).join('\n\n');
    return code;
  }
}

class ListInner {
  /// 需要轉換的類
  ClassType type;

  /// 原始資料的類型
  ClassType oriType;

  /// 類名
  String className;

  ListInner({this.type, this.oriType, this.className});
}

/// 物件定義
class ValueDef {
  /// 型態
  ClassType type;

  /// 若為列表, 則還會有泛型型態
  ClassType listType;

  String rootClassName;

  bool rootClassNameWithPrefixSuffix;

  /// 若為多層列表時, 取得最裡面的型態
  ListInner get listInnerType {
    if (listType == null) {
      return null;
    }

    ListInner findInner(ValueDef def) {
      if (def.type == ClassType.tListDynamic) {
        if (def.listType == ClassType.tDynamic) {
          return ListInner(
            type: ClassType.tDynamic,
            oriType: ClassType.tDynamic,
            className: ClassType.tDynamic.value,
          );
        } else {
          return findInner((def.childrenDef as List<ValueDef>).first);
        }
      } else if (def.type == ClassType.tObject) {
        var customObject = findCustomObject(def);
        return ListInner(
          type: def.type,
          oriType: def.type,
          className: customObject.classNameFull,
        );
      } else {
        return ListInner(
          type: def.type,
          oriType: ClassType.getType(def.value),
          className: def.type.value,
        );
      }
    }

    return findInner(this);
  }

  /// 是否為根節點
  bool get isRoot => parent == null;

  /// 根節點是否為列表
  bool get isListRoot {
    var parentDef = this;

    while (true) {
      if (parentDef.parent == null) {
        break;
      }
      parentDef = parentDef.parent;
    }
    return parentDef.type.isList;
  }

  /// 父親
  ValueDef parent;

  /// 當前節點深度
  int get depth {
    return (parent?.depth ?? -1) + 1;
  }

  /// 一階段的空格
  String get _intentSpace {
    return '  ';
  }

  /// 依照當前的深度決定輸出空格(方便格式化)
  String get _depthIntentSpace {
    var text = '';
    for (var i = 0; i < depth; i++) {
      text += _intentSpace;
    }
    return text;
  }

  /// 尋找距離最近的父親key
  String get parentKey {
    var parentDef = this;
    var key = parentDef.key;

    while (key == null && parentDef != null) {
      key = parentDef.key;
      parentDef = parentDef.parent;
    }
    return key;
  }

  /// key 當為陣列內的元素或者最外層元素時沒有key
  final String key;

  /// 原始資料
  final dynamic value;

  /// 經過定義後的資料
  dynamic childrenDef;

  /// 類名的前後綴
  ClassNamePrefixSuffixBuilder classNamePrefixSuffixBuilder;

  /// 類名前綴
  String get classNamePrefix =>
      classNamePrefixSuffixBuilder?.call(
        classNameNoPrefixSuffix,
        true,
      ) ??
      '';

  /// 類名後綴
  String get classNameSuffix =>
      classNamePrefixSuffixBuilder?.call(
        classNameNoPrefixSuffix,
        false,
      ) ??
      '';

  /// 所有需要自定義的class
  /// 即是型態為 ClassType.tObject 的資料
  List<ValueDef> get customObjects {
    var objects = <ValueDef>[];
    if (depth != 0 && type == ClassType.tObject) {
      objects.add(this);
    }

    if (childrenDef is List<ValueDef>) {
      var childrenObject = (childrenDef as List<ValueDef>)
          .map((e) => e.customObjects)
          .expand((element) => element)
          .toList();
      objects.addAll(childrenObject);
    } else if (childrenDef is Map<String, ValueDef>) {
      var childrenObject = (childrenDef as Map<String, ValueDef>)
          .entries
          .map((e) => e.value.customObjects)
          .expand((element) => element)
          .toList();
      objects.addAll(childrenObject);
    }
    return objects;
  }

  /// 取得所有的自定義object
  List<ValueDef> get _allCustomObject {
    var parentDef = this;
    do {
      parentDef = parentDef?.parent;
    } while (parentDef?.parent != null);
    return parentDef?.customObjects ?? customObjects;
  }

  /// 尋找符合[def]結構的自定義物件
  ValueDef findCustomObject(ValueDef def) {
    var find = _allCustomObject.firstWhere(
      (element) => def.isStructSame(element),
      orElse: () => null,
    );
    return find;
  }

  /// 是否擁有相同的結構
  bool isStructSame(ValueDef other) {
    if (childrenDef is List<ValueDef> && other.childrenDef is List<ValueDef>) {
      var thisFirst = (childrenDef as List<ValueDef>).first;
      var otherFirst = (other.childrenDef as List<ValueDef>).first;
      return thisFirst.isStructSame(otherFirst);
    } else if (childrenDef is Map<String, ValueDef> &&
        other.childrenDef is Map<String, ValueDef>) {
      var thisKeyList = (childrenDef as Map<String, ValueDef>).entries;
      var otherKeyList = (other.childrenDef as Map<String, ValueDef>).entries;
      var isLengthSame = thisKeyList.length == otherKeyList.length;

      if (isLengthSame) {
        // 長度相同, 接下來檢查元素是否相同
        var isSame = !thisKeyList.any((element) {
          var thisValue = element.value;
          var otherDef = otherKeyList.firstWhere(
            (element) => thisValue.isStructSame(element.value),
            orElse: () => null,
          );

          return otherDef == null;
        });

        return isSame;
      }
    } else if (type == other.type) {
      return true;
    }

    return false;
  }

  ValueDef copyWith({ClassType type, ClassType listType, dynamic childrenDef}) {
    return ValueDef._(
      rootClassName: rootClassName,
      type: type ?? this.type,
      listType: listType,
      key: key,
      childrenDef: childrenDef ?? this.childrenDef,
    )
      ..classNamePrefixSuffixBuilder = classNamePrefixSuffixBuilder
      ..rootClassNameWithPrefixSuffix = rootClassNameWithPrefixSuffix;
  }

  ValueDef._({
    this.rootClassName,
    this.type,
    this.listType,
    this.key,
    this.childrenDef,
  }) : value = null {
    _detectAllParentNode();
  }

  ValueDef({
    this.rootClassName,
    this.rootClassNameWithPrefixSuffix,
    this.key,
    this.value,
    this.classNamePrefixSuffixBuilder,
  }) : type = ClassType.getType(value) {
    _childDef();
    _detectAllParentNode();
  }

  /// 檢測所有孩子的上級關西
  void _detectAllParentNode() {
    if (childrenDef is List<ValueDef>) {
      (childrenDef as List<ValueDef>).forEach((element) {
        element.parent = this;
        element._detectAllParentNode();
      });
    } else if (childrenDef is Map<String, ValueDef>) {
      (childrenDef as Map<String, ValueDef>).forEach((key, value) {
        value.parent = this;
        value._detectAllParentNode();
      });
    }
  }

  /// 定義所有孩子
  void _childDef() {
    switch (type) {
      case ClassType.tListDynamic:
        childrenDef = (value as List)
            .map((e) => ValueDef(
                  value: e,
                  classNamePrefixSuffixBuilder: classNamePrefixSuffixBuilder,
                ))
            .toList();
        break;
      case ClassType.tObject:
        childrenDef =
            (value as Map<String, dynamic>).map((key, value) => MapEntry(
                key,
                ValueDef(
                  key: key,
                  value: value,
                  classNamePrefixSuffixBuilder: classNamePrefixSuffixBuilder,
                )));
        break;
      default:
        childrenDef = value;
        break;
    }
  }

  /// 在總結資料時, 與其他資料的合併
  /// 父輩元素有列表時開始進來
  ValueDef _summarizeData(ValueDef other) {
    if (type == ClassType.tListDynamic &&
        other.type == ClassType.tListDynamic) {
      // 合併的同樣是列表
      ValueDef elementDef;

      var keyList = List<ValueDef>.from(childrenDef);
      keyList.addAll(other.childrenDef);

      for (var i = 0; i < keyList.length; i++) {
        var element = keyList[i];

        elementDef ??= element;
        elementDef = elementDef._summarizeData(element);

        // print('類型轉換: ${elementDef.type}');
        listType = elementDef.type;
        if (listType == ClassType.tDynamic) {
          // 代表無法合併
          break;
        }
      }

      return copyWith(
        type: type,
        listType: listType,
        childrenDef: listType == ClassType.tDynamic ? [] : [elementDef],
      );
    } else if (type == ClassType.tObject && other.type == ClassType.tObject) {
      var keyMap = Map<String, ValueDef>.from(childrenDef);

      // 合併的同樣是映射
      (other.childrenDef as Map<String, ValueDef>).forEach((key, value) {
        if (keyMap.containsKey(key)) {
          // print('重複 key = $key, value = $value');
          keyMap[key] = keyMap[key]._summarizeData(value);
        } else {
          keyMap[key] = value;
        }
      });
      return copyWith(type: type, childrenDef: keyMap);
    } else {
      // 其餘類型直接返回錯誤
      var resultType = ClassType.mergeType(type, other.type);
      var mergeListType = ClassType.mergeType(listType, other.listType);
      var children = type.isNull ? other.childrenDef : childrenDef;
      // print('哈哈: $type + ${other.type} => ${result}');
      return copyWith(
        type: resultType,
        listType: mergeListType,
        childrenDef: children,
      );
    }
  }

  /// 總結資料入口
  ValueDef _summarizeEntry() {
    switch (type) {
      case ClassType.tListDynamic:
        if ((childrenDef as List).isEmpty) {
          listType = ClassType.tDynamic;

          return copyWith(
            type: type,
            listType: listType,
          );
        } else {
          ValueDef elementDef;
          // 是個列表

          var keyList = List<ValueDef>.from(childrenDef);
          for (var i = 0; i < keyList.length; i++) {
            var element = keyList[i];

            elementDef ??= element;
            elementDef = elementDef._summarizeData(element);

            // print('類型轉換: ${elementDef.type}');
            listType = elementDef.type;
            if (listType == ClassType.tDynamic) {
              // 代表無法合併
              break;
            }
          }

          return copyWith(
            type: type,
            listType: listType,
            childrenDef: listType == ClassType.tDynamic ? [] : [elementDef],
          );
        }
        break;
      case ClassType.tObject:
        // 是個映射
        var keyMap = Map<String, ValueDef>.from(childrenDef);
        (childrenDef as Map<String, ValueDef>).forEach((key, value) {
          // print('key = $key, value = $value');
          keyMap[key] = value._summarizeEntry();
        });
        return copyWith(type: type, childrenDef: keyMap);
      default:
        // 一般基本資料
        return this;
    }
  }

  /// 遍歷所有資料, 將null型態轉為dynamic
  ValueDef _convertNullToDynamic(ValueDef def) {
    switch (def.type) {
      case ClassType.tListDynamic:
        var listType = def.listType;
        if (listType.isNull || listType.isDynamic) {
          listType = ClassType.tDynamic;
          return def.copyWith(
            type: def.type,
            listType: listType,
          );
        } else {
          var keyList = List<ValueDef>.from(def.childrenDef);
          for (var i = 0; i < keyList.length; i++) {
            keyList[i] = _convertNullToDynamic(keyList[i]);
          }
          return def.copyWith(
            type: def.type,
            listType: listType,
            childrenDef: keyList,
          );
        }
        break;
      case ClassType.tObject:
        var keyMap = Map<String, ValueDef>.from(def.childrenDef);
        (def.childrenDef as Map<String, ValueDef>).forEach((key, value) {
          keyMap[key] = _convertNullToDynamic(value);
        });
        return def.copyWith(type: def.type, childrenDef: keyMap);
      default:
        if (def.type.isNull) {
          // print('空轉動態: ${key}');
          def.type = ClassType.tDynamic;
        }
        return def;
    }
  }

  /// 總結資料
  /// 列表的值需要保持相同(或可相容的值)
  /// 映射下相同路徑的值也需要保持相同(或可相容的值)
  ValueDef summarize() {
    // 總結資料
    var def = _summarizeEntry();

    // 遍歷所有資料, 將null型態轉為dynamic
    // return def;
    return _convertNullToDynamic(def);
  }

  @override
  String toString() => structString;

  /// 結構字串
  String get structString {
    // print('打印深度: $depth');
    var keyShow = '';
    if (key != null) {
      keyShow = '($key)';
    }
    if (childrenDef is Map) {
      return '${_depthIntentSpace}Map$keyShow {\n${(childrenDef as Map).values.join(',\n')}\n${_depthIntentSpace}}';
    } else if (childrenDef is List) {
      if ((childrenDef as List).isEmpty) {
        return '${_depthIntentSpace}List<${listType}>$keyShow []';
      } else {
        return '${_depthIntentSpace}List<${listType}>$keyShow [\n${(childrenDef as List).join(',\n')}\n${_depthIntentSpace}]';
      }
    } else {
      return '${_depthIntentSpace}$type$keyShow $childrenDef';
    }
  }

  /// 所有自訂物件字串
  String get customObjectString {
    var text = '';
    customObjects.forEach((element) {
      if (text.isNotEmpty) {
        text += '\n\n';
      }
      var tempParent = parent;
      element.parent = null;
      text += element.structString;
      element.parent = tempParent;
    });
    return text;
  }

  /// 完整的類名
  /// 根節點不需要加前後綴
  String get classNameFull {
    if (isRoot && !rootClassNameWithPrefixSuffix) {
      return classNameNoPrefixSuffix;
    } else {
      return '$classNamePrefix$classNameNoPrefixSuffix$classNameSuffix';
    }
  }

  /// 當此節點為一個 class 時
  /// 轉換而成的類名(不包含前綴以及後綴)
  String get classNameNoPrefixSuffix {
    if (isRoot) {
      // 根節點
      return rootClassName ?? 'Root';
    } else {
      // 取得父親的類名, 由父親類名往下推
      var parentName = parent?.classNameNoPrefixSuffix;

      // 檢查是否有父輩關西的key
      // 若沒有代表根節點為列表, 且為第一個映射物件
      if (parentKey == null && type.isObject) {
        // 當根節點為列表, 且為第一個映射物件時, 在類名後面加上Value
        // print('往父親找: $parentName');
        return '${parentName}Value'.upperCamel();
        // return '${parentName}'.upperCamel();
      } else {
        // 檢查是否有key值
        // 若無key值有兩種可能
        // 根節點或者列表底下, 根節點的可能已在上一個 isRoot 排除
        // 因此key若為null代表列表底下
        if (key == null) {
          return '${parentName}'.upperCamel();
        } else {
          return '${parentName}${key.upperCamel()}'.upperCamel();
        }
      }
    }
  }
}

extension StringExtension on String {
  String upperCamel() {
    String capitalize(Match match) {
      var text = match[0];
      if (text.length >= 2) {
        return '${text[0].toUpperCase()}${text.substring(1)}';
      } else if (text.length == 1) {
        return '${text[0].toUpperCase()}';
      } else {
        return text;
      }
    }

    String skip(String s) => '';

    return splitMapJoin(
      RegExp(r'[a-zA-Z0-9]+'),
      onMatch: capitalize,
      onNonMatch: skip,
    );
  }

  String lowerCamel() {
    var upper = upperCamel();
    return '${upper[0].toLowerCase()}${upper.substring(1)}';
  }
}
