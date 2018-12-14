#!/usr/bin/env dart
import 'package:args/args.dart';
import 'package:process_run/cmd_run.dart' hide runCmd;
import 'package:tekartik_pub/bin/src/pubbin_utils.dart';
import 'package:tekartik_pub/io.dart';
import 'package:tekartik_pub/src/rpubpath.dart';
import 'dart:async';

class PubFmtOptions extends PubBinOptions {
  bool forceRecursive;
  bool oneByOne;
  bool fix;
}

// chmod +x ...
main(List<String> arguments) async {
  ArgParser parser = ArgParser(allowTrailingOptions: true);
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

  ArgResults argResults = parser.parse(arguments);

  bool help = argResults[argHelpFlag] as bool;
  if (help) {
    print(parser.usage);
    return;
  }
  if (parseCommonOptions(argResults)) {
    return;
  }

  bool oneByOne = argResults[argOneByOneFlag];
  bool forceRecursive = argResults[argForceRecursiveFlag];
  bool dryRun = argResults[argDryRunFlag];

  List<String> rest = argResults.rest;
  // if no default to current folder
  if (rest.length == 0) {
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
  List<Future> futures = [];
  List<String> pkgPaths = [];
  // Also Handle recursive projects
  await recursivePubPath(directories, forceRecursive: options.forceRecursive)
      .listen((String dir) {
    pkgPaths.add(dir);
  }).asFuture();

  for (String dir in pkgPaths) {
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
    var cmd = DartFmtCmd(args)..workingDirectory = dir;
    var future = runCmd(cmd, options: options);
    if (options.oneByOne == true) {
      await future;
    }
    futures.add(future);
  }
  await Future.wait(futures);
  return futures.length;
}
