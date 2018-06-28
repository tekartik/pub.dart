import 'package:path/path.dart';

// relative to project folder
String outSubPath = join('.dart_tool', 'tekartik_pub', 'test');

// relative to current folder
String testOutTopPath = outSubPath;

final String packageRoot = normalize(absolute('.'));
