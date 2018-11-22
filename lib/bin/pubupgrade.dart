#!/usr/bin/env dart
import 'dart:io';
import 'package:args/args.dart';
import 'package:tekartik_pub/io.dart';
import 'package:tekartik_pub/bin/src/pubbin_utils.dart';
import 'pubget.dart';

// chmod +x ...
main(List<String> arguments) async {
  ArgParser parser = ArgParser(allowTrailingOptions: true);
  parser.addFlag(argHelp, abbr: 'h', help: 'Usage help', negatable: false);
  parser.addFlag(argOneByOne,
      abbr: 'o', help: 'One at a time', defaultsTo: Platform.isWindows);
  parser.addFlag(argOffline, help: 'offline get', negatable: false);
  parser.addFlag(argForceRecursive,
      abbr: 'f',
      help: 'Force going recursive even in dart project',
      negatable: false);
  parser.addFlag(argPackagesDir,
      help: 'generates packages dir', negatable: false);

  ArgResults argResults = parser.parse(arguments);

  bool help = argResults[argHelp] as bool;
  if (help) {
    print(parser.usage);
    return;
  }

  bool oneByOne = argResults[argOneByOne];
  bool offline = argResults[argOffline];
  bool packagesDir = argResults[argPackagesDir];
  bool forceRecursive = argResults[argForceRecursive];

  List<String> rest = argResults.rest;
  // if no default to current folder
  if (rest.length == 0) {
    rest = ['.'];
  }

  await pubUpgrade(
      rest,
      PubGetOptions()
        ..oneByOne = oneByOne
        ..forceRecursive = forceRecursive
        ..packagesDir = packagesDir
        ..offline = offline);
}

pubUpgrade(List<String> directories, PubGetOptions options) async {
  List<String> pkgPaths = [];
  // Also Handle recursive projects
  await recursivePubPath(directories, forceRecursive: options.forceRecursive)
      .listen((String dir) {
    pkgPaths.add(dir);
  }).asFuture();

  for (String dir in pkgPaths) {
    PubPackage pkg = PubPackage(dir);
    ProcessCmd cmd;
    if (await isFlutterPackageRoot(dir)) {
      if (!isFlutterSupported) {
        continue;
      }
      cmd = FlutterCmd(['packages', 'upgrade'])..workingDirectory = dir;
    } else {
      cmd = pkg.pubCmd(pubUpgradeArgs(
          offline: options.offline, packagesDir: options.packagesDir));
    }

    var future = runCmd(cmd, oneByOne: options.oneByOne);
    if (options.oneByOne) {
      await future;
    }
  }
}
