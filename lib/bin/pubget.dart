#!/usr/bin/env dart
import 'dart:io';

import 'package:args/args.dart';
import 'package:process_run/cmd_run.dart';
import 'package:tekartik_pub/io.dart';

const String argHelp = 'help';
const String argOneByOne = 'one';
const String argOffline = "offline";
const String argPackagesDir = "packages-dir";
const String argForceRecursive = "force-recursive";

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

  List<String> pkgPaths = [];
  // Also Handle recursive projects
  await recursivePubPath(rest, forceRecursive: forceRecursive)
      .listen((String dir) {
    pkgPaths.add(dir);
  }).asFuture();

  for (String dir in pkgPaths) {
    PubPackage pkg = PubPackage(dir);
    ProcessCmd cmd;
    if (await isFlutterPackageRoot(dir) && isFlutterSupported) {
      cmd = FlutterCmd(['packages', 'get']);
    } else {
      cmd = pkg.pubCmd(pubGetArgs(offline: offline, packagesDir: packagesDir));
    }

    if (oneByOne) {
      stdout.writeln('[$dir]');
      var result = await runCmd(cmd, verbose: true);
      if (result.exitCode != 0) {
        exit(result.exitCode);
      }
    } else {
      runCmd(cmd).then((ProcessResult result) {
        stdout.writeln('[$dir]');
        stdout.writeln('\$ $cmd');
        stdout.write(result.stdout);
        stderr.write(result.stderr);
        if (result.exitCode != 0) {
          exit(result.exitCode);
        }
      });
    }
  }
}
