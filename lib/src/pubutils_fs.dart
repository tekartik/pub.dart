library tekartik_pub.src.pubutils_fs;

import 'import.dart';
import 'package:yaml/yaml.dart';

const String pubspecYamlBasename = 'pubspec.yaml';

Future<Map> getDotPackagesYaml(Directory packageDir) async {
  String yamlPath = _pubspecDotPackagesPath(packageDir.path);
  String content = await childFile(packageDir, yamlPath).readAsString();

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

//String _pubspecYamlPath(String packageRoot) =>
//    join(packageRoot, 'pubspec.yaml');
String _pubspecDotPackagesPath(String packageRoot) =>
    join(packageRoot, '.packages');

Future<Map> getPackageYaml(Directory packageDirt) =>
    _getYaml(packageDirt, "pubspec.yaml");

Future<Map> _getYaml(Directory packageDir, String name) async {
  String yamlPath = join(packageDir.path, name);
  String content = await childFile(packageDir, yamlPath).readAsString();
  return loadYaml(content);
}

Uri dotPackagesGetLibUri(Map yaml, String packageName) {
  return Uri.parse(yaml[packageName]);
}

// in dev tree
String pubspecYamlGetPackageName(Map yaml) => yaml['name'];

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

Version pubspecLockGetVersion(Map yaml, String packageName) =>
    new Version.parse(yaml['packages'][packageName]['version']);

bool pubspecYamlHasAnyDependencies(Map yaml, List<String> dependencies) {
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
