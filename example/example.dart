import 'package:json_dart_generator/json_dart_generator.dart';

void main(List<String> args) {
  var jsonText = '''
[
  [
    {
      "aa": "cc",
      "bb": true,
      "cc": {
        "ilis": [
          10,
          20,
          30.0
        ]
      }
    }
  ]
]
  ''';

  var generator = DartCodeGenerator(
    rootClassName: 'Root', // 根類名
    rootClassNameWithPrefixSuffix: true, // 根類名是否套用前後綴
    classPrefix: 'Hi', // 類名前綴
    classSuffix: 'Go', // 類名後綴
  );

  // 呼叫 generate 帶入 json 字串生成 dart code
  var code = generator.generate(jsonText);
  print(code);
}