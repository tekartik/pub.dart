import 'dart:convert';
import 'dart:io';

import 'package:dev_build/build_support.dart';
import 'package:path/path.dart';

/// Read info from `.packages` file, key being the package, value being the path
/// as a file Uri
@Deprecated('Returns a map package to uri - use packageConfig')
Future<Map<String, String>> getDotPackagesYamlMap(String packageRoot) async {
  var resultMap = <String, String>{};
  var configMap = await pathGetPackageConfigMap(packageRoot);

  var packageMap = configMap['packages'] as List;
  for (var packageSrc in packageMap) {
    var map = packageSrc as Map;
    var package = map['name'].toString();
    var rootUri = map['rootUri'].toString();
    resultMap[package] = rootUri;
  }
  return resultMap;
}

// ignore: unused_element
Future<Map<String, String>> _getDotPackagesYamlMapCompat(
    String packageRoot) async {
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
@Deprecated('No longer supported')
String dotPackagesYamlMapGetPackageLibPath(
    Map<String, String> dotPackagesYamlMap, String package) {
  return Uri.parse(dotPackagesYamlMap[package]!).toFilePath();
}

/// In a given project, for a given dependency package, find a given file in the lib folder
Future<String> pubGetPackageFilePath(
    String packageRoot, String package, String file) async {
  var configMap = await pathGetPackageConfigMap(packageRoot);
  var packagePath =
      pathPackageConfigMapGetPackagePath(packageRoot, configMap, package)!;
  return join(packagePath, 'lib', file);
}
