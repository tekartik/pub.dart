@TestOn('vm')
library tekartik_pub.test.bin_pubanalyze_test;

import 'package:path/path.dart';
import 'package:process_run/cmd_run.dart' hide runCmd;
import 'package:tekartik_common_utils/common_utils_import.dart';
import 'package:tekartik_pub/bin/pubanalyze.dart';
import 'package:tekartik_pub/bin/pubfmt.dart';
import 'package:tekartik_pub/bin/src/pubbin_utils.dart';
import 'package:test/test.dart';

ProcessCmd binCmd(String bin, List<String> arguments) {
  return DartCmd([join('bin', '$bin.dart'), ...arguments]);
}

Future<String> runOutput(ProcessCmd cmd) async {
  return (await runCmd(cmd)).stdout?.toString();
}

void main() {
  group('bin', () {
    test('pubanalyze', () async {
      expect(
          await pubAnalyze(['.'], PubAnalyzeOptions()..forceRecursive = true),
          2);
    });
    test('pubfmt', () async {
      expect(await pubFmt(['.'], PubFmtOptions()..forceRecursive = true), 2);
    });
    test('pubList', () async {
      expect(await pubFmt(['.'], PubFmtOptions()..forceRecursive = true), 2);
    });

    test('version', () async {
      //expect(parseVersion(await runOutput(binCmd('publist', ['--version']))),
      //  binVersion);
    });
  });
}
