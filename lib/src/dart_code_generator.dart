import 'dart:convert';
import 'dart:io';

import 'package:dart_style/dart_style.dart';

import 'json_def.dart';

/// dart類別產生器
/// 將json轉為dart code
class DartCodeGenerator {
  /// 根類名
  final String? rootClassName;

  /// 根類名是否套用前後綴
  final bool rootClassNameWithPrefixSuffix;

  /// 類名的前綴
  final String? classPrefix;

  /// 類名的後綴
  final String? classSuffix;

  DartCodeGenerator({
    this.rootClassName,
    this.rootClassNameWithPrefixSuffix = true,
    this.classPrefix,
    this.classSuffix,
  });

  String generate(String rawJson) {
    dynamic jsonData;
    try {
      jsonData = json.decode(rawJson);
    } catch (e) {
      stderr.write('json資料格式化錯誤\n$e\n');
      return '';
    }

    var def = JsonDef(
      rootClassName: rootClassName,
      jsonData: jsonData,
      rootClassNameWithPrefixSuffix: rootClassNameWithPrefixSuffix,
      classNamePrefixSuffixBuilder: (String name, bool isPrefix) {
        if (isPrefix) {
          return classPrefix;
        } else {
          return classSuffix;
        }
      },
    );

    final formatter = DartFormatter();

    // print('=== 打印所有物件 ===');
    // def.allCustomObject.forEach((element) {
    //   final formatter = DartFormatter();
    //   // print('${formatter.format(element.classCode)}');
    //   print('${element.classCode}');
    //   print('\n\n');
    // });
    // print('=== 打印所有物件 ===');

    // print('=== 打印完整 ===');
    // print('${formatter.format(def.classCode)}');
    // print('${def.classCode}');
    // print('=== 打印完整 ===');

    // print('\n\n\n');

    // print('=== 打印結構 ===');
    // print(def.summarizeString);
    // print('=== 打印結構 ===');

    return formatter.format(def.classCode);
  }
}
