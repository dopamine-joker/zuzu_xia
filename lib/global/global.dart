import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

const String TokenKey = "X-TOKEN";

class Global {
  static Global? _instance;
  late Dio dio;

  static Global? getInstance() {
    _instance ??= Global();
    return _instance;
  }

  Future<String> _getToken() async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    return sharedPreferences.getString("token") ?? "";
  }

  Global() {
    dio = Dio();
    dio.options = BaseOptions(
      baseUrl: "http://1.15.20.165:7070",
      connectTimeout: 5000,
      sendTimeout: 5000,
      receiveTimeout: 5000,
      // headers: {
      //   "X-TOKEN": "123",
      // },
      contentType: Headers.jsonContentType,
      responseType: ResponseType.json,
    );

    dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          String token = await _getToken();

          // options.queryParameters["X-TOKEN"] = token;
          print("req.header=" + options.headers.toString());
          print("req.param=" + options.queryParameters.toString());
          return handler.next(options);
        },
        onResponse: (response, handler) {
          print("res=" + response.toString());
          return handler.next(response);
        },
        onError: (e, handler) {
          print("err=" + e.toString());
          return handler.next(e);
        },
      ),
    );
  }
}

Future<String> getToken() async {
  SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
  return sharedPreferences.getString("token") ?? "";
}

Future<int> getUserId() async {
  SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
  return sharedPreferences.getInt("id") ?? -1;
}
