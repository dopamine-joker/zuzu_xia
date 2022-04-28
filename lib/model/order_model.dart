import 'package:dio/dio.dart';
import 'package:flutter_demo/global/global.dart';

Future AddOrderModel(String token, int buyId, int sellId, int gid, String school) async {
  return await Global.getInstance()!.dio.post(
    "/order/add",
    options: Options(
      headers: {
        TokenKey: token,
      },
      responseType: ResponseType.json,
    ),
    data: {
      "buyid": buyId,
      "sellid": sellId,
      "gid": gid,
      "school": school,
    },
  );
}

Future GetBuyOrderModel(String token, int buyId) async {
  return await Global.getInstance()!.dio.post(
    "/order/getBuy",
    options: Options(
      headers: {
        TokenKey: token,
      },
      responseType: ResponseType.json,
    ),
    data: {
      "buyid": buyId,
    },
  );
}

Future GetSellOrderModel(String token, int sellId) async {
  return await Global.getInstance()!.dio.post(
    "/order/getSell",
    options: Options(
      headers: {
        TokenKey: token,
      },
      responseType: ResponseType.json,
    ),
    data: {
      "sellid": sellId,
    },
  );
}

Future UpdateOrderStatusModel(String token, int oid, int status) async {
  return await Global.getInstance()!.dio.post(
    "/order/update",
    options: Options(
      headers: {
        TokenKey: token,
      },
      responseType: ResponseType.json,
    ),
    data: {
      "id": oid,
      "status": status,
    },
  );
}
