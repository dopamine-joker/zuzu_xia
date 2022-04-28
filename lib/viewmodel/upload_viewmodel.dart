import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_demo/global/global.dart';
import 'package:flutter_demo/global/rescode.dart';
import 'package:flutter_demo/model/upload_model.dart';
import 'package:flutter_demo/utils/dialog.dart';
import 'package:flutter_demo/utils/event.dart';
import 'package:shared_preferences/shared_preferences.dart';

class UploadVideModel extends ChangeNotifier {
  Future<bool> upload(
      name, price, type, school, detail, coverList, uploadList) async {

    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    int userId = sharedPreferences.getInt("id") ?? -1;

    List<dynamic> _imgListUpload = [];
    uploadList.forEach((element) {
      _imgListUpload.add(
          MultipartFile.fromFileSync(element.path, filename: element.name));
    });

    List<dynamic> _imgCoverListUpload = [];
    coverList.forEach((element) {
      _imgCoverListUpload.add(
          MultipartFile.fromFileSync(element.path, filename: element.name));
    });

    if (type == null || type < 0 || type > 5) {
      eventBus.fire(UploadErrEvent("价格时间单位错误"));
      return false;
    }

    if (name == null || name == "") {
      eventBus.fire(UploadErrEvent("物品名称非空"));
      return false;
    }
    if (price == null || price == "") {
      eventBus.fire(UploadErrEvent("物品价格非空"));
      return false;
    }
    if (school == null || school == "") {
      eventBus.fire(UploadErrEvent("学校非空"));
      return false;
    }
    if (detail == null || detail == "") {
      eventBus.fire(UploadErrEvent("物品描述非空"));
      return false;
    }
    if (_imgListUpload.isEmpty) {
      eventBus.fire(UploadErrEvent("物品照片至少一张图片"));
      return false;
    }
    if (_imgCoverListUpload.isEmpty) {
      eventBus.fire(UploadErrEvent("物品封面至少一张图片"));
      return false;
    }
    var formData = FormData.fromMap({
      'uid': userId,
      'name': name,
      'price': price,
      'type': type,
      'detail': detail,
      'school': school,
      'cover': _imgCoverListUpload,
      'files': _imgListUpload,
    });

    // print(formData.files.length);
    // print(formData.files);
    // for (var item in formData.files) {
    // print(item.value.contentType);
    //   print(item.value.filename);
    // }

    String token = await getToken();
    Response rsp = await uploadModel(token, formData);

    if (rsp.data["code"] == Code.codeFail ||
        rsp.data["code"] == Code.codeTokenErr ||
        rsp.data["code"] == Code.codeAPILimit) {
      showToast("上传失败, ${rsp.data['message']}");
      return false;
    }

    return true;
  }
}
