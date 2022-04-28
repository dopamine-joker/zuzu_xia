import 'package:dialogs/dialogs.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_demo/global/global.dart';
import 'package:flutter_demo/utils/dialog.dart';
import 'package:flutter_demo/viewmodel/comment_viewmodel.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/src/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../viewmodel/order_viewmodel.dart';

class CommentView extends StatefulWidget {
  int gid;
  int oid;

  CommentView({Key? key, required this.gid, required this.oid})
      : super(key: key);

  @override
  _CommentViewState createState() => _CommentViewState();
}

class _CommentViewState extends State<CommentView> {
  TextEditingController _commentContent = TextEditingController();
  TextEditingController _commentLevel = TextEditingController();

  _commit(int gid, int oid) async {
    ProgressDialog dialog = getProgressDialog(context, "请等待...");
    dialog.show();
    String token = await getToken();
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    int? uid = sharedPreferences.getInt("id");
    context
        .read<CommentViewModel>()
        .addCommentModel(
          token,
          uid!,
          gid,
          oid,
          int.tryParse(_commentLevel.text) ?? 0,
          _commentContent.text,
        )
        .then((value) {
      dialog.dismiss();
      if (value == true) {
        showToast("评论成功");
        context.read<OrderViewModel>().getBuyOrder(token, uid);
        Navigator.pop(context);
      } else {
        showToast("评论失败");
      }
    });
    print("提交评论");
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.grey[800],
        title: Text(
          "评论",
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
                _commit(widget.gid, widget.oid);
              },
              child: Text("提交"),
              style: ButtonStyle(
                backgroundColor: MaterialStateProperty.all(Colors.green),
              ),
            ),
          )
        ],
      ),
      body: SingleChildScrollView(
        child: Form(
          autovalidateMode: AutovalidateMode.always,
          child: Column(
            children: [
              Container(
                width: MediaQuery.of(context).size.width,
                margin:
                    EdgeInsets.only(left: 25.0.w, right: 25.0.w, top: 20.0.h),
                // padding: EdgeInsets.only(left: 0.0.w, right: 10.0.w),
                alignment: Alignment.center,
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: <Widget>[
                    Expanded(
                      child: TextFormField(
                        maxLines: 5,
                        maxLength: 200,
                        controller: _commentContent,
                        textAlign: TextAlign.left,
                        keyboardType: TextInputType.text,
                        textInputAction: TextInputAction.next,
                        decoration: InputDecoration(
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(15.0.sp),
                          ),
                          prefixIcon: Icon(Icons.text_fields),
                          labelText: "评论内容",
                          labelStyle: TextStyle(
                            color: Colors.blue,
                          ),
                          // border: InputBorder.none,
                          hintText: "评论内容,最多200字",
                          hintStyle: TextStyle(color: Colors.grey),
                        ),
                        validator: (v) {
                          if (v == null || v.length == 0) {
                            return "评论为空";
                          }
                        },
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                width: MediaQuery.of(context).size.width,
                margin:
                    EdgeInsets.only(left: 25.0.w, right: 25.0.w, top: 20.0.h),
                // padding: EdgeInsets.only(left: 0.0.w, right: 10.0.w),
                alignment: Alignment.center,
                decoration: BoxDecoration(
                    // border: Border(
                    //   bottom: BorderSide(
                    //       color: Colors.white,
                    //       width: 0.5,
                    //       style: BorderStyle.solid),
                    // ),
                    ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: <Widget>[
                    Expanded(
                      child: TextFormField(
                        controller: _commentLevel,
                        maxLength: 1,
                        textAlign: TextAlign.left,
                        keyboardType: TextInputType.number,
                        inputFormatters: [
                          LengthLimitingTextInputFormatter(1),
                        ],
                        textInputAction: TextInputAction.next,
                        decoration: InputDecoration(
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(15.0.sp),
                          ),
                          prefixIcon: Icon(Icons.money),
                          labelText: "物品评分",
                          labelStyle: TextStyle(
                            color: Colors.white,
                          ),
                          // border: InputBorder.none,
                          hintText: "物品评分(1-5)",
                          hintStyle: TextStyle(color: Colors.blue),
                        ),
                        validator: (v) {
                          if (v == null || v.length == 0) {
                            return "评分非空";
                          }
                          if (int.tryParse(v) == null) {
                            return "请输入数字";
                          }
                          int num = int.tryParse(v) ?? 0;
                          print(num);
                          if (num < 0 || num > 5) {
                            return "评论区间1-5";
                          }
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
