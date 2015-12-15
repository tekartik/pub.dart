library tekartik_io_tools.pub_utils;

import 'package:process_run/process_run.dart';
import 'package:process_run/dartbin.dart' as _dartbin;
import 'package:process_run/cmd_run.dart';
import 'dart:async';
import 'dart:io';
import 'package:path/path.dart';
import 'pubspec.dart';

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

const String pubBuildFormatRelease = "release";
const String pubBuildFormatDebug = "debug";

/// list of argument for pubCmd
Iterable<String> pubBuildArgs(
    {Iterable<String> args, String mode, String format, String output}) {
  List<String> buildArgs = ['build'];
  // --mode      Mode to run transformers in.
  //    (defaults to "release")
  if (mode != null) {
    buildArgs.addAll(['--mode', mode]);
  }
  // --format    How output should be displayed.
  // [text (default), json]
  if (format != null) {
    buildArgs.addAll(['--format', format]);
  }
  // -o, --output    Directory to write build outputs to.
  // (defaults to "build")
  if (output != null) {
    buildArgs.addAll(['--output', output]);
  }
  if (args != null) {
    buildArgs.addAll(args);
  }

  return buildArgs;
}

Iterable<String> pubGetArgs({bool offline, bool dryRun}) {
  List<String> args = ['get'];
  if (offline == true) {
    args.add('--offline');
  }
  if (dryRun == true) {
    args.add('--dry-run');
  }
  return args;
}

Iterable<String> pubUpgradeArgs({bool offline, bool dryRun}) {
  List<String> args = ['upgrade'];
  if (offline == true) {
    args.add('--offline');
  }
  if (dryRun == true) {
    args.add('--dry-run');
  }
  return args;
}

/// list of argument for pubCmd
Iterable<String> pubRunTestArgs(
    {Iterable<String> args,
    TestReporter reporter,
    bool color,
    int concurrency,
    List<String> platforms,
    String name}) {
  List<String> testArgs = ['run', 'test'];
  if (reporter != null) {
    testArgs.addAll(['-r', testReporterString(reporter)]);
  }
  if (concurrency != null) {
    testArgs.addAll(['-j', concurrency.toString()]);
  }
  if (name != null) {
    testArgs.addAll(['-n', name]);
  }
  if (color != null) {
    if (color) {
      testArgs.add('--color');
    } else {
      testArgs.add('--no-color');
    }
  }
  if (platforms != null) {
    for (String platform in platforms) {
      testArgs.addAll(['-p', platform]);
    }
  }
  if (args != null) {
    testArgs.addAll(args);
  }
  return (testArgs);
}

///
/// A local pub package
///
class PubPackage {
  String _path;

  String _name;
  @deprecated
  String get name {
    if (_name == null) {
      _name = extractPubspecYamlNameSync(_path);
    }
    return _name;
  }

  set name(String name) => _name = name;

  String get path => _path;

  PubPackage(this._path);

  @deprecated
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

  @deprecated
  ProcessCmd testCmd(List<String> args,
          {TestReporter reporter,
          bool color,
          int concurrency,
          List<String> platforms,
          String name}) =>
      _pubCmd(pubRunTestArgs(
          args: args,
          reporter: reporter,
          color: color,
          concurrency: concurrency,
          platforms: platforms,
          name: name));

  ProcessCmd _pubCmd(List<String> args) {
    return pubCmd(args)..workingDirectory = path;
  }

  @deprecated
  ProcessCmd buildCmd({String format}) => _pubCmd(pubBuildArgs(format: format));

  @deprecated
  ProcessCmd upgradeCmd({bool offline, bool dryRun}) =>
      _pubCmd(pubUpgradeArgs(offline: offline, dryRun: dryRun));
  @deprecated
  ProcessCmd getCmd({bool offline, bool dryRun}) =>
      _pubCmd(pubGetArgs(offline: offline, dryRun: dryRun));

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
