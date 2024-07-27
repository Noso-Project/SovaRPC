import 'dart:io';
import 'dart:math';

import 'package:noso_dart/models/noso/seed.dart';
import 'package:noso_dart/node_request.dart';

import '../cli/pen.dart';
import '../services/noso_network_service.dart';
import '../services/settings_yaml.dart';

final class VerificationService {
  static const List<String> seedsVerification = [
    "20.199.50.27",
    "84.247.143.153",
    "64.69.43.225",
    "4.233.61.8",
    "141.11.192.215",
    "23.95.216.80",
    "142.171.231.9"
  ];

  static const int durationTimeOut = 3;
  static const int delaySync = 30;

  static Future<String> getRandomNode(String? inputString) async {
    List<String> elements = (inputString ?? "").split(',');
    int elementCount = elements.length;
    if (elementCount > 0 && inputString != null && inputString.isNotEmpty) {
      int randomIndex = Random().nextInt(elementCount);
      var targetSeed = elements[randomIndex].split("|")[0];
      return targetSeed;
    } else {
      var devNode = await VerificationService.getVerificationSeedList();
      int randomDev = Random().nextInt(devNode.length);
      return devNode[randomDev].toTokenizer;
    }
  }

  static Future<List<Seed>> getVerificationSeedList() async {
    var settingsSeeds =
        await SettingsYamlHandler().getSet(SettingsKeys.verificationSeeds);
    List<String> mVerSeeds = List.from(seedsVerification);
    var newSeedList = settingsSeeds.split(",");
    if (settingsSeeds.isNotEmpty && newSeedList.length >= 4) {
      mVerSeeds.clear();
      mVerSeeds.addAll(newSeedList);
    }

    List<Seed> defSeed = [];
    for (String seed in mVerSeeds) {
      defSeed.add(Seed(ip: seed));
    }
    return defSeed;
  }

  static seedsTester({List<String> setSeeds = VerificationService.seedsVerification}) async {
    for (int i = 0; i < setSeeds.length; i++) {
      try {
        var connect = await NosoNetworkService()
            .fetchNode(NodeRequest.getNodeStatus, Seed(ip: setSeeds[i]));
        if (connect.errors == null) {
          stdout.writeln(Pen().greenText('>>> ${setSeeds[i]} OKAY'));
        } else {
          stdout.writeln(Pen().red('>>> ${setSeeds[i]} FAIL'));
        }
      } catch (e) {
        stdout.writeln(Pen().red('>>> Error processing ${setSeeds[i]}: $e'));
      }
    }
  }
}
