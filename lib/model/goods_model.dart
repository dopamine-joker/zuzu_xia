import 'package:dio/dio.dart';
import 'package:flutter_demo/global/global.dart';

Future getGoodsDetailModel(String token, int gid) async {
  return await Global.getInstance()!.dio.post(
    "/goods/goodsDetail",
    options: Options(
      headers: {
        TokenKey: token,
      },
      responseType: ResponseType.json,
    ),
    data: {
      "gid": gid,
    },
  );
}

Future getUserGoodsListModel(String token, int uid) async {
  return await Global.getInstance()!.dio.post(
    "/goods/userGoods",
    options: Options(
      headers: {
        TokenKey: token,
      },
      responseType: ResponseType.json,
    ),
    data: {
      "uid": uid,
    },
  );
}

Future deleteGoodsModel(String token, int gid) async {
  return await Global.getInstance()!.dio.post(
    "/goods/delete",
    options: Options(
      headers: {
        TokenKey: token,
      },
      responseType: ResponseType.json,
    ),
    data: {
      "gid": gid,
    },
  );
}
