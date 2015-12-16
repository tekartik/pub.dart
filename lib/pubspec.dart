library tekartik_pub.pubspec;

import 'package:pub_semver/pub_semver.dart';
import 'dart:io';
import 'package:path/path.dart';
import 'package:yaml/yaml.dart';
import 'dart:async';
import 'src/rpubpath.dart';
import 'pub.dart';
import 'src/pubutils_fs.dart' show pubspecYamlGetPackageName;

// packages:
//   pubglobalupdate:
//     description: pubglobalupdate
//     source: hosted
//     version: "0.3.0"

Future<Version> extractPubspecLockVersion(String packageRoot) async {
  // get the package name from the base directory
  // ~/.pub-cache/global_packages/pubglobalupdate/
  String packageName = basename(packageRoot);
  return await extractPackagePubspecLockVersion(packageName, packageRoot);
}

Future<Version> extractPackagePubspecLockVersion(
    String packageName, String packageRoot) async {
  try {
    Map pubspecLock = loadYaml(
        await new File(join(packageRoot, 'pubspec.lock')).readAsString());
    return new Version.parse(pubspecLock['packages'][packageName]['version']);
  } catch (_) {}
  return null;
}

// in dev tree
Future<Version> extractPubspecYamlVersion(String packageRoot) async {
  try {
    Map pubspecYaml = await getPackageYaml(packageRoot);
    return new Version.parse(pubspecYaml['version']);
  } catch (_) {}
  return null;
}

// in dev tree
String extractPubspecYamlNameSync(String packageRoot) {
  try {
    Map pubspecYaml = getPackageYamlSync(packageRoot);
    return pubspecYamlGetPackageName(pubspecYaml);
  } catch (_) {}
  return null;
}

Future<Version> extractPackageVersion(String packageRoot) async {
  Version version = await extractPubspecLockVersion(packageRoot);
  if (version == null) {
    version = await extractPubspecYamlVersion(packageRoot);
  }
  return version;
}

// return as package name
Future<Iterable<String>> extractPubspecDependencies(String packageRoot) async {
  Map yaml = await getPackageYaml(packageRoot);
  Iterable<String> list = await pubspecYamlGetTestDependenciesPackageName(yaml);
  if (list == null) {
    list = pubspecYamlGetDependenciesPackageName(yaml);
  }
  return list;
}

Future<PubPackage> extractPackage(
    String packageName, String fromPackageRoot) async {
  try {
    Map yaml = await getDotPackagesYaml(fromPackageRoot);
    String libPath = dotPackagesGetLibUri(yaml, packageName).toFilePath();
    // On windows we have lib/ resolved to lib/.
    // dirname on lib/ is not giving the expected result on windows
    // so build the path first
    // and linux/mac lib/ resolve to lib
    if (basename(libPath) == 'lib') {
      String path = libPath;
      if (isRelative(path)) {
        // use dirname to remove the ending separator
        path = normalize(join(fromPackageRoot, path));
      }
      // use dirname to remove the ending lib
      path = dirname(path);

      return new PubPackage(path);
    }
  } catch (_) {}
  return null;
}
