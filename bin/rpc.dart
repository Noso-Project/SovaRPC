import 'dart:async';
import 'dart:io';

import 'package:args/args.dart';
import 'package:logging/logging.dart';
import 'package:logging_appenders/logging_appenders.dart';
import 'package:sovarpc/cli/cli_rpc_handler.dart';
import 'package:sovarpc/cli/comands.dart';
import 'package:sovarpc/cli/exit.dart';
import 'package:sovarpc/cli/pen.dart';
import 'package:sovarpc/utils/version.dart';

final _logger = Logger("");

Future<void> main(List<String> arguments) async {
  PrintAppender.setupLogging();
  final ArgParser argParser = ArgParser()
    ..addFlag(CliCommands.help,
        abbr: 'h', negatable: false, help: 'Show all RPC commands')
    ..addFlag(CliCommands.methods,
        abbr: 'm', negatable: false, help: 'Show all JSON-RPC methods')
    ..addFlag(CliCommands.run,
        abbr: 'r', negatable: false, help: 'Start RPC mode')
    ..addFlag(CliCommands.version,
        abbr: 'v', negatable: false, help: 'Get version SovaRPC')
    ..addFlag(CliCommands.testSeeds,
        abbr: 't', negatable: false, help: 'Testing of verified seeds')
    ..addFlag(CliCommands.config,
        abbr: 'c',
        negatable: false,
        help:
            'Displays the contents of the configuration file, if it does not exist, it creates it.');

  var rpcHandler = CliRpcHandler();
  try {
    final ArgResults args = argParser.parse(arguments);
    if (args[CliCommands.help] as bool) {
      rpcHandler.help(argParser.usage);
      return;
    }

    if (args[CliCommands.testSeeds] as bool) {
      rpcHandler.testSeeds();
      return;
    }

    if (args[CliCommands.version] as bool) {
      rpcHandler.version();
      return;
    }

    if (args[CliCommands.methods] as bool) {
      rpcHandler.methods();
      return;
    }

    if (args[CliCommands.run] as bool || arguments.isEmpty) {
      CliExit.exitListener(AppType.rpc);

      stdout
          .writeln(Pen().greenText('>>> SovaRPC v${VersionUtil.getVersion()}'));
      await rpcHandler.runRpcMode(_logger);
      return;
    }

    if (args[CliCommands.config] as bool) {
      stdout.writeln('Checking configuration...');
      await rpcHandler.checkConfig();
      return;
    }
  } catch (_) {}

  stdout.writeln(Pen().red(
      '> Error: Command or parameter not found. Please use --help to see available options.'));
}
