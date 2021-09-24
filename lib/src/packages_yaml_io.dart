import 'dart:convert';
import 'dart:io';

import 'package:path/path.dart';

/// Read info from `.packages` file, key being the package, value being the path
/// as a file Uri
Future<Map<String, String>> getDotPackagesYamlMap(String packageRoot) async {
  final yamlPath = join(packageRoot, '.packages');
  final content = await File(yamlPath).readAsString();

  final map = <String, String>{};
  final lines = LineSplitter.split(content);
  for (var line in lines) {
    line = line.trim();
    if (!line.startsWith('#')) {
      final separator = line.indexOf(':');
      if (separator != -1) {
        map[line.substring(0, separator)] = line.substring(separator + 1);
      }
    }
  }
  return map;
}

/// Get the lib path for a given package
String dotPackagesYamlMapGetPackageLibPath(
    Map<String, String> dotPackagesYamlMap, String package) {
  return Uri.parse(dotPackagesYamlMap[package]!).toFilePath();
}

/// In a given project, for a given dependency package, find a given file.
Future<String> pubGetPackageFilePath(
    String packageRoot, String package, String file) async {
  return join(
      dotPackagesYamlMapGetPackageLibPath(
          await getDotPackagesYamlMap(packageRoot), package),
      file);
}
