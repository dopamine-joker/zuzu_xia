import 'package:dialogs/dialogs/choice_dialog.dart';
import 'package:dialogs/dialogs/message_dialog.dart';
import 'package:dialogs/dialogs/progress_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:fluttertoast/fluttertoast.dart';

ProgressDialog getProgressDialog(context, String loadingText) {
  return ProgressDialog(
    context: context,
    loadingText: loadingText,
    backgroundColor: Colors.grey,
    textColor: Colors.white,
  );
}

MessageDialog getDialog(title, text) {
  return MessageDialog(
    dialogBackgroundColor: Colors.white,
    title: title,
    titleColor: Colors.black,
    message: text,
    messageColor: Colors.black,
    buttonOkText: "OK",
    buttonOkColor: Colors.blueAccent,
    dialogRadius: 15.0,
    buttonRadius: 15.0,
    iconButtonOk: const Icon(Icons.one_k),
  );
}

ChoiceDialog getChoiceDialog(title, text, okFunc, cancelFunc) {
  return ChoiceDialog(
    dialogBackgroundColor: Colors.white,
    title: title,
    titleColor: Colors.black,
    message: text,
    messageColor: Colors.black,
    buttonOkText: "确定",
    buttonOkColor: Colors.blueAccent,
    buttonOkOnPressed: okFunc,
    buttonCancelText: "取消",
    buttonCancelBorderColor: Colors.blueAccent,
    buttonCancelOnPressed: cancelFunc,
    buttonRadius: 15.0,
    dialogRadius: 15.0,
    iconButtonOk: const Icon(Icons.one_k),
    iconButtonCancel: const Icon(Icons.cancel),
  );
}

void showToast(text) {
  Fluttertoast.showToast(
    msg: text,
    toastLength: Toast.LENGTH_SHORT,
    gravity: ToastGravity.BOTTOM,
    timeInSecForIosWeb: 1,
    backgroundColor: Colors.black,
    textColor: Colors.white,
    fontSize: 16.0.sp,
  );
}
