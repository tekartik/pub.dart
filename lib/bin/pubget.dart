import 'dart:async';

import 'package:tekartik_pub/bin/src/pub_action.dart';
import 'package:tekartik_pub/bin/src/pub_workspace_cache.dart';
import 'package:tekartik_pub/bin/src/pubbin_utils.dart';

/// Options for the `pubget` command.
class PubGetOptions extends PubBinOptions {
  /// Force recursive search even in a Dart project.
  bool? forceRecursive;

  /// Whether to run pub get offline.
  bool? offline;

  /// Obsolete since Dart 2 (no more packages directory), ignored.
  bool? packagesDir;

  /// Enable verbose output.
  bool? verbose;

  /// Ignore errors and continue processing all projects.
  bool? ignoreErrors;
}

// chmod +x ...
Future<void> main(List<String> arguments) =>
    pubActionMain(arguments, PubWorkspaceCacheAction.get);

/// Run the pub get command on the given directories.
///
/// In dry run mode the commands are only printed.
Future<void> pubGet(List<String> directories, PubGetOptions options) =>
    runPubAction(directories, options, PubWorkspaceCacheAction.get);
