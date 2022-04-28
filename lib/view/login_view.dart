import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_demo/config/config.dart';
import 'package:flutter_demo/utils/dialog.dart';
import 'package:flutter_demo/utils/event.dart';
import 'package:flutter_demo/viewmodel/chat_viewmodel.dart';
import 'package:flutter_demo/viewmodel/conversation_viewmodel.dart';
import 'package:flutter_demo/viewmodel/login_viewmodel.dart';
import 'package:provider/src/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tencent_im_sdk_plugin/enum/V2TimSDKListener.dart';
import 'package:tencent_im_sdk_plugin/enum/log_level_enum.dart';
import 'package:tencent_im_sdk_plugin/manager/v2_tim_manager.dart';
import 'package:tencent_im_sdk_plugin/tencent_im_sdk_plugin.dart';

class LoginView extends StatefulWidget {
  @override
  _LoginViewState createState() => _LoginViewState();
}

class _LoginViewState extends State<LoginView> with TickerProviderStateMixin {
  TextEditingController _loginUser = TextEditingController();
  TextEditingController _loginPwd = TextEditingController();
  TextEditingController _registerUser = TextEditingController();
  TextEditingController _registerPwd = TextEditingController();
  TextEditingController _registerCheckPwd = TextEditingController();
  TextEditingController _registerName = TextEditingController();

  bool isinit = false; //im sdk是否初始化

  @override
  void initState() {
    super.initState();

    // 监听登陆错误事件
    eventBus.on<LoginInErrEvent>().listen((event) {
      getDialog("登陆提示", event.detail).show(context);
    });

    // 监听注册错误事件
    eventBus.on<RegisterErrEvent>().listen((event) {
      getDialog("注册提示", event.detail).show(context);
    });

    initSDK();
    loadData();
  }

  @override
  void dispose() {
    super.dispose();
    _loginUser.dispose();
    _loginPwd.dispose();
    _registerUser.dispose();
    _registerPwd.dispose();
    _registerCheckPwd.dispose();
  }

  Widget HomePage() {
    return SingleChildScrollView(
      child: Container(
        height: MediaQuery.of(context).size.height,
        decoration: BoxDecoration(
          color: Colors.grey[600],
          image: DecorationImage(
            colorFilter: ColorFilter.mode(
              Colors.black.withOpacity(0.1),
              BlendMode.dstATop,
            ),
            image: AssetImage('assets/images/mountains.jpg'),
            fit: BoxFit.cover,
          ),
        ),
        child: Column(
          children: <Widget>[
            Container(
              padding: EdgeInsets.only(top: 150.0.r),
              child: Center(
                child: Icon(
                  Icons.home,
                  color: Colors.white,
                  size: 35.0.sp,
                ),
              ),
            ),
            Container(
              padding: EdgeInsets.only(top: 10.0.h),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Text(
                    "租租",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 15.0.sp,
                    ),
                  ),
                  Text(
                    "侠",
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 15.0.sp,
                        fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),
            Container(
              width: MediaQuery.of(context).size.width,
              margin:
                  EdgeInsets.only(left: 25.0.w, right: 25.0.w, top: 150.0.h),
              alignment: Alignment.center,
              child: Row(
                children: <Widget>[
                  Expanded(
                    child: FlatButton(
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30.0)),
                      color: Colors.black12,
                      // highlightedBorderColor: Colors.white,
                      onPressed: () => gotoSignup(),
                      child: Container(
                        padding: EdgeInsets.symmetric(
                          vertical: 15.0.h,
                          horizontal: 10.0.w,
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: <Widget>[
                            Expanded(
                              child: Text(
                                "注册",
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontSize: 10.0.sp,
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Container(
              width: MediaQuery.of(context).size.width,
              margin: EdgeInsets.only(left: 25.0.w, right: 25.0.w, top: 20.0.h),
              alignment: Alignment.center,
              child: Row(
                children: <Widget>[
                  Expanded(
                    child: FlatButton(
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30.0)),
                      color: Colors.white,
                      onPressed: () => gotoLogin(),
                      child: Container(
                        padding: EdgeInsets.symmetric(
                          vertical: 15.0.h,
                          horizontal: 10.0.w,
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: <Widget>[
                            Expanded(
                              child: Text(
                                "登陆",
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontSize: 10.0.sp,
                                  color: Colors.redAccent,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget LoginPage() {
    return SingleChildScrollView(
      // height: MediaQuery.of(context).size.height,
      child: Container(
        height: MediaQuery.of(context).size.height,
        decoration: BoxDecoration(
          color: Colors.grey[700],
          image: DecorationImage(
            colorFilter: ColorFilter.mode(
                Colors.black.withOpacity(0.05), BlendMode.dstATop),
            image: AssetImage('assets/images/mountains.jpg'),
            fit: BoxFit.cover,
          ),
        ),
        child: Column(
          children: <Widget>[
            Container(
              padding: EdgeInsets.all(100.0.r),
              child: Center(
                child: Icon(
                  Icons.home,
                  color: Colors.redAccent,
                  size: 35.0.sp,
                ),
              ),
            ),
            Row(
              children: <Widget>[
                Expanded(
                  child: Padding(
                    padding: EdgeInsets.only(left: 25.0.w),
                    child: Text(
                      "邮箱",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.white70,
                        fontSize: 10.0.sp,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            Container(
              width: MediaQuery.of(context).size.width,
              margin: EdgeInsets.only(left: 25.0.w, right: 25.0.w, top: 10.0.h),
              alignment: Alignment.center,
              decoration: BoxDecoration(
                border: Border(
                  bottom: BorderSide(
                      color: Colors.white,
                      width: 0.5,
                      style: BorderStyle.solid),
                ),
              ),
              padding: EdgeInsets.only(left: 0.0.w, right: 10.0.w),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.start,
                children: <Widget>[
                  Expanded(
                    child: TextField(
                      controller: _loginUser,
                      textAlign: TextAlign.left,
                      decoration: InputDecoration(
                        border: InputBorder.none,
                        hintText: '输入邮箱',
                        hintStyle: TextStyle(color: Colors.grey),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Divider(
              height: 20.0.h,
            ),
            Row(
              children: <Widget>[
                Expanded(
                  child: Padding(
                    padding: EdgeInsets.only(left: 25.0.w),
                    child: Text(
                      "密码",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.white70,
                        fontSize: 10.0.sp,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            Container(
              width: MediaQuery.of(context).size.width,
              margin: EdgeInsets.only(left: 25.0.w, right: 25.0.w, top: 10.0.h),
              alignment: Alignment.center,
              decoration: BoxDecoration(
                border: Border(
                  bottom: BorderSide(
                      color: Colors.white,
                      width: 0.5,
                      style: BorderStyle.solid),
                ),
              ),
              padding: EdgeInsets.only(left: 0.0.w, right: 10.0.w),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.start,
                children: <Widget>[
                  Expanded(
                    child: TextField(
                      controller: _loginPwd,
                      obscureText: true,
                      textAlign: TextAlign.left,
                      decoration: InputDecoration(
                        border: InputBorder.none,
                        hintText: '输入密码',
                        hintStyle: TextStyle(color: Colors.grey),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Divider(
              height: 20.0.h,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: <Widget>[
                Padding(
                  padding: EdgeInsets.only(right: 15.0.w),
                  child: FlatButton(
                    child: Text(
                      "忘记密码?",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.blue,
                        fontSize: 10.sp,
                      ),
                      textAlign: TextAlign.end,
                    ),
                    onPressed: () => {print("找回密码")},
                  ),
                ),
              ],
            ),
            Container(
              width: MediaQuery.of(context).size.width,
              margin: EdgeInsets.only(left: 25.0.w, right: 25.0.w, top: 10.0.h),
              alignment: Alignment.center,
              child: Row(
                children: <Widget>[
                  Expanded(
                    child: FlatButton(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30.0.r),
                      ),
                      color: Colors.white,
                      onPressed: _login,
                      child: Container(
                        padding: EdgeInsets.symmetric(
                          vertical: 15.0.h,
                          horizontal: 10.0.w,
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: <Widget>[
                            Expanded(
                              child: Text(
                                "登陆",
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontSize: 10.0.sp,
                                  color: Colors.redAccent,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Container(
              width: MediaQuery.of(context).size.width,
              margin: EdgeInsets.only(left: 20.0.w, right: 20.0.w, top: 10.0.h),
              alignment: Alignment.center,
              child: Row(
                children: <Widget>[
                  Expanded(
                    child: Container(
                      margin: EdgeInsets.all(8.0.r),
                      decoration:
                          BoxDecoration(border: Border.all(width: 0.25)),
                    ),
                  ),
                  Text(
                    "其他登陆方式",
                    style: TextStyle(
                      fontSize: 10.0.sp,
                      color: Colors.black,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Expanded(
                    child: Container(
                      margin: EdgeInsets.all(8.0),
                      decoration:
                          BoxDecoration(border: Border.all(width: 0.25)),
                    ),
                  ),
                ],
              ),
            ),
            Container(
              width: MediaQuery.of(context).size.width,
              margin: EdgeInsets.only(left: 25.0.w, right: 25.0.w, top: 20.0.h),
              child: Row(
                children: <Widget>[
                  Expanded(
                    child: Container(
                      margin: EdgeInsets.only(right: 8.0.w),
                      alignment: Alignment.center,
                      child: Row(
                        children: <Widget>[
                          Expanded(
                            child: FlatButton(
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(30.0.r),
                              ),
                              color: Colors.green[600],
                              onPressed: () => {},
                              child: Container(
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: <Widget>[
                                    Expanded(
                                      child: FlatButton(
                                        onPressed: () => {},
                                        padding: EdgeInsets.only(
                                          top: 15.0.h,
                                          bottom: 15.0.h,
                                        ),
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceEvenly,
                                          children: <Widget>[
                                            Icon(
                                              const IconData(0xea90,
                                                  fontFamily: 'icomoon'),
                                              color: Colors.white,
                                              size: 12.0.sp,
                                            ),
                                            Text(
                                              "微信",
                                              textAlign: TextAlign.center,
                                              style: TextStyle(
                                                fontSize: 10.0.sp,
                                                color: Colors.white,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  Expanded(
                    child: Container(
                      margin: EdgeInsets.only(left: 8.0.w),
                      alignment: Alignment.center,
                      child: Row(
                        children: <Widget>[
                          Expanded(
                            child: FlatButton(
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(30.0.r),
                              ),
                              color: Color(0Xffdb3236),
                              onPressed: () => {},
                              child: Container(
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: <Widget>[
                                    Expanded(
                                      child: FlatButton(
                                        onPressed: () => {},
                                        padding: EdgeInsets.only(
                                          top: 15.0.h,
                                          bottom: 15.0.h,
                                        ),
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceEvenly,
                                          children: <Widget>[
                                            Icon(
                                              const IconData(0xea88,
                                                  fontFamily: 'icomoon'),
                                              color: Colors.white,
                                              size: 12.0.sp,
                                            ),
                                            Text(
                                              "GOOGLE",
                                              textAlign: TextAlign.center,
                                              style: TextStyle(
                                                fontSize: 10.0.sp,
                                                color: Colors.white,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget SignupPage() {
    return SingleChildScrollView(
      child: Container(
        height: MediaQuery.of(context).size.height,
        decoration: BoxDecoration(
          color: Colors.grey[700],
          image: DecorationImage(
            colorFilter: ColorFilter.mode(
                Colors.black.withOpacity(0.05), BlendMode.dstATop),
            image: AssetImage('assets/images/mountains.jpg'),
            fit: BoxFit.cover,
          ),
        ),
        child: Column(
          children: <Widget>[
            Container(
              padding: EdgeInsets.all(70.0.r),
              child: Center(
                child: Icon(
                  Icons.home,
                  color: Colors.redAccent,
                  size: 50.0,
                ),
              ),
            ),
            Row(
              children: <Widget>[
                Expanded(
                  child: Padding(
                    padding: EdgeInsets.only(left: 25.0.w),
                    child: Text(
                      "邮箱",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.white70,
                        fontSize: 10.0.sp,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            Container(
              width: MediaQuery.of(context).size.width,
              margin: EdgeInsets.only(left: 25.0.w, right: 25.0.w, top: 5.0.h),
              alignment: Alignment.center,
              decoration: BoxDecoration(
                border: Border(
                  bottom: BorderSide(
                      color: Colors.white,
                      width: 0.5,
                      style: BorderStyle.solid),
                ),
              ),
              padding: EdgeInsets.only(left: 0.0.w, right: 10.0.w),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.start,
                children: <Widget>[
                  Expanded(
                    child: TextField(
                      controller: _registerUser,
                      textAlign: TextAlign.left,
                      decoration: InputDecoration(
                        border: InputBorder.none,
                        hintText: '输入邮箱',
                        hintStyle: TextStyle(color: Colors.grey),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Divider(
              height: 20.0.h,
            ),
            Row(
              children: <Widget>[
                Expanded(
                  child: Padding(
                    padding: EdgeInsets.only(left: 25.0.w),
                    child: Text(
                      "用户名",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.white70,
                        fontSize: 10.0.sp,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            Container(
              width: MediaQuery.of(context).size.width,
              margin: EdgeInsets.only(left: 25.0.w, right: 25.0.w, top: 5.0.w),
              alignment: Alignment.center,
              decoration: BoxDecoration(
                border: Border(
                  bottom: BorderSide(
                      color: Colors.white,
                      width: 0.5,
                      style: BorderStyle.solid),
                ),
              ),
              padding: EdgeInsets.only(left: 0.0.w, right: 10.0.w),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.start,
                children: <Widget>[
                  Expanded(
                    child: TextField(
                      controller: _registerName,
                      textAlign: TextAlign.left,
                      decoration: InputDecoration(
                        border: InputBorder.none,
                        hintText: '输入用户名',
                        hintStyle: TextStyle(color: Colors.grey),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Divider(
              height: 20.0.h,
            ),
            Row(
              children: <Widget>[
                Expanded(
                  child: Padding(
                    padding: EdgeInsets.only(left: 25.0.w),
                    child: Text(
                      "密码",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.white70,
                        fontSize: 10.0.sp,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            Container(
              width: MediaQuery.of(context).size.width,
              margin: EdgeInsets.only(left: 25.0.w, right: 25.0.w, top: 5.0.h),
              alignment: Alignment.center,
              decoration: BoxDecoration(
                border: Border(
                  bottom: BorderSide(
                      color: Colors.white,
                      width: 0.5,
                      style: BorderStyle.solid),
                ),
              ),
              padding: EdgeInsets.only(left: 0.0.w, right: 10.0.w),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.start,
                children: <Widget>[
                  Expanded(
                    child: TextField(
                      controller: _registerPwd,
                      obscureText: true,
                      textAlign: TextAlign.left,
                      decoration: InputDecoration(
                        border: InputBorder.none,
                        hintText: '输入密码',
                        hintStyle: TextStyle(color: Colors.grey),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Divider(
              height: 20.0.h,
            ),
            Row(
              children: <Widget>[
                Expanded(
                  child: Padding(
                    padding: EdgeInsets.only(left: 25.0.w),
                    child: Text(
                      "确认密码",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.white70,
                        fontSize: 10.0.sp,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            Container(
              width: MediaQuery.of(context).size.width,
              margin: EdgeInsets.only(left: 25.0.w, right: 25.0.w, top: 5.0.h),
              alignment: Alignment.center,
              decoration: BoxDecoration(
                border: Border(
                  bottom: BorderSide(
                      color: Colors.white,
                      width: 0.5,
                      style: BorderStyle.solid),
                ),
              ),
              padding: EdgeInsets.only(left: 0.0.w, right: 10.0.h),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.start,
                children: <Widget>[
                  Expanded(
                    child: TextField(
                      controller: _registerCheckPwd,
                      obscureText: true,
                      textAlign: TextAlign.left,
                      decoration: InputDecoration(
                        border: InputBorder.none,
                        hintText: '确认密码',
                        hintStyle: TextStyle(color: Colors.grey),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Divider(
              height: 20.0.h,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: <Widget>[
                Padding(
                  padding: EdgeInsets.only(right: 15.0.w),
                  child: FlatButton(
                    child: Text(
                      "已有帐号?立刻登陆!",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.blue,
                        fontSize: 10.0.sp,
                      ),
                      textAlign: TextAlign.end,
                    ),
                    onPressed: gotoLogin,
                  ),
                ),
              ],
            ),
            Container(
              width: MediaQuery.of(context).size.width,
              margin: EdgeInsets.only(left: 20.0.w, right: 20.0.w, top: 10.0.h),
              alignment: Alignment.center,
              child: Row(
                children: <Widget>[
                  Expanded(
                    child: FlatButton(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30.0),
                      ),
                      color: Color(0XFFFFFFFF),
                      onPressed: _register,
                      child: Container(
                        padding: EdgeInsets.symmetric(
                          vertical: 15.0.h,
                          horizontal: 10.0.w,
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: <Widget>[
                            Expanded(
                              child: Text(
                                "注册",
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontSize: 10.0.sp,
                                  color: Colors.redAccent,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  gotoLogin() {
    //controller_0To1.forward(from: 0.0);
    _controller.animateToPage(
      0,
      duration: Duration(milliseconds: 800),
      curve: Curves.bounceOut,
    );
  }

  gotoSignup() {
    //controller_minus1To0.reverse(from: 0.0);
    _controller.animateToPage(
      2,
      duration: Duration(milliseconds: 800),
      curve: Curves.bounceOut,
    );
  }

  initSDK() async {
    V2TIMManager timManager = TencentImSDKPlugin.v2TIMManager;
    await timManager.initSDK(
      sdkAppID: Config.sdkappid,
      loglevel: LogLevelEnum.V2TIM_LOG_DEBUG,
      listener: V2TimSDKListener(
        onConnectFailed: (code, error) {
          print("初始化SDK失败");
          showToast("sdk初始化失败，聊天功能将无法使用");
        },
        onConnectSuccess: () {
          print("初始化SDK成功");
          // showToast("sdk初始化成功");
        },
        onConnecting: () {},
        onKickedOffline: () {
          showToast("被踢下线");
        },
        onSelfInfoUpdated: (info) {
          // showToast("sdk个人信息发生变化");
        },
        onUserSigExpired: () {
          // showToast("sdk 签名过期");
        },
      ),
    );

    print("初始化sdk");
  }

  void loadData() async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    String? token = sharedPreferences.getString("token");
    if (token != null && token != "") {
      _tokenLogin(token);
    }
  }

  //调用后台tokenlogin接口
  void _tokenLogin(String token) async {
    bool result = await context.read<LoginViewmodel>().tokenLogin(token);
    bool sdkRes = await context.read<LoginViewmodel>().sdkInit(Config.sdkappid);
    if (result == true && sdkRes == true) {
      Navigator.of(context).popAndPushNamed("menu");
    }
  }

  //调用后台login接口
  void _login() async {
    Provider.of<LoginViewmodel>(context, listen: false).clear();
    Provider.of<ConversationViewModel>(context, listen: false).clear();
    Provider.of<ChatViewModel>(context, listen: false).clear();
    bool result = await context
        .read<LoginViewmodel>()
        .login(_loginUser.text, _loginPwd.text);
    print(_loginUser.text);
    print(_loginPwd.text);
    //初始化 im sdk
    bool sdkRes = await context.read<LoginViewmodel>().sdkInit(Config.sdkappid);
    if (result == true && sdkRes == true) {
      _loginUser.clear();
      _loginPwd.clear();
      Navigator.of(context).popAndPushNamed("menu");
    }
  }

  // 调用后台register接口
  void _register() async {
    bool result = await context.read<LoginViewmodel>().register(
        _registerUser.text,
        _registerName.text,
        _registerPwd.text,
        _registerCheckPwd.text);
    if (result == true) {
      _registerUser.clear();
      _registerName.clear();
      _registerPwd.clear();
      _registerCheckPwd.clear();
      gotoLogin();
    }
  }

  PageController _controller =
      PageController(initialPage: 1, viewportFraction: 1.0);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        height: MediaQuery.of(context).size.height,
        child: PageView(
          controller: _controller,
          physics: AlwaysScrollableScrollPhysics(),
          children: [LoginPage(), HomePage(), SignupPage()],
          scrollDirection: Axis.horizontal,
        ),
      ),
    );

    // return Container(
    //   height: MediaQuery.of(context).size.height,
//      child:  GestureDetector(
//        onHorizontalDragStart: _onHorizontalDragStart,
//        onHorizontalDragUpdate: _onHorizontalDragUpdate,
//        onHorizontalDragEnd: _onHorizontalDragEnd,
//        behavior: HitTestBehavior.translucent,
//        child: Stack(
//          children: <Widget>[
//             FractionalTranslation(
//              translation: Offset(-1 - (scrollPercent / (1 / numCards)), 0.0),
//              child: SignupPage(),
//            ),
//             FractionalTranslation(
//              translation: Offset(0 - (scrollPercent / (1 / numCards)), 0.0),
//              child: HomePage(),
//            ),
//             FractionalTranslation(
//              translation: Offset(1 - (scrollPercent / (1 / numCards)), 0.0),
//              child: LoginPage(),
//            ),
//          ],
//        ),
//      ),
    // child: PageView(
    //   controller: _controller,
    //   physics: AlwaysScrollableScrollPhysics(),
    //   children: <Widget>[LoginPage(), HomePage(), SignupPage()],
    //   scrollDirection: Axis.horizontal,
    // ),
    // );
  }
}
