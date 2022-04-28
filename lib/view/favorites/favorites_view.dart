import 'package:flutter/material.dart';
import 'package:flutter_demo/global/priceType.dart';
import 'package:flutter_demo/view/home/goods_detail_view.dart';
import 'package:flutter_demo/viewmodel/favorites_viewmodel.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_demo/global/global.dart';
import 'package:flutter_demo/utils/dialog.dart';
import 'package:flutter_demo/utils/event.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:provider/src/provider.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:shared_preferences/shared_preferences.dart';

class FavoritesView extends StatefulWidget {
  FavoritesView({Key? key}) : super(key: key);

  @override
  _FavoritesViewState createState() => _FavoritesViewState();
}

class _FavoritesViewState extends State<FavoritesView>
    with SingleTickerProviderStateMixin {
  RefreshController _refreshController = RefreshController();

  int _index = 0;

  @override
  void initState() {
    super.initState();

    eventBus.on<RecordErrEvenet>().listen((e) {
      getDialog("提示", e.detail).show(context);
    });

    context.read<FavoritesViewModel>().clear();
    _initData();
  }

  Future<void> _onRefresh() async {
    _refreshController.refreshCompleted();
    await Future.delayed(Duration(milliseconds: 500));
    _initData();
  }

  _initData() async {
    context.read<FavoritesViewModel>().clear();
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    String token = await getToken();
    int? userId = sharedPreferences.getInt("id");
    if (userId == null) {
      eventBus.fire(RecordErrEvenet("未登陆，请重新登陆"));
      return;
    }

    context
        .read<FavoritesViewModel>()
        .getMyFavorites(token, userId)
        .then((value) {
      if (value == true) {
        showToast("个人收藏拉取成功");
      }
    });
  }

  toDetail(int gId) {
    print(gId);
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => GoodsDetail(
          goodsId: gId,
        ),
      ),
    );
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    List<Favorites> list =
        Provider.of<FavoritesViewModel>(context, listen: true).myFavorites;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.grey[800],
        title: Text(
          "我的收藏",
          style: TextStyle(
            fontSize: 15.0.sp,
          ),
        ),
        elevation: 10,
        centerTitle: true,
        automaticallyImplyLeading: false,
      ),
      body: Column(
        children: [
          // ElevatedButton(
          //   onPressed: () {
          //     _initData();
          //   },
          //   child: Text("press"),
          // ),
          Expanded(
            child: SmartRefresher(
              enablePullDown: true,
              header: const ClassicHeader(
                idleText: "下拉刷新",
                refreshingText: "刷新中",
                completeText: "ok",
                releaseText: "释放刷新",
                failedText: "刷新失败",
              ),
              controller: _refreshController,
              onRefresh: _onRefresh,
              child: list.isEmpty
                  ? const Center(child: Text("暂无记录~"))
                  : ListView.builder(
                      itemCount: list.length,
                      itemBuilder: (context, index) {
                        Favorites favorites = list[index];
                        return InkWell(
                          onTap: () {
                            if (mounted) {
                              setState(() {});
                            }
                            toDetail(favorites.gid);
                          },
                          child: Slidable(
                            key: Key(favorites.id.toString()),
                            endActionPane: ActionPane(
                              motion: StretchMotion(),
                              children: [
                                SlidableAction(
                                  flex: 1,
                                  label: "删除",
                                  icon: Icons.delete,
                                  backgroundColor: Colors.red,
                                  onPressed: (BuildContext context) async {
                                    String _token = await getToken();
                                    context
                                        .read<FavoritesViewModel>()
                                        .deleteFavorites(_token, favorites.id, favorites.gid);
                                    print("删除 ${favorites.id}");
                                  },
                                ),
                              ],
                            ),
                            child: Card(
                              shape: RoundedRectangleBorder(
                                  borderRadius:
                                      BorderRadiusDirectional.circular(
                                          5.0.sp)),
                              margin: EdgeInsets.only(
                                left: 5.0.w,
                                right: 5.0.w,
                                top: 3.0.h,
                                bottom: 3.0.w,
                              ),
                              color: Colors.grey[100],
                              child: Row(
                                children: [
                                  Container(
                                    color: Colors.grey[200],
                                    margin: EdgeInsets.all(3.0.w),
                                    height: 80.0.h,
                                    width: 80.0.w,
                                    child: ClipRRect(
                                      borderRadius: BorderRadius.all(
                                        Radius.circular(10.0.sp),
                                      ),
                                      child: Image.network(
                                        favorites.cover,
                                        fit: BoxFit.contain,
                                      ),
                                    ),
                                  ),
                                  Container(
                                    height: 80.0.h,
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Container(
                                          margin: EdgeInsets.only(
                                              left: 3.0.w, top: 8.0.h),
                                          child: Text(
                                            favorites.gname,
                                            style: TextStyle(
                                              fontSize: 12.0.sp,
                                            ),
                                          ),
                                        ),
                                        Container(
                                          margin:
                                              EdgeInsets.only(left: 3.0.w),
                                          child: Text(
                                            "¥ ${favorites.price}元${priceType.priceH[favorites.type]}",
                                            style: TextStyle(
                                              fontSize: 12.0.sp,
                                              color: Colors.red,
                                            ),
                                          ),
                                        ),
                                        Card(
                                          color: Colors.grey[100],
                                          child: Container(
                                            margin:
                                                EdgeInsets.only(left: 3.0.w),
                                            child: Text(
                                              "物品名: ${favorites.gname}",
                                              style: TextStyle(
                                                fontSize: 12.0.sp,
                                                color: Colors.black,
                                              ),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  )
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                    ),
            ),
          ),
        ],
      ),
    );
  }
}
