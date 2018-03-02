#!/usr/bin/env dart
import 'dart:io';
import 'package:args/args.dart';
import 'package:tekartik_pub/io.dart';
import 'package:process_run/cmd_run.dart';

const String argHelp = 'help';
const String argOneByOne = 'one';
const String argOffline = "offline";
const String argPackagesDir = "packages-dir";

// chmod +x ...
main(List<String> arguments) async {
  ArgParser parser = new ArgParser(allowTrailingOptions: true);
  parser.addFlag(argHelp, abbr: 'h', help: 'Usage help', negatable: false);
  parser.addFlag(argOneByOne,
      abbr: 'o', help: 'One at a time', defaultsTo: Platform.isWindows);
  parser.addFlag(argOffline, help: 'offline get', negatable: false);
  parser.addFlag(argPackagesDir,
      help: 'generates packages dir', negatable: false);

  ArgResults argResults = parser.parse(arguments);

  bool help = argResults[argHelp] as bool;
  if (help) {
    print(parser.usage);
    return;
  }

  bool oneByOne = argResults[argOneByOne] as bool;
  bool offline = argResults[argOffline] as bool;
  bool packagesDir = argResults[argPackagesDir] as bool;

  List<String> rest = argResults.rest;
  // if no default to current folder
  if (rest.length == 0) {
    rest = ['.'];
  }

  List<String> pkgPaths = [];
  // Also Handle recursive projects
  await recursivePubPath(rest).listen((String dir) {
    pkgPaths.add(dir);
  }).asFuture();

  for (String dir in pkgPaths) {
    PubPackage pkg = new PubPackage(dir);
    ProcessCmd cmd =
        pkg.pubCmd(pubGetArgs(offline: offline, packagesDir: packagesDir));

    if (oneByOne) {
      await runCmd(cmd, verbose: true);
    } else {
      runCmd(cmd).then((ProcessResult result) {
        stdout.writeln('\$ $cmd');
        stdout.write(result.stdout);
        stderr.write(result.stderr);
      });
    }
  }
}
