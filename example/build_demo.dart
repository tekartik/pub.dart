import 'dart:async';
import 'dart:io';

import 'package:process_run/cmd_run.dart';
import 'package:tekartik_pub/io.dart';

/// `dart run build_runner build` in the current package (`pub build` and
/// `pubBuildArgs` are gone since Dart 2).
Future<void> main() async {
  final pkg = PubPackage(Directory.current.path);

  final result = await runCmd(
    pkg.pbrCmd(['build', '--delete-conflicting-outputs']),
    verbose: true,
  );
  stdout.writeln('exitCode: ${result.exitCode}');
}
