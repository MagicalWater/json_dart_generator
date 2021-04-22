import 'dart:io';

import 'package:args/args.dart';
import 'package:json_dart_generator/json_dart_generator.dart';

void main(List<String> args) {
  var parser = initArgParser();
  ArgResults result;
  try {
    result = parser.parse(args);
  } on Exception catch (e) {
    _handleArgError(parser, e.toString());
  }

  bool help = result['help'];
  if (help || result.arguments.isEmpty) {
    _handleArgError(parser);
  }

  String jsonPath = result['file'];
  String output = result['output'];
  String name = result['name'];
  String namePrefix = result['name_prefix'];
  String nameSuffix = result['name_suffix'];

  if (jsonPath == null || jsonPath.isEmpty) {
    stderr.write('-f: json檔案 為必填\n');
    return;
  }

  var jsonFile = File(jsonPath);

  if (!jsonFile.existsSync()) {
    stderr.write('在此路徑下無法找到json檔案: $jsonPath\n');
    return;
  }

  if (output == null || output.isEmpty) {
    stderr.write('-o: 輸出路徑 為必填\n');
    return;
  }

  var content = jsonFile.readAsStringSync();

  var generator = DartCodeGenerator(
    rootClassName: name,
    rootClassNameWithPrefixSuffix: true,
    classPrefix: namePrefix,
    classSuffix: nameSuffix,
  );

  var code = generator.generate(content);

  File(output).writeAsStringSync(code);
}

void _handleArgError(ArgParser parser, [String msg]) {
  if (msg != null) {
    stderr.write(msg);
  }
  stdout.write('參數:\n\t${parser.usage.replaceAll('\n', '\n\t')}\n');
  exit(1);
}

ArgParser initArgParser() {
  return ArgParser()
    ..addOption('file', abbr: 'f', help: 'json來源檔案')
    ..addOption('output', abbr: 'o', help: '輸出dart class的完整路徑(含檔案名)')
    ..addOption('name', abbr: 'n', help: '根類名稱')
    ..addOption('name_prefix', abbr: 'p', help: '子類名稱前綴(不包含根類別)')
    ..addOption('name_suffix', abbr: 's', help: '子類名稱後綴(不包含根類別)')
    ..addFlag('help', abbr: 'h', help: '說明');
}
