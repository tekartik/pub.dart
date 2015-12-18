import 'package:tekartik_pub/pub_fs_io.dart';

main() async {
  IoFsPubPackage pkg = new IoFsPubPackage(Directory.current);

  // Run all tests
  ProcessResult result = await pkg.runPub(pubRunTestArgs(),
      connectStdout: true, connectStderr: true);
  print('exitCode: ${result.exitCode}');
}
