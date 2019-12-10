#!/usr/bin/env dart
import 'dart:async';

import 'package:args/args.dart';
import 'package:tekartik_pub/bin/src/pubbin_utils.dart';
import 'package:tekartik_pub/io.dart';

class PubGetOptions extends PubBinOptions {
  bool forceRecursive;
  bool offline;
  bool packagesDir;
  bool verbose;
}

// chmod +x ...
Future main(List<String> arguments) async {
  final parser = ArgParser(allowTrailingOptions: true);
  parser.addFlag(argHelpFlag, abbr: 'h', help: 'Usage help', negatable: false);

  parser.addFlag(argOfflineFlag, help: 'offline get', negatable: false);
  parser.addFlag(argForceRecursiveFlag,
      abbr: 'f',
      help: 'Force going recursive even in dart project',
      defaultsTo: true);
  parser.addFlag(argPackagesDirFlag,
      help: 'generates packages dir', negatable: false);
  addCommonOptions(parser);

  final argResults = parser.parse(arguments);

  var help = argResults[argHelpFlag] as bool;
  if (help) {
    print(parser.usage);
    return;
  }
  if (parseCommonOptions(argResults)) {
    return;
  }

  final oneByOne = argResults[argOneByOneFlag] as bool;
  final offline = argResults[argOfflineFlag] as bool;
  final packagesDir = argResults[argPackagesDirFlag] as bool;
  final forceRecursive = argResults[argForceRecursiveFlag] as bool;
  final dryRun = argResults[argDryRunFlag] as bool;
  final verbose = argResults[argVerboseFlag] as bool;

  var rest = argResults.rest;
  // if no default to current folder
  if (rest.isEmpty) {
    rest = ['.'];
  }

  await pubGet(
      rest,
      PubGetOptions()
        ..oneByOne = oneByOne
        ..forceRecursive = forceRecursive
        ..packagesDir = packagesDir
        ..offline = offline
        ..verbose = verbose
        ..dryRun = dryRun);
}

Future pubGet(List<String> directories, PubGetOptions options) async {
  final pkgPaths = <String>[];
  // Also Handle recursive projects
  await recursivePubPath(directories, forceRecursive: options.forceRecursive)
      .listen((String dir) {
    pkgPaths.add(dir);
  }).asFuture();

  if (options.verbose == true) {
    print('found package(s): ${pkgPaths}');
  }
  for (final dir in pkgPaths) {
    final pkg = PubPackage(dir);
    ProcessCmd cmd;
    if (await isFlutterPackageRoot(dir)) {
      if (!isFlutterSupported) {
        continue;
      }
      cmd = FlutterCmd(['packages', 'get'])..workingDirectory = dir;
    } else {
      cmd = pkg.pubCmd(pubGetArgs(
          offline: options.offline, packagesDir: options.packagesDir));
    }
    var future = runCmd(cmd, options: options);
    if (options.oneByOne) {
      await future;
    }
  }
}
