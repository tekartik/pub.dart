import 'dart:async';

import 'package:args/args.dart';
import 'package:dev_build/menu/menu_run_ci.dart';
import 'package:path/path.dart';
import 'package:process_run/stdio.dart';
import 'package:tekartik_pub/bin/pubget.dart' show PubGetOptions;
import 'package:tekartik_pub/bin/src/pub_workspace_cache.dart';
import 'package:tekartik_pub/bin/src/pubbin_utils.dart';
import 'package:tekartik_pub/io.dart';

/// The argument parser shared by `pubget` and `pubupgrade`.
ArgParser pubActionArgParser() {
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
  // Obsolete since Dart 2 (no more packages dir), still accepted.
  parser.addFlag(
    argPackagesDirFlag,
    help: 'Obsolete, ignored',
    negatable: false,
    hide: true,
  );

  addCommonOptions(parser);
  return parser;
}

/// The `main` of `pubget` and `pubupgrade`.
Future<void> pubActionMain(
  List<String> arguments,
  PubWorkspaceCacheAction action,
) async {
  final parser = pubActionArgParser();
  final argResults = parser.parse(arguments);

  var help = argResults[argHelpFlag] as bool;
  if (help) {
    stdout.writeln(parser.usage);
    return;
  }
  if (parseCommonOptions(argResults)) {
    return;
  }

  var rest = argResults.rest;
  // if no default to current folder
  if (rest.isEmpty) {
    rest = ['.'];
  }

  initPubWorkspacesCache();
  await runPubAction(
    rest,
    PubGetOptions()
      ..oneByOne = argResults[argOneByOneFlag] as bool
      ..forceRecursive = argResults[argForceRecursiveFlag] as bool
      ..packagesDir = argResults[argPackagesDirFlag] as bool
      ..offline = argResults[argOfflineFlag] as bool
      ..verbose = argResults[argVerboseFlag] as bool
      ..dryRun = argResults[argDryRunFlag] as bool
      ..ignoreErrors = argResults[argIgnoreErrorsFlag] as bool,
    action,
  );
}

/// The package paths to handle in [directories].
///
/// Unless [forceRecursive] is false, sub packages of a package are included.
Future<List<String>> pubBinPackagePaths(
  List<String> directories, {
  bool? forceRecursive,
}) async {
  if (forceRecursive ?? true) {
    return await recursivePubPath(directories);
  }
  var paths = <String>[];
  var others = <String>[];
  for (var directory in directories) {
    if (await isPubPackageRoot(directory)) {
      paths.add(directory);
    } else {
      others.add(directory);
    }
  }
  if (others.isNotEmpty) {
    paths.addAll(await recursivePubPath(others));
  }
  return paths;
}

/// Run `pub get` or `pub upgrade` on the packages found in [directories].
///
/// In dry run mode the commands are only printed.
Future<void> runPubAction(
  List<String> directories,
  PubGetOptions options,
  PubWorkspaceCacheAction action,
) async {
  final pkgPaths = await pubBinPackagePaths(
    directories,
    forceRecursive: options.forceRecursive,
  );

  if (options.verbose == true) {
    stdout.writeln('found package(s): $pkgPaths');
  }
  var offline = options.offline ?? false;
  var dryRun = options.dryRun ?? false;
  var futures = <Future<void>>[];
  for (final dir in pkgPaths) {
    var pubIoPackage = PubIoPackage(dir);
    await pubIoPackage.ready;

    if (pubWorkspacesCache != null &&
        (pubIoPackage.hasWorkspaceResolution || pubIoPackage.isWorkspace)) {
      var root = await pubIoPackage.getWorkspaceRootPath();
      var cache = PubWorkspaceCache(root, action, offline);
      if (!pubWorkspacesCache!.cacheIfNeeded(cache)) {
        continue;
      }
    }

    var packagePath = normalize(absolute(pubIoPackage.path));
    var future = () async {
      await shellStdioLinesGrouper.runZoned(() async {
        stdout.writeln('# $packagePath');
        var command =
            '${pubIoPackage.dofPub} ${action.name}'
            '${offline ? ' --offline' : ''}';
        if (dryRun) {
          stdout.writeln('\$ $command');
          return;
        }
        try {
          switch (action) {
            case PubWorkspaceCacheAction.get:
              await pubIoPackage.pubGet(offline: offline);
            case PubWorkspaceCacheAction.upgrade:
              await pubIoPackage.pubUpgrade(offline: offline);
            case PubWorkspaceCacheAction.downgrade:
              await pubIoPackage.shell.run(command);
          }
        } catch (e) {
          stderr.writeln('Error in $packagePath: $e');
          if (options.ignoreErrors ?? false) {
            // ok
          } else {
            rethrow;
          }
        }
      });
    }();
    if (options.oneByOne == true) {
      await future;
    } else {
      futures.add(future);

      await limitConcurrentTasks(futures);
    }
  }
  await Future.wait(futures);
}
