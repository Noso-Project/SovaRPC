import 'package:drift/drift.dart';
import 'package:noso_dart/models/noso/address_object.dart';

@DataClassName('Address')
class Address extends AddressObject {
  /// Returns the wallet address displayed to the user, either truncated or custom.
  get nameAddressPublic => custom ?? hash;

  /// Does he work at this address?
  bool nodeStatusOn;

  /// How much does this node earn per day?
  double rewardDay;

  String seedNodeOn = "";

  final String? description;

  Address({
    required super.hash,
    super.custom,
    required super.publicKey,
    required super.privateKey,
    super.balance,
    super.score,
    super.lastOP,
    super.isLocked,
    super.incoming,
    super.outgoing,
    this.rewardDay = 0,
    this.nodeStatusOn = false,
    this.description,
  });

  factory Address.fromJson(Map<String, dynamic> json) {
    return Address(
      hash: json['hash'],
      publicKey: json['publicKey'],
      privateKey: json['privateKey'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'hash': hash,
      'publicKey': publicKey,
      'privateKey': privateKey,
    };
  }
}
