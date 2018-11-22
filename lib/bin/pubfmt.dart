#!/usr/bin/env dart
import 'dart:io';
import 'package:args/args.dart';
import 'package:tekartik_pub/bin/src/pubbin_utils.dart';
import 'package:tekartik_pub/io.dart';
import 'package:process_run/cmd_run.dart' hide runCmd;
import 'pubget.dart';

class PubFmtOptions {
  bool forceRecursive;
  bool oneByOne;
}

// chmod +x ...
main(List<String> arguments) async {
  ArgParser parser = ArgParser(allowTrailingOptions: true);
  parser.addFlag(argHelp, abbr: 'h', help: 'Usage help', negatable: false);
  parser.addFlag(argOneByOne,
      abbr: 'o', help: 'One at a time', defaultsTo: Platform.isWindows);
  parser.addFlag(argForceRecursive,
      abbr: 'f',
      help: 'Force going recursive even in dart project',
      negatable: false);

  ArgResults argResults = parser.parse(arguments);

  bool help = argResults[argHelp] as bool;
  if (help) {
    print(parser.usage);
    return;
  }

  bool oneByOne = argResults[argOneByOne];
  bool forceRecursive = argResults[argForceRecursive];
  List<String> rest = argResults.rest;
  // if no default to current folder
  if (rest.length == 0) {
    rest = ['.'];
  }
  await pubFmt(
      rest,
      PubFmtOptions()
        ..oneByOne = oneByOne
        ..forceRecursive = forceRecursive);
}

pubFmt(List<String> directories, PubFmtOptions options) async {
  List<String> pkgPaths = [];
  // Also Handle recursive projects
  await recursivePubPath(directories, forceRecursive: options.forceRecursive)
      .listen((String dir) {
    pkgPaths.add(dir);
  }).asFuture();

  for (String dir in pkgPaths) {
    ProcessCmd cmd = DartFmtCmd(['-w', dir]);
    var future = runCmd(cmd, oneByOne: options.oneByOne);
    if (options.oneByOne) {
      await future;
    }
  }
}
