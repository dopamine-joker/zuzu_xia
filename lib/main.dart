import 'package:flutter/material.dart';
import 'package:flutter_demo/routes/routes.dart';
import 'package:flutter_demo/view/home/goods_detail_view.dart';
import 'package:flutter_demo/viewmodel/chat_viewmodel.dart';
import 'package:flutter_demo/viewmodel/comment_viewmodel.dart';
import 'package:flutter_demo/viewmodel/conversation_viewmodel.dart';
import 'package:flutter_demo/viewmodel/favorites_viewmodel.dart';
import 'package:flutter_demo/viewmodel/goods_viewmodel.dart';
import 'package:flutter_demo/viewmodel/home_viewmodel.dart';
import 'package:flutter_demo/viewmodel/login_viewmodel.dart';
import 'package:flutter_demo/viewmodel/order_viewmodel.dart';
import 'package:flutter_demo/viewmodel/upload_viewmodel.dart';
import 'package:provider/provider.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

void main() {
  runApp(MultiProvider(
    providers: [
      ChangeNotifierProvider(create: (context) => LoginViewmodel()),
      ChangeNotifierProvider(create: (context) => UploadVideModel()),
      ChangeNotifierProvider(create: (context) => ChatViewModel()),
      ChangeNotifierProvider(create: (context) => ConversationViewModel()),
      ChangeNotifierProvider(create: (context) => HomeViewmodel()),
      ChangeNotifierProvider(create: (context) => GoodsViewModel()),
      ChangeNotifierProvider(create: (context) => OrderViewModel()),
      ChangeNotifierProvider(create: (context) => FavoritesViewModel()),
      ChangeNotifierProvider(create: (context) => CommentViewModel()),
    ],
    child: MyApp(),
  ));
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      designSize: Size(360, 690),
      builder: () => MaterialApp(
        localizationsDelegates: [
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
        ],
        supportedLocales: [
          const Locale('zh', 'CN'),
          const Locale('en', 'US'),
        ],
        navigatorKey: navigatorKey,
        debugShowCheckedModeBanner: false,
        title: '租租侠',
        theme: ThemeData(
          primarySwatch: Colors.blue,
        ),
        routes: appRoutes,
        initialRoute: "/",
        builder: (context, widget) {
          return MediaQuery(
            //Setting font does not change with system font size
            data: MediaQuery.of(context).copyWith(textScaleFactor: 1.0),
            child: widget!,
          );
        },
      ),
    );
  }
}
