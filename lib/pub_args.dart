library;

/// Reporter options for running tests.
enum RunTestReporter {
  /// Compact reporter (deprecated, use [compact]).
  @Deprecated('Use compact')
  // ignore: constant_identifier_names
  COMPACT,

  /// Expanded reporter (deprecated, use [expanded]).
  @Deprecated('Use expanded')
  // ignore: constant_identifier_names
  EXPANDED,

  /// JSON reporter (deprecated, use [json]).
  @Deprecated('Use json')
  // ignore: constant_identifier_names
  JSON,

  /// Compact reporter.
  compact,

  /// Expanded reporter.
  expanded,

  /// JSON reporter.
  json,
}

/// Build modes.
enum BuildMode {
  /// Debug mode (deprecated, use [debug]).
  @Deprecated('Use debug')
  // ignore: constant_identifier_names
  DEBUG,

  /// Release mode (deprecated, use [release]).
  @Deprecated('Use release')
  // ignore: constant_identifier_names
  RELEASE,

  /// Debug mode.
  debug,

  /// Release mode.
  release,
}

/// Formats for build output.
enum BuildFormat {
  /// Text format (deprecated, use [text]).
  @Deprecated('Use test')
  // ignore: constant_identifier_names
  TEXT,

  /// JSON format (deprecated, use [json]).
  @Deprecated('Use json')
  // ignore: constant_identifier_names
  JSON,

  /// Text format.
  text,

  /// JSON format.
  json,
}

final Map<BuildMode, String> _buildModeValueMap = Map.fromIterables(
  [
    // ignore: deprecated_member_use, deprecated_member_use_from_same_package
    BuildMode.DEBUG,
    // ignore: deprecated_member_use, deprecated_member_use_from_same_package
    BuildMode.RELEASE, BuildMode.debug, BuildMode.release,
  ],
  ['debug', 'release', 'debug', 'release'],
);

final Map<BuildFormat, String> _buildFormatValueMap = Map.fromIterables(
  [
    // ignore: deprecated_member_use, deprecated_member_use_from_same_package
    BuildFormat.TEXT,
    // ignore: deprecated_member_use, deprecated_member_use_from_same_package
    BuildFormat.JSON, BuildFormat.text, BuildFormat.json,
  ],
  ['text', 'json', 'text', 'json'],
);

final Map<RunTestReporter, String> _runTestReporterValueMap = Map.fromIterables(
  [
    // ignore: deprecated_member_use, deprecated_member_use_from_same_package
    RunTestReporter.COMPACT,
    // ignore: deprecated_member_use, deprecated_member_use_from_same_package
    RunTestReporter.EXPANDED,
    // ignore: deprecated_member_use, deprecated_member_use_from_same_package
    RunTestReporter.JSON,
    RunTestReporter.compact,
    RunTestReporter.expanded,
    RunTestReporter.json,
  ],
  ['compact', 'expanded', 'json', 'compact', 'expanded', 'json'],
);

Map<String, RunTestReporter>? _runTestReporterEnumMap;

/// Converts a string to a [RunTestReporter], or null if not found.
RunTestReporter? runTestReporterFromString(String reporter) {
  if (_runTestReporterEnumMap == null) {
    _runTestReporterEnumMap = {};
    _runTestReporterValueMap.forEach((
      RunTestReporter runTestReporter,
      String reporter,
    ) {
      _runTestReporterEnumMap![reporter] = runTestReporter;
    });
  }
  return _runTestReporterEnumMap![reporter];
}

/// Returns command line arguments for the pub tool.
List<String> pubArgs({
  Iterable<String>? args,
  @Deprecated('version no longer supported') bool? version,
  bool? help,
  bool? verbose,
}) {
  final pubArgs = <String>[];
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
List<String> pubBuildArgs({
  Iterable<String>? directories,
  Iterable<String>? args,
  BuildMode? mode,
  BuildFormat? format,
  String? output,
}) {
  final buildArgs = <String>[
    'build',
    // --mode      Mode to run transformers in.
    //    (defaults to 'release')
    if (mode != null) ...['--mode', _buildModeValueMap[mode]!],
    // --format    How output should be displayed.
    // [text (default), json]
    if (format != null) ...['--format', _buildFormatValueMap[format]!],

    // -o, --output    Directory to write build outputs to.
    // (defaults to 'build')
    if (output != null) ...['--output', output],

    ...?directories,

    ...?args,
  ];

  return buildArgs;
}

/// Returns arguments for the `pub get` command.
List<String> pubGetArgs({bool? offline, bool? dryRun, bool? packagesDir}) {
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

/// Returns arguments for the `pub upgrade` command.
List<String> pubUpgradeArgs({bool? offline, bool? dryRun, bool? packagesDir}) {
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

/// Compact style for pub deps.
const pubDepsStyleCompact = 'compact';

/// Tree style for pub deps.
const pubDepsStyleTree = 'tree';

/// List style for pub deps.
const pubDepsStyleList = 'list';

/// Returns arguments for the `pub deps` command.
List<String> pubDepsArgs({Iterable<String>? args, String? style}) {
  final depsArgs = <String>['deps'];
  if (style != null) {
    depsArgs.addAll(['--style', style]);
  }
  if (args != null) {
    depsArgs.addAll(args);
  }
  return (depsArgs);
}

/// JSON reporter constant.
const pubRunTestReporterJson = 'json';

/// Expanded reporter constant.
const pubRunTestReporterExpanded = 'expanded';

/// Compact reporter constant.
const pubRunTestReporterCompact = 'compact';

/// List of all pub run test reporters.
List<String> pubRunTestReporters = [
  pubRunTestReporterCompact,
  pubRunTestReporterExpanded,
  pubRunTestReporterJson,
];

/// Arguments for test runner.
class TestRunnerArgs {
  /// Constructor for TestRunnerArgs.
  TestRunnerArgs({
    this.args,
    this.reporter,
    this.color,
    this.concurrency,
    this.platforms,
    this.name,
  });

  /// Custom arguments.
  final Iterable<String>? args;

  /// The test reporter type.
  final RunTestReporter? reporter;

  /// Whether to output colored logs.
  final bool? color;

  /// Number of concurrent test runs.
  final int? concurrency;

  /// Target platforms.
  final List<String>? platforms;

  /// Test name filter pattern.
  final String? name;
}

/// Returns argument list for the pub run test runner with custom options.
List<String> pubRunTestRunnerArgs([TestRunnerArgs? args]) {
  final testArgs = <String>[];
  if (args?.reporter != null) {
    testArgs.addAll(['-r', _runTestReporterValueMap[args!.reporter!]!]);
  }
  if (args?.concurrency != null) {
    testArgs.addAll(['-j', args!.concurrency.toString()]);
  }
  if (args?.name != null) {
    testArgs.addAll(['-n', args!.name!]);
  }
  if (args?.color != null) {
    if (args!.color!) {
      testArgs.add('--color');
    } else {
      testArgs.add('--no-color');
    }
  }
  if (args?.platforms != null) {
    for (final platform in args!.platforms!) {
      testArgs.addAll(['-p', platform]);
    }
  }
  if (args?.args != null) {
    testArgs.addAll(args!.args!);
  }
  return (testArgs);
}

/// list of argument for pub run test or pbr test --
List<String> testRunnerArgs({
  Iterable<String>? args,
  RunTestReporter? reporter,
  bool? color,
  int? concurrency,
  List<String>? platforms,
  String? name,
}) {
  final testArgs = <String>[];
  testArgs.addAll(
    pubRunTestRunnerArgs(
      TestRunnerArgs(
        args: args,
        reporter: reporter,
        color: color,
        concurrency: concurrency,
        platforms: platforms,
        name: name,
      ),
    ),
  );
  return (testArgs);
}

/// list of argument for pubCmd
List<String> pubRunTestArgs({
  Iterable<String>? args,
  RunTestReporter? reporter,
  bool? color,
  int? concurrency,
  List<String>? platforms,
  String? name,
}) {
  final testArgs = <String>['run', 'test'];
  testArgs.addAll(
    pubRunTestRunnerArgs(
      TestRunnerArgs(
        args: args,
        reporter: reporter,
        color: color,
        concurrency: concurrency,
        platforms: platforms,
        name: name,
      ),
    ),
  );
  return (testArgs);
}

/// list of argument for pubCmd
List<String> pubRunArgs(Iterable<String> args) {
  final runArgs = <String>['run', ...args];
  return (runArgs);
}

/// Returns arguments for the `dartdoc` command.
List<String> dartdocArgs({
  Iterable<String>? args,
  bool? version,
  bool? help,
  String? input,
  String? output,
}) {
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
    pubArgs
      ..add('--input')
      ..add(input);
  }
  if (output != null) {
    pubArgs
      ..add('--output')
      ..add(output);
  }
  if (args != null) {
    pubArgs.addAll(args);
  }

  return pubArgs;
}
