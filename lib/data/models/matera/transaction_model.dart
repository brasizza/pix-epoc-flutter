import 'dart:convert';

class TransactionModel {
  String transactionId;
  String externalIdentifier;
  String status;
  DateTime transactionDate;
  String transactionType;
  double totalAmount;
  double paidAmount;
  String textQrcode;
  String referenceQrcode;
  String qrcodeUrl;
  String imageMimeType;
  String imageContent;
  TransactionModel({
    this.transactionId,
    this.externalIdentifier,
    this.status,
    this.transactionDate,
    this.transactionType,
    this.totalAmount,
    this.paidAmount,
    this.textQrcode,
    this.referenceQrcode,
    this.qrcodeUrl,
    this.imageMimeType,
    this.imageContent,
  });

  Map<String, dynamic> toMap() {
    return {
      'transactionId': transactionId,
      'externalIdentifier': externalIdentifier,
      'status': status,
      'transactionDate': transactionDate.millisecondsSinceEpoch,
      'transactionType': transactionType,
      'totalAmount': totalAmount,
      'paidAmount': paidAmount,
      'textQrcode': textQrcode,
      'referenceQrcode': referenceQrcode,
      'qrcodeUrl': qrcodeUrl,
      'imageMimeType': imageMimeType,
      'imageContent': imageContent,
    };
  }

  factory TransactionModel.fromMap(Map<String, dynamic> map) {
    return TransactionModel(
      transactionId: map['transactionId'] ?? '',
      externalIdentifier: map['externalIdentifier'] ?? '',
      status: map['financialStatement']['status'] ?? '',
      transactionDate: (DateTime.parse(map['transactionDate'])) ?? '',
      transactionType: map['transactionType'] ?? '',
      totalAmount: map['totalAmount'] ?? '',
      paidAmount: map['paidAmount'] ?? '',
      textQrcode: map['instantPayment']['textContent'] ?? '',
      referenceQrcode: map['instantPayment']['reference'] ?? '',
      qrcodeUrl: map['instantPayment']['qrcodeUrl'] ?? '',
      imageMimeType: map['instantPayment']['generateImage']['mimeType'] ?? '',
      imageContent: map['instantPayment']['generateImage']['imageContent'] ?? '',
    );
  }

  String toJson() => json.encode(toMap());

  factory TransactionModel.fromJson(String source) => TransactionModel.fromMap(json.decode(source));
}
