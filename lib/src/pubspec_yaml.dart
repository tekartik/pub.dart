import 'package:tekartik_common_utils/map_utils.dart';
import 'package:tekartik_common_utils/version_utils.dart';
import 'package:tekartik_pub/pubspec_yaml.dart';

/// Concrete implementation of [PubspecYaml].
class PubspecYamlImpl implements PubspecYaml {
  /// The underlying map representation of pubspec.yaml.
  Map<String, dynamic>? get map => pubspecYamlMap;

  /// The raw pubspec.yaml map.
  final Map<String, dynamic>? pubspecYamlMap;

  /// Constructor for [PubspecYamlImpl].
  PubspecYamlImpl(this.pubspecYamlMap);

  @override
  String? get name => pubspecYamlMap!['name'] as String?;

  /// The version string from pubspec.yaml.
  String? get versionText => pubspecYamlMap!['version'] as String?;

  Version? _parseVersion(String? text) {
    if (text == null) {
      return null;
    }
    return parseVersion(text);
  }

  @override
  Version? get version => _parseVersion(versionText);

  /// Whether the package is a Flutter package.
  bool get isFlutter {
    return mapValueFromParts<Object?>(map!, ['dependencies', 'flutter']) !=
        null;
  }

  /// List of build targets for this package.
  List<String> get targets {
    var list = <String>[];
    if (isFlutter) {
      list.add('flutter');
    }
    return list;
  }

  @override
  String toString() {
    return '$name $version ${targets.isEmpty ? '' : [(targets.join(','))]}';
  }
}
