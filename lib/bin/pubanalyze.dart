#!/usr/bin/env dart
import 'dart:io';
import 'package:args/args.dart';
import 'package:path/path.dart';
import 'package:tekartik_common_utils/common_utils_import.dart';
import 'package:tekartik_pub/bin/src/pubbin_utils.dart';
import 'package:tekartik_pub/io.dart';
import 'package:process_run/cmd_run.dart' hide runCmd;
import 'package:tekartik_pub/src/rpubpath.dart';
import 'pubget.dart';

class PubAnalyzeOptions {
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
  await pubAnalyze(
      rest,
      PubAnalyzeOptions()
        ..oneByOne = oneByOne
        ..forceRecursive = forceRecursive);
}

Future<int> pubAnalyze(
    List<String> directories, PubAnalyzeOptions options) async {
  List<Future> futures = [];
  List<String> pkgPaths = [];
  // Also Handle recursive projects
  await recursivePubPath(directories, forceRecursive: options.forceRecursive)
      .listen((String dir) {
    pkgPaths.add(dir);
  }).asFuture();

  for (String dir in pkgPaths) {
    ProcessCmd cmd;

    if (await isFlutterPackageRoot(dir)) {
      if (!isFlutterSupported) {
        continue;
      }
      cmd = FlutterCmd(['analyze']);
    } else {
      // list of dir to check
      var targets = <String>[];
      for (var entity
          in await Directory(dir).list(followLinks: false).toList()) {
        var entityBasename = basename(entity.path);
        var subDir = join(dir, entityBasename);
        if (FileSystemEntity.isDirectorySync(subDir)) {
          bool _isToBeIgnored(String baseName) {
            if (baseName == '.' || baseName == '..') {
              return false;
            }

            return baseName.startsWith('.');
          }

          if (!_isToBeIgnored(entityBasename)) {
            var paths = (await recursiveDartEntities(subDir))
                .map((path) => join(subDir, path))
                .toList(growable: false);

            if (containsPubPackage(paths)) {
              continue;
            }
            if (!containsDartFiles(paths)) {
              continue;
            }
            // devPrint('$subDir sub: ${listTruncate(paths, 100)}');
            targets.add(entityBasename);
          }

          //devPrint(entities);
        }
        if (targets.isEmpty) {
          continue;
        }
        cmd = DartAnalyzerCmd(['--fatal-warnings']..addAll(targets))
          ..workingDirectory = dir;
      }
      /*
      cmd = DartAnalyzerCmd()pkg
          .pubCmd(pubUpgradeArgs(offline: options.offline, packagesDir: options.packagesDir));
          */
      //continue;
    }

    var future = runCmd(cmd, oneByOne: options.oneByOne == true);
    if (options.oneByOne == true) {
      await future;
    }
    futures.add(future);
  }
  await Future.wait(futures);
  return futures.length;
}
