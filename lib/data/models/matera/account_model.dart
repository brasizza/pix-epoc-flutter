import 'dart:convert';

import 'package:pix_epoc/pix_epoc.dart';

class AccountModel {
  String accountId;
  int account;
  int branch;
  String accountHolderId;
  double fee;
  double minFee = 0;
  double maxFee = 0;
  FeeType feeType = FeeType.value;
  String accountStatus;
  String clientType;
  String alias;
  AccountModel({
    this.accountId,
    this.account,
    this.branch,
    this.accountHolderId,
    this.fee,
    this.minFee,
    this.maxFee,
    this.feeType,
    this.accountStatus,
    this.clientType,
    this.alias,
  });

  Map<String, dynamic> toMap() {
    return {
      'accountId': accountId,
      'account': account,
      'branch': branch,
      'accountHolderId': accountHolderId,
      'fee': fee,
      'minFee': minFee,
      'maxFee': maxFee,
      'feeType': feeType,
      'accountStatus': accountStatus,
      'clientType': clientType,
      'alias': alias,
    };
  }

  factory AccountModel.fromMap(Map<String, dynamic> map) {
    return AccountModel(
      accountId: map['accountId'],
      account: map['account'],
      branch: map['branch'],
      accountHolderId: map['accountHolderId'],
      fee: map['fee'],
      minFee: map['minFee'],
      maxFee: map['maxFee'],
      feeType: (map['feeType']),
      accountStatus: map['accountStatus'],
      clientType: map['clientType'],
      alias: map['alias'],
    );
  }

  String toJson() => json.encode(toMap());

  factory AccountModel.fromJson(String source) => AccountModel.fromMap(json.decode(source));
}
