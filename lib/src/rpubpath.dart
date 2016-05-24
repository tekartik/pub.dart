library tekartik_pub.src.rpubpath;

import 'dart:async';
import 'dart:io';
import 'package:path/path.dart';
import 'package:tekartik_pub/pub.dart';
import 'package:yaml/yaml.dart';
import 'dart:convert';

//String _pubspecYamlPath(String packageRoot) =>
//    join(packageRoot, 'pubspec.yaml');
String _pubspecDotPackagesPath(String packageRoot) =>
    join(packageRoot, '.packages');

Map getPackageYamlSync(String packageRoot) {
  String pubspecYaml = "pubspec.yaml";
  String pubspecYamlPath = join(packageRoot, pubspecYaml);
  String content = new File(pubspecYamlPath).readAsStringSync();
  return loadYaml(content);
}

Future<Map> getPackageYaml(String packageRoot) =>
    _getYaml(packageRoot, "pubspec.yaml");

Future<Map> _getYaml(String packageRoot, String name) async {
  String yamlPath = join(packageRoot, name);
  String content = await new File(yamlPath).readAsString();
  return loadYaml(content);
}

Future<Map> getDotPackagesYaml(String packageRoot) async {
  String yamlPath = _pubspecDotPackagesPath(packageRoot);
  String content = await new File(yamlPath).readAsString();

  Map map = {};
  Iterable<String> lines = LineSplitter.split(content);
  for (String line in lines) {
    line = line.trim();
    if (!line.startsWith('#')) {
      int separator = line.indexOf(":");
      if (separator != -1) {
        map[line.substring(0, separator)] = line.substring(separator + 1);
      }
    }
  }
  return map;
}

Uri dotPackagesGetLibUri(Map yaml, String packageName) {
  return Uri.parse(yaml[packageName]);
}

Iterable<String> pubspecYamlGetDependenciesPackageName(Map yaml) {
  return (yaml['dependencies'] as Map).keys as Iterable<String>;
}

Iterable<String> pubspecYamlGetTestDependenciesPackageName(Map yaml) {
  if (yaml.containsKey('test_dependencies')) {
    Iterable<String> list = yaml['test_dependencies'] as Iterable<String>;
    if (list == null) {
      list = [];
    }
    return list;
  }
  return null;
}

bool yamlHasAnyDependencies(Map yaml, List<String> dependencies) {
  bool _hasDependencies(String kind, String dependency) {
    Map dependencies = yaml[kind];
    if (dependencies != null) {
      if (dependencies[dependency] != null) {
        return true;
      }
    }
    return false;
  }

  for (String dependency in dependencies) {
    if (_hasDependencies('dependencies', dependency) ||
        _hasDependencies('dev_dependencies', dependency) ||
        _hasDependencies('dependency_overrides', dependency)) {
      return true;
    }
  }

  return false;
}

bool _isToBeIgnored(String baseName) {
  if (baseName == '.' || baseName == '..') {
    return false;
  }

  return baseName.startsWith('.');
}

Stream<String> recursivePubPath(List<String> dirs,
    {List<String> dependencies}) {
  StreamController<String> ctlr = new StreamController();

  Future _handleDir(String dir) async {
    // Ignore folder starting with .
    // don't event go below
    if (!_isToBeIgnored(basename(dir))) {
      if (await isPubPackageRoot(dir)) {
        if (dependencies is List && !dependencies.isEmpty) {
          Map yaml = getPackageYamlSync(dir);
          if (yamlHasAnyDependencies(yaml, dependencies)) {
            ctlr.add(dir);
          }
        } else {
          // add package path
          ctlr.add(dir);
        }
      } else {
        List<Future> sub = [];
        return new Directory(dir)
            .list()
            .listen((FileSystemEntity fse) {
              if (FileSystemEntity.isDirectorySync(fse.path)) {
                sub.add(_handleDir(fse.path));
              }
            })
            .asFuture()
            .then((_) {
              return Future.wait(sub);
            });
      }
    }
  }

  List<Future> futures = [];
  for (String dir in dirs) {
    if (FileSystemEntity.isDirectorySync(dir)) {
      Future _handle = _handleDir(dir);
      if (_handle is Future) {
        futures.add(_handle);
      }
    } else {
      throw '${dir} not a directory';
    }
  }

  Future.wait(futures).then((_) {
    ctlr.close();
  });

  return ctlr.stream;
}
