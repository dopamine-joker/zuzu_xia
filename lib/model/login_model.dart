import 'package:dio/dio.dart';
import 'package:flutter_demo/global/global.dart';

Future logoutModel(String token) async {
  return await Global.getInstance()!.dio.post(
    "/user/logout",
    options: Options(
      headers: {
        TokenKey: token,
      },
      responseType: ResponseType.json,
    ),
    data: {
      "token": token,
    },
  );
}

Future tokenLoginModel(String token) async {
  return await Global.getInstance()!.dio.post(
    "/user/tokenLogin",
    data: {
      "token": token,
    },
  );
}

Future loginModel(String user, String pwd) async {
  return await Global.getInstance()!.dio.post(
    "/user/login",
    options: Options(
      responseType: ResponseType.json,
    ),
    data: {
      "email": user,
      "password": pwd,
    },
  );
}

Future registerModel(String user, String pwd, String name) async {
  return await Global.getInstance()!.dio.post(
    "/user/register",
    options: Options(
      responseType: ResponseType.json,
    ),
    data: {
      "email": user,
      "password": pwd,
      "name": name,
    },
  );
}

Future getSig(String userIdStr, int sdkAppId, int expire) async {
  return await Global.getInstance()!.dio.post(
    "/user/getSig",
    options: Options(
      responseType: ResponseType.json,
    ),
    data: {
      "userId": userIdStr,
      "sdkAppId": sdkAppId,
      "expire": expire,
    },
  );
}

Future updateUserModel(
    String token, String email, String phone, String name, String school,
    int sex, String password, int uid) async {
  return await Global.getInstance()!.dio.post(
    "/user/update",
    options: Options(
      headers: {
        TokenKey: token,
      },
      responseType: ResponseType.json,
    ),
    data: {
      "id": uid,
      "email": email,
      "phone": phone,
      "password": password,
      "name": name,
      "sex": sex,
      "school": school,
    },
  );
}

Future uploadFaceModel(String token, formData) async {
  return await Global.getInstance()!.dio.post(
        "/user/uploadFace",
        options: Options(
          headers: {
            TokenKey: token,
          },
          responseType: ResponseType.json,
        ),
        data: formData,
      );
}
