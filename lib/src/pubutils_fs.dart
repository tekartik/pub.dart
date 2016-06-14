library tekartik_pub.src.pubutils_fs;

import 'import.dart';
import 'package:yaml/yaml.dart';

const String pubspecYamlBasename = 'pubspec.yaml';
const String dotPackagesBasename = '.packages';

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
    join(packageRoot, dotPackagesBasename);

@deprecated
Future<Map> getPackageYaml(Directory packageDir) => getPubspecYaml(packageDir);

Future<Map> getPubspecYaml(Directory packageDir) =>
    _getYaml(packageDir, "pubspec.yaml");

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

Version pubspecYamlGetVersion(Map yaml) => new Version.parse(yaml['version']);

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

Iterable<String> pubspecYamlGetDependenciesPackageName(Map yaml) {
  return (yaml['dependencies'] as Map).keys as Iterable<String>;
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

/// result must be run with reporter:json
bool pubRunTestJsonIsSuccess(String stdout) {
  try {
    Map map = JSON.decode(LineSplitter.split(stdout).last);
    return map['success'];
  } catch (_) {
    return false;
  }
}

int pubRunTestJsonSuccessCount(String stdout) {
  //int _warn;
  //print('# ${processResultToDebugString(result)}');
  int count = 0;
  for (String line in LineSplitter.split(stdout)) {
    try {
      var map = JSON.decode(line);
      //print(map);
      if (map is Map) {
        // {testID: 0, result: success, hidden: true, type: testDone, time: 199}
        // {testID: 2, result: success, hidden: false, type: testDone, time: 251}
        //
        // {protocolVersion: 0.1.0, runnerVersion: 0.12.6+2, type: start, time: 0}
        // {test: {id: 0, name: loading test/data/success_test_.dart, groupIDs: [], metadata: {skip: false, skipReason: null}}, type: testStart, time: 0}
        // {testID: 0, result: success, hidden: true, type: testDone, time: 224}
        // {group: {id: 1, parentID: null, name: null, metadata: {skip: false, skipReason: null}}, type: group, time: 227}
        // {test: {id: 2, name: success, groupIDs: [1], metadata: {skip: false, skipReason: null}}, type: testStart, time: 227}
        // {testID: 2, result: success, hidden: false, type: testDone, time: 251}
        if (map['testID'] != null) {
          //print('1 $map');
          if ((map['result'] == 'success') && (map['hidden'] != true)) {
            //print('2 $map');
            count++;
          }
        }
      }
    } catch (_) {}
  }

  return count;
}

/*
{"protocolVersion":"0.1.0","runnerVersion":"0.12.6+2","type":"start","time":0}
{"test":{"id":0,"name":"loading test/data/fail_test_.dart","groupIDs":[],"metadata":{"skip":false,"skipReason":null}},"type":"testStart","time":0}
{"testID":0,"result":"success","hidden":true,"type":"testDone","time":180}
{"group":{"id":1,"parentID":null,"name":null,"metadata":{"skip":false,"skipReason":null}},"type":"group","time":182}
{"test":{"id":2,"name":"failed","groupIDs":[1],"metadata":{"skip":false,"skipReason":null}},"type":"testStart","time":183}
{"testID":2,"error":"will fail","stackTrace":"package:test                   fail\ntest/data/fail_test_.dart 7:5  main.<fn>.<async>\n===== asynchronous gap ===========================\ndart:async                     _Completer.completeError\ntest/data/fail_test_.dart 8:4  main.<fn>.<async>\n===== asynchronous gap ===========================\ndart:async                     Future.Future.microtask\ntest/data/fail_test_.dart      main.<fn>\n","isFailure":true,"type":"error","time":345}
{"testID":2,"result":"failure","hidden":false,"type":"testDone","time":346}
{"success":false,"type":"done","time":348}
 */
int pubRunTestJsonFailureCount(String stdout) {
  int count = 0;
  for (String line in LineSplitter.split(stdout)) {
    try {
      var map = JSON.decode(line);
      //print(map);
      if (map is Map) {
        // {"testID":2,"result":"failure","hidden":false,"type":"testDone","time":346}
        if (map['testID'] != null) {
          if ((map['result'] == 'failure') && (map['hidden'] != true)) {
            count++;
          }
        }
      }
    } catch (_) {}
  }

  return count;
}
