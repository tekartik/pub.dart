// 2016-09-25
import 'dart:async';
import 'dart:io';

import 'package:path/path.dart';
import 'package:process_run/cmd_run.dart';
import 'package:tekartik_pub/io.dart';

Future main() async {
  final pkg = PubPackage(Directory.current.path);

  // Run all tests
  final result = await runCmd(
      pkg.pubCmd(
          pubBuildArgs(directories: [join('example_packages', 'simple')])),
      verbose: true);
  print('exitCode: ${result.exitCode}');
}
