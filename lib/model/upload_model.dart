import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter_demo/global/global.dart';

Future uploadModel(token, formData) async {
  return await Global.getInstance()!.dio.post(
        "/goods/upload",
        options: Options(
          headers: {
            TokenKey: token,
          },
          responseType: ResponseType.json,
        ),
        data: formData,
      );
}
