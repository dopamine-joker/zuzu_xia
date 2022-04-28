import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_demo/global/rescode.dart';
import 'package:flutter_demo/model/home_model.dart';
import 'package:flutter_demo/model/order_model.dart';
import 'package:flutter_demo/utils/dialog.dart';
import 'package:flutter_demo/utils/event.dart';
import 'package:image_picker/image_picker.dart';

class HomeViewmodel extends ChangeNotifier {
  String _query = "";

  // int _sum = 0; //累计获取多少条数据
  bool _finish = false;

  // 搜索界面
  List<Goods> _searchList = List.empty(growable: true);

  get sList => _searchList;

  //主页
  List<Goods> _goodsList = List.empty(growable: true);

  get list => _goodsList;

  // get sum => _sum;
  get finish => _finish;

  get query => _query;

  setQuery(String txt) {
    _query = txt;
  }

  clear() {
    // _sum = 0;
    _finish = false;
    _goodsList.clear();
    notifyListeners();
  }

  refreshSearch() {
    _searchList = List.empty(growable: true);
  }

  Future<bool> getGoods(String token, int count) async {
    if (token == "") {
      eventBus.fire(HomeErrEvent("拉取数据失败, 登陆已过期"));
      return false;
    }

    Response rsp = await getGoodsModel(token, _goodsList.length, count);
    try {
      print(rsp.headers);
      print(rsp.data);
      print(rsp.statusMessage);

      if (rsp.data["code"] == Code.codeFail ||
          rsp.data["code"] == Code.codeTokenErr ||
          rsp.data["code"] == Code.codeAPILimit) {
        showToast(rsp.data["message"]);
        return false;
      }

      int cnt = rsp.data["data"]["len"];

      if (rsp.data["data"]["len"] == 0) {
        _finish = true;
        showToast("没有更多数据");
        notifyListeners();
        return true;
      } else if (rsp.data["data"]["len"] != 0) {
        _finish = false;
      }

      rsp.data["data"]["goods"].forEach((e) {
        String cover = e["cover"].toString();
        int id = e["id"];
        String name = e["name"].toString();
        double price = double.tryParse(e["price"]) ?? 0.0;
        String uname = e["uname"].toString();
        int type = e["type"];

        Goods g = Goods(
          id: id,
          name: name,
          price: price,
          type: type,
          uname: uname,
          cover: cover,
        );

        print("货物类型+" + g.type.toString());

        // _sum += cnt;
        _goodsList.add(g);
      });
    } catch (e) {
      showToast(e.toString());
      return false;
    }
    print(_goodsList.length);
    notifyListeners();
    return true;
  }

  Future<bool> searchList(String token, String name) async {
    Response rsp = await SearchGoodsModel(token, name);
    try {
      if (rsp.data["code"] == Code.codeFail ||
          rsp.data["code"] == Code.codeTokenErr ||
          rsp.data["code"] == Code.codeAPILimit) {
        showToast(rsp.data["message"]);
        return false;
      }

      // print(rsp.data["data"].runtimeType);
      if (rsp.data["data"]["len"] == 0) {
        return true;
      }

      rsp.data["data"]["data"].forEach((e) {
        String cover = e["cover"].toString();
        int gid = e["gid"];
        String name = e["name"].toString();
        double price = double.tryParse(e["price"]) ?? 0.0;
        int type = e["type"];
        String uname = e["uname"].toString();

        Goods g = Goods(
          id: gid,
          name: name,
          price: price,
          type: type,
          uname: uname,
          cover: cover,
        );

        _searchList.add(g);
      });
    } catch (e) {
      showToast(e.toString());
      return false;
    }
    notifyListeners();
    return true;
  }

  Future<String> VoiceToTxt(String token, XFile uploadFile) async {
    dynamic voice = MultipartFile.fromFileSync(
      uploadFile.path,
      filename: uploadFile.name,
    );

    var formData = FormData.fromMap({
      'voice': voice,
    });

    String txt = "";
    Response rsp = await VoiceToTxtModel(token, formData);
    try {
      if (rsp.data["code"] == Code.codeFail ||
          rsp.data["code"] == Code.codeTokenErr ||
          rsp.data["code"] == Code.codeAPILimit) {
        showToast("上传失败, ${rsp.data['message']}");
        return "";
      }

      txt = rsp.data["data"]["txt"];
    } catch (e) {
      showToast("上传 ${e.toString()}");
      return "";
    }
    notifyListeners();
    return txt;
  }
}

class Goods {
  String cover;
  int id;
  String name;
  double price;
  int type;
  String uname;

  Goods(
      {required this.id,
      required this.name,
      required this.price,
      required this.type,
      required this.uname,
      required this.cover});
}
