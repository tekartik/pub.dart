import 'package:tekartik_common_utils/map_utils.dart';
import 'package:tekartik_common_utils/version_utils.dart';
import 'package:tekartik_pub/pubspec_yaml.dart';

class PubspecYamlImpl implements PubspecYaml {
  Map<String, dynamic>? get map => pubspecYamlMap;
  final Map<String, dynamic>? pubspecYamlMap;

  PubspecYamlImpl(this.pubspecYamlMap);

  @override
  String? get name => pubspecYamlMap!['name'] as String?;

  String? get versionText => pubspecYamlMap!['version'] as String?;

  Version? _parseVersion(String? text) {
    if (text == null) {
      return null;
    }
    return parseVersion(text);
  }

  @override
  Version? get version => _parseVersion(versionText);

  bool get isFlutter {
    return mapValueFromParts(map!, ['dependencies', 'flutter']) != null;
  }

  List<String> get targets {
    var list = <String>[];
    if (isFlutter) {
      list.add('flutter');
    }
    return list;
  }

  @override
  String toString() {
    return '$name $version ${targets.isEmpty ? '' : ['${targets.join(',')}']}';
  }
}
