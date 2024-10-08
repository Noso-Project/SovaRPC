import 'dart:async';
import 'dart:io';
import 'dart:math';

import 'package:noso_dart/models/noso/seed.dart';
import 'package:noso_dart/node_request.dart';
import 'package:sovarpc/models/response_node.dart';

import '../utils/verification_service.dart';

class NosoNetworkService {
  Future<ResponseNode<List<int>>> fetchNode(String command, Seed seed) async {
    final responseBytes = <int>[];
    try {
      var socket = await Socket.connect(seed.ip, seed.port,
          timeout: const Duration(seconds: 1));

      final startTime = DateTime.now().millisecondsSinceEpoch;
      socket.write(command);
      await for (var byteData in socket) {
        responseBytes.addAll([...byteData]);
      }
      final endTime = DateTime.now().millisecondsSinceEpoch;
      final responseTime = endTime - startTime;

      socket.close();
      if (responseBytes.isNotEmpty) {
        seed.ping = responseTime;
        seed.online = true;
        return ResponseNode(value: responseBytes, seed: seed);
      } else {
        return command == NodeRequest.getPendingsList
            ? ResponseNode(value: [])
            : ResponseNode(errors: "Empty response");
      }
    } on TimeoutException catch (_) {
      print("Connection timed out. Check server availability.");
      return ResponseNode(
          errors: "Connection timed out. Check server availability.");
    } on SocketException catch (e) {
      print("SocketException: ${e.message}");
      return ResponseNode(errors: "SocketException: ${e.message}");
    } catch (e) {
      print("ServerService Exception: $e");
      return ResponseNode(errors: "ServerService Exception: $e");
    }
  }

  Future<ResponseNode<List<int>>> getRandomDevNode() async {
    List<Seed> seedsDefault = await VerificationService.getVerificationSeedList();

    final responseBytes = <int>[];
    Random random = Random();
    int randomIndex = random.nextInt(seedsDefault.length);
    var targetSeed = seedsDefault[randomIndex];
    try {
      var socket = await _connectSocket(targetSeed);
      final startTime = DateTime.now().millisecondsSinceEpoch;
      socket.write(NodeRequest.getNodeStatus);
      await for (var byteData in socket) {
        responseBytes.addAll(byteData);
      }
      final endTime = DateTime.now().millisecondsSinceEpoch;
      final responseTime = endTime - startTime;

      socket.close();
      if (responseBytes.isNotEmpty) {
        targetSeed.ping = responseTime;
        targetSeed.online = true;

        return ResponseNode(value: responseBytes, seed: targetSeed);
      } else {
        return ResponseNode(errors: "Empty response");
      }
    } on TimeoutException catch (_) {
      print("Connection timed out. Check server availability.");
      return ResponseNode(
          errors: "Connection timed out. Check server availability.");
    } on SocketException catch (e) {
      print("SocketException: ${e.message}");
      return ResponseNode(errors: "SocketException: ${e.message}");
    } catch (e) {
      print("ServerService Exception: $e");
      return ResponseNode(errors: "ServerService Exception: $e");
    }
  }

  Future<Socket> _connectSocket(Seed seed) async {
    return Socket.connect(seed.ip, seed.port,
        timeout: const Duration(seconds: VerificationService.durationTimeOut));
  }
}
