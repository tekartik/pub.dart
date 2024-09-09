#!/usr/bin/env dart

import 'dart:async';

import 'package:args/args.dart';
import 'package:dev_build/package.dart';
import 'package:tekartik_pub/bin/src/pubbin_utils.dart';
import 'package:tekartik_pub/src/rpubpath.dart';

class PubFmtOptions extends PubBinOptions {
  bool? forceRecursive;
  bool? fix;
}

// chmod +x ...
Future main(List<String> arguments) async {
  final parser = ArgParser(allowTrailingOptions: true);
  parser.addFlag(argHelpFlag, abbr: 'h', help: 'Usage help', negatable: false);

  parser.addFlag(
    argForceRecursiveFlag,
    abbr: 'f',
    help: 'Force going recursive even in dart project',
    defaultsTo: true,
  );
  parser.addFlag(
    argFixFlag,
    abbr: 'x',
    help: 'Fix code',
    defaultsTo: true,
  );
  addCommonOptions(parser);

  final argResults = parser.parse(arguments);

  final help = argResults[argHelpFlag] as bool;
  if (help) {
    print(parser.usage);
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
        ..dryRun = dryRun);
}

Future<int> pubFmt(List<String> directories, PubFmtOptions options) async {
  final futures = <Future>[];
  final pkgPaths = await recursivePubPath(directories);

  for (final dir in pkgPaths) {
    // list of dir to check
    var targets = await findTargetDartDirectories(dir);
    if (targets.isEmpty) {
      continue;
    }
    var args = ['-w'];
    if (options.fix == true) {
      args.add('--fix');
    }
    args.addAll(targets);
    var future = packageRunCi(dir,
        options: PackageRunCiOptions(
            noPubGet: true,
            formatOnly: true,
            recursive: false,
            noOverride: true));
    if (options.oneByOne == true) {
      await future;
    } else {
      futures.add(future);
      await limitConcurrentTasks(futures);
    }
  }
  await Future.wait(futures);
  return futures.length;
}
