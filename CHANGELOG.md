## 0.9.3
- 修正當資料值null時, 型態應該為dynamic而非Null
- 修正key值有出現蛇底式風格文字時, 轉大駝峰小駝峰出錯
- 修正陣列在非根節點且為dynamic的型態時, formJson方法的模板字串錯誤
- 修正當陣列的第一個元素為null時, 後續的元素合併後仍然是null的問題

## 0.9.2
- 修正key值有出現蛇底式風格文字時, 轉大駝峰小駝峰出錯

## 0.9.1

- DartCodeGenerator 新增參數: rootClassNameWithPrefixSuffix => 控制根類別是否套用類名前後綴
- 修正當陣列底下皆為Object時解析出錯

## 0.9.0+1

- 添加命令行調用 `json_dart_generator`

## 0.9.0

- Initial version, created by Stagehand
