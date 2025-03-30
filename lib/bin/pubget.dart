import 'dart:async';

import 'package:args/args.dart';
import 'package:dev_build/menu/menu_run_ci.dart';
import 'package:process_run/stdio.dart';
import 'package:tekartik_pub/bin/src/pub_workspace_cache.dart';
import 'package:tekartik_pub/bin/src/pubbin_utils.dart';
import 'package:tekartik_pub/io.dart';

class PubGetOptions extends PubBinOptions {
  bool? forceRecursive;
  bool? offline;
  bool? packagesDir;
  bool? verbose;
  bool? ignoreErrors;
}

// chmod +x ...
Future main(List<String> arguments) async {
  final parser = ArgParser(allowTrailingOptions: true);
  parser.addFlag(argHelpFlag, abbr: 'h', help: 'Usage help', negatable: false);

  parser.addFlag(argOfflineFlag, help: 'offline get', negatable: false);
  parser.addFlag(
    argForceRecursiveFlag,
    abbr: 'f',
    help: 'Force going recursive even in dart project',
    defaultsTo: true,
  );
  parser.addFlag(
    argIgnoreErrorsFlag,
    abbr: 'i',
    help: 'Ignore errors, all projects are processed',
    negatable: false,
  );
  parser.addFlag(
    argPackagesDirFlag,
    help: 'generates packages dir',
    negatable: false,
  );
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
  final ignoreErrors = argResults[argIgnoreErrorsFlag] as bool;

  var rest = argResults.rest;
  // if no default to current folder
  if (rest.isEmpty) {
    rest = ['.'];
  }

  initPubWorkspacesCache();
  await pubGet(
    rest,
    PubGetOptions()
      ..oneByOne = oneByOne
      ..forceRecursive = forceRecursive
      ..packagesDir = packagesDir
      ..offline = offline
      ..verbose = verbose
      ..dryRun = dryRun
      ..ignoreErrors = ignoreErrors,
  );
}

Future pubGet(List<String> directories, PubGetOptions options) async {
  final pkgPaths = await recursivePubPath(directories);

  if (options.verbose == true) {
    print('found package(s): $pkgPaths');
  }
  var offline = options.offline ?? false;
  var futures = <Future>[];
  for (final dir in pkgPaths) {
    var pubIoPackage = PubIoPackage(dir);
    await pubIoPackage.ready;

    if (pubWorkspacesCache != null &&
        (pubIoPackage.hasWorkspaceResolution || pubIoPackage.isWorkspace)) {
      var root = await pubIoPackage.getWorkspaceRootPath();
      var cache = PubWorkspaceCache(root, PubWorkspaceCacheAction.get, offline);
      if (!pubWorkspacesCache!.cacheIfNeeded(cache)) {
        continue;
      }
    }

    var future = () async {
      await shellStdioLinesGrouper.runZoned(() async {
        try {
          await pubIoPackage.pubGet(offline: offline);
        } catch (e) {
          stderr.writeln('Error in $pubIoPackage: $e');
          if (options.ignoreErrors ?? false) {
            // ok
          } else {
            rethrow;
          }
        }
      });
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
