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

  Future<Map> getPackageYaml() => pub.getPackageYaml(dir);

  Future<String> extractPackageName() async {
    return pubspecYamlGetPackageName(await getPackageYaml());
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
        return new FsPubPackage(fs.newDirectory(path));
      }
    } catch (_) {}
    return null;
  }

  /// Clone a package content
  ///
  /// if [delete] is true, content will be deleted first
  Future<FsPubPackage> clone(Directory toDir, {bool delete: false}) async {
    Directory src = dir;
    Directory dst = toDir;
    if (await isPubPackageDir(src)) {
      await copyDirectory(
          src, dst,
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
}

/// return true if root package
Future<bool> isPubPackageDir(Directory dir) async {
  File pubspecYamlFile = childFile(dir, pubspecYamlBasename);
  return await dir.fs.isFile(pubspecYamlFile.path);
}

/// throws if no project found
Future<Directory> getPubPackageDir(Directory resolverDir) async {
  Directory dir =
      resolverDir.fs.newDirectory(normalize(absolute(resolverDir.path)));

  while (true) {
    // Find the project root path
    if (await isPubPackageDir(dir)) {
      return dir;
    }
    Directory parent = dir.parent;

    if (parent.path == dir.path) {
      throw new Exception("No project found for path '$resolverDir");
    }
    dir = parent;
  }
}
