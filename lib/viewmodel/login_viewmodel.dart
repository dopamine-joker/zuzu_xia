import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter_demo/config/config.dart';
import 'package:flutter_demo/global/global.dart';
import 'package:flutter_demo/global/rescode.dart';
import 'package:flutter_demo/model/login_model.dart';
import 'package:flutter_demo/utils/dialog.dart';
import 'package:flutter_demo/utils/event.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tencent_im_sdk_plugin/models/v2_tim_user_full_info.dart';
import 'package:tencent_im_sdk_plugin/models/v2_tim_user_info.dart';
import 'package:tencent_im_sdk_plugin/models/v2_tim_value_callback.dart';
import 'package:tencent_im_sdk_plugin/tencent_im_sdk_plugin.dart';

// 全局状态管理
class LoginViewmodel extends ChangeNotifier {
  bool _isLogin = false;
  String _facePath = "";

  get getIsLogin => _isLogin;
  get face => _facePath;

  setIsLogin(bool value) {
    _isLogin = value;
    notifyListeners();
  }

  clear() {
    _isLogin = false;
    notifyListeners();
  }

  Future<bool> logout(String token) async {
    if (token == "") {
      eventBus.fire(MeErrEvent("退出失败，登陆已过期"));
      return false;
    }
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    Response rsp = await logoutModel(token);
    try {
      if (rsp.data["code"] == Code.codeFail ||
          rsp.data["code"] == Code.codeTokenErr || rsp.data["code"] == Code.codeAPILimit) {
        eventBus.fire(MeErrEvent(rsp.data["message"]));
        return false;
      }
    } catch (e) {
      print("logout err" + e.toString());
    }
    sharedPreferences.remove("token");
    sharedPreferences.remove("id");
    sharedPreferences.remove("email");
    sharedPreferences.remove("name");
    sharedPreferences.remove("userSig");
    setIsLogin(false);
    return true;
  }

  Future<bool> sdkInit(int sdkAppId) async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    String userIdStr = sharedPreferences.getInt("id").toString();
    if (sdkAppId <= 0) {
      return false;
    }
    Response sdkRsp = await getSig(userIdStr, Config.sdkappid, 24 * 60 * 3600);
    try {
      String sig = sdkRsp.data["data"]["sig"].toString();
      TencentImSDKPlugin.v2TIMManager
          .login(
        userID: userIdStr,
        userSig: sig,
      )
          .then(
        (res) async {
          if (res.code != 0) {
            throw Exception("登录出错, ${res.desc}");
          }
          V2TimValueCallback<List<V2TimUserFullInfo>> infos =
              await TencentImSDKPlugin.v2TIMManager.getUsersInfo(
            userIDList: [userIdStr],
          );
          if (infos.code == 0) {
            String Uname = await sharedPreferences.getString("name")!;
            if (infos.data![0].nickName.toString() != Uname) {
              TencentImSDKPlugin.v2TIMManager.setSelfInfo(
                userFullInfo: V2TimUserFullInfo.fromJson(
                  {
                    "nickName": Uname,
                  },
                ),
              );
            }
            print("sdk中用户身份" + infos.toJson().toString());
          }
        },
      );

      sharedPreferences.setString("sig", sdkRsp.data["data"]["sig"].toString());
    } catch (e) {
      showToast(e.toString());
      return false;
    }
    return true;
  }

  Future<bool> tokenLogin(token) async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    setIsLogin(false);
    if (token == null || token == "") {
      return false;
    }
    Response rsp = await tokenLoginModel(token);
    try {
      if (rsp.data["code"] == Code.codeFail) {
        sharedPreferences.remove("token");
        return false;
      }
      if (rsp.data["code"] == Code.codeFail) {
        return false;
      }

      _facePath = rsp.data["data"]["user"]["Face"];
    } catch (e) {
      eventBus.fire(LoginInErrEvent(e.toString()));
      return false;
    }
    sharedPreferences.setInt("id", rsp.data["data"]["user"]["Id"]);
    sharedPreferences.setString(
        "email", rsp.data["data"]["user"]["Email"].toString());
    sharedPreferences.setString(
        "name", rsp.data["data"]["user"]["Name"].toString());
    sharedPreferences.setString(
        "face", rsp.data["data"]["user"]["Face"].toString());
    setIsLogin(true);
    return true;
  }

  Future<bool> login(user, pwd) async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    setIsLogin(false);
    if (user == "") {
      eventBus.fire(LoginInErrEvent("邮箱不能为空!"));
      return false;
    }
    if (pwd == "") {
      eventBus.fire(LoginInErrEvent("密码不能为空!"));
      return false;
    }
    Response rsp = await loginModel(user, pwd);
    try {
      print(rsp.runtimeType);
      print(rsp.headers.toString());
      print(rsp.data.toString());
      print("code=" + rsp.data["code"].toString());
      print("data=" + rsp.data["data"].toString());

      if (rsp.data["code"] == Code.codeFail) {
        eventBus.fire(LoginInErrEvent(rsp.data["message"]));
        return false;
      }
      _facePath = rsp.data["data"]["user"]["Face"];
    } catch (e) {
      eventBus.fire(LoginInErrEvent(e.toString()));
      return false;
    }

    // 保存token
    sharedPreferences.setString("token", rsp.data["data"]["token"].toString());
    sharedPreferences.setInt("id", rsp.data["data"]["user"]["Id"]);
    sharedPreferences.setString(
        "email", rsp.data["data"]["user"]["Email"] == null? "": rsp.data["data"]["user"]["Email"].toString());
    sharedPreferences.setString(
        "name", rsp.data["data"]["user"]["Name"] == null? "":  rsp.data["data"]["user"]["Name"].toString());
    sharedPreferences.setString(
        "face", rsp.data["data"]["user"]["Face"] == null ? "": rsp.data["data"]["user"]["Face"].toString());
    sharedPreferences.setString(
        "phone", rsp.data["data"]["user"]["phone"] == null ? "" : rsp.data["data"]["user"]["phone"].toString());
    sharedPreferences.setString(
        "school", rsp.data["data"]["user"]["school"] == null ? "" : rsp.data["data"]["user"]["school"].toString());
    sharedPreferences.setInt(
        "sex", rsp.data["data"]["user"]["sex"]);
    setIsLogin(true);
    return true;
  }

  Future<bool> register(user, name, pwd, checkPwd) async {
    if (user == "") {
      eventBus.fire(RegisterErrEvent("邮箱不能为空!"));
      return false;
    }
    if (name == "") {
      eventBus.fire(RegisterErrEvent("用户名不能为空!"));
      return false;
    }
    if (pwd == "") {
      eventBus.fire(RegisterErrEvent("密码不能为空!"));
      return false;
    }
    if (pwd != checkPwd) {
      eventBus.fire(RegisterErrEvent("密码输入不一致"));
      return false;
    }
    Response rsp = await registerModel(user, pwd, name);
    try {
      print(rsp.data);
      if (rsp.data["code"] == Code.codeFail) {
        eventBus.fire(LoginInErrEvent(rsp.data["message"]));
        return false;
      }
    } catch (e) {
      print("register err:" + e.toString());
    }
    return true;
  }

  Future<bool> updateUser(
      String token, String email, String phone, String name, String school, String password, int sex, int uid) async {
    if (token == "" || email == "" || name == "" || password == "") {
      showToast("存在空数据");
      return false;
    }

    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    Response rsp = await updateUserModel(token, email, phone, name, school, sex, password, uid);
    try {
      if (rsp.data["code"] == Code.codeFail ||
          rsp.data["code"] == Code.codeTokenErr || rsp.data["code"] == Code.codeAPILimit) {
        showToast(rsp.data["message"]);
        return false;
      }

      TencentImSDKPlugin.v2TIMManager.setSelfInfo(
        userFullInfo: V2TimUserFullInfo.fromJson(
          {
            "userID": uid.toString(),
            "nickName": name,
          },
        ),
      );
      await logout(token);
      await login(email, password);
      await sdkInit(Config.sdkappid);
    } catch (e) {
      showToast("更新失败 ${e.toString()}");
      return false;
    }
    notifyListeners();
    return true;
  }

  Future<bool> UpdataFace(String token, int uid, XFile uploadFace) async {
    dynamic img = MultipartFile.fromFileSync(
      uploadFace.path,
      filename: uploadFace.name,
    );

    var formData = FormData.fromMap({
      'id': uid,
      'face': img,
    });

    Response rsp = await uploadFaceModel(token, formData);
    try {
      if (rsp.data["code"] == Code.codeFail ||
          rsp.data["code"] == Code.codeTokenErr || rsp.data["code"] == Code.codeAPILimit) {
        showToast("上传失败, ${rsp.data['message']}");
        return false;
      }

      _facePath = rsp.data["data"]["path"];
    } catch (e) {
      showToast("上传 ${e.toString()}");
      return false;
    }
    notifyListeners();
    return true;
  }
}
