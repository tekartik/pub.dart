import 'package:fs_shim/utils/copy.dart';
import 'package:path/path.dart' as p;
import 'package:process_run/cmd_run.dart';

import 'import.dart';
import 'import.dart' as pub;
import 'pub_package_fs.dart';

export 'pubutils_fs.dart'
    show
        getPubspecYaml,
        pubspecYamlBasename,
        pubspecYamlHasAnyDependencies,
        pubspecYamlGetVersion,
        pubRunTestJsonFailureCount,
        pubRunTestJsonIsSuccess,
        pubRunTestJsonSuccessCount;

/// Factory function type to create an [FsPubPackage].
typedef FsPubPackageFactoryCreate =
    FsPubPackage Function(Directory dir, [String? name]);

/// Factory to construct [FsPubPackage] objects.
class FsPubPackageFactory {
  /// The factory function to create [FsPubPackage] instances.
  FsPubPackageFactoryCreate create;

  /// Constructor for [FsPubPackageFactory].
  FsPubPackageFactory(this.create);
}

/// Default instance of [FsPubPackageFactory].
final FsPubPackageFactory defaultFsPubPackageFactory = FsPubPackageFactory(
  (Directory dir, [String? name]) => FsPubPackage(dir, name),
);

// abstract?
/// File system based pub package representation.
class FsPubPackage extends Object implements PubPackageDir, PubPackageName {
  /// The factory associated with this package.
  final FsPubPackageFactory factory;

  /// Gets the file system of the package directory.
  FileSystem get fs => dir.fs;
  @override
  Directory dir;

  /// Constructor for FsPubPackage.
  FsPubPackage(Directory dir, [String? name])
    : this.created(defaultFsPubPackageFactory, dir, name);

  /// Constructor with custom factory.
  FsPubPackage.created(this.factory, this.dir, [this.name]);

  @override
  String? name;

  /// Prepare a command to be run within the package directory.
  ProcessCmd prepareCmd(ProcessCmd cmd) => cmd..workingDirectory = dir.path;

  /// Get the package yaml.
  @Deprecated('Use dev_test')
  Future<Map?> getPackageYaml() => pub.getPubspecYaml(dir);

  /// Get the pubspec yaml file contents.
  Future<Map?> getPubspecYaml() => pub.getPubspecYaml(dir);

  /// Get the pubspec as a map.
  Future<Map<String, dynamic>?> getPubspecYamlMap() =>
      pub.getPubspecYamlMap(dir);

  /// Extract the package name from pubspec.
  Future<String?> extractPackageName() async {
    return pubspecYamlGetPackageName((await getPubspecYaml())!);
  }

  /// Extract the package version from pubspec.
  Future<Version> extractVersion() async {
    return pubspecYamlGetVersion((await getPubspecYaml())!);
  }

  /// Extract the dependencies listed in pubspec.yaml.
  Future<Iterable<String>?> extractPubspecDependencies() async {
    final yaml = (await (getPubspecYaml()))!;
    final list = pubspecYamlGetDependenciesPackageName(yaml);
    return list;
  }

  /// Extract a package dependency from the package configuration.
  Future<FsPubPackage?> extractPackage(String? packageName) async {
    try {
      final yaml = await getDotPackagesYaml(dir);
      final libPath = dotPackagesGetLibUri(
        yaml,
        packageName,
      ).toFilePath(windows: dir.fs.path.style == p.windows.style);
      if (basename(libPath) == 'lib') {
        var path = dirname(libPath);
        if (isRelative(path)) {
          path = normalize(join(dir.path, path));
        }
        return factory.create(fs.directory(path), packageName);
      }
    } catch (_) {}
    return null;
  }

  /// Clone a package content
  ///
  /// if [delete] is true, content will be deleted first
  Future<FsPubPackage> clone(Directory toDir, {bool delete = false}) async {
    final src = dir;
    final dst = toDir;
    if (await isPubPackageDir(src)) {
      await copyDirectory(
        src,
        dst,
        options: CopyOptions(
          recursive: true,
          delete: delete, // delete before copying
          exclude: ['packages', '.packages', '.pub', 'pubspec.lock', 'build'],
        ),
      );
    } else {
      throw ArgumentError('not a pub directory');
    }
    return factory.create(dst);
  }

  @override
  String toString() => dir.toString();
}

/// return true if root package
Future<bool> isPubPackageDir(Directory dir) async {
  final pubspecYamlFile = childFile(dir, pubspecYamlBasename);
  return await dir.fs.isFile(pubspecYamlFile.path);
}

/// throws if no project found above
Future<Directory> getPubPackageDir(FileSystemEntity resolver) async {
  var path = resolver.path;
  var pathContent = resolver.fs.path;
  if (!(await resolver.fs.isDirectory(resolver.path))) {
    path = pathContent.dirname(path);
  }
  var dir = resolver.fs.directory(pathContent.normalize(path));

  while (true) {
    // Find the project root path
    if (await isPubPackageDir(dir)) {
      return dir;
    }
    final parent = dir.parent;

    if (parent.path == dir.path) {
      throw Exception("No project found for path '$resolver");
    }
    dir = parent;
  }
}
