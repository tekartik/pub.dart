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

Iterable<String> pubArgs(
    {Iterable<String> args, bool version, bool help, bool verbose}) {
  List<String> pubArgs = [];
  // --version          Print pub version.

  if (version == true) {
    pubArgs.add('--version');
  }
  // --help             Print this usage information.
  if (help == true) {
    pubArgs.add('--help');
  }
  // --verbose          Shortcut for "--verbosity=all".
  if (verbose == true) {
    pubArgs.add('--verbose');
  }
  if (args != null) {
    pubArgs.addAll(args);
  }

  return pubArgs;
}

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

const pubDepsStyleCompact = "compact";
const pubDepsStyleTree = "tree";
const pubDepsStyleList = "list";

Iterable<String> pubDepsArgs({Iterable<String> args, String style}) {
  List<String> depsArgs = ['deps'];
  if (style != null) {
    depsArgs.addAll(['--style', style]);
  }
  if (args != null) {
    depsArgs.addAll(args);
  }
  return (depsArgs);
}

const pubRunTestReporterJson = "json";
const pubRunTestReporterExpanded = "expanded";
const pubRunTestReporterCompact = "compact";

List<String> pubRunTestReporters = [
  pubRunTestReporterCompact,
  pubRunTestReporterExpanded,
  pubRunTestReporterJson
];

/// list of argument for pubCmd
Iterable<String> pubRunTestArgs(
    {Iterable<String> args,
    String reporter,
    bool color,
    int concurrency,
    List<String> platforms,
    String name}) {
  List<String> testArgs = ['run', 'test'];
  if (reporter != null) {
    testArgs.addAll(['-r', reporter]);
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

Iterable<String> dartdocArgs(
    {Iterable<String> args,
    bool version,
    bool help,
    String input,
    String output}) {
  List<String> pubArgs = [];
  // --version          Print pub version.

  if (version == true) {
    pubArgs.add('--version');
  }
  // --help             Print this usage information.
  if (help == true) {
    pubArgs.add('--help');
  }
  // --verbose          Shortcut for "--verbosity=all".
  if (input != null) {
    pubArgs..add('--input')..add(input);
  }
  if (output != null) {
    pubArgs..add('--output')..add(output);
  }
  if (args != null) {
    pubArgs.addAll(args);
  }

  return pubArgs;
}
