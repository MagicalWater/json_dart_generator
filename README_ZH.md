Language: [English](README.md) | [中文](README_ZH.md)

# json_dart_generator
[![Pub](https://img.shields.io/pub/v/json_dart_generator.svg?style=flat-square)](https://pub.dartlang.org/packages/json_dart_generator)

解析json生成dart code

支持多種格式(含根節點為陣列)  
當陣列內元素不同時會盡可能地轉為可互相包容的型態  
若無法互相包容則會以dynamic的方式展示, 且底下的元素不再做解析

如以下陣列element的型態將會是List<String>
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

如以下陣列element的型態將會是List<dynamic
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


## 使用方式
使用方式有以下兩種

#### 1. 透過程式碼
將 json_dart_generator 加入 dependencies

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
    rootClassName: 'Root', // 根類名
    rootClassNameWithPrefixSuffix: true, // 根類名是否套用前後綴
    classPrefix: 'Hi', // 類名前綴
    classSuffix: 'Go', // 類名後綴
  );

  // 呼叫 generate 帶入 json 字串生成 dart code
  var code = generator.generate(jsonText);
  print(code);
}
```

#### 2. 透過命令行
1. 透過命令激活  

        dart pub global activate json_dart_generator
       
2. 調用命令解析json並輸出dart class檔案    

        json_dart_generator -f {json檔案路徑} -o {輸出檔案路徑}
        
3. 命令參數
    ```shell script
    -f, --file           json來源檔案
    -o, --output         輸出dart class的完整路徑(含檔案名)
    -n, --name           根類名(默認Root)
    -p, --name_prefix    類名前綴
    -s, --name_suffix    類名後綴
    -h, --[no-]help      說明
    ```

(若於第二步驟出現 `command not found` 請參考 [此處](https://dart.cn/tools/pub/cmd/pub-global) 添加環境變數) 
