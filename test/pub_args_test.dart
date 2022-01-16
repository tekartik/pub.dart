@TestOn('vm')
library tekartik_pub.test.pub_args_test;

import 'package:tekartik_pub/pub_args.dart';
import 'package:test/test.dart';

void main() => defineTests();

void defineTests() {
  //useVMConfiguration();
  group('pub_args', () {
    test('pubArgs', () {
      expect(pubArgs(), []);
      expect(pubArgs(help: true), ['--help']);
      expect(pubArgs(verbose: true), ['--verbose']);
    });

    test('pubBuildArgs', () {
      expect(pubBuildArgs(), ['build']);
      expect(pubBuildArgs(output: 'out'), ['build', '--output', 'out']);
      expect(pubBuildArgs(mode: BuildMode.debug), ['build', '--mode', 'debug']);
      expect(pubBuildArgs(mode: BuildMode.release),
          ['build', '--mode', 'release']);
      expect(pubBuildArgs(format: BuildFormat.json),
          ['build', '--format', 'json']);
      expect(pubBuildArgs(format: BuildFormat.text),
          ['build', '--format', 'text']);
      expect(pubBuildArgs(args: ['web']), ['build', 'web']);
      expect(pubBuildArgs(directories: ['web']), ['build', 'web']);
    });

    test('pubRunTestArgs', () {
      expect(pubRunTestArgs(), ['run', 'test']);
      expect(
          pubRunTestArgs(
              args: ['arg1', 'arg2'],
              platforms: ['platform1', 'platform2'],
              reporter: RunTestReporter.json,
              color: true,
              concurrency: 2,
              name: 'name'),
          [
            'run',
            'test',
            '-r',
            'json',
            '-j',
            '2',
            '-n',
            'name',
            '--color',
            '-p',
            'platform1',
            '-p',
            'platform2',
            'arg1',
            'arg2'
          ]);
    });

    test('pubRunTestRunnerArgs', () {
      expect(pubRunTestRunnerArgs(), []);
      expect(
          pubRunTestRunnerArgs(TestRunnerArgs(
              args: ['arg1', 'arg2'],
              platforms: ['platform1', 'platform2'],
              reporter: RunTestReporter.compact,
              color: true,
              concurrency: 2,
              name: 'name')),
          [
            '-r',
            'compact',
            '-j',
            '2',
            '-n',
            'name',
            '--color',
            '-p',
            'platform1',
            '-p',
            'platform2',
            'arg1',
            'arg2'
          ]);
    });

    test('runTestReporterFromString', () {
      expect(runTestReporterFromString('json'), RunTestReporter.json);
    });

    test('pubGetArgs', () {
      expect(pubGetArgs(), ['get']);
    });

    test('pubUpgradeArgs', () {
      expect(pubUpgradeArgs(), ['upgrade']);
    });
  });
}
