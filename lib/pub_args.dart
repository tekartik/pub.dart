library tekartik_io_tools.pub_args;

enum RunTestReporter {
  @deprecated
  // ignore: constant_identifier_names
  COMPACT,
  @deprecated
// ignore: constant_identifier_names
  EXPANDED,

  @deprecated
// ignore: constant_identifier_names
  JSON,
  compact,
  expanded,
  json
}

enum BuildMode {
  @deprecated
  // ignore: constant_identifier_names
  DEBUG,
  @deprecated
  // ignore: constant_identifier_names
  RELEASE,
  debug,
  release
}
enum BuildFormat {
  @deprecated
  // ignore: constant_identifier_names
  TEXT,
  @deprecated
  // ignore: constant_identifier_names
  JSON,
  text,
  json
}

final Map<BuildMode, String> _buildModeValueMap = Map.fromIterables([
  // ignore: deprecated_member_use, deprecated_member_use_from_same_package
  BuildMode.DEBUG,
  // ignore: deprecated_member_use, deprecated_member_use_from_same_package
  BuildMode.RELEASE, BuildMode.debug, BuildMode.release
], [
  'debug',
  'release',
  'debug',
  'release'
]);

final Map<BuildFormat, String> _buildFormatValueMap = Map.fromIterables([
  // ignore: deprecated_member_use, deprecated_member_use_from_same_package
  BuildFormat.TEXT,
  // ignore: deprecated_member_use, deprecated_member_use_from_same_package
  BuildFormat.JSON, BuildFormat.text, BuildFormat.json
], [
  'text',
  'json',
  'text',
  'json'
]);

final Map<RunTestReporter, String> _runTestReporterValueMap =
    Map.fromIterables([
  // ignore: deprecated_member_use, deprecated_member_use_from_same_package
  RunTestReporter.COMPACT,
  // ignore: deprecated_member_use, deprecated_member_use_from_same_package
  RunTestReporter.EXPANDED,
  // ignore: deprecated_member_use, deprecated_member_use_from_same_package
  RunTestReporter.JSON,
  RunTestReporter.compact,
  RunTestReporter.expanded,
  RunTestReporter.json,
], [
  'compact',
  'expanded',
  'json',
  'compact',
  'expanded',
  'json'
]);

Map<String, RunTestReporter> _runTestReporterEnumMap;

RunTestReporter runTestReporterFromString(String reporter) {
  if (_runTestReporterEnumMap == null) {
    _runTestReporterEnumMap = {};
    _runTestReporterValueMap
        .forEach((RunTestReporter runTestReporter, String reporter) {
      _runTestReporterEnumMap[reporter] = runTestReporter;
    });
  }
  return _runTestReporterEnumMap[reporter];
}

List<String> pubArgs(
    {Iterable<String> args, bool version, bool help, bool verbose}) {
  final pubArgs = <String>[];
  // --version          Print pub version.

  if (version == true) {
    pubArgs.add('--version');
  }
  // --help             Print this usage information.
  if (help == true) {
    pubArgs.add('--help');
  }
  // --verbose          Shortcut for '--verbosity=all'.
  if (verbose == true) {
    pubArgs.add('--verbose');
  }
  if (args != null) {
    pubArgs.addAll(args);
  }

  return pubArgs;
}

/// list of argument for pubCmd
List<String> pubBuildArgs(
    {Iterable<String> directories,
    Iterable<String> args,
    BuildMode mode,
    BuildFormat format,
    String output}) {
  final buildArgs = <String>['build'];
  // --mode      Mode to run transformers in.
  //    (defaults to 'release')
  if (mode != null) {
    buildArgs.addAll(['--mode', _buildModeValueMap[mode]]);
  }
  // --format    How output should be displayed.
  // [text (default), json]
  if (format != null) {
    buildArgs.addAll(['--format', _buildFormatValueMap[format]]);
  }
  // -o, --output    Directory to write build outputs to.
  // (defaults to 'build')
  if (output != null) {
    buildArgs.addAll(['--output', output]);
  }
  if (directories != null) {
    buildArgs.addAll(directories);
  }
  if (args != null) {
    buildArgs.addAll(args);
  }

  return buildArgs;
}

List<String> pubGetArgs({bool offline, bool dryRun, bool packagesDir}) {
  final args = <String>['get'];
  if (offline == true) {
    args.add('--offline');
  }
  if (dryRun == true) {
    args.add('--dry-run');
  }
  if (packagesDir == true) {
    args.add('--packages-dir');
  }
  return args;
}

List<String> pubUpgradeArgs({bool offline, bool dryRun, bool packagesDir}) {
  final args = <String>['upgrade'];
  if (offline == true) {
    args.add('--offline');
  }
  if (dryRun == true) {
    args.add('--dry-run');
  }
  if (packagesDir == true) {
    args.add('--packages-dir');
  }
  return args;
}

const pubDepsStyleCompact = 'compact';
const pubDepsStyleTree = 'tree';
const pubDepsStyleList = 'list';

List<String> pubDepsArgs({Iterable<String> args, String style}) {
  final depsArgs = <String>['deps'];
  if (style != null) {
    depsArgs.addAll(['--style', style]);
  }
  if (args != null) {
    depsArgs.addAll(args);
  }
  return (depsArgs);
}

const pubRunTestReporterJson = 'json';
const pubRunTestReporterExpanded = 'expanded';
const pubRunTestReporterCompact = 'compact';

List<String> pubRunTestReporters = [
  pubRunTestReporterCompact,
  pubRunTestReporterExpanded,
  pubRunTestReporterJson
];

class TestRunnerArgs {
  TestRunnerArgs(
      {this.args,
      this.reporter,
      this.color,
      this.concurrency,
      this.platforms,
      this.name});

  final Iterable<String> args;
  final RunTestReporter reporter;
  final bool color;
  final int concurrency;
  final List<String> platforms;
  final String name;
}

List<String> pubRunTestRunnerArgs([TestRunnerArgs args]) {
  final testArgs = <String>[];
  if (args?.reporter != null) {
    testArgs.addAll(['-r', _runTestReporterValueMap[args.reporter]]);
  }
  if (args?.concurrency != null) {
    testArgs.addAll(['-j', args.concurrency.toString()]);
  }
  if (args?.name != null) {
    testArgs.addAll(['-n', args.name]);
  }
  if (args?.color != null) {
    if (args.color) {
      testArgs.add('--color');
    } else {
      testArgs.add('--no-color');
    }
  }
  if (args?.platforms != null) {
    for (final platform in args.platforms) {
      testArgs.addAll(['-p', platform]);
    }
  }
  if (args?.args != null) {
    testArgs.addAll(args.args);
  }
  return (testArgs);
}

/// list of argument for pub run test or pbr test --
List<String> testRunnerArgs(
    {Iterable<String> args,
    RunTestReporter reporter,
    bool color,
    int concurrency,
    List<String> platforms,
    String name}) {
  final testArgs = <String>[];
  testArgs.addAll(pubRunTestRunnerArgs(TestRunnerArgs(
      args: args,
      reporter: reporter,
      color: color,
      concurrency: concurrency,
      platforms: platforms,
      name: name)));
  return (testArgs);
}

/// list of argument for pubCmd
List<String> pubRunTestArgs(
    {Iterable<String> args,
    RunTestReporter reporter,
    bool color,
    int concurrency,
    List<String> platforms,
    String name}) {
  final testArgs = <String>['run', 'test'];
  testArgs.addAll(pubRunTestRunnerArgs(TestRunnerArgs(
      args: args,
      reporter: reporter,
      color: color,
      concurrency: concurrency,
      platforms: platforms,
      name: name)));
  return (testArgs);
}

/// list of argument for pubCmd
List<String> pubRunArgs(Iterable<String> args) {
  final runArgs = <String>['run'];
  if (args != null) {
    runArgs.addAll(args);
  }
  return (runArgs);
}

List<String> dartdocArgs(
    {Iterable<String> args,
    bool version,
    bool help,
    String input,
    String output}) {
  final pubArgs = <String>[];
  // --version          Print pub version.

  if (version == true) {
    pubArgs.add('--version');
  }
  // --help             Print this usage information.
  if (help == true) {
    pubArgs.add('--help');
  }
  // --verbose          Shortcut for '--verbosity=all'.
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
