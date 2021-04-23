import 'json_def.dart';

import 'class_type.dart';

extension DartCodeGenerator on ValueDef {
  /// 輸出轉換成 class 的字串
  String get classCode {
    if (!(childrenDef is List) && !(childrenDef is Map)) {
      return '';
    }

    // 變數區域字串
    String fieldText() {
      String detectListInner(ValueDef def) {
        if (def.type.isList) {
          if (def.listType.isDynamic) {
            // 不需要往下
            return 'List<${def.listType.value}>';
          } else if (def.listType.isPrimitive) {
            // 不需要往下
            return 'List<${def.listType.value}>';
          } else if (def.listType.isList) {
            // 再往下找
            var childType =
                detectListInner((def.childrenDef as List<ValueDef>).first);
            return 'List<$childType>';
          } else {
            // 物件
            // print('物件 def = ${(def.childrenDef as List<ValueDef>).first}');
            return 'List<${detectListInner((def.childrenDef as List<ValueDef>).first)}>';
          }
        }
        // print('尋找 def = $_allCustomObject');
        var obj = findCustomObject(def);
        return obj.classNameFull;
      }

      var text = '';
      if (childrenDef is List<ValueDef>) {
        // print('目錄列表');
        var prefix = '${detectListInner(this)}';
        text += '${prefix} value;';
      } else if (childrenDef is Map<String, ValueDef>) {
        // print('目錄映射');
        var keyMap = childrenDef as Map<String, ValueDef>;
        keyMap.forEach((key, value) {
          if (value.type == ClassType.tListDynamic) {
            var prefix = '${detectListInner(value)}';
            text += '${prefix} ${key.lowerCamel()};';
          } else if (value.type == ClassType.tObject) {
            var findCustomDef = findCustomObject(value);
            text += '${findCustomDef.classNameFull} ${key.lowerCamel()};';
          } else {
            text += '${value.type} ${key.lowerCamel()};';
          }
        });
      }
      return text;
    }

    // 建構子區域
    String constructorText() {
      var body = '';

      if (childrenDef is List<ValueDef>) {
        body += 'this.value';
      } else if (childrenDef is Map<String, ValueDef>) {
        var keyMap = childrenDef as Map<String, ValueDef>;
        keyMap.forEach((key, value) {
          body += 'this.${key.lowerCamel()},';
        });
      }

      if (body.isNotEmpty) {
        body = '{$body}';
      }

      return '$classNameFull($body);';
    }

    // fromJson 區域
    String fromJsonText() {
      var body = '';
      var param = '';

      String listInnerContent(ListInner innerType) {
        if (innerType.type.isObject) {
          return '${innerType.className}.fromJson(e)';
        } else if (innerType.type.isPrimitive) {
          if (innerType.type == ClassType.tDouble) {
            return 'e.toDouble()';
          } else if (innerType.type == ClassType.tString) {
            return 'e.toString()';
          } else {
            return 'e as ${innerType.type.value}';
          }
        } else if (innerType.type.isDynamic) {
          return 'e';
        }
        return '未知';
      }

      // 循環組出整體轉換, [depth] 代表深度, 從0開始
      // 第0層固定為 => (json[\'${value.key}\'] as List)
      String detectListInner(
        ValueDef def,
        String innerContent, [
        int depth = 0,
      ]) {
        String nextInner() {
          return detectListInner(
            ((def.childrenDef as List<ValueDef>).first),
            innerContent,
            depth + 1,
          );
        }

        if (depth == 0) {
          if (def.listType.isDynamic) {
            return isListRoot && isRoot ? 'json' : 'json[\'${def.key}\'] as List';
          } else {
            return isListRoot && isRoot
                ? 'json${nextInner()}'
                : '(json[\'${def.key}\'] as List)${nextInner()}';
          }
        } else {
          if (def.type.isList) {
            if (def.listType.isDynamic) {
              return '.map((e) => (e as List).toList()).toList()';
            } else {
              return '.map((e) => (e as List)${nextInner()}).toList()';
            }
          } else {
            return '.map((e) => $innerContent).toList()';
          }
        }
      }

      if (childrenDef is List<ValueDef>) {
        param = 'List<dynamic> json';
        var innerType = listInnerType;

        body += 'value = ${detectListInner(
          this,
          listInnerContent(innerType),
        )};';
      } else if (childrenDef is Map<String, ValueDef>) {
        param = 'Map<String, dynamic> json';
        var keyMap = childrenDef as Map<String, ValueDef>;
        keyMap.forEach((key, value) {
          if (body.isNotEmpty) {
            body += '\n';
          }

          if (value.type == ClassType.tListDynamic) {
            var innerType = value.listInnerType;
            body +=
                'if (json[\'${value.key}\'] != null) {\n ${(value.key ?? value.parentKey).lowerCamel()} = ${detectListInner(
              value,
              listInnerContent(innerType),
            )}; \n}';
          } else if (value.type == ClassType.tObject) {
            var findCustomDef = findCustomObject(value);
            body +=
                '${key.lowerCamel()} = json[\'$key\'] != null ?  ${findCustomDef.classNameFull}.fromJson(json[\'${findCustomDef.key}\']) : null;';
          } else {
            body += '${key.lowerCamel()} = json[\'$key\']';

            if (value.type == ClassType.tDouble) {
              body += '?.toDouble();';
            } else if (value.type == ClassType.tString) {
              body += '?.toString();';
            } else {
              body += ';';
            }
          }
        });
      }

      return '$classNameFull.fromJson($param) {\n$body\n}';
    }

    String toJsonText() {
      var body = '';
      var returnText = '';

      // 循環組出整體轉換, [depth] 代表深度, 從0開始
      // 第0層固定為 => (json[\'${value.key}\'] as List)
      String detectListInner(ValueDef def, String innerContent,
          [int depth = 0]) {
        String nextInner() {
          return detectListInner(
            (def.childrenDef as List<ValueDef>).first,
            innerContent,
            depth + 1,
          );
        }

        if (depth == 0) {
          return '${isListRoot ? 'value' : (def.key ?? def.parentKey).lowerCamel()}${nextInner()}';
        } else {
          if (def.type.isList) {
            return '.map((e) => e${nextInner()}).toList()';
          } else {
            return '.map((e) => $innerContent).toList()';
          }
        }
      }

      if (childrenDef is List<ValueDef>) {
        returnText = 'List<dynamic>';

        var innerType = listInnerType;

        if (innerType.type.isObject) {
          var innerContent = 'e.toJson()';
          body += 'return ${detectListInner(this, innerContent)};';
        } else {
          body += 'return value;';
        }

        // if (listType.isDynamic) {
        //   body += 'return value;';
        // } else if (listType.isList)
        //   // return value.map((e) => e.toJson()).toList();
        //   body += 'return value.map((e) => e.toJson()).toList();';
      } else if (childrenDef is Map<String, ValueDef>) {
        returnText = 'Map<String, dynamic>';
        var keyMap = childrenDef as Map<String, ValueDef>;
        keyMap.forEach((key, value) {
          if (body.isNotEmpty) {
            body += '\n';
          }

          if (value.type == ClassType.tListDynamic) {
            var innerType = value.listInnerType;

            if (innerType.type.isObject) {
              var innerContent = 'e.toJson()';
              body += '\'${key}\' : ${detectListInner(value, innerContent)},';
            } else {
              body += '\'${key}\' : ${key.lowerCamel()},';
            }
          } else if (value.type == ClassType.tObject) {
            body += '\'${key}\' : ${key.lowerCamel()}?.toJson(),';
          } else {
            body += '\'${key}\' : ${key.lowerCamel()},';
          }
        });
        body = 'return {\n$body\n};';
      }

      return '$returnText toJson() {\n$body\n}';
    }

    // 先取得 class 名稱
    // 名稱的命名為整體路徑
    return '''
class $classNameFull {
${fieldText()}

${constructorText()}

${fromJsonText()}

${toJsonText()}
}
    ''';
  }
}
