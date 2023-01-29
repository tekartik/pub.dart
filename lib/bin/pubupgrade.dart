#!/usr/bin/env dart

import 'dart:async';
import 'dart:io';

import 'package:args/args.dart';
import 'package:tekartik_pub/bin/src/pubbin_utils.dart';
import 'package:tekartik_pub/io.dart';

import 'pubget.dart';

// chmod +x ...
Future main(List<String> arguments) async {
  final parser = ArgParser(allowTrailingOptions: true);
  parser.addFlag(argHelpFlag, abbr: 'h', help: 'Usage help', negatable: false);
  addCommonOptions(parser);
  parser.addFlag(argOfflineFlag, help: 'offline get', negatable: false);
  parser.addFlag(argForceRecursiveFlag,
      abbr: 'f',
      help: 'Force going recursive even in dart project',
      defaultsTo: true);
  parser.addFlag(argPackagesDirFlag,
      help: 'generates packages dir', negatable: false);
  parser.addFlag(argIgnoreErrorsFlag,
      abbr: 'i',
      help: 'Ignore errors, all projects are processed',
      negatable: false);
  final argResults = parser.parse(arguments);

  final help = argResults[argHelpFlag] as bool;
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
  var rest = argResults.rest;
  final verbose = argResults[argVerboseFlag] as bool;
  final ignoreErrors = argResults[argIgnoreErrorsFlag] as bool;

  // if no default to current folder
  if (rest.isEmpty) {
    rest = ['.'];
  }

  await pubUpgrade(
      rest,
      PubGetOptions()
        ..oneByOne = oneByOne
        ..forceRecursive = forceRecursive
        ..packagesDir = packagesDir
        ..offline = offline
        ..dryRun = dryRun
        ..verbose = verbose
        ..ignoreErrors = ignoreErrors);
}

Future pubUpgrade(List<String> directories, PubGetOptions options) async {
  final pkgPaths = <String>[];
  // Also Handle recursive projects
  await recursivePubPath(directories, forceRecursive: options.forceRecursive)
      .listen((String dir) {
    pkgPaths.add(dir);
  }).asFuture<void>();
  var futures = <Future>[];
  for (final dir in pkgPaths) {
    final pkg = PubPackage(dir);
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

    var future = () async {
      try {
        await runCmd(cmd, options: options);
      } catch (e) {
        stderr.writeln('Error in $pkg: $e');
        if (options.ignoreErrors ?? false) {
          // ok
        } else {
          rethrow;
        }
      }
    }();

    if (options.oneByOne!) {
      await future;
    } else {
      futures.add(future);
      await limitConcurrentTasks(futures);
    }
  }
  await Future.wait(futures);
}
