import 'dart:io';

class LangConfig {
  static const KEYCODE_COLUMN_NAME = 'name';
  static const HEADER_ROW_INDEX = 0;
  static const TEXT_NAME_CLASS_FILE_NAME = 'text_names.dart';

  static const TEXT_NAME_CLASS = 'TextName';

  static String get xlsxDocPath => Directory.current.path + '/strings/';
  static String get generateDirectory => Directory.current.path + '/generated/';
}
