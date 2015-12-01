library tekartik_io_tools.pub_utils;

import 'package:process_run/process_run.dart';
import 'package:process_run/dartbin.dart' as _dartbin;
import 'dart:async';
import 'dart:io';
import 'package:path/path.dart';

bool _DEBUG = false;

enum TestReporter { COMPACT, EXPANDED }

final Map<String, TestReporter> _testReporterMap = new Map.fromIterables(
    ["compact", "expanded"], [TestReporter.COMPACT, TestReporter.EXPANDED]);

final Map<TestReporter, String> _testReporterStringMap =
    new Map.fromIterables(_testReporterMap.values, _testReporterMap.keys);

String testReporterString(TestReporter reporter) =>
    _testReporterStringMap[reporter];

List<String> testReporterStrings = new List.from(_testReporterStringMap.values);
TestReporter testReporterFromString(String reporterString) =>
    _testReporterMap[reporterString];

///
/// A local pub package
///
class PubPackage {
  String _path;

  String get path => _path;

  PubPackage(this._path);

  Future<ProcessResult> pubRun(List<String> args) {
    return run(_dartbin.dartExecutable, _dartbin.pubArguments(args),
        workingDirectory: _path);
  }
  /*
  List<String> pubCmd(List<String> args) =>
      pubArguments(args), workingDirectory: _path
      */

  List<String> upgradeCmdArgs() {
    //args = new List.from(args);
    //args.insertAll(0, ['upgrade']);
    return ['upgrade'];
  }

  List<String> runTestCmdArgs(List<String> args,
      {TestReporter reporter,
      bool color,
      int concurrency,
      List<String> platforms,
      String name}) {
    args = new List.from(args);
    args.insertAll(0, ['run', 'test']);
    if (reporter != null) {
      args.addAll(['-r', testReporterString(reporter)]);
    }
    if (concurrency != null) {
      args.addAll(['-j', concurrency.toString()]);
    }
    if (name != null) {
      args.addAll(['-n', name]);
    }
    if (color != null) {
      if (color) {
        args.add('--color');
      } else {
        args.add('--no-color');
      }
    }
    if (platforms != null) {
      for (String platform in platforms) {
        args.addAll(['-p', platform]);
      }
    }
    return args;
  }

  // same package is same path

  @override
  int get hashCode => path.hashCode;

  @override
  bool operator ==(o) => path == o.path;

  @override
  String toString() => path;
}

final String _pubspecYaml = "pubspec.yaml";

/// return true if root package
Future<bool> isPubPackageRoot(String dirPath) async {
  String pubspecYamlPath = join(dirPath, _pubspecYaml);
  return await FileSystemEntity.isFile(pubspecYamlPath);
}

bool isPubPackageRootSync(String dirPath) {
  String pubspecYamlPath = join(dirPath, _pubspecYaml);
  return FileSystemEntity.isFileSync(pubspecYamlPath);
}

/// throws if no project found
Future<String> getPubPackageRoot(String resolverPath) async {
  String dirPath = normalize(absolute(resolverPath));

  while (true) {
    // Find the project root path
    if (await isPubPackageRoot(dirPath)) {
      return dirPath;
    }
    String parentDirPath = dirname(dirPath);

    if (parentDirPath == dirPath) {
      throw new Exception("No project found for path '$resolverPath");
    }
    dirPath = parentDirPath;
  }
}

String getPubPackageRootSync(String resolverPath) {
  String dirPath = normalize(absolute(resolverPath));

  while (true) {
    // Find the project root path
    if (isPubPackageRootSync(dirPath)) {
      return dirPath;
    }
    String parentDirPath = dirname(dirPath);

    if (parentDirPath == dirPath) {
      throw new Exception("No project found for path '$resolverPath");
    }
    dirPath = parentDirPath;
  }
}
