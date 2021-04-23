Language: [English](README.md) | [中文](README_ZH.md)

# json_dart_generator
[![Pub](https://img.shields.io/pub/v/json_dart_generator.svg?style=flat-square)](https://pub.dartlang.org/packages/json_dart_generator)

Convert json data to dart class

Support multiple formats(array root / multiple array)
When the elements in the array are different, it will be converted to a mutually inclusive type as much as possible
If they cannot contain each other, they will be displayed in a dynamic way, and the underlying elements will no longer be analyzed

example: the type of element will be List&lt;String&gt;
```json
{
  "element": [
    10,
    10.0,
    true,
    "20"
  ]
}
```

example: the type of element will be List&lt;dynamic&gt;
```json
{
  "element": [
    10,
    {
      "byebye": 10
    }
  ]
}
```


## Usage

#### 1. Use this package as a library
add json_dart_generator to dependencies

```yaml
dev_dependencies:
  json_dart_generator: any
```

```dart
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
```

#### 2. Use this package as an executable
1. Activating a package   

        dart pub global activate json_dart_generator
       
2. Running    

        json_dart_generator -f {json source path} -o {output path}
        
3. Command Line Arguments
    ```shell script
    -f, --file           json source file
    -o, --output         output dart code path(include filename)
    -n, --name           root class name(default: Root)
    -p, --name_prefix    class name prefix
    -s, --name_suffix    class name suffix
    -h, --[no-]help      description
    ```

(If thrown error `command not found` on step2, check [this](https://dart.cn/tools/pub/cmd/pub-global) add path to env) 
