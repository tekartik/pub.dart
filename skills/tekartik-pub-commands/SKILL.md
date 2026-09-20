---
name: tekartik-pub-commands
description: >-
  Use when scripting dart/pub commands over one or many packages with
  tekartik_pub: PubPackage.pubCmd/dartCmd/pbrCmd with process_run runCmd, the
  argument builders pubGetArgs, pubUpgradeArgs, pubRunArgs, pubRunTestArgs,
  testRunnerArgs, pubDepsArgs, dartdocArgs, RunTestReporter, TestRunnerArgs,
  parsing the json reporter with pubRunTestJsonIsSuccess /
  pubRunTestJsonSuccessCount / pubRunTestJsonFailureCount, and the recursive
  pubget / pubupgrade / pubfmt / publist commands (pubGet, pubUpgrade,
  pubFmt, pubList, PubGetOptions, PubFmtOptions, PubListOptions).
---

# Running pub and dart commands (tekartik_pub)

`tekartik_pub` turns a package path into `process_run` commands (`dart pub
get`, `dart run test`, `dart run build_runner ...`) and ships recursive
`pubget` / `pubupgrade` / `pubfmt` / `publist` implementations that apply
them to every package of a tree. Everything runs on the Dart VM only.

## Guidelines

* Dependency (git only, not on pub.dev - the repo root is the package, no
  `path:`):
  ```yaml
  dependencies:
    tekartik_pub:
      git:
        url: https://github.com/tekartik/pub.dart
  ```
  You also import `package:process_run/cmd_run.dart` to run the commands.
* `import 'package:tekartik_pub/io.dart';` gives `PubPackage` plus every
  argument builder (it re-exports `pub_args.dart`). The recursive commands
  live in `package:tekartik_pub/bin/pubget.dart`,
  `.../bin/pubupgrade.dart`, `.../bin/pubfmt.dart` and
  `.../bin/publist.dart`; each also exposes a `main(List<String>)` for a
  thin executable wrapper.
* Command objects: `pkg.pubCmd(args)` builds a `dart pub <args>` `ProcessCmd`
  with `workingDirectory` set to the package, `pkg.dartCmd(args)` a plain
  `dart <args>`, `pkg.pbrCmd(args)` a `dart run build_runner <args>`. Run
  them with `await runCmd(cmd)` (add `verbose: true` to stream output);
  `runCmd` does not throw on a non-zero exit, check `result.exitCode`.
* Argument builders (all return `List<String>`): `pubGetArgs(offline:,
  dryRun:)`, `pubUpgradeArgs(offline:, dryRun:)`, `pubRunArgs(args)`,
  `pubRunTestArgs(args:, reporter:, color:, concurrency:, platforms:,
  name:)`, `testRunnerArgs(...)` (same options, without the leading
  `run test`), `pubRunTestRunnerArgs(TestRunnerArgs(...))`,
  `pubDepsArgs(style: pubDepsStyleCompact | pubDepsStyleTree |
  pubDepsStyleList)`, `dartdocArgs(input:, output:)` and the generic
  `pubArgs(args:, help:, verbose:)`.
* `RunTestReporter` is an enum with `compact`, `expanded` and `json` (the
  upper-case `COMPACT`/`EXPANDED`/`JSON` values are deprecated aliases).
  `runTestReporterFromString('json')` parses one from a command line;
  `pubRunTestReporters` lists the three names as strings
  (`pubRunTestReporterCompact`, `...Expanded`, `...Json`).
* With `reporter: RunTestReporter.json`, parse the captured stdout with
  `pubRunTestJsonIsSuccess(stdout)` (`bool?`, null when undecidable),
  `pubRunTestJsonSuccessCount(stdout)` and
  `pubRunTestJsonFailureCount(stdout)`.
* `pubBuildArgs(...)`, `BuildMode` and `BuildFormat` target the removed
  `pub build` command; use `pkg.pbrCmd(['build', '--output', 'web:build'])`
  instead. `PubPackage.testCmd`, `getCmd`, `upgradeCmd` and `upgradeCmdArgs`
  are `@Deprecated` - build the args explicitly and call `pubCmd`.
* Recursive commands take a list of directories and an options object:
  `pubGet(dirs, PubGetOptions()..oneByOne = false)`,
  `pubUpgrade(dirs, PubGetOptions()...)` (same options class),
  `pubFmt(dirs, PubFmtOptions()..forceRecursive = true)` (returns the number
  of packages processed, formats through `dev_build`'s `packageRunCi` in
  format-only mode), `pubList(dirs, PubListOptions()..oneByOne = true)`
  (prints `<name> <version>` per package).
* Always set `oneByOne` on `PubGetOptions` and `PubListOptions`: those two
  read it with `!` and throw a null error when it is left unset. `oneByOne`
  runs the packages sequentially (required on Windows), otherwise up to ten
  run concurrently. `dryRun` prints the command instead of running it,
  `ignoreErrors` keeps going after a failing package, `offline` adds
  `--offline`.
* `pubGet`/`pubUpgrade` are workspace aware: when a package has
  `resolution: workspace`, only its workspace root is resolved once. That
  de-duplication only happens if you call `initPubWorkspacesCache()` first,
  which the commands' own `main` does.
* Expose the commands as executables by re-exporting their `main` from a
  `bin/*.dart` of your own package, the way `example/bin/pubget.dart` does in
  this repo; then `dart run <your_package>:pubget`.
* Finding the packages to act on (`recursivePubPath`, `PubPackage`, pubspec
  reading) is covered by
  [../tekartik-pub-package/SKILL.md](../tekartik-pub-package/SKILL.md).

## Examples

### Run the tests of a package and read the result

```dart
import 'package:process_run/cmd_run.dart';
import 'package:tekartik_pub/io.dart';

Future<void> main() async {
  var pkg = PubPackage('.');
  var result = await runCmd(
    pkg.pubCmd(pubRunTestArgs(reporter: RunTestReporter.expanded)),
    verbose: true,
  );
  print('exitCode: ${result.exitCode}');
}
```

### Count failures with the json reporter

```dart
import 'package:process_run/cmd_run.dart';
import 'package:tekartik_pub/io.dart';

Future<int> failureCount(String packagePath) async {
  var pkg = PubPackage(packagePath);
  var result = await runCmd(
    pkg.pubCmd(
      pubRunTestArgs(
        reporter: RunTestReporter.json,
        concurrency: 1,
        platforms: ['vm'],
      ),
    ),
  );
  var stdout = result.stdout.toString();
  print('success: ${pubRunTestJsonIsSuccess(stdout)}');
  print('passed: ${pubRunTestJsonSuccessCount(stdout)}');
  return pubRunTestJsonFailureCount(stdout);
}
```

### pub get, deps and build_runner on one package

```dart
import 'package:process_run/cmd_run.dart';
import 'package:tekartik_pub/io.dart';

Future<void> prepare(String path) async {
  var pkg = PubPackage(path);
  await runCmd(pkg.pubCmd(pubGetArgs(offline: true)));
  var deps = await runCmd(pkg.pubCmd(pubDepsArgs(style: pubDepsStyleCompact)));
  print(deps.stdout);
  await runCmd(
    pkg.pbrCmd(['build', '--delete-conflicting-outputs']),
    verbose: true,
  );
  await runCmd(pkg.dartCmd(['analyze', '--fatal-infos']));
}
```

### Recursive pub get / upgrade over a tree

```dart
import 'package:tekartik_pub/bin/pubget.dart';
import 'package:tekartik_pub/bin/pubupgrade.dart' as pubupgrade;

Future<void> main(List<String> args) async {
  var dirs = args.isEmpty ? ['.'] : args;
  // oneByOne must be set: pubGet/pubUpgrade dereference it.
  await pubGet(
    dirs,
    PubGetOptions()
      ..oneByOne = false
      ..offline = true,
  );
  await pubupgrade.pubUpgrade(
    dirs,
    PubGetOptions()
      ..oneByOne = true
      ..ignoreErrors = true,
  );
}
```

### Recursive format and listing

```dart
import 'package:tekartik_pub/bin/pubfmt.dart';
import 'package:tekartik_pub/bin/publist.dart';

Future<void> main(List<String> args) async {
  var dirs = args.isEmpty ? ['.'] : args;
  var count = await pubFmt(dirs, PubFmtOptions()..forceRecursive = true);
  print('formatted $count package(s)');
  await pubList(dirs, PubListOptions()..oneByOne = true);
}
```

### Exposing pubget as an executable of your own package

```dart
// bin/pubget.dart in your package, then: dart run my_package:pubget
import 'package:tekartik_pub/bin/pubget.dart' as pubget;

Future<void> main(List<String> arguments) => pubget.main(arguments);
```

## Common mistakes

* Leaving `oneByOne` null in `PubGetOptions` / `PubListOptions` - it is read
  with `!`.
* Assuming `runCmd` throws on failure: it returns the `ProcessResult`, check
  `exitCode` yourself.
* Using `pubBuildArgs` / `BuildMode` / `BuildFormat` - `pub build` no longer
  exists; use `pbrCmd` (build_runner).
* Calling the deprecated `pkg.getCmd()` / `pkg.upgradeCmd()` / `pkg.testCmd()`
  instead of `pkg.pubCmd(pubGetArgs())` and friends.
* Running many packages concurrently (`oneByOne = false`) and interleaving
  their stdout; pass `oneByOne = true` when the output must stay readable.
