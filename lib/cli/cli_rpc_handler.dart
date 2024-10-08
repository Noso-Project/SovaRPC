import 'dart:io';

import 'package:logging/logging.dart';
import 'package:noso_dart/utils/noso_utility.dart';
import 'package:sovarpc/cli/pen.dart';

import '../blocs/network_events.dart';
import '../blocs/noso_network_bloc.dart';
import '../blocs/rpc_bloc.dart';
import '../blocs/rpc_events.dart';
import '../di.dart';
import '../models/log_level.dart';
import '../services/settings_yaml.dart';
import '../utils/path_app_rpc.dart';
import '../utils/verification_service.dart';
import '../utils/version.dart';

class CliRpcHandler {
  help(String usage) {
    stdout.writeln('Available commands:\n$usage');
  }

  testSeeds() async {
    stdout.writeln(Pen().greenText('> Start testing verified nodes'));

    var settingsSeeds =
        await SettingsYamlHandler().getSet(SettingsKeys.verificationSeeds);

    if (settingsSeeds.isNotEmpty && settingsSeeds.split(",").length >= 4) {
      var setSeeds = settingsSeeds.split(",");
      stdout.writeln(Pen().greenText(
          '> List of verified nodes is loaded from the config_rpc.yaml file'));
      await VerificationService.seedsTester(setSeeds: setSeeds);
    } else {
      stdout.writeln(Pen().red(
          '> The list of installed nodes in config_rpc.yaml is empty. skip testing...'));
    }
    stdout.writeln(Pen().greenText('\n'));
    stdout.writeln(
        Pen().greenText('> List of verified nodes encoded in binary code'));
    await VerificationService.seedsTester();
  }

  version() {
    stdout.writeln('> SovaRPC v${VersionUtil.getVersion()}');
  }

  methods() {
    stdout.writeln('JSON-RPC all methods:\n'
        '[getmainnetinfo,getpendingorders,getblockorders,getorderinfo,getaddressbalance,getnewaddress,getnewaddressfull,islocaladdress,getwalletbalance,setdefault,sendfunds,reset]\n'
        'Detail: https://github.com/Noso-Project/NosoSova/');
  }

  checkConfig() async {
    var settings = await SettingsYamlHandler().checkConfig();
    if (settings.isEmpty) {
      stdout.writeln('${PathAppRpcUtil.rpcConfigFilePath} not found...');
      return;
    }
    if (settings[2].isEmpty || !NosoUtility.isValidHashNoso(settings[2])) {
      stdout.writeln(
          Pen().red('> Please note! The billing address is not specified.'));
    }
    stdout.writeln(Pen().greenBg('${PathAppRpcUtil.rpcConfigFilePath}:'));
    stdout.writeln('IP:PORT: ${settings[0]}\n'
        'LOG_LEVEL: ${settings[1]}\n'
        'PAYMENT ADDRESS:  ${settings[2].isEmpty ? Pen().red("ERROR") : settings[2]}\n'
        'IGNORE METHODS RPC:  ${settings[3].isEmpty ? "NONE" : settings[3]}\n'
        'WHITE LIST IPs:  ${settings[4].isEmpty ? "NONE" : settings[4]}\n');
  }

  Future<void> runRpcMode(Logger logger) async {
    var settings = await SettingsYamlHandler().checkConfig();
    if (settings.isEmpty) {
      stdout.writeln('${PathAppRpcUtil.rpcConfigFilePath} not found...');
      stdout.writeln('Please use: --config: Create/Check configuration');
      return;
    }

    if (settings[2].isEmpty || !NosoUtility.isValidHashNoso(settings[2])) {
      stdout.writeln(
          Pen().red('> Please note! The billing address is not specified.'));
    }

    if (settings[4].split(',').isEmpty || settings[4].isEmpty) {
      stdout.writeln(Pen().greenText(
          '> Your WhiteList is empty your rpc is available for any addresses'));
    } else {
      stdout.writeln(Pen().red('> WhiteList activated ->\n${settings[4]}'));
    }

    var settingsSeeds =
        await SettingsYamlHandler().getSet(SettingsKeys.verificationSeeds);
    if (settingsSeeds.isNotEmpty && settingsSeeds.split(",").length >= 4) {
      stdout.writeln(Pen().greenText(
          '> The list of verified nodes is loaded from the config_rpc.yaml file'));
    } else {
      stdout.writeln(
          Pen().greenText('> List of verified nodes encoded in binary code'));
    }
    stdout.writeln("\n");
    await setupDiRPC(PathAppRpcUtil.getAppPath(),
        logger: logger, logLevel: LogLevel(level: settings[1]));
    locatorRpc<NosoNetworkBloc>().add(InitialConnect());
    await Future.delayed(const Duration(seconds: 5));
    locatorRpc<RpcBloc>()
        .add(StartServer(settings[0], settings[3], settings[4]));
  }
}
