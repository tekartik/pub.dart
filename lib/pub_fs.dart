library tekartik_io_tools.pub_utils;

//import 'package:process_run/cmd_run.dart';
//import 'pub.dart';
//export 'pub.dart';
import 'pub_package.dart';
//import 'pubspec.dart';
import 'package:fs_shim/fs.dart';
import 'package:fs_shim/utils/entity.dart';
import 'dart:async';
import 'src/import.dart';

class FsPubPackage extends Object implements PubPackageDir, PubPackageName {
  FileSystem get fs => dir.fs;
  @override
  Directory dir;
  FsPubPackage(Directory dir, [this.name]) : dir = dir;

  @override
  String name;

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
}

/// return true if root package
Future<bool> isPubPackageRoot(Directory dir) async {
  File pubspecYamlFile = childFile(dir, pubspecYamlBasename);
  return await dir.fs.isFile(pubspecYamlFile.path);
}
