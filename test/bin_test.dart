@TestOn("vm")
library tekartik_pub.test.bin_pubanalyze_test;

import 'package:tekartik_pub/bin/pubfmt.dart';
import 'package:test/test.dart';
import 'package:tekartik_pub/bin/pubanalyze.dart';

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
  });
}
