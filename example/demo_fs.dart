import 'dart:async';

import 'package:process_run/cmd_run.dart';
import 'package:tekartik_pub/src/pub_fs_io.dart';

Future main() async {
  final pkg = IoFsPubPackage(Directory.current);

  // Run all tests
  final result = await runCmd(
      pkg.pubCmd(pubRunTestArgs(reporter: RunTestReporter.expanded)),
      verbose: true);
  print('exitCode: ${result.exitCode}');
}
