import 'package:dio/dio.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_demo/global/rescode.dart';
import 'package:flutter_demo/model/goods_model.dart';
import 'package:flutter_demo/utils/dialog.dart';
import 'package:flutter_demo/utils/event.dart';

class GoodsViewModel extends ChangeNotifier {
  GDetail? _detail;

  List<GDetail> _userGoodsList = List.empty(growable: true);

  get gDetail => _detail;

  get uGoodsList => _userGoodsList;

  clear() {
    _detail = null;
    _userGoodsList.clear();
    notifyListeners();
  }

  clearUList() {
    _userGoodsList.clear();
    notifyListeners();
  }

  Future<bool> getDetail(String token, int gid) async {
    Response rsp = await getGoodsDetailModel(token, gid);
    try {
      if (rsp.data["code"] == Code.codeFail ||
          rsp.data["code"] == Code.codeTokenErr || rsp.data["code"] == Code.codeAPILimit || rsp.data["code"] == Code.codeAPILimit) {
        throw Exception("商品不存在");
      }

      List<Pic> pList = List.empty(growable: true);
      rsp.data["data"]["picList"].forEach((e) {
        pList.add(Pic(id: e["id"]!, path: e["path"]!));
      });

      String cover = rsp.data["data"]["cover"];
      int create_time = rsp.data["data"]["create_time"];
      String detail = rsp.data["data"]["detail"];
      int gid = rsp.data["data"]["gid"];
      String name = rsp.data["data"]["name"];
      double price = double.tryParse(rsp.data["data"]["price"]) ?? 0.0;
      int type = rsp.data["data"]["type"];
      int uid = rsp.data["data"]["uid"];
      String uname = rsp.data["data"]["uname"];
      String school = rsp.data["data"]["school"];
      List<Pic> picList = pList;

      _detail = GDetail(
        cover: cover,
        gid: gid,
        create_time: create_time,
        detail: detail,
        name: name,
        price: price,
        type: type,
        uid: uid,
        uname: uname,
        picList: picList,
        school: school,
      );

      print(_detail);
    } catch (e) {
      eventBus.fire(DetailErrEvenet(e.toString()));
      return false;
    }
    notifyListeners();
    return true;
  }

  Future<bool> getUList(String token, int uid) async {
    Response rsp = await getUserGoodsListModel(token, uid);
    try {
      if (rsp.data["code"] == Code.codeFail ||
          rsp.data["code"] == Code.codeTokenErr || rsp.data["code"] == Code.codeAPILimit) {
        throw Exception("用户不存在");
      }

      _userGoodsList.clear();

      rsp.data["data"]["data"].forEach((e) {
        String cover = e["cover"];
        int create_time = e["create_time"];
        String detail = e["detail"];
        int gid = e["gid"];
        String name = e["name"];
        double price = double.tryParse(e["price"]) ?? 0.0;
        int type = e["type"];
        int uid = e["uid"];
        String uname = e["uname"];
        String school = e["school"];

        GDetail g = GDetail(
          cover: cover,
          gid: gid,
          create_time: create_time,
          detail: detail,
          name: name,
          price: price,
          type: type,
          uid: uid,
          uname: uname,
          school: school,
        );

        _userGoodsList.add(g);
      });
    } catch (e) {
      eventBus.fire(DetailErrEvenet(e.toString()));
      return false;
    }
    notifyListeners();
    return true;
  }

  Future<bool> deleteGoods(String token, int gid) async {
    Response rsp = await deleteGoodsModel(token, gid);
    try {
      if (rsp.data["code"] == Code.codeFail ||
          rsp.data["code"] == Code.codeTokenErr || rsp.data["code"] == Code.codeAPILimit) {
        throw Exception("内部出错");
      }

      //删除链表对应的节点
      _userGoodsList.removeWhere((element) => element.gid == gid);
    } catch (e) {
      eventBus.fire(DetailErrEvenet("删除失败${e.toString()}"));
      return false;
    }
    notifyListeners();
    return true;
  }
}

class GDetail {
  int gid;
  String cover;
  int create_time;
  String detail;
  String name;
  double price;
  int type;
  int uid;
  String uname;
  String school;
  List<Pic>? picList;

  GDetail({
    required this.gid,
    required this.cover,
    required this.create_time,
    required this.detail,
    required this.name,
    required this.price,
    required this.type,
    required this.uid,
    required this.uname,
    required this.school,
    this.picList,
  });
}

class Pic {
  int id;
  String path;

  Pic({required this.id, required this.path});
}
