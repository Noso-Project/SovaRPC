import 'dart:io';

import 'package:path/path.dart';
import 'package:yaml/yaml.dart';

class VersionUtil {
  static getVersion() {
    String pathToYaml =
        join(dirname(Platform.script.toFilePath()), '../pubspec.yaml');

    File f = new File(pathToYaml);
    String yamlText = f.readAsStringSync();
    Map yaml = loadYaml(yamlText);

    return yaml['version'];
  }
}
