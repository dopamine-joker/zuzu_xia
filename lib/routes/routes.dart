import 'package:flutter/material.dart';
import 'package:flutter_demo/view/chat/chat_view.dart';
import 'package:flutter_demo/view/login_view.dart';
import 'package:flutter_demo/view/menu_view.dart';
import 'package:flutter_demo/view/upload/upload_view.dart';

Map<String, WidgetBuilder> appRoutes = {
  "/": (BuildContext context) => LoginView(),
  "menu": (BuildContext context) => MenuView(),
  "upload": (BuildContext context) => uploadView(),
  // "chat": (BuildContext context) => chatView(),
  // "register": (BuildContext context) => const registerView(),
};
