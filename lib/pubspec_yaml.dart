library tekartik_pub.pubspec_yaml;

import 'package:pub_semver/pub_semver.dart';
import 'package:tekartik_pub/src/pubspec_yaml.dart';

abstract class PubspecYaml {
  factory PubspecYaml.fromMap(Map<String, dynamic>? pubspecYamlMap) {
    return PubspecYamlImpl(pubspecYamlMap);
  }

  String? get name;

  Version? get version;
}
