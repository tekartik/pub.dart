import 'dart:async';
import 'dart:io' as io;

import 'package:fs_shim/fs_io.dart' as fs;
import 'package:path/path.dart';
import 'package:process_run/cmd_run.dart';
import 'package:process_run/cmd_run.dart' as cmd_run;
import 'package:tekartik_common_utils/common_utils_import.dart';
import 'package:tekartik_common_utils/map_utils.dart';

import 'pubspec.dart';
import 'src/pub_fs_io.dart';
import 'src/pubutils_fs.dart' as fs;
import 'tekartik_pub.dart' as common;

export 'pub_args.dart';
export 'pubspec.dart';
export 'src/pubutils_fs.dart'
    show
        pubspecYamlBasename,
        pubspecYamlHasAnyDependencies,
        pubspecYamlGetVersion,
        pubRunTestJsonFailureCount,
        pubRunTestJsonIsSuccess,
        pubRunTestJsonSuccessCount;
export 'src/rpubpath.dart' show recursivePubPath;

// bool _DEBUG = false;

class PubPackage extends common.PubPackage {
  io.Directory get dir => unwrapIoDirectory(fsPubPackage.dir);

  PubPackage._(FsPubPackage fsPubPackage) : super(fsPubPackage);

  PubPackage(String path) : this._(IoFsPubPackage(Directory(path)));

  @override
  String? get name {
    if (super.name == null) {
      super.name = extractPubspecYamlNameSync(path);
    }
    return super.name;
  }

  ProcessCmd pbrCmd(List<String> args) => _pbrCmd(args);

  /// When running
  ProcessCmd pubCmd(List<String> args) => _pubCmd(args);

  ProcessCmd dartCmd(List<String> args) => _dartCmd(args);

  Future<Map?> getPubspecYaml() => fsPubPackage.getPubspecYaml();

  Future<Map<String, dynamic>?> getPubspecYamlMap() =>
      fsPubPackage.getPubspecYamlMap();

  Future<Iterable<String>?> extractPubspecDependencies() =>
      fsPubPackage.extractPubspecDependencies();

  Future<PubPackage?> extractPackage(String dependency) async {
    final fsDependencyPubPackage =
        await fsPubPackage.extractPackage(dependency);
    if (fsDependencyPubPackage != null) {
      return PubPackage._(fsDependencyPubPackage);
    }
    return null;
  }

  @deprecated
  List<String> upgradeCmdArgs() {
    //args = new List.from(args);
    //args.insertAll(0, ['upgrade']);
    return ['upgrade'];
  }

  @deprecated
  ProcessCmd testCmd(List<String> args,
          {RunTestReporter? reporter,
          bool? color,
          int? concurrency,
          List<String>? platforms,
          String? name}) =>
      _pubCmd(pubRunTestArgs(
          args: args,
          reporter: reporter,
          color: color,
          concurrency: concurrency,
          platforms: platforms,
          name: name));

  ProcessCmd _pubCmd(List<String> args) {
    return cmd_run.PubCmd(args)..workingDirectory = path;
  }

  ProcessCmd _pbrCmd(List<String> args) {
    return _pubCmd(<String>['run', 'build_runner', ...args]);
  }

  ProcessCmd _dartCmd(List<String> args) {
    return cmd_run.DartCmd(args)..workingDirectory = path;
  }

  @deprecated
  ProcessCmd upgradeCmd({bool? offline, bool? dryRun}) =>
      _pubCmd(pubUpgradeArgs(offline: offline, dryRun: dryRun));

  @deprecated
  ProcessCmd getCmd({bool? offline, bool? dryRun, bool? packagesDir}) =>
      _pubCmd(pubGetArgs(
          offline: offline, dryRun: dryRun, packagesDir: packagesDir));

  // same package is same path

  @override
  int get hashCode => path.hashCode;

  @override
  bool operator ==(o) => o is PubPackage && path == o.path;

  @override
  String toString() => path;

  /// Clone a package content
  ///
  /// if [delete] is true, content will be deleted first
  Future<PubPackage> clone(String dir, {bool delete = false}) async {
    return PubPackage._(
        await fsPubPackage.clone(fs.Directory(dir), delete: delete));
  }
}

final String _pubspecYaml = 'pubspec.yaml';

/// return true if root package

/// @deprecated
Future<bool> isPubPackageRoot(String dirPath) async {
  final pubspecYamlPath = join(dirPath, _pubspecYaml);
  // ignore: avoid_slow_async_io
  return FileSystemEntity.isFile(pubspecYamlPath);
}

bool isPubPackageRootSync(String dirPath) {
  final pubspecYamlPath = join(dirPath, _pubspecYaml);
  return io.FileSystemEntity.isFileSync(pubspecYamlPath);
}

Future<bool> isFlutterPackageRoot(String dirPath) async {
  var map = (await getPubspecYaml(dirPath));
  if (map == null) {
    return false;
  }
  return mapValueFromParts(map, ['dependencies', 'flutter']) != null;
}

/// throws if no project found
Future<String> getPubPackageRoot(String resolverPath) async {
  var dirPath = normalize(absolute(resolverPath));

  while (true) {
    // Find the project root path
    if (await isPubPackageRoot(dirPath)) {
      return dirPath;
    }
    final parentDirPath = dirname(dirPath);

    if (parentDirPath == dirPath) {
      throw Exception("No project found for path '$resolverPath'");
    }
    dirPath = parentDirPath;
  }
}

String getPubPackageRootSync(String resolverPath) {
  var dirPath = normalize(absolute(resolverPath));

  while (true) {
    // Find the project root path
    if (isPubPackageRootSync(dirPath)) {
      return dirPath;
    }
    final parentDirPath = dirname(dirPath);

    if (parentDirPath == dirPath) {
      throw Exception("No project found for path '$resolverPath'");
    }
    dirPath = parentDirPath;
  }
}

Future<Map?> getPubspecYaml(String dirPath) =>
    fs.getPubspecYaml(wrapIoDirectory(io.Directory(dirPath)));
