## 1.0.2+1
- Fixed when parsing json, the added element of the list is missing to consider whether it is null

## 1.0.1+1
- Fixed the error that occurs when the internal type of the list is primitive

## 1.0.0+4
- Support null-safety
- Fixed in some cases, it fails to determine whether the class structure is the same

## 0.9.5+4
- Update README.MD
- Update description
- Add example code

## 0.9.3
- Fix when value is null, the type should be dynamic
- Fix when json element is array and generic type is dynamic, fromJson method template Incorrect
- Fix when array first element is null, then array generic type will be null problem

## 0.9.2
- Fixed when key is snake case will no convert to camel

## 0.9.1

- DartCodeGenerator add parameter: 
    rootClassNameWithPrefixSuffix - is root class name apply the prefix/suffix class name
- Fix throw exception when array elements is object 

## 0.9.0+1

- add json_dart_generator `json_dart_generator`

## 0.9.0

- Initial version, created by Stagehand
