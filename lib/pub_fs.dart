library tekartik_io_tools.pub_fs;

import 'package:process_run/cmd_run.dart';
//import 'pub.dart';
//export 'pub.dart';
import 'pub_package.dart';
//import 'pubspec.dart';
import 'package:fs_shim/fs.dart';
import 'package:fs_shim/utils/entity.dart';
import 'package:fs_shim/utils/copy.dart';
import 'dart:async';
import 'src/import.dart';
import 'src/import.dart' as pub;
export 'src/pubutils_fs.dart'
    show
        getPubspecYaml,
        dotPackagesBasename,
        pubspecYamlBasename,
        pubspecYamlHasAnyDependencies,
        pubspecYamlGetVersion;

bool _debug = false;

typedef FsPubPackage FsPubPackageFactoryCreate(Directory dir, [String name]);

class FsPubPackageFactory {
  FsPubPackageFactoryCreate create;

  FsPubPackageFactory(this.create);
}

final FsPubPackageFactory defaultFsPubPackageFactory = new FsPubPackageFactory(
    (Directory dir, [String name]) => new FsPubPackage(dir, name));

// abstract?
class FsPubPackage extends Object implements PubPackageDir, PubPackageName {
  final FsPubPackageFactory factory;

  FileSystem get fs => dir.fs;
  @override
  Directory dir;
  FsPubPackage(Directory dir, [String name])
      : this.created(defaultFsPubPackageFactory, dir, name);

  FsPubPackage.created(this.factory, Directory dir, [this.name]) : dir = dir;
  @override
  String name;

  ProcessCmd prepareCmd(ProcessCmd cmd) => cmd..workingDirectory = dir.path;

  @deprecated
  Future<Map> getPackageYaml() => pub.getPubspecYaml(dir);
  Future<Map> getPubspecYaml() => pub.getPubspecYaml(dir);

  Future<String> extractPackageName() async {
    return pubspecYamlGetPackageName(await getPubspecYaml());
  }

  Future<Version> extractVersion() async {
    return pubspecYamlGetVersion(await getPubspecYaml());
  }

  // return as package name
  Future<Iterable<String>> extractPubspecDependencies() async {
    Map yaml = await getPubspecYaml();
    Iterable<String> list = pubspecYamlGetDependenciesPackageName(yaml);
    return list;
  }

  // Extract a package (dependency)
  Future<FsPubPackage> extractPackage(String packageName) async {
    try {
      Map yaml = await getDotPackagesYaml(dir);
      String libPath = dotPackagesGetLibUri(yaml, packageName).toFilePath();
      if (basename(libPath) == 'lib') {
        String path = dirname(libPath);
        if (isRelative(path)) {
          path = normalize(join(dir.path, path));
        }
        return factory.create(fs.newDirectory(path), packageName);
      }
    } catch (_e) {
      if (_debug) {
        print(_e);
      }
    }
    return null;
  }

  /// Clone a package content
  ///
  /// if [delete] is true, content will be deleted first
  Future<FsPubPackage> clone(Directory toDir, {bool delete: false}) async {
    Directory src = dir;
    Directory dst = toDir;
    if (await isPubPackageDir(src)) {
      await copyDirectory(src, dst,
          options: new CopyOptions(
              recursive: true,
              delete: delete, // delete before copying
              exclude: [
                'packages',
                '.packages',
                '.pub',
                'pubspec.lock',
                'build'
              ]));
    } else {
      throw new ArgumentError('not a pub directory');
    }
    return factory.create(dst);
  }

  @override
  String toString() => dir.toString();
}

/// return true if root package
Future<bool> isPubPackageDir(Directory dir) async {
  File pubspecYamlFile = childFile(dir, pubspecYamlBasename);
  return await dir.fs.isFile(pubspecYamlFile.path);
}

/// throws if no project found above
Future<Directory> getPubPackageDir(FileSystemEntity resolver) async {
  String path = resolver.path;
  if (!(await resolver.fs.isDirectory(resolver.path))) {
    path = resolver.fs.pathContext.dirname(path);
  }
  Directory dir = resolver.fs.newDirectory(normalize(absolute(path)));

  while (true) {
    // Find the project root path
    if (await isPubPackageDir(dir)) {
      return dir;
    }
    Directory parent = dir.parent;

    if (parent.path == dir.path) {
      throw new Exception("No project found for path '$resolver");
    }
    dir = parent;
  }
}
