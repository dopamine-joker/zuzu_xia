import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:flutter_demo/utils/dialog.dart';
import 'package:flutter_demo/utils/event.dart';
import 'package:flutter_demo/view/upload/image_upload.dart';
import 'package:flutter_demo/viewmodel/upload_viewmodel.dart';
import 'package:provider/src/provider.dart';
import 'package:dialogs/dialogs/progress_dialog.dart';

final _formKey = GlobalKey<FormBuilderState>();

class uploadView extends StatefulWidget {
  const uploadView({Key? key}) : super(key: key);

  @override
  _uploadViewState createState() => _uploadViewState();
}

class _uploadViewState extends State<uploadView> {
  int _typeValue = -1;

  TextEditingController _uploadName = TextEditingController();
  TextEditingController _uploadPrice = TextEditingController();
  TextEditingController _uploadType = TextEditingController(text: "请选择");
  TextEditingController _uploadSchool = TextEditingController();
  TextEditingController _uploadDetail = TextEditingController();

  imageUploadWidget _uploadPicWidget = imageUploadWidget(imgNum: 6);
  imageUploadWidget _uploadCoverPicWidget = imageUploadWidget(imgNum: 1);


  @override
  void initState() {
    super.initState();

    eventBus.on<UploadErrEvent>().listen((event) {
      getDialog("上传提示", event.detail).show(context);
    });
  }

  void _upload() async {
    print(_uploadSchool.text);
    ProgressDialog dialog = getProgressDialog(context, "上传中...");
    dialog.show();
    context.read<UploadVideModel>().upload(
      _uploadName.text,
      _uploadPrice.text,
      _typeValue,
      _uploadSchool.text,
      _uploadDetail.text,
      _uploadCoverPicWidget.imageList,
      _uploadPicWidget.imageList,
    ).then((result) {
      dialog.dismiss();
      if (result) {
        showToast("上传成功");
        Navigator.of(context).pop();
      } else {
        showToast("上传失败,请检查信息是否正确");
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        backgroundColor: Colors.grey[800],
        title: Text(
          "上传",
          style: TextStyle(
            fontSize: 15.0.sp,
          ),
        ),
        elevation: 10,
        actions: [
          Container(
            margin: EdgeInsets.fromLTRB(0, 10.0.h, 10.0.w, 10.0.h),
            child: ElevatedButton(
              onPressed: () {
                _upload();
                // Navigator.of(context).pop();
              },
              child: Text("上传"),
              style: ButtonStyle(
                backgroundColor: MaterialStateProperty.all(Colors.green),
              ),
            ),
          )
        ],
        // centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Form(
          autovalidateMode: AutovalidateMode.always,
          child: Container(
            // height: MediaQuery.of(context).size.height,
            // height: 2000,
            decoration: BoxDecoration(
              color: Colors.grey[700],
              image: DecorationImage(
                colorFilter: ColorFilter.mode(
                    Colors.black.withOpacity(0.05), BlendMode.dstATop),
                image: AssetImage('assets/images/mountains.jpg'),
                fit: BoxFit.cover,
              ),
            ),
            // child: Expanded(
            child: Column(
              children: [
                SizedBox(
                  height: 15.0.h,
                ),
                Container(
                  width: MediaQuery
                      .of(context)
                      .size
                      .width,
                  margin:
                  EdgeInsets.only(left: 25.0.w, right: 25.0.w, top: 5.0.h),
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
                          maxLength: 20,
                          controller: _uploadName,
                          textAlign: TextAlign.left,
                          keyboardType: TextInputType.name,
                          textInputAction: TextInputAction.next,
                          decoration: InputDecoration(
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(15.0.sp),
                            ),
                            prefixIcon: Icon(Icons.category),
                            labelText: "物品名称",
                            labelStyle: TextStyle(
                              color: Colors.white,
                            ),
                            hintText: "输入名称",
                            hintStyle: TextStyle(
                              color: Colors.grey,
                            ),
                          ),
                          validator: (v) {
                            if (v == null || v.length == 0) {
                              return "物品名称非空";
                            }
                          },
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  width: MediaQuery
                      .of(context)
                      .size
                      .width,
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
                        flex: 2,
                        child: TextFormField(
                          controller: _uploadPrice,
                          maxLength: 10,
                          textAlign: TextAlign.left,
                          keyboardType: TextInputType.number,
                          inputFormatters: [
                            LengthLimitingTextInputFormatter(10),
                          ],
                          textInputAction: TextInputAction.next,
                          decoration: InputDecoration(
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(15.0.sp),
                            ),
                            prefixIcon: Icon(Icons.money),
                            labelText: "物品价格",
                            labelStyle: TextStyle(
                              color: Colors.white,
                            ),
                            // border: InputBorder.none,
                            hintText: "输入价格",
                            hintStyle: TextStyle(color: Colors.grey),
                          ),
                          validator: (v) {
                            if (v == null || v.length == 0) {
                              return "价格非空";
                            }
                            if (double.tryParse(v) == null) {
                              return "请输入数字";
                            }
                          },
                        ),
                      ),
                      SizedBox(
                        width: 10.w,
                      ),
                      Expanded(
                        child: InkWell(
                          onTap: () async {
                            print("!!!!!");
                            await showDialog(
                              context: context,
                              builder: (context) {
                                return SimpleDialog(
                                  title: Text("请选择"),
                                  children: [
                                    SimpleDialogOption(
                                      child: Text("每分钟"),
                                      onPressed: () {
                                        _uploadType.text = "每分钟";
                                        _typeValue = 1;
                                        Navigator.pop(context);
                                      },
                                    ),
                                    Divider(),
                                    SimpleDialogOption(
                                      child: Text("每小时"),
                                      onPressed: () {
                                        _uploadType.text = "每小时";
                                        _typeValue = 2;
                                        Navigator.pop(context);
                                      },
                                    ),
                                    Divider(),
                                    SimpleDialogOption(
                                      child: Text("每天"),
                                      onPressed: () {
                                        _uploadType.text = "每天";
                                        _typeValue = 3;
                                        Navigator.pop(context);
                                      },
                                    ),
                                    Divider(),
                                    SimpleDialogOption(
                                      child: Text("每月"),
                                      onPressed: () {
                                        _uploadType.text = "每月";
                                        _typeValue = 4;
                                        Navigator.pop(context);
                                      },
                                    ),
                                    Divider(),
                                    SimpleDialogOption(
                                      child: Text("每年"),
                                      onPressed: () {
                                        _uploadType.text = "每年";
                                        _typeValue = 5;
                                        Navigator.pop(context);
                                      },
                                    ),
                                    Divider(),
                                    SimpleDialogOption(
                                      child: Text("其他"),
                                      onPressed: () {
                                        _uploadType.text = "其他";
                                        _typeValue = 0;
                                        Navigator.pop(context);
                                      },
                                    ),
                                  ],
                                );
                              },
                            );
                          },
                          child: TextFormField(
                            // enableInteractiveSelection: false,
                            enabled: false,
                            controller: _uploadType,
                            maxLength: 10,
                            textAlign: TextAlign.center,
                            inputFormatters: [
                              LengthLimitingTextInputFormatter(10),
                            ],
                            textInputAction: TextInputAction.next,
                            decoration: InputDecoration(
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(15.0.sp),
                              ),
                              labelText: "价格时间单位",
                              labelStyle: TextStyle(
                                color: Colors.white,
                              ),
                              // border: InputBorder.none,
                            ),
                            validator: (v) {
                              if(_typeValue <= 0 || _typeValue >= 5) {
                                return "请选择";
                              }
                            },
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  width: MediaQuery
                      .of(context)
                      .size
                      .width,
                  margin:
                  EdgeInsets.only(left: 25.0.w, right: 25.0.w, top: 5.0.h),
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
                          maxLength: 20,
                          controller: _uploadSchool,
                          textAlign: TextAlign.left,
                          keyboardType: TextInputType.name,
                          textInputAction: TextInputAction.next,
                          decoration: InputDecoration(
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(15.0.sp),
                            ),
                            prefixIcon: Icon(Icons.category),
                            labelText: "学校",
                            labelStyle: TextStyle(
                              color: Colors.white,
                            ),
                            hintText: "输入学校",
                            hintStyle: TextStyle(
                              color: Colors.grey,
                            ),
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
                ),
                Container(
                  width: MediaQuery
                      .of(context)
                      .size
                      .width,
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
                          controller: _uploadDetail,
                          textAlign: TextAlign.left,
                          keyboardType: TextInputType.text,
                          textInputAction: TextInputAction.next,
                          decoration: InputDecoration(
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(15.0.sp),
                            ),
                            prefixIcon: Icon(Icons.text_fields),
                            labelText: "物品描述",
                            labelStyle: TextStyle(
                              color: Colors.white,
                            ),
                            // border: InputBorder.none,
                            hintText: "物品描述,最多200字",
                            hintStyle: TextStyle(color: Colors.grey),
                          ),
                          validator: (v) {
                            if (v == null || v.length == 0) {
                              return "描述非空";
                            }
                          },
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  width: MediaQuery
                      .of(context)
                      .size
                      .width,
                  margin:
                  EdgeInsets.only(left: 20.0.w, right: 20.0.w, top: 10.0.h),
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
                        "物品封面",
                        style: TextStyle(
                          fontSize: 10.0.sp,
                          color: Colors.white,
                          // fontWeight: FontWeight.bold,
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
                _uploadCoverPicWidget,
                Container(
                  width: MediaQuery
                      .of(context)
                      .size
                      .width,
                  margin:
                  EdgeInsets.only(left: 20.0.w, right: 20.0.w, top: 10.0.h),
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
                        "物品照片(最多六张)",
                        style: TextStyle(
                          fontSize: 10.0.sp,
                          color: Colors.white,
                          // fontWeight: FontWeight.bold,
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
                _uploadPicWidget,
              ],
            ),
            // ),
          ),
        ),
      ),
    );
  }
}
