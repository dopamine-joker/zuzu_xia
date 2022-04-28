import 'package:dialogs/dialogs.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_demo/global/global.dart';
import 'package:flutter_demo/utils/dialog.dart';
import 'package:flutter_demo/view/login_view.dart';
import 'package:flutter_demo/viewmodel/login_viewmodel.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class UserInfoView extends StatefulWidget {
  const UserInfoView({Key? key}) : super(key: key);

  @override
  _UserInfoViewState createState() => _UserInfoViewState();
}

class _UserInfoViewState extends State<UserInfoView> {
  TextEditingController _userName = TextEditingController();
  TextEditingController _userEmail = TextEditingController();
  TextEditingController _userPhone = TextEditingController();
  TextEditingController _userSchool= TextEditingController();
  TextEditingController _userPassword = TextEditingController();
  int _sex = 3;

  @override
  void initState() {
    super.initState();
    _initData();
  }

  _initData() async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    _userName.text = sharedPreferences.getString("name") ?? "";
    _userEmail.text = sharedPreferences.getString("email") ?? "";
    _userPhone.text = sharedPreferences.getString("phone") ?? "";
    _userSchool.text = sharedPreferences.getString("school") ?? "";
    setState(() {
      _sex = sharedPreferences.getInt("sex") ?? 3;
    });
  }

  @override
  void dispose() {
    super.dispose();
    _userName.dispose();
    _userEmail.dispose();
    _userPhone.dispose();
    _userSchool.dispose();
    _userPassword.dispose();
  }

  _update() async {
    ProgressDialog dialog = getProgressDialog(context, "请等待...");
    dialog.show();
    String token = await getToken();
    int id = await getUserId();
    context.read<LoginViewmodel>().updateUser(
          token,
          _userEmail.text,
          _userPhone.text,
          _userName.text,
          _userSchool.text,
          _userPassword.text,
          _sex,
          id,
        ).then((result) {
      dialog.dismiss();
      if (result) {
        showToast("修改成功");
        Navigator.of(context).pop();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.grey[800],
        title: Text(
          "信息",
          style: TextStyle(
            fontSize: 15.0.sp,
          ),
        ),
        elevation: 10,
        centerTitle: true,
        actions: [
          Container(
            margin: EdgeInsets.fromLTRB(0, 10.0.h, 10.0.w, 10.0.h),
            child: ElevatedButton(
              onPressed: () {
                _update();
                // Navigator.of(context).pop();
              },
              child: Text("提交"),
              style: ButtonStyle(
                backgroundColor: MaterialStateProperty.all(Colors.green),
              ),
            ),
          )
        ],
      ),
      body: Container(
        margin: EdgeInsets.all(10.0.w),
        child: Column(
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.start,
              children: <Widget>[
                Expanded(
                  child: TextFormField(
                    controller: _userEmail,
                    textAlign: TextAlign.left,
                    keyboardType: TextInputType.name,
                    textInputAction: TextInputAction.next,
                    decoration: InputDecoration(
                      labelText: "邮箱",
                      labelStyle: TextStyle(
                        color: Colors.blue,
                      ),
                      hintText: "输入名称",
                      hintStyle: TextStyle(
                        color: Colors.grey,
                      ),
                      prefixIcon: Icon(Icons.email),
                    ),
                    validator: (v) {
                      if (v == null || v.length == 0) {
                        return "邮箱非空";
                      }
                    },
                  ),
                ),
              ],
            ),
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.start,
              children: <Widget>[
                Expanded(
                  child: TextFormField(
                    controller: _userName,
                    textAlign: TextAlign.left,
                    keyboardType: TextInputType.name,
                    textInputAction: TextInputAction.next,
                    decoration: InputDecoration(
                      labelText: "用户名",
                      labelStyle: TextStyle(
                        color: Colors.blue,
                      ),
                      hintText: "输入名称",
                      hintStyle: TextStyle(
                        color: Colors.grey,
                      ),
                      prefixIcon: Icon(Icons.person),
                    ),
                    validator: (v) {
                      if (v == null || v.length == 0) {
                        return "用户名非空";
                      }
                    },
                  ),
                ),
              ],
            ),
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.start,
              children: <Widget>[
                Expanded(
                  child: TextFormField(
                    controller: _userPhone,
                    textAlign: TextAlign.left,
                    keyboardType: TextInputType.name,
                    textInputAction: TextInputAction.next,
                    decoration: InputDecoration(
                      labelText: "手机号码",
                      labelStyle: TextStyle(
                        color: Colors.blue,
                      ),
                      hintText: "输入号码",
                      hintStyle: TextStyle(
                        color: Colors.grey,
                      ),
                      prefixIcon: Icon(Icons.phone),
                    ),
                    validator: (v) {
                      if (v == null || v.length == 0) {
                        return "手机号码非空";
                      }
                    },
                  ),
                ),
              ],
            ),
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.start,
              children: <Widget>[
                Expanded(
                  child: TextFormField(
                    controller: _userSchool,
                    textAlign: TextAlign.left,
                    keyboardType: TextInputType.name,
                    textInputAction: TextInputAction.next,
                    decoration: InputDecoration(
                      labelText: "学校",
                      labelStyle: TextStyle(
                        color: Colors.blue,
                      ),
                      hintText: "输入学校",
                      hintStyle: TextStyle(
                        color: Colors.grey,
                      ),
                      prefixIcon: Icon(Icons.school),
                    ),
                    validator: (v) {
                      if (v == null || v.length == 0) {
                        return "学校非空";
                      }
                    },
                  ),
                ),
              ],
            ),
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.start,
              children: <Widget>[
                Expanded(
                  child: TextFormField(
                    controller: _userPassword,
                    textAlign: TextAlign.left,
                    keyboardType: TextInputType.name,
                    textInputAction: TextInputAction.next,
                    decoration: InputDecoration(
                      labelText: "密码",
                      labelStyle: TextStyle(
                        color: Colors.blue,
                      ),
                      hintText: "密码",
                      hintStyle: TextStyle(
                        color: Colors.grey,
                      ),
                      prefixIcon: Icon(Icons.lock),
                    ),
                    obscureText: true,
                    validator: (v) {
                      if (v == null || v.length == 0) {
                        return "密码非空";
                      }
                    },
                  ),
                ),
              ],
            ),
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.end,
              children: <Widget>[
                Text("男:"),
                Radio<int>(
                  value: 1,
                  groupValue: this._sex,
                  onChanged: (value) {
                    setState(() {
                      this._sex = value!;
                    });
                  },
                ),
                SizedBox(width: 20),
                Text("女:"),
                Radio<int>(
                  value: 2,
                  groupValue: this._sex,
                  onChanged: (value) {
                    setState(() {
                      this._sex =  value!;
                    });
                  },
                ),
                SizedBox(width: 20),
                Text("未知:"),
                Radio<int>(
                  value: 3,
                  groupValue: this._sex,
                  onChanged: (value) {
                    setState(() {
                      this._sex =  value!;
                    });
                  },
                )
              ],
            ),
          ],
        ),
      ),
    );
  }
}
