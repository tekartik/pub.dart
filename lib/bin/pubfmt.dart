#!/usr/bin/env dart

import 'dart:async';
import 'dart:io';

import 'package:args/args.dart';
import 'package:tekartik_pub/bin/src/pub_action.dart';
import 'package:tekartik_pub/bin/src/pubbin_utils.dart';
import 'package:tekartik_pub/src/rpubpath.dart';

/// Options for the `pubfmt` command.
class PubFmtOptions extends PubBinOptions {
  /// Force recursive search even in a Dart project.
  bool? forceRecursive;

  /// Obsolete, ignored (`dart format` has no more `--fix`).
  bool? fix;
}

// chmod +x ...
Future<void> main(List<String> arguments) async {
  final parser = ArgParser(allowTrailingOptions: true);
  parser.addFlag(argHelpFlag, abbr: 'h', help: 'Usage help', negatable: false);

  parser.addFlag(
    argForceRecursiveFlag,
    abbr: 'f',
    help: 'Force going recursive even in dart project',
    defaultsTo: true,
  );
  // Obsolete (`dart format` has no more `--fix`), still accepted.
  parser.addFlag(
    argFixFlag,
    abbr: 'x',
    help: 'Obsolete, ignored',
    defaultsTo: true,
    hide: true,
  );

  addCommonOptions(parser);

  final argResults = parser.parse(arguments);

  final help = argResults[argHelpFlag] as bool;
  if (help) {
    stdout.writeln(parser.usage);
    return;
  }
  if (parseCommonOptions(argResults)) {
    return;
  }

  final oneByOne = argResults[argOneByOneFlag] as bool /*!*/;
  final forceRecursive = argResults[argForceRecursiveFlag] as bool /*!*/;
  final dryRun = argResults[argDryRunFlag] as bool;

  var rest = argResults.rest;
  // if no default to current folder
  if (rest.isEmpty) {
    rest = ['.'];
  }
  await pubFmt(
    rest,

    PubFmtOptions()
      ..oneByOne = oneByOne
      ..forceRecursive = forceRecursive
      ..dryRun = dryRun,
  );
}

/// Run `dart format` on the dart directories of the packages found in
/// [directories].
///
/// In dry run mode the commands are only printed. Returns the number of
/// packages formatted.
Future<int> pubFmt(List<String> directories, PubFmtOptions options) async {
  final futures = <Future<void>>[];
  final pkgPaths = await pubBinPackagePaths(
    directories,
    forceRecursive: options.forceRecursive,
  );
  var count = 0;
  for (final dir in pkgPaths) {
    // list of dir to check
    var targets = await findTargetDartDirectories(dir);
    if (targets.isEmpty) {
      continue;
    }
    count++;
    var cmd = DartCmd(['format', ...targets])..workingDirectory = dir;
    var future = runCmd(cmd, options: options);
    if (options.oneByOne == true) {
      await future;
    } else {
      futures.add(future);

      await limitConcurrentTasks(futures);
    }
  }
  await Future.wait(futures);
  return count;
}
