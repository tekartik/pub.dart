library tekartik_pub.pubspec;

import 'package:pub_semver/pub_semver.dart';
import 'dart:io';
import 'package:path/path.dart';
import 'package:yaml/yaml.dart';
import 'dart:async';

// packages:
//   pubglobalupdate:
//     description: pubglobalupdate
//     source: hosted
//     version: "0.3.0"

Future<Version> extractPubspecLockVersion(String packageRoot) async {
  // get the package name from the base directory
  // ~/.pub-cache/global_packages/pubglobalupdate/
  String packageName = basename(packageRoot);
  return extractPackagePubspecLockVersion(packageName, packageRoot);
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
    Map pubspecYaml = loadYaml(
        await new File(join(packageRoot, 'pubspec.yaml')).readAsString());
    return new Version.parse(pubspecYaml['version']);
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
