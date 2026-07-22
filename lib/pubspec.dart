library;

import 'dart:async';
import 'dart:io';

import 'package:path/path.dart';
import 'package:pub_semver/pub_semver.dart';
import 'package:yaml/yaml.dart';

import 'io.dart';
import 'src/pubutils_fs.dart' show pubspecYamlGetPackageName;
import 'src/rpubpath.dart';

// packages:
//   pubglobalupdate:
//     description: pubglobalupdate
//     source: hosted
//     version: "0.3.0"

/// Extract the package version from pubspec.lock based on package root path.
Future<Version?> extractPubspecLockVersion(String packageRoot) async {
  // get the package name from the base directory
  // ~/.pub-cache/global_packages/pubglobalupdate/
  final packageName = basename(packageRoot);

  return await extractPackagePubspecLockVersion(packageName, packageRoot);
}

/// Extract the version for a specific package from pubspec.lock.
Future<Version?> extractPackagePubspecLockVersion(
  String packageName,
  String packageRoot,
) async {
  try {
    final pubspecLock =
        loadYaml(await File(join(packageRoot, 'pubspec.lock')).readAsString())
            as Map;
    return Version.parse(
      ((pubspecLock['packages'] as Map)[packageName] as Map)['version']
          as String,
    );
  } catch (_) {}
  return null;
}

// in dev tree
/// Extract the version from pubspec.yaml.
Future<Version?> extractPubspecYamlVersion(String packageRoot) async {
  try {
    final pubspecYaml = (await getPackageYaml(packageRoot))!;
    return Version.parse(pubspecYaml['version'] as String);
  } catch (_) {}
  return null;
}

// in dev tree
/// Extract the package name from pubspec.yaml synchronously.
String? extractPubspecYamlNameSync(String packageRoot) {
  try {
    final pubspecYaml = getPackageYamlSync(packageRoot)!;

    return pubspecYamlGetPackageName(pubspecYaml);
  } catch (_) {}
  return null;
}

/// Extract the package version from lock file or yaml file.
Future<Version?> extractPackageVersion(String packageRoot) async {
  var version =
      await extractPubspecLockVersion(packageRoot) ??
      await extractPubspecYamlVersion(packageRoot);

  return version;
}

// return as package name
/// Extract the dependencies listed in pubspec.yaml.
Future<Iterable<String>?> extractPubspecDependencies(String packageRoot) async {
  final yaml = (await getPackageYaml(packageRoot))!;
  var list = pubspecYamlGetTestDependenciesPackageName(yaml);
  list ??= pubspecYamlGetDependenciesPackageName(yaml);

  return list;
}

/// Extract a specific package dependency.
@Deprecated('No longer supported')
Future<PubPackage?> extractPackage(
  String? packageName,
  String fromPackageRoot,
) async {
  try {
    final yaml = await getDotPackagesMap(fromPackageRoot);
    final libPath = dotPackagesGetLibUri(yaml, packageName).toFilePath();
    // On windows we have lib/ resolved to lib/.
    // dirname on lib/ is not giving the expected result on windows
    // so build the path first
    // and linux/mac lib/ resolve to lib
    if (basename(libPath) == 'lib') {
      var path = libPath;
      if (isRelative(path)) {
        // use dirname to remove the ending separator
        path = normalize(join(fromPackageRoot, path));
      }
      // use dirname to remove the ending lib
      path = dirname(path);

      return PubPackage(path);
    }
  } catch (_) {}
  return null;
}
