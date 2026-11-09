# tekartik_pub

Helpers for Dart build and CI scripts that work on pub packages: find the
packages of a folder tree, read their pubspec, build the `dart pub` /
`dart run test` / `dart run build_runner` commands of a package, and the
recursive `pubget`, `pubupgrade`, `pubfmt` and `publist` commands.

Dart VM only (`dart:io`): scripts, tools and `@TestOn('vm')` tests, not web nor
Flutter apps.

## Getting started

The package is not on pub.dev, add it as a git dependency (the repository root
is the package), with `process_run` to run the commands:

```yaml
dependencies:
  tekartik_pub:
    git:
      url: https://github.com/tekartik/pub.dart
  process_run: any
```

List the packages of a folder tree, then run the tests of one of them:

```dart
import 'package:process_run/cmd_run.dart';
import 'package:tekartik_pub/io.dart';
import 'package:tekartik_pub/pubspec_yaml.dart';

Future<void> main() async {
  // Every package below the current folder (itself included).
  for (var path in await recursivePubPath(['.'])) {
    var pkg = PubPackage(path);
    var pubspec = PubspecYaml.fromMap(await pkg.getPubspecYamlMap());
    print('$path: ${pubspec.name} ${pubspec.version}');
  }

  // dart test in the current package, output streamed.
  var pkg = PubPackage('.');
  var result = await runCmd(
    pkg.pubCmd(pubRunTestArgs(reporter: RunTestReporter.expanded)),
    verbose: true,
  );
  // runCmd does not throw on a failure: check the exit code.
  print('exitCode: ${result.exitCode}');
}
```

## When to use what

Import `package:tekartik_pub/io.dart` (the other entry points `pub.dart`,
`pub_io.dart`, `pub_fs.dart`, `pub_fs_io.dart` and `pub_package.dart` are
deprecated).

* Find packages: `recursivePubPath(dirs)`, `isPubPackageRoot(path)`,
  `getPubPackageRoot(path)`, `isFlutterPackageRoot(path)`.
* One package: `PubPackage(path)` with `name`, `getPubspecYamlMap()`,
  `extractPubspecDependencies()`, `clone(dir)`; `pubCmd(args)` (`dart pub`),
  `dartCmd(args)` and `pbrCmd(args)` (`dart run build_runner`) build
  `process_run` commands, run them with `runCmd`.
* Arguments: `pubGetArgs`, `pubUpgradeArgs`, `pubRunTestArgs`,
  `testRunnerArgs`, `pubDepsArgs`, `dartdocArgs`; the json test reporter output
  is read with `pubRunTestJsonIsSuccess`, `pubRunTestJsonSuccessCount` and
  `pubRunTestJsonFailureCount`.
* Versions: `extractPackageVersion(path)` (pubspec.lock first, then
  pubspec.yaml), `PubspecYaml.fromMap(map)` from `pubspec_yaml.dart`.
* Recursive commands: `pubGet`, `pubUpgrade`, `pubFmt`, `pubList` from
  `package:tekartik_pub/bin/pubget.dart`, `pubupgrade.dart`, `pubfmt.dart` and
  `publist.dart`.

## Commands

`pubget`, `pubupgrade` (pub get / upgrade in every package found, a workspace
once), `pubfmt` (`dart format` of the dart folders of every package) and
`publist` (name and version of every package) take folders (default `.`).
`pubget`, `pubupgrade` and `pubfmt` also take `--dry-run` (`-d`) to only print
the commands and `--one` (`-o`) to run one package at a time (the default on
Windows, up to 10 at once otherwise); `pubget` and `pubupgrade` take
`--offline` and `--ignore-errors` (`-i`).

This package declares no executable: from a checkout, run
`dart run example/bin/pubget.dart <folders>`; in your own package, add a
`bin/pubget.dart` (then `dart run my_package:pubget`):

```dart
import 'package:tekartik_pub/bin/pubget.dart' as pubget;

Future<void> main(List<String> arguments) => pubget.main(arguments);
```

## Common pitfalls

* `runCmd` returns the result even when the command fails: check `exitCode`.
* `PubPackage.extractPackage(name)` only reads the `.packages` file, which Dart
  3 no longer writes: it returns null. Find a dependency with
  `pubGetPackageFilePath` (`package:tekartik_pub/packages_yaml_io.dart`),
  which reads `.dart_tool/package_config.json`.
* `extractPackageVersion` and the other `extract...` helpers return null
  instead of throwing when a file is missing or invalid.
* `pubBuildArgs`, `BuildMode` and `BuildFormat` target `pub build`, removed
  with Dart 2: use `pkg.pbrCmd(['build'])`.
* `clone` does not copy `build`, `pubspec.lock` and `.packages`, but copies
  `.dart_tool`: run `dart pub get` in the clone.
* Set `PubListOptions.oneByOne` before calling `pubList`, it is read with `!`.

Agent skills: [skills/tekartik-pub-package](skills/tekartik-pub-package/SKILL.md)
(finding and reading packages) and
[skills/tekartik-pub-commands](skills/tekartik-pub-commands/SKILL.md) (commands).
