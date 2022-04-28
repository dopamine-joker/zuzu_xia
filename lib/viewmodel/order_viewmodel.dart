import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_demo/global/rescode.dart';
import 'package:flutter_demo/model/order_model.dart';
import 'package:flutter_demo/utils/dialog.dart';

class OrderStatus {
  static const COMMIT = 0;
  static const SUCCESS = 1;
  static const FAIL = 2;
  static const CHECK = 3;
  static const COMMENT = 4;
}

class OrderViewModel extends ChangeNotifier {
  //自己购买的订单
  List<Order> _finishList = List.empty(growable: true);
  List<Order> _unfinishList = List.empty(growable: true);

  //自己卖出的订单
  List<Order> _myFinishList = List.empty(growable: true);
  List<Order> _myUnfinishList = List.empty(growable: true);

  get finishList => _finishList;

  get unfinishList => _unfinishList;

  get myFinishList => _myFinishList;

  get myUnfinishList => _myUnfinishList;

  clear() {
    _finishList.clear();
    _unfinishList.clear();
    // notifyListeners();
  }

  clearOrder() {
    _myFinishList.clear();
    _myUnfinishList.clear();
  }

  Future<bool> addOrder(
      String token, int buyid, int sellid, int gid, String school) async {
    Response rsp = await AddOrderModel(token, buyid, sellid, gid, school);
    try {
      if (rsp.data["code"] == Code.codeFail ||
          rsp.data["code"] == Code.codeTokenErr ||
          rsp.data["code"] == Code.codeAPILimit) {
        showToast(rsp.data["message"]);
        return false;
      }
    } catch (e) {
      showToast(e.toString());
      return false;
    }
    return true;
  }

  Future<bool> getBuyOrder(String token, int buyid) async {
    Response rsp = await GetBuyOrderModel(token, buyid);
    try {
      if (rsp.data["code"] == Code.codeFail ||
          rsp.data["code"] == Code.codeTokenErr ||
          rsp.data["code"] == Code.codeAPILimit) {
        showToast(rsp.data["message"]);
        return false;
      }

      print(rsp.data["data"]["len"]);
      print(rsp.data["data"]["data"]);

      if (rsp.data["data"]["data"] == null) {
        return true;
      }

      _unfinishList.clear();
      _finishList.clear();

      rsp.data["data"]["data"].forEach((e) {
        Order order = Order(
          id: e["id"],
          buyid: e["buyid"],
          buyName: e["buyName"],
          sellid: e["sellid"],
          sellName: e["sellName"],
          gid: e["gid"],
          gname: e["gName"],
          price: double.tryParse(e["price"]) ?? 0.0,
          type: e["type"],
          school: e["school"],
          cover: e["cover"],
          status: e["status"],
          time: e["time"],
        );
        if (order.status == OrderStatus.COMMIT ||
            order.status == OrderStatus.CHECK) {
          _unfinishList.add(order);
        } else if (order.status == OrderStatus.SUCCESS ||
            order.status == OrderStatus.FAIL ||
            order.status == OrderStatus.COMMENT) {
          _finishList.add(order);
        }
      });
    } catch (e) {
      showToast(e.toString());
      return false;
    }
    notifyListeners();
    return true;
  }

  Future<bool> getSellOrder(String token, int sellid) async {
    Response rsp = await GetSellOrderModel(token, sellid);
    try {
      if (rsp.data["code"] == Code.codeFail ||
          rsp.data["code"] == Code.codeTokenErr ||
          rsp.data["code"] == Code.codeAPILimit) {
        showToast(rsp.data["message"]);
        return false;
      }

      print(rsp.data["data"]["len"]);
      print(rsp.data["data"]["data"]);

      if (rsp.data["data"]["data"] == null) {
        return true;
      }

      rsp.data["data"]["data"].forEach((e) {
        Order order = Order(
          id: e["id"],
          buyid: e["buyid"],
          buyName: e["buyName"],
          sellid: e["sellid"],
          sellName: e["sellName"],
          gid: e["gid"],
          gname: e["gName"],
          price: double.tryParse(e["price"]) ?? 0.0,
          type: e["type"],
          school: e["school"],
          cover: e["cover"],
          status: e["status"],
          time: e["time"],
        );
        if (order.status == OrderStatus.COMMIT ||
            order.status == OrderStatus.CHECK) {
          _myUnfinishList.add(order);
        } else if (order.status == OrderStatus.SUCCESS ||
            order.status == OrderStatus.FAIL ||
            order.status == OrderStatus.COMMENT) {
          _myFinishList.add(order);
        }
      });
    } catch (e) {
      showToast(e.toString());
      return false;
    }
    notifyListeners();
    return true;
  }

  //更新自己卖出的订单状态
  Future<bool> updateOrder(
      String token, int oid, int sellid, int buyid, int uid, int status) async {
    Response rsp = await UpdateOrderStatusModel(token, oid, status);
    try {
      if (rsp.data["code"] == Code.codeFail ||
          rsp.data["code"] == Code.codeTokenErr ||
          rsp.data["code"] == Code.codeAPILimit) {
        showToast(rsp.data["message"]);
        return false;
      }

      //卖家，在“我的订单”里面修改ui
      if (sellid == uid) {
        if (status == OrderStatus.FAIL) {
          int idx = _myUnfinishList.indexWhere((element) => element.id == oid);
          Order o = _myUnfinishList[idx];
          _myUnfinishList.removeWhere((element) => element.id == oid);
          _myFinishList.add(o);
        } else if (status == OrderStatus.CHECK) {
          clearOrder();
          getSellOrder(token, uid);
        }
      } else if (buyid == uid) {
        //买家，在我的记录里面修改
        if (status == OrderStatus.SUCCESS) {
          int idx = _unfinishList.indexWhere((element) => element.id == oid);
          Order o = _unfinishList[idx];
          _unfinishList.removeWhere((element) => element.id == oid);
          _finishList.add(o);
        }
      }

      // int idx = _unfinishList.indexWhere((element) => element.id == oid);
      // Order o = _unfinishList[idx];
      // o.status = status;
      // if (status == OrderStatus.SUCCESS) {
      //   print("set status success");
      //   if (buyid == uid) {
      //     _unfinishList.removeWhere((element) => element.id == oid);
      //     _finishList.add(o);
      //   }
      // }
      // if (status == OrderStatus.CHECK) {}
    } catch (e) {
      showToast(e.toString());
      return false;
    }
    notifyListeners();
    return true;
  }
}

class Order {
  int id;
  int buyid;
  String buyName;
  int sellid;
  String sellName;
  int gid;
  String gname;
  double price;
  int type;
  String school;
  String cover;
  int status;
  int time;

  Order({
    required this.id,
    required this.buyid,
    required this.buyName,
    required this.sellid,
    required this.sellName,
    required this.gid,
    required this.gname,
    required this.price,
    required this.type,
    required this.school,
    required this.cover,
    required this.status,
    required this.time,
  });
}
