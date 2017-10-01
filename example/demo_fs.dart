import 'package:tekartik_pub/src/pub_fs_io.dart';
import 'package:process_run/cmd_run.dart';

main() async {
  IoFsPubPackage pkg = new IoFsPubPackage(Directory.current);

  // Run all tests
  ProcessResult result = await runCmd(
      pkg.pubCmd(pubRunTestArgs(reporter: pubRunTestReporterExpanded)),
      verbose: true);
  print('exitCode: ${result.exitCode}');
}
