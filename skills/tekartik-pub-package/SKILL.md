---
name: tekartik-pub-package
description: >-
  Use when finding pub packages on disk and reading their pubspec from Dart
  with tekartik_pub: recursivePubPath, isPubPackageRoot/isPubPackageRootSync,
  getPubPackageRoot/getPubPackageRootSync, isFlutterPackageRoot, the
  PubPackage class (path, dir, name, getPubspecYamlMap,
  extractPubspecDependencies, clone), PubspecYaml.fromMap,
  extractPackageVersion, extractPubspecYamlVersion,
  extractPubspecLockVersion, extractPubspecYamlNameSync,
  pubspecYamlGetVersion, pubspecYamlHasAnyDependencies and
  pubGetPackageFilePath, via package:tekartik_pub/io.dart.
---

# Finding and inspecting pub packages (tekartik_pub)

`tekartik_pub` walks a directory tree looking for `pubspec.yaml` files and
gives a small object (`PubPackage`) over each package found: its path, its
pubspec map, its version, its dependencies. It is a `dart:io` / desktop-only
package used by build and CI scripts.

## Guidelines

* Dependency (git only, not on pub.dev - the repo root is the package, no
  `path:`):
  ```yaml
  dependencies:
    tekartik_pub:
      git:
        url: https://github.com/tekartik/pub.dart
  ```
* `import 'package:tekartik_pub/io.dart';` is the single entry point for
  everything below. It re-exports `pub_args.dart`, `pubspec.dart`, the
  `recursivePubPath` helper and, from `dev_build`, `isPubPackageRoot`,
  `isPubPackageRootSync`, `isFlutterPackageRoot`, `getPubPackageRoot`,
  `getPubPackageRootSync`, `pubspecYamlBasename`, `pubspecYamlGetVersion`
  and `pubspecYamlHasAnyDependencies`. Add
  `package:tekartik_pub/pubspec_yaml.dart` for `PubspecYaml` and
  `package:tekartik_pub/packages_yaml_io.dart` for `pubGetPackageFilePath`.
* Several libraries of this package are marked `@Deprecated`: `pub.dart`,
  `pub_io.dart`, `pub_fs.dart`, `pub_fs_io.dart`, `pub_package.dart` and a
  few `PubPackage` members. Import `io.dart` (not deprecated) and prefer
  `package:dev_build/package.dart` in new code; use `tekartik_pub` for the
  package-walking helpers it still owns.
* `await recursivePubPath(['.'])` returns the list of package root paths
  under the given directories, itself included, skipping hidden folders,
  `build/`, `node_modules/` and packages whose sdk constraint does not match
  the running sdk. `recursivePubPath(dirs, dependencies: ['direct:path'])`
  keeps only packages depending on a given package (prefix a dependency with
  `direct:`, `dev:` or `override:`).
* `PubPackage(path)` never touches the disk in its constructor. `pkg.path` is
  the path it was built with, `pkg.dir` the `dart:io` `Directory`,
  `pkg.name` a lazily parsed (synchronous) pubspec name, and
  `pkg.toString()` the path. Two `PubPackage` with the same path are `==`.
* Reading the pubspec: `await pkg.getPubspecYamlMap()` gives a
  `Map<String, dynamic>?`, `await pkg.extractPackageName()` the name,
  `await pkg.extractPubspecDependencies()` the dependency names (it returns
  the `test_dependencies:` list instead when the pubspec has one).
  `getPubspecYaml(dirPath)` is the top-level equivalent when you do not need
  a `PubPackage`.
* Versions come from `pubspec.dart` (re-exported): `extractPackageVersion`
  (lock file first, then yaml), `extractPubspecLockVersion`,
  `extractPackagePubspecLockVersion(name, root)`,
  `extractPubspecYamlVersion`, and the synchronous
  `extractPubspecYamlNameSync`. They all return `null` instead of throwing
  when the file is missing or malformed, so check for `null`.
* `PubspecYaml.fromMap(map)` wraps a pubspec map in an object with `name` and
  `version` (a `pub_semver` `Version?`); its `toString()` is
  `'<name> <version>'`. Use `pubspecYamlGetVersion(map)` (throws when
  absent) or `pubspecYamlHasAnyDependencies(map, ['flutter'])` for a raw map.
* `await pkg.clone(targetDir, delete: true)` copies the package content to
  another directory, excluding `build`, `packages`, `.packages`, `.pub` and
  `pubspec.lock`, and returns the new `PubPackage`. This is the standard way
  to run destructive tests on a sample package.
* `pubGetPackageFilePath(packageRoot, package, file)` resolves a file inside
  a *dependency*'s `lib/` through `.dart_tool/package_config.json`; the
  package must have been resolved (`dart pub get`) first.
* `PubPackage.extractPackage(dependency)` and the `getDotPackagesYamlMap` /
  `dotPackagesYamlMapGetPackageLibPath` helpers read the legacy `.packages`
  file, which modern Dart sdks no longer write: they return `null` (or
  throw) on a current checkout. Use `pubGetPackageFilePath` instead.
* Everything here is `dart:io`: VM/desktop scripts, `@TestOn('vm')` tests,
  CI tools. Nothing works on the web or in Flutter apps.
* Building and running `pub`/`dart` commands for those packages (`pubCmd`,
  `pubGetArgs`, `pubRunTestArgs`, the recursive `pubget`/`pubupgrade`
  commands) is covered by
  [../tekartik-pub-commands/SKILL.md](../tekartik-pub-commands/SKILL.md).

## Examples

### List every package of a tree with its version

```dart
import 'package:tekartik_pub/io.dart';
import 'package:tekartik_pub/pubspec_yaml.dart';

Future<void> main(List<String> args) async {
  var dirs = args.isEmpty ? ['.'] : args;
  for (var path in await recursivePubPath(dirs)) {
    var pkg = PubPackage(path);
    var pubspecYaml = PubspecYaml.fromMap(await pkg.getPubspecYamlMap());
    print('$path: ${pubspecYaml.name} ${pubspecYaml.version}');
  }
}
```

### Find the package root of the current script and read it

```dart
import 'package:tekartik_pub/io.dart';

Future<void> main() async {
  if (!await isPubPackageRoot('.')) {
    print('not a package, root is ${await getPubPackageRoot('.')}');
  }
  var pkg = PubPackage(getPubPackageRootSync('.'));
  print('name: ${pkg.name} (dir ${pkg.dir.path})');
  print('flutter: ${await isFlutterPackageRoot(pkg.path)}');
  print('version: ${await extractPackageVersion(pkg.path)}');
  print('dependencies: ${await pkg.extractPubspecDependencies()}');
}
```

### Select the packages depending on a given package

```dart
import 'package:tekartik_pub/io.dart';

Future<List<String>> packagesUsingSembast(String root) async {
  return await recursivePubPath([root], dependencies: ['direct:sembast']);
}
```

### Raw pubspec map helpers

```dart
import 'package:tekartik_pub/io.dart';

Future<void> describe(String packageRoot) async {
  var map = (await getPubspecYaml(packageRoot))!.cast<String, Object?>();
  print('file: $pubspecYamlBasename');
  print('version: ${pubspecYamlGetVersion(map)}');
  print('flutter: ${pubspecYamlHasAnyDependencies(map, ['flutter'])}');
  print('name (sync): ${extractPubspecYamlNameSync(packageRoot)}');
}
```

### Clone a sample package before testing it

```dart
@TestOn('vm')
library;

import 'package:path/path.dart';
import 'package:tekartik_pub/io.dart';
import 'package:test/test.dart';

void main() {
  test('clone', () async {
    var src = PubPackage(join('example_packages', 'simple'));
    var out = join('.dart_tool', 'tekartik_pub', 'simple');
    var pkg = await src.clone(out, delete: true);
    expect(await pkg.extractPackageName(), await src.extractPackageName());
  });
}
```

## Common mistakes

* Importing `package:tekartik_pub/pub.dart`, `pub_io.dart` or `pub_fs.dart`:
  all deprecated, import `io.dart`.
* Using `PubPackage.extractPackage()` or the `.packages` helpers on a modern
  sdk; use `pubGetPackageFilePath` and `package_config.json`.
* Expecting `extractPackageVersion` and friends to throw: they swallow errors
  and return `null`.
* Calling `recursivePubPath` on a huge tree without noticing it descends into
  every sub package (it is recursive by design).
* Using any of this from Flutter or web code - it is `dart:io` only.
