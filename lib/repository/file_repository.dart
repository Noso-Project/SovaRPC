import 'dart:typed_data';


import '../services/file_service_rpc.dart';
import '../models/address_wallet.dart';


class FileRepositoryRpc {
  final FileServiceRpc _fileService;

  FileRepositoryRpc(this._fileService);



  Future<bool> writeSummaryZip(List<int> bytes) async {
    return await _fileService.saveSummary(bytes);
  }

  Future<Uint8List?> loadSummary() async {
    return await _fileService.loadSummary();
  }

  Future<bool> saveExportWallet(
      List<Address> addresses, String filepath) async {
    return await _fileService.saveWallet(addresses, filepath);
  }

}
