
import 'package:dio/dio.dart';
import 'package:flutter_demo/global/global.dart';

Future AddFavorites(String token, int uid, int gid) async {
  return await Global.getInstance()!.dio.post(
    "/favorites/add",
    options: Options(
      headers: {
        TokenKey: token,
      },
      responseType: ResponseType.json,
    ),
    data: {
      "uid": uid,
      "gid": gid,
    },
  );
}

Future DeleteFavorites(String token, int fid) async {
  return await Global.getInstance()!.dio.post(
    "/favorites/delete",
    options: Options(
      headers: {
        TokenKey: token,
      },
      responseType: ResponseType.json,
    ),
    data: {
      "fid": fid,
    },
  );
}

Future GetUserFavorites(String token, int uid) async {
  return await Global.getInstance()!.dio.post(
    "/favorites/user",
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