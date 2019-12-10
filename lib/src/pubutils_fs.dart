library tekartik_pub.src.pubutils_fs;

import 'package:yaml/yaml.dart';

import 'import.dart';

const String pubspecYamlBasename = 'pubspec.yaml';
const String dotPackagesBasename = '.packages';

Future<Map> getDotPackagesYaml(Directory packageDir) async {
  final yamlPath = _pubspecDotPackagesPath(packageDir.path);
  final content = await childFile(packageDir, yamlPath).readAsString();

  final map = {};
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

//String _pubspecYamlPath(String packageRoot) =>
//    join(packageRoot, 'pubspec.yaml');
String _pubspecDotPackagesPath(String packageRoot) =>
    join(packageRoot, dotPackagesBasename);

@deprecated
Future<Map> getPackageYaml(Directory packageDir) => getPubspecYaml(packageDir);

// 2018-12 to deprecate
Future<Map> getPubspecYaml(Directory packageDir) =>
    getPubspecYamlMap(packageDir);

Future<Map<String, dynamic>> getPubspecYamlMap(Directory packageDir) =>
    _getYaml(packageDir, 'pubspec.yaml');

Future<Map<String, dynamic>> _getYaml(Directory packageDir, String name) async {
  final content = await childFile(packageDir, name).readAsString();
  return (loadYaml(content) as Map)?.cast<String, dynamic>();
}

Uri dotPackagesGetLibUri(Map yaml, String packageName) {
  return Uri.parse(yaml[packageName] as String);
}

// in dev tree
String pubspecYamlGetPackageName(Map yaml) => yaml['name'] as String;

Version pubspecYamlGetVersion(Map yaml) =>
    Version.parse(yaml['version'] as String);

Iterable<String> pubspecYamlGetTestDependenciesPackageName(Map yaml) {
  if (yaml.containsKey('test_dependencies')) {
    final list =
        (yaml['test_dependencies'] as Iterable)?.cast<String>() ?? <String>[];

    return list;
  }
  return null;
}

Iterable<String> pubspecYamlGetDependenciesPackageName(Map yaml) {
  return ((yaml['dependencies'] as Map)?.keys)?.cast<String>();
}

Version pubspecLockGetVersion(Map yaml, String packageName) =>
    Version.parse(yaml['packages'][packageName]['version'] as String);

bool pubspecYamlHasAnyDependencies(Map yaml, List<String> dependencies) {
  bool _hasDependencies(String kind, String dependency) {
    final dependencies = yaml[kind] as Map;
    if (dependencies != null) {
      if (dependencies[dependency] != null) {
        return true;
      }
    }
    return false;
  }

  for (final dependency in dependencies) {
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
    final map = json.decode(LineSplitter.split(stdout).last) as Map;
    return map['success'] as bool;
  } catch (_) {
    return false;
  }
}

int pubRunTestJsonSuccessCount(String stdout) {
  //int _warn;
  //print('# ${processResultToDebugString(result)}');
  var count = 0;
  for (final line in LineSplitter.split(stdout)) {
    try {
      var map = json.decode(line);
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
{'protocolVersion':'0.1.0','runnerVersion':'0.12.6+2','type':'start','time':0}
{'test':{'id':0,'name':'loading test/data/fail_test_.dart','groupIDs':[],'metadata':{'skip':false,'skipReason':null}},'type':'testStart','time':0}
{'testID':0,'result':'success','hidden':true,'type':'testDone','time':180}
{'group':{'id':1,'parentID':null,'name':null,'metadata':{'skip':false,'skipReason':null}},'type':'group','time':182}
{'test':{'id':2,'name':'failed','groupIDs':[1],'metadata':{'skip':false,'skipReason':null}},'type':'testStart','time':183}
{'testID':2,'error':'will fail','stackTrace':'package:test                   fail\ntest/data/fail_test_.dart 7:5  main.<fn>.<async>\n===== asynchronous gap ===========================\ndart:async                     _Completer.completeError\ntest/data/fail_test_.dart 8:4  main.<fn>.<async>\n===== asynchronous gap ===========================\ndart:async                     Future.Future.microtask\ntest/data/fail_test_.dart      main.<fn>\n','isFailure':true,'type':'error','time':345}
{'testID':2,'result':'failure','hidden':false,'type':'testDone','time':346}
{'success':false,'type':'done','time':348}
 */
int pubRunTestJsonFailureCount(String stdout) {
  var count = 0;
  for (final line in LineSplitter.split(stdout)) {
    try {
      var map = json.decode(line);
      print(map);
      if (map is Map) {
        // {'testID':2,'result':'failure','hidden':false,'type':'testDone','time':346}
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
