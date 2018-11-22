@TestOn("vm")
library tekartik_pub.test.bin_pubanalyze_test;

import 'package:test/test.dart';
import 'package:tekartik_pub/bin/pubanalyze.dart';

void main() {
  group('bin', () {
    test('pubanalyze', () async {
      expect(
          await pubAnalyze(['.'], PubAnalyzeOptions()..forceRecursive = true),
          2);
    });
  });
}
