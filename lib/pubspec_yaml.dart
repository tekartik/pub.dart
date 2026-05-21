library;

import 'package:pub_semver/pub_semver.dart';
import 'package:tekartik_pub/src/pubspec_yaml.dart';

/// Representation of pubspec.yaml file contents.
abstract class PubspecYaml {
  /// Create a PubspecYaml from a raw map.
  factory PubspecYaml.fromMap(Map<String, dynamic>? pubspecYamlMap) {
    return PubspecYamlImpl(pubspecYamlMap);
  }

  /// The name of the package.
  String? get name;

  /// The version of the package.
  Version? get version;
}
