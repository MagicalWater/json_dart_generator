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
    rootClassName: 'Root', // root class name
    rootClassNameWithPrefixSuffix: true, // root class name include classPrefix / classSuffix
    classPrefix: 'Hi', // class name prefix
    classSuffix: 'Go', // class name suffix
  );

  // call generate to generate code
  var code = generator.generate(jsonText);
  print(code);
}