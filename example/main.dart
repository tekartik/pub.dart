// ignore_for_file: avoid_print
import 'package:tekartik_pub/io.dart';
import 'package:tekartik_pub/pubspec_yaml.dart';

/// Lists the pub packages found below the given folders (default: the
/// current one) with their name and version.
///
/// `dart run example/main.dart [folders...]`
Future<void> main(List<String> arguments) async {
  var dirs = arguments.isEmpty ? ['.'] : arguments;
  for (var path in await recursivePubPath(dirs)) {
    var pkg = PubPackage(path);
    var pubspec = PubspecYaml.fromMap(await pkg.getPubspecYamlMap());
    print('$path: ${pubspec.name} ${pubspec.version}');
  }
}
