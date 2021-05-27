import 'package:dio/dio.dart';

class DioInterceptor extends InterceptorsWrapper {
  @override
  Future onRequest(RequestOptions options) {
    print('INICIANDO A REQUISICAO  ${options?.path}');
    print('PARAMETROS  ${options?.queryParameters}');
    return super.onRequest(options);
  }

  @override
  Future onResponse(Response response) {
    print('RESPOSTA[${response?.statusCode}] => PATH: ${response?.request?.path}');
    return super.onResponse(response);
  }

  @override
  Future onError(DioError err) async {
    print('ERRO [${err?.response?.statusCode}] => PATH: ${err?.request?.path}');

    String mensagem = "";
    mensagem += "ERRO [${err?.response?.statusCode}] => PATH: ${err?.request?.path}\n";
    mensagem += "MENSAGEM [${err?.response?.statusMessage}]\n";
    mensagem += "ENTRADA [${err?.request?.data}]\n";
    mensagem += "SAIDA [${err?.response?.data}]\n";
    mensagem += "URL [${err?.request?.uri}]\n";
    print(mensagem);

    return super.onError(err);
  }
}
