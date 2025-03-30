library;

import 'dart:io';

import 'package:path/path.dart';
import 'package:tekartik_common_utils/common_utils_import.dart';
import 'package:tekartik_pub/io.dart';
import 'package:yaml/yaml.dart';

export 'package:dev_build/package.dart' show recursivePubPath;

//String _pubspecYamlPath(String packageRoot) =>
//    join(packageRoot, 'pubspec.yaml');
String _pubspecDotPackagesPath(String packageRoot) =>
    join(packageRoot, '.packages');

Map? getPackageYamlSync(String packageRoot) {
  final pubspecYaml = 'pubspec.yaml';
  final pubspecYamlPath = join(packageRoot, pubspecYaml);
  final content = File(pubspecYamlPath).readAsStringSync();
  return loadYaml(content) as Map?;
}

Future<Map?> getPackageYaml(String packageRoot) =>
    _getYaml(packageRoot, 'pubspec.yaml');

Future<Map?> _getYaml(String packageRoot, String name) async {
  final yamlPath = join(packageRoot, name);
  final content = await File(yamlPath).readAsString();
  return loadYaml(content) as Map?;
}

@Deprecated('Use dev_build')
Future<Map> getDotPackagesYaml(String packageRoot) =>
    getDotPackagesMap(packageRoot);

/// Read info from `.packages` file, key being the package, value being the path
Future<Map<String, String>> getDotPackagesMap(String packageRoot) async {
  final yamlPath = _pubspecDotPackagesPath(packageRoot);
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

Uri dotPackagesGetLibUri(Map yaml, String? packageName) {
  return Uri.parse(yaml[packageName] as String);
}

Iterable<String>? pubspecYamlGetDependenciesPackageName(Map yaml) {
  return ((yaml['dependencies'] as Map?)?.keys)?.cast<String>();
}

Iterable<String>? pubspecYamlGetTestDependenciesPackageName(Map yaml) {
  if (yaml.containsKey('test_dependencies')) {
    var list = (yaml['test_dependencies'] as Iterable?)?.cast<String>();
    list ??= [];

    return list;
  }
  return null;
}

bool yamlHasAnyDependencies(Map yaml, List<String> dependencies) =>
    pubspecYamlHasAnyDependencies(yaml, dependencies);

bool _isToBeIgnored(String baseName) {
  if (baseName == '.') {
    return false;
  }

  if (baseName == '..') {
    return true;
  }
  if (baseName == 'node_modules') {
    return true;
  }
  // Ignore blacklisted too
  if (_blackListedTargets.contains(baseName)) {
    return true;
  }

  return baseName.startsWith('.');
}

Future<List<String>> recursiveDartEntities(String dir) async {
  var entities = await _recursiveDartEntities(dir, null);

  return entities;
}

final List<String> _blackListedTargets = [
  '.',
  '..',
  'build',
  // 2018-03-18 removed
  // 'packages',
  'deploy',
  'node_modules',
];

/// find the path at the top level that contains dart file
/// and does not contain sub project
Future<List<String>> findTargetDartDirectories(String dir) async {
  var targets = <String>[];
  for (var entity in await Directory(dir).list(followLinks: false).toList()) {
    var entityBasename = basename(entity.path);
    var subDir = join(dir, entityBasename);
    if (isDirectoryNotLinkSynk(subDir)) {
      bool isToBeIgnored(String baseName) {
        if (_blackListedTargets.contains(baseName)) {
          return true;
        }

        if (baseName.startsWith('.')) {
          return true;
        }

        return false;
      }

      if (!isToBeIgnored(entityBasename) && !(await isPubPackageRoot(subDir))) {
        var paths = (await recursiveDartEntities(
          subDir,
        )).map((path) => join(subDir, path)).toList(growable: false);

        if (containsPubPackage(paths)) {
          continue;
        }
        if (!containsDartFiles(paths)) {
          continue;
        }
        targets.add(entityBasename);
      }

      //devPrint(entities);
    }
  }
  // devPrint('targets: $targets');
  return targets;
}

Future<List<String>> _recursiveDartEntities(String dir, String? base) async {
  var entities = <String>[]; // dir];
  // list of basename
  var list = (await Directory(dir).list(followLinks: false).toList())
      .map((fileSystemEntity) => basename(fileSystemEntity.path))
      .toList(growable: false);
  for (var item in list) {
    var fullpath = join(dir, item);
    String subBase;
    if (base == null) {
      subBase = item;
    } else {
      subBase = join(base, item);
    }

    if (isDirectoryNotLinkSynk(fullpath)) {
      if (!_isToBeIgnored(item)) {
        entities.add(subBase);
        entities.addAll(await _recursiveDartEntities(fullpath, subBase));
      }
    } else {
      entities.add(subBase);
    }
  }
  return entities;
}

bool isDirectoryNotLinkSynk(String path) =>
    FileSystemEntity.isDirectorySync(path) &&
    !FileSystemEntity.isLinkSync(path);

bool containsPubPackage(Iterable<String> paths) {
  for (var path in paths) {
    if (isDirectoryNotLinkSynk(path)) {
      if (isPubPackageRootSync(path)) {
        return true;
      }
    }
  }
  return false;
}

bool containsDartFiles(Iterable<String> paths) {
  for (var path in paths) {
    if (extension(path) == '.dart' && FileSystemEntity.isFileSync(path)) {
      return true;
    }
  }
  return false;
}
