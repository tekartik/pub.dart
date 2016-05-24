library tekartik_io_tools.pub;

import 'package:process_run/process_run.dart';
import 'package:process_run/dartbin.dart' as _dartbin;
import 'package:process_run/cmd_run.dart';
import 'dart:async';
import 'dart:io';
import 'package:path/path.dart';
import 'pubspec.dart';
import 'pub_args.dart';
export 'pub_args.dart';

bool _DEBUG = false;

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

  @deprecated
  set name(String name) {
    _name = name;
  }

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

  @deprecated
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
          reporter: reporter.toString(),
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

/// @deprecated
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
