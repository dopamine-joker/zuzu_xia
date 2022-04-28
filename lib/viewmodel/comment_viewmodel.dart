import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_demo/model/comment_model.dart';

import '../global/rescode.dart';
import '../utils/dialog.dart';

class CommentViewModel extends ChangeNotifier {
  List<UserComment> _myCommentList = List.empty(growable: true);
  List<GoodsComment> _goodsCommentList = List.empty(growable: true);

  get myCommentList => _myCommentList;

  get goodsCommentList => _goodsCommentList;

  _clear() {
    _myCommentList.clear();
    _goodsCommentList.clear();
  }

  Future<bool> addCommentModel(String token, int uid, int gid, int oid,
      int level, String content) async {
    if(content.length > 200) {
      showToast("评论内容字数不能大于200");
      return false;
    }
    if(level < 0 || level >  5) {
      showToast("评分区间[1-5]");
      return false;
    }
    Response rsp = await AddComment(token, uid, gid, oid, level, content);
    try {
      if (rsp.data["code"] == Code.codeFail ||
          rsp.data["code"] == Code.codeTokenErr || rsp.data["code"] == Code.codeAPILimit) {
        showToast(rsp.data["message"]);
        return false;
      }
    } catch (e) {
      showToast(e.toString());
      return false;
    }
    return true;
  }

  Future<bool> deleteCommentModel(String token, int cid) async {
    Response rsp = await DeleteComment(token, cid);
    try {
      if (rsp.data["code"] == Code.codeFail ||
          rsp.data["code"] == Code.codeTokenErr || rsp.data["code"] == Code.codeAPILimit) {
        showToast(rsp.data["message"]);
        return false;
      }
      _myCommentList.removeWhere((e) => e.id == cid);
    } catch (e) {
      showToast(e.toString());
      return false;
    }
    notifyListeners();
    return true;
  }

  Future<bool> getCommentByUserIdModel(String token, int uid) async {
    Response rsp = await GetCommentByUserId(token, uid);
    try {
      if (rsp.data["code"] == Code.codeFail ||
          rsp.data["code"] == Code.codeTokenErr || rsp.data["code"] == Code.codeAPILimit) {
        showToast(rsp.data["message"]);
        return false;
      }
      print(rsp.data["data"]["len"]);
      print(rsp.data["data"]["data"]);

      _myCommentList.clear();

      if (rsp.data["data"]["data"] != null) {
        rsp.data["data"]["data"].forEach((e) {
          UserComment comment = UserComment(
            id: e["id"],
            uid: e["uid"],
            gid: e["gid"],
            oid: e["oid"],
            content: e["content"],
            level: e["level"],
            time: e["time"],
            goodsName: e["goodsName"],
            price: double.tryParse(e["price"]) ?? 0.0,
            cover: e["cover"],
          );
          _myCommentList.add(comment);
        });
      }
    } catch (e) {
      showToast(e.toString());
      return false;
    }
    notifyListeners();
    return true;
  }

  Future<bool> getCommentByGoodsIdModel(String token, int gid) async {
    Response rsp = await GetCommentByGoodsId(token, gid);
    try {
      if (rsp.data["code"] == Code.codeFail ||
          rsp.data["code"] == Code.codeTokenErr || rsp.data["code"] == Code.codeAPILimit) {
        showToast(rsp.data["message"]);
        return false;
      }
      print(rsp.data["data"]["len"]);
      print(rsp.data["data"]["data"]);

      _goodsCommentList.clear();

      if (rsp.data["data"]["data"] != null) {
        rsp.data["data"]["data"].forEach((e) {
          GoodsComment comment = GoodsComment(
            id: e["id"],
            uid: e["uid"],
            gid: e["gid"],
            oid: e["oid"],
            content: e["content"],
            level: e["level"],
            time: e["time"],
            userName: e["userName"],
            userFace: e["userFace"],
          );
          _goodsCommentList.add(comment);
        });
      }
    } catch (e) {
      showToast(e.toString());
      return false;
    }
    notifyListeners();
    return true;
  }
}

class UserComment {
  int id;
  int uid;
  int gid;
  int oid;
  String content;
  int level;
  int time;
  String goodsName;
  double price;
  String cover;

  UserComment({
    required this.id,
    required this.uid,
    required this.gid,
    required this.oid,
    required this.content,
    required this.level,
    required this.time,
    required this.goodsName,
    required this.price,
    required this.cover,
  });
}

class GoodsComment {
  int id;
  int uid;
  int gid;
  int oid;
  String content;
  int level;
  int time;
  String userName;
  String userFace;

  GoodsComment({
    required this.id,
    required this.uid,
    required this.gid,
    required this.oid,
    required this.content,
    required this.level,
    required this.time,
    required this.userName,
    required this.userFace,
  });
}
