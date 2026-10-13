#!/usr/bin/env dart

import 'dart:async';

import 'package:tekartik_pub/bin/src/pub_action.dart';
import 'package:tekartik_pub/bin/src/pub_workspace_cache.dart';

import 'pubget.dart';

// chmod +x ...
Future<void> main(List<String> arguments) =>
    pubActionMain(arguments, PubWorkspaceCacheAction.upgrade);

/// Run the pub upgrade command on the given directories.
///
/// In dry run mode the commands are only printed.
Future<void> pubUpgrade(List<String> directories, PubGetOptions options) =>
    runPubAction(directories, options, PubWorkspaceCacheAction.upgrade);
