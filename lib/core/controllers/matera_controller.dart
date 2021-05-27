import 'package:dio/dio.dart';
import 'package:flutter/src/widgets/image.dart';
import 'package:pix_epoc/core/custom_dio.dart';
import 'package:pix_epoc/core/exception_pix.dart';
import 'package:pix_epoc/core/utils.dart';
import 'package:pix_epoc/data/models/matera/account_model.dart';
import 'package:pix_epoc/data/models/matera/matera_model.dart';
import 'package:pix_epoc/data/models/matera/transaction_model.dart';
import 'package:pix_epoc/implementation/i_pix.dart';
import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:pix_epoc/pix_epoc.dart';
import 'package:uuid/uuid.dart';

class MateraController implements IPix {
  static MateraController _instance;
  MateraController._();

  static MateraController get instance {
    _instance ??= MateraController._();
    return _instance;
  }

  final urlProducao = "https://producao-matera-xxxs";
  final urlHomolog = "https://incubadora-mp-api-hml.matera.systems";
  String urlMatera;
  MateraModel provider;
  AccountModel _account;
  TransactionModel _transaction;
  Response res;

  set debug(newValue) => urlMatera = newValue == true ? urlHomolog : urlProducao;

  @override
  Future addProvider(Object _model, {debug = false}) async {
    this.debug = debug;
    this.provider = _model;
  }

  MateraModel get getProvider => provider;
  AccountModel get account => this._account;
  set account(AccountModel account) => this._account = account;

  TransactionModel get transaction => this._transaction;
  set transaction(TransactionModel transaction) => this._transaction = transaction;

  String _transactionHash(String hash) {
    var key = utf8.encode(provider.secretKey);
    var bytes = utf8.encode(hash);
    var hmacSha256 = Hmac(sha256, key); // HMAC-SHA256
    var digest = hmacSha256.convert(bytes);
    return digest.toString();
  }

  @override
  Future generateQrCode({
    Duration expiration,
    String urlCallback,
    String comment,
    double value,
  }) async {
    double _feeValue = 0.0;
    if (account.alias == null) {
      account = await getAlias(account);
      if (account.alias == null) {
        throw ExceptionPix("Alias not created yet! try again later!");
      }
    }
    if (account.feeType == FeeType.value) {
      _feeValue = account.fee;
    } else {
      _feeValue = double.parse((value * (account.fee / 100)).toStringAsFixed(2));

      if ((account?.minFee ?? 0) > 0 && _feeValue < account.minFee) {
        _feeValue = account.minFee;
      }

      if ((account?.maxFee ?? 0) > 0 && _feeValue > account.maxFee) {
        _feeValue = account.maxFee;
      }
    }
    if (value == null || value <= 0) {
      throw ExceptionPix("Value cannot be null or less than ZERO");
    }

    var _generation = {
      "externalIdentifier": Uuid().v4(),
      "totalAmount": value,
      "currency": "BRL",
      "paymentInfo": {
        "transactionType": "InstantPayment",
        "instantPayment": {
          "alias": account.alias,
          "qrCodeImageGenerationSpecification": {
            "errorCorrectionLevel": "M",
            "imageWidth": 400,
            "generateImageRendering": true,
          },
          "expiration": expiration?.inSeconds ?? 86400
        }
      },
      "recipients": [
        {
          "account": {
            "accountId": account.accountId,
          },
          "amount": value,
          "currency": "BRL",
          "mediatorFee": _feeValue,
          "senderComment": comment ?? '',
          "recipientComment": comment ?? ''
        }
      ],
    };
    if (urlCallback != null) {
      _generation['callbackAddress'] = urlCallback;
    }

    var hash = account.alias + value.floor().toString() + account.accountId + value.floor().toString();
    Dio dio = CustomDio.instance;
    String urlCreateQrCode = urlMatera + "/v1/payments";
    try {
      res = await dio.post(
        urlCreateQrCode,
        data: _generation,
        options: Options(headers: _buildHeader(hash)),
      );

      if (res.statusCode != 200 && res.statusCode != 202) {
        throw ExceptionPix("Fail to get alias");
      }
    } on DioError catch (e) {
      if (e.response.data['error'] != null) {
        throw ExceptionPix(e.response.data['error']['description']);
      } else {
        throw ExceptionPix(e.response.statusMessage);
      }
    }

    transaction = TransactionModel.fromMap(res.data['data']);
    return true;
  }

  Map<String, dynamic> _buildHeader(String hash) {
    Map<String, dynamic> _headers = {
      'Api-Access-Key': provider.apiKey,
    };
    if (hash != null) {
      _headers['Transaction-Hash'] = _transactionHash(hash);
    }
    return _headers;
  }

  Future addAccount(String accountId) async {
    Dio dio = CustomDio.instance;
    String urlAccount = urlMatera + "/v1/accounts/$accountId";
    try {
      res = await dio.get(
        urlAccount,
        options: Options(
          headers: _buildHeader(accountId),
        ),
      );
      if (res.statusCode == 200) {
        Map<String, dynamic> _result = res.data;
        if (_result['data'] == null) {
          throw ExceptionPix("Fail to get account");
        } else {
          _account = AccountModel.fromMap(_result['data']['account']);
          _account.accountHolderId = _result['data']['accountHolderId'];
          _account.accountStatus = _result['data']['accountStatus'];
          _account.clientType = _result['data']['clientType'];
          _account = await getAlias(_account);
        }
      } else {
        throw ExceptionPix("Fail to get account");
      }
    } on DioError catch (e) {
      if (e.response.data['error'] != null) {
        throw ExceptionPix(e.response.data['error']['description']);
      } else {
        throw ExceptionPix(e.response.statusMessage);
      }
    }
  }

  Future createAlias(AccountModel account) async {
    Dio dio = CustomDio.instance;
    String urlAlias = urlMatera + "/v1/accounts/${account.accountId}/aliases";
    Map<String, dynamic> _aliasData = {
      "externalIdentifier": Uuid().v4(),
      "alias": {"type": "EVP"}
    };

    res = await dio.post(
      urlAlias,
      data: _aliasData,
      options: Options(
        headers: _buildHeader("post:/v1/accounts/${account.accountId}/aliases:"),
      ),
    );
    if (res.statusCode != 200 && res.statusCode != 202) {
      throw ExceptionPix("Fail to get alias");
    }
    return null;
  }

  Future<AccountModel> getAlias(AccountModel account) async {
    try {
      Dio dio = CustomDio.instance;
      String urlAlias = urlMatera + "/v1/accounts/${account.accountId}/aliases";
      res = await dio.get(
        urlAlias,
        options: Options(headers: _buildHeader(null)),
      );
      if (res.statusCode != 200) {
        throw ExceptionPix("Fail to get alias");
      }
      if (res.data['data'].length == 0) {
        return createAlias(account);
      } else {
        account.alias = (res.data['data']['aliases'][0]['status'] == 'ACTIVE') ? res.data['data']['aliases'][0]['name'] : null;
        return account;
      }
    } on DioError catch (e) {
      if (e.response.data['error'] != null) {
        throw ExceptionPix(e.response.data['error']['description']);
      } else {
        throw ExceptionPix(e.response.statusMessage);
      }
    }
  }

  void configureGateway({double fee, double minFee, double maxFee, FeeType feeType}) {
    this.account.fee = fee;
    this.account.minFee = minFee;
    this.account.maxFee = maxFee;
    this.account.feeType = feeType;
  }

  Image convertImage(String image) {
    return Utils.imageFromBase64String(image) ?? null;
  }
}
