@TestOn('vm')
library;

import 'package:path/path.dart';
import 'package:tekartik_common_utils/common_utils_import.dart';
import 'package:tekartik_pub/bin/pubfmt.dart';
import 'package:tekartik_pub/bin/src/pubbin_utils.dart';
import 'package:test/test.dart';

ProcessCmd binCmd(String bin, List<String> arguments) {
  return DartCmd([join('example', 'bin', '$bin.dart'), ...arguments]);
}

Future<String?> runOutput(ProcessCmd cmd) async {
  return (await runCmd(cmd))!.stdout?.toString();
}

void main() {
  group('bin', () {
    test('pubfmt', () async {
      expect(await pubFmt(['.'], PubFmtOptions()..forceRecursive = true), 2);
    });

    test('version', () async {
      //expect(parseVersion(await runOutput(binCmd('publist', ['--version']))),
      //  binVersion);
    });
  });
}
