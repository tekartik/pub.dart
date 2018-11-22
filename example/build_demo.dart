// 2016-09-25
import 'package:path/path.dart';
import 'package:tekartik_pub/io.dart';
import 'dart:io';
import 'package:process_run/cmd_run.dart';

main() async {
  PubPackage pkg = PubPackage(Directory.current.path);

  // Run all tests
  ProcessResult result = await runCmd(
      pkg.pubCmd(
          pubBuildArgs(directories: [join('example_packages', 'simple')])),
      verbose: true);
  print('exitCode: ${result.exitCode}');
}
