import 'dart:convert';
import 'dart:io';
import 'package:path/path.dart';
import 'package:recase/recase.dart';
import 'package:spreadsheet_decoder/spreadsheet_decoder.dart';

import 'lang_config.dart';

String get _xlsxDocPath => LangConfig.xlsxDocPath;
String get _generateDirectory => LangConfig.generateDirectory;

const String separator_line =
    '-------------------------------------------------------------------------------';

const String extension_valid = 'xlsx';

String _createDirectoryRecursively(String path) {
  Directory(path).createSync(recursive: true);
  return path;
}

bool _isNumeric(String str) {
  if (str == null) {
    return false;
  }
  return double.tryParse(str) != null;
}

String _makeChoices(String header, List<String> choices) {
  __printSeparatorHeader(header);
  for (var i = 0; i < choices.length; i++) {
    stdout.writeln('[ $i ]\t' + choices[i]);
  }
  var input = '';
  var idx;

  var _valid = false;
  stdout.writeln();
  stderr.writeln('INPUT YOUR CHOICE: ');
  do {
    input = stdin.readLineSync();

    if (_isNumeric(input)) {
      idx = int.parse(input);

      _valid = (idx < choices.length);
    }
    if (!_valid) print('-> Invalid');
  } while (!_valid);

  return choices[idx];
}

void __printSeparatorHeader(String header) {
  header = ' [ $header ] ';
  final ln = header.length;

  var startIndex = ((separator_line.length - ln) / 2).round();
  final str = separator_line.replaceRange(startIndex, startIndex + ln, header);

  stdout.writeln('\n$str\n');
}

String _promptAccessorSource() {
  var assetsDir = Directory(LangConfig.xlsxDocPath);

  List contents = assetsDir.listSync();

  var names = <String>[];
  contents.forEach((element) {
    if (element is File) {
      var name = basename(element.path);
      if (extension_valid == name.split('.').last) {
        names.add(name);
      }
    }
  });

  stdout.writeln();

  stdout.writeln();
  return _makeChoices('YOUR CHOICE:', names);
}

void main(List<String> arguments) async {
  var fileNamed = _promptAccessorSource();

  __printSeparatorHeader(fileNamed);
  stdout.writeln();
  __printSeparatorHeader('GAME BEGIN');
  stdout.writeln();

  _createDirectoryRecursively(_generateDirectory);

  var bytes = File(_xlsxDocPath + fileNamed).readAsBytesSync();
  var decoder = SpreadsheetDecoder.decodeBytes(bytes, update: true);

  final sheets = decoder.tables.keys.toList();

  var tableSheetName = _makeChoices('SELECT TABLE SHEET', sheets);

  for (var table in decoder.tables.keys) {
    var languages = <String, Map<String, dynamic>>{};
    if (tableSheetName == table) {
      var languageCodes = <int, String>{};
      final headers = decoder.tables[table].rows[LangConfig.HEADER_ROW_INDEX];
      final indexColumnOfKey = headers.indexOf(LangConfig.KEYCODE_COLUMN_NAME);

      for (var i = 0; i < headers.length; i++) {
        if (i != indexColumnOfKey && headers[i] != null) {
          languageCodes[i] = headers[i];
        }
      }

      var allValues = languageCodes.values;
      __printSeparatorHeader('LANGUAGES: [ $allValues ]');

      var tables = decoder.tables[table];

      languageCodes.forEach((cIndex, value) {
        var lang = <String, dynamic>{};
        for (var i = 0; i < tables.maxRows; i++) {
          if (LangConfig.HEADER_ROW_INDEX != i) {
            var value = tables.rows[i][cIndex];
            if (tables.rows[i][indexColumnOfKey] != null) {
              lang[tables.rows[i][indexColumnOfKey]] =
                  (value != null) ? value.toString() : '';
            } else {
              print('INVALID ROW: [ $i ]');
            }
          }
        }
        languages[value] = lang;
      });

      await genJsons(languages, dirName: tableSheetName);

      // generator language codes
      var keys = languages.values.first.keys.toList();

      await genClassKeys(keys, dirName: tableSheetName);
    }
  }
  __printSeparatorHeader('GAME END');
}

void genJsons(Map<String, Map<String, dynamic>> languages,
    {String dirName = ''}) async {
  sleep(Duration(seconds: 1));
  // generate json language files
  __printSeparatorHeader('GENERATE LANGUAGE JSON');
  final dirPath =
      _createDirectoryRecursively(_generateDirectory + dirName + '/');
  languages.forEach(
    (key, value) {
      var jsonData = json.encode(value);
      final file = File(dirPath + key + '.json');
      print('[$key]:' + file.path);

      file.writeAsStringSync(jsonData);
    },
  );
  __printSeparatorHeader('COMPLETED');
}

void genClassKeys(List<String> keys,
    {bool isUpperCase, String dirName = ''}) async {
  sleep(Duration(seconds: 1));
  __printSeparatorHeader('GENERATE CLASS KEY');
  final dirPath =
      _createDirectoryRecursively(_generateDirectory + dirName + '/');

  var file = File(dirPath + LangConfig.TEXT_NAME_CLASS_FILE_NAME);

  print(file.path);
  stdout.writeln();

  var exist = await file.exists();
  // delete if exist
  if (exist) {
    await file.delete(recursive: true);
  }

  await file.create().then((value) {
    value.writeAsStringSync('class ' + LangConfig.TEXT_NAME_CLASS + ' {\n',
        mode: FileMode.append);
    final declare_accessor = '\tstatic const ';
    for (var i = 0; i < keys.length; i++) {
      var line = declare_accessor +
          ReCase(keys[i].toUpperCase()).camelCase +
          ' = ' +
          '\'' +
          keys[i] +
          '\';' +
          '\n';
      value.writeAsStringSync(line, mode: FileMode.append);
    }
    value.writeAsStringSync('}', mode: FileMode.append);
  });
  __printSeparatorHeader('COMPLETED');
}
