#!/usr/bin/env dart
import 'package:args/args.dart';
import 'package:process_run/cmd_run.dart' hide runCmd;
import 'package:tekartik_common_utils/common_utils_import.dart';
import 'package:tekartik_pub/bin/src/pubbin_utils.dart';
import 'package:tekartik_pub/io.dart';
import 'package:tekartik_pub/src/rpubpath.dart';

class PubAnalyzeOptions extends PubBinOptions {
  bool forceRecursive;
  bool fatalInfos;
}

const String argFatalInfosFlag = "fatal-infos";

// chmod +x ...
Future main(List<String> arguments) async {
  ArgParser parser = ArgParser(allowTrailingOptions: true);
  parser.addFlag(argHelpFlag, abbr: 'h', help: 'Usage help', negatable: false);

  parser.addFlag(argForceRecursiveFlag,
      abbr: 'f',
      help: 'Force going recursive even in dart project',
      defaultsTo: true);
  parser.addFlag(argFatalInfosFlag,
      help: 'Treat infos as fatal', defaultsTo: true);
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
  bool fatalInfos = argResults[argFatalInfosFlag];

  List<String> rest = argResults.rest;
  // if no default to current folder
  if (rest.isEmpty) {
    rest = ['.'];
  }
  await pubAnalyze(
      rest,
      PubAnalyzeOptions()
        ..oneByOne = oneByOne
        ..forceRecursive = forceRecursive
        ..fatalInfos = fatalInfos
        ..dryRun = dryRun);
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
      cmd = FlutterCmd(['analyze'])..workingDirectory = dir;
    } else {
      // list of dir to check
      var targets = await findTargetDartDirectories(dir);
      if (targets.isEmpty) {
        continue;
      }
      var args = ['--fatal-warnings'];
      if (options?.fatalInfos != false) {
        args.add('--fatal-infos');
      }
      args.addAll(targets);
      cmd = DartAnalyzerCmd(args)..workingDirectory = dir;
      /*
      cmd = DartAnalyzerCmd()pkg
          .pubCmd(pubUpgradeArgs(offline: options.offline, packagesDir: options.packagesDir));
          */
      //continue;
    }

    var future = runCmd(cmd, options: options);
    if (options.oneByOne == true) {
      await future;
    }
    futures.add(future);
  }
  await Future.wait(futures);
  return futures.length;
}
