import 'package:dio/dio.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_demo/global/global.dart';

Future getGoodsModel(String token, int page, int count) async {
  return await Global.getInstance()!.dio.post(
    "/goods/getGoods",
    options: Options(
      headers: {
        TokenKey: token,
      },
      responseType: ResponseType.json,
    ),
    data: {
      "page": page,
      "count": count,
    },
  );
}

Future SearchGoodsModel(String token, String name) async {
  return await Global.getInstance()!.dio.post(
    "/goods/search",
    options: Options(
      headers: {
        TokenKey: token,
      },
      responseType: ResponseType.json,
    ),
    data: {
      "gname": name,
    },
  );
}

Future VoiceToTxtModel(String token, formData) async {
  return await Global.getInstance()!.dio.post(
    "/voice/process",
    options: Options(
      headers: {
        TokenKey: token,
      },
      responseType: ResponseType.json,
    ),
    data: formData,
  );
}
