

import 'package:dio/dio.dart';
import 'package:flutter_demo/global/global.dart';

Future AddComment(String token, int uid, int gid, int oid, int level, String content) async {
  return await Global.getInstance()!.dio.post(
    "/comment/add",
    options: Options(
      headers: {
        TokenKey: token,
      },
      responseType: ResponseType.json,
    ),
    data: {
      "uid": uid,
      "gid": gid,
      "oid": oid,
      "level": level,
      "content": content,
    },
  );
}

Future DeleteComment(String token, int cid) async {
  return await Global.getInstance()!.dio.post(
    "/comment/delete",
    options: Options(
      headers: {
        TokenKey: token,
      },
      responseType: ResponseType.json,
    ),
    data: {
      "cid": cid,
    },
  );
}

Future GetCommentByUserId(String token, int uid) async {
  return await Global.getInstance()!.dio.post(
    "/comment/user",
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

Future GetCommentByGoodsId(String token, int gid) async {
  return await Global.getInstance()!.dio.post(
    "/comment/goods",
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