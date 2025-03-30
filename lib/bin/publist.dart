#!/usr/bin/env dart

import 'dart:async';

import 'package:args/args.dart';
import 'package:tekartik_pub/bin/src/pubbin_utils.dart';
import 'package:tekartik_pub/io.dart';
import 'package:tekartik_pub/pubspec_yaml.dart';

class PubListOptions extends PubBinOptions {
  bool? forceRecursive;
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
  addCommonOptions(parser);

  final argResults = parser.parse(arguments);

  final help = argResults[argHelpFlag] as bool;
  if (help) {
    print('List recursively pub package');
    print(parser.usage);
    return;
  }
  if (parseCommonOptions(argResults)) {
    return;
  }

  final oneByOne = argResults[argOneByOneFlag] as bool;
  final forceRecursive = argResults[argForceRecursiveFlag] as bool;
  final dryRun = argResults[argDryRunFlag] as bool;

  var rest = argResults.rest;
  // if no default to current folder
  if (rest.isEmpty) {
    rest = ['.'];
  }

  await pubList(
    rest,
    PubListOptions()
      ..oneByOne = oneByOne
      ..forceRecursive = forceRecursive
      ..dryRun = dryRun,
  );
}

Future pubList(List<String> directories, PubListOptions options) async {
  final pkgPaths = await recursivePubPath(directories);

  for (final dir in pkgPaths) {
    final pkg = PubPackage(dir);
    var pubspecYaml = PubspecYaml.fromMap(await pkg.getPubspecYamlMap());
    try {
      print(pubspecYaml);
    } catch (e) {
      print(pubspecYaml.name);
    }
    /*
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
    */
    if (options.oneByOne!) {
      // await future;
    }
  }
}
