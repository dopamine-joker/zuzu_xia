import 'package:flutter/foundation.dart';
import 'package:dio/dio.dart';
import 'package:flutter_demo/global/rescode.dart';
import 'package:flutter_demo/model/favorites_model.dart';
import 'package:flutter_demo/utils/dialog.dart';

class FavoritesViewModel extends ChangeNotifier {
  final List<Favorites> _myFavorites = List.empty(growable: true);
  final Set<int> _myFavoritesGoodsIdsSet = {};

  get myFavorites => _myFavorites;

  get myFavoritesGoodsIdsSet => _myFavoritesGoodsIdsSet;

  clear() {
    _myFavorites.clear();
    _myFavoritesGoodsIdsSet.clear();
  }

  bool isContains(int gid) {
    return _myFavoritesGoodsIdsSet.contains(gid);
  }

  Future<bool> addFavorites(String token, int uid, int gid, String gname,
      double price, int type, String cover) async {
    Response rsp = await AddFavorites(token, uid, gid);
    try {
      if (rsp.data["code"] == Code.codeFail ||
          rsp.data["code"] == Code.codeTokenErr ||
          rsp.data["code"] == Code.codeAPILimit) {
        showToast(rsp.data["message"]);
        return false;
      }
      int fid = rsp.data["data"]["fid"];
      Favorites favorites = Favorites(
        id: fid,
        uid: uid,
        gid: gid,
        gname: gname,
        price: price,
        type: type,
        cover: cover,
      );
      _myFavorites.add(favorites);
      _myFavoritesGoodsIdsSet.add(gid);
      print("add favorite gid ${gid}");
    } catch (e) {
      showToast(e.toString());
      return false;
    }
    notifyListeners();
    return true;
  }

  Future<bool> deleteFavoriteByGid(String token, int gid) async {
    try {
      // 找到这个gid对应的fid
      Favorites f = _myFavorites.firstWhere((e) => e.gid == gid);
      // 删除元素
      deleteFavorites(token, f.id, f.gid).then((res) {
        if (res == false) {
          return false;
        }
      });
    } catch (e) {
      showToast("取消失败，收藏夹没有该物品");
      return false;
    }
    return true;
  }

  Future<bool> deleteFavorites(String token, int fid, int gid) async {
    Response rsp = await DeleteFavorites(token, fid);
    try {
      if (rsp.data["code"] == Code.codeFail ||
          rsp.data["code"] == Code.codeTokenErr ||
          rsp.data["code"] == Code.codeAPILimit) {
        showToast(rsp.data["message"]);
        return false;
      }

      //删除链表对应的节点
      _myFavorites.removeWhere((element) => element.id == fid);
      //删除set
      _myFavoritesGoodsIdsSet.remove(gid);
    } catch (e) {
      showToast(e.toString());
      return false;
    }
    notifyListeners();
    return true;
  }

  Future<bool> getMyFavorites(String token, int uid) async {
    Response rsp = await GetUserFavorites(token, uid);
    try {
      if (rsp.data["code"] == Code.codeFail ||
          rsp.data["code"] == Code.codeTokenErr ||
          rsp.data["code"] == Code.codeAPILimit) {
        showToast(rsp.data["message"]);
        return false;
      }
      print(rsp.data["data"]["len"]);
      print(rsp.data["data"]["data"]);

      clear();

      if (rsp.data["data"]["data"] != null) {
        rsp.data["data"]["data"].forEach((e) {
          Favorites favorites = Favorites(
            id: e["id"],
            uid: e["uid"],
            gid: e["gid"],
            gname: e["gname"],
            price: double.tryParse(e["price"]) ?? 0.0,
            type: e["type"],
            cover: e["cover"],
          );
          _myFavorites.add(favorites);
          _myFavoritesGoodsIdsSet.add(favorites.gid);
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

class Favorites {
  int id;
  int uid;
  int gid;
  String gname;
  double price;
  int type;
  String cover;

  Favorites({
    required this.id,
    required this.uid,
    required this.gid,
    required this.gname,
    required this.price,
    required this.type,
    required this.cover,
  });
}
