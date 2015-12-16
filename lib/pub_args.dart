library tekartik_io_tools.pub_args;

enum TestReporter { COMPACT, EXPANDED }

final Map<String, TestReporter> _testReporterMap = new Map.fromIterables(
    ["compact", "expanded"], [TestReporter.COMPACT, TestReporter.EXPANDED]);

final Map<TestReporter, String> _testReporterStringMap =
    new Map.fromIterables(_testReporterMap.values, _testReporterMap.keys);

String testReporterString(TestReporter reporter) =>
    _testReporterStringMap[reporter];

List<String> testReporterStrings = new List.from(_testReporterStringMap.values);
TestReporter testReporterFromString(String reporterString) =>
    _testReporterMap[reporterString];

const String pubBuildFormatRelease = "release";
const String pubBuildFormatDebug = "debug";

/// list of argument for pubCmd
Iterable<String> pubBuildArgs(
    {Iterable<String> args, String mode, String format, String output}) {
  List<String> buildArgs = ['build'];
  // --mode      Mode to run transformers in.
  //    (defaults to "release")
  if (mode != null) {
    buildArgs.addAll(['--mode', mode]);
  }
  // --format    How output should be displayed.
  // [text (default), json]
  if (format != null) {
    buildArgs.addAll(['--format', format]);
  }
  // -o, --output    Directory to write build outputs to.
  // (defaults to "build")
  if (output != null) {
    buildArgs.addAll(['--output', output]);
  }
  if (args != null) {
    buildArgs.addAll(args);
  }

  return buildArgs;
}

Iterable<String> pubGetArgs({bool offline, bool dryRun}) {
  List<String> args = ['get'];
  if (offline == true) {
    args.add('--offline');
  }
  if (dryRun == true) {
    args.add('--dry-run');
  }
  return args;
}

Iterable<String> pubUpgradeArgs({bool offline, bool dryRun}) {
  List<String> args = ['upgrade'];
  if (offline == true) {
    args.add('--offline');
  }
  if (dryRun == true) {
    args.add('--dry-run');
  }
  return args;
}

/// list of argument for pubCmd
Iterable<String> pubRunTestArgs(
    {Iterable<String> args,
    TestReporter reporter,
    bool color,
    int concurrency,
    List<String> platforms,
    String name}) {
  List<String> testArgs = ['run', 'test'];
  if (reporter != null) {
    testArgs.addAll(['-r', testReporterString(reporter)]);
  }
  if (concurrency != null) {
    testArgs.addAll(['-j', concurrency.toString()]);
  }
  if (name != null) {
    testArgs.addAll(['-n', name]);
  }
  if (color != null) {
    if (color) {
      testArgs.add('--color');
    } else {
      testArgs.add('--no-color');
    }
  }
  if (platforms != null) {
    for (String platform in platforms) {
      testArgs.addAll(['-p', platform]);
    }
  }
  if (args != null) {
    testArgs.addAll(args);
  }
  return (testArgs);
}
