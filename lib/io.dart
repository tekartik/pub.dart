import 'dart:async';
import 'dart:io' as io;

import 'package:fs_shim/fs_io.dart';
import 'package:fs_shim/fs_io.dart' as fs;
import 'package:path/path.dart';
import 'package:process_run/cmd_run.dart';
import 'package:process_run/cmd_run.dart' as cmd_run;
import 'package:process_run/dartbin.dart' as _dartbin;
import 'package:process_run/process_run.dart';

import 'pub_args.dart';
import 'pubspec.dart';
import 'src/pub_fs_io.dart';
import 'tekartik_pub.dart' as common;

export 'pub_args.dart';

bool _DEBUG = false;

class PubPackage extends common.PubPackage {

  String _name;

  @deprecated
  String get name {
    if (_name == null) {
      _name = extractPubspecYamlNameSync(path);
    }
    return _name;
  }

  @deprecated
  set name(String name) {
    _name = name;
  }

  io.Directory get dir => unwrapIoDirectory(fsPubPackage.dir);

  PubPackage._(IoFsPubPackage fsPubPackage) : super(fsPubPackage);

  PubPackage(String path) : this._(new IoFsPubPackage(new Directory(path)));

  @deprecated
  Future<ProcessResult> pubRun(List<String> args) {
    return run(_dartbin.dartExecutable, _dartbin.pubArguments(args),
        workingDirectory: path);
  }

  ProcessCmd pubCmd(List<String> args) => _pubCmd(args);

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
    return cmd_run.pubCmd(args)
      ..workingDirectory = path;
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

  /// Clone a package content
  ///
  /// if [delete] is true, content will be deleted first
  Future<PubPackage> clone(String dir, {bool delete: false}) async {
    return new PubPackage._(
        await fsPubPackage.clone(new fs.Directory(dir), delete: delete));
  }

/*
  // 2016-09-24
  ProcessCmd cmd(Iterable<String> args) {
    ProcessCmd _cmd = cmd_run.pubCmd(args)
      ..workingDirectory = path;

    return _cmd;
  }
  */
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
  return io.FileSystemEntity.isFileSync(pubspecYamlPath);
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