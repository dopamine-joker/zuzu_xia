import 'package:flutter/material.dart';
import 'package:flutter_demo/global/priceType.dart';
import 'package:flutter_demo/view/me/goods_comment_view.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:flutter_demo/global/global.dart';
import 'package:flutter_demo/utils/dialog.dart';
import 'package:flutter_demo/view/home/goods_detail_view.dart';
import 'package:flutter_demo/viewmodel/goods_viewmodel.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class MyGoodsView extends StatefulWidget {
  const MyGoodsView({Key? key}) : super(key: key);

  @override
  _MyGoodsViewState createState() => _MyGoodsViewState();
}

class _MyGoodsViewState extends State<MyGoodsView> {
  @override
  void initState() {
    super.initState();
    _initData();
  }

  _initData() async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    String _token = await getToken();
    int uid = sharedPreferences.getInt("id") ?? -1;

    if (uid == -1) {
      showToast("登陆失效，请重新登陆");
      return;
    }
    context.read<GoodsViewModel>().getUList(_token, uid).then((value) {
      if (value == true) {
        showToast("拉取成功");
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    List<GDetail> list =
        Provider.of<GoodsViewModel>(context, listen: true).uGoodsList;

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

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.grey[800],
        title: Text(
          "我的商品",
          style: TextStyle(
            fontSize: 15.0.sp,
          ),
        ),
        elevation: 10,
        centerTitle: true,
      ),
      body: list.isEmpty
          ? const Center(
              child: Text("暂无记录"),
            )
          : ListView.builder(
              itemCount: list.length,
              itemBuilder: (context, index) {
                GDetail g = list[index];

                return InkWell(
                  onTap: () {
                    if (mounted) {
                      setState(() {});
                    }
                    toDetail(g.gid);
                  },
                  child: Slidable(
                    key: Key(g.gid.toString()),
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
                                .read<GoodsViewModel>()
                                .deleteGoods(_token, g.gid);
                            print("删除 ${g.gid}");
                          },
                        ),
                      ],
                    ),
                    child: Card(
                      shape: RoundedRectangleBorder(
                          borderRadius:
                              BorderRadiusDirectional.circular(5.0.sp)),
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
                                g.cover,
                                fit: BoxFit.contain,
                              ),
                            ),
                          ),
                          Container(
                            height: 120.0.h,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Container(
                                  margin:
                                      EdgeInsets.only(left: 3.0.w, top: 8.0.h),
                                  child: Text(
                                    g.name,
                                    style: TextStyle(
                                      fontSize: 12.0.sp,
                                    ),
                                  ),
                                ),
                                Container(
                                  margin: EdgeInsets.only(left: 3.0.w),
                                  child: Text(
                                    "¥ ${g.price.toString()}${priceType.priceH[g.type]}",
                                    style: TextStyle(
                                      fontSize: 12.0.sp,
                                      color: Colors.red,
                                    ),
                                  ),
                                ),
                                Container(
                                  width: 200.0.w,
                                  alignment: Alignment.centerLeft,
                                  padding: EdgeInsets.only(left: 3.0.w),
                                  child: Container(
                                    child: Text(
                                      // "222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222",
                                      "卖家描述: ${g.detail}",
                                      maxLines: 3,
                                      overflow: TextOverflow.ellipsis,
                                      softWrap: true,
                                      style: TextStyle(
                                        fontSize: 12.0.sp,
                                      ),
                                    ),
                                  ),
                                ),
                                Container(
                                  margin: EdgeInsets.only(left: 3.0.w),
                                  child: Text(
                                    "提交时间: ${DateTime.fromMillisecondsSinceEpoch(g.create_time * 1000).toUtc().toString().substring(0, 19)}",
                                    style: TextStyle(
                                      fontSize: 12.0.sp,
                                    ),
                                  ),
                                ),
                                ElevatedButton(
                                  onPressed: () async {
                                    print("查看评论 ${g.gid}");
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) =>
                                            GoodsCommentListView(
                                          gid: g.gid,
                                        ),
                                      ),
                                    );
                                  },
                                  style: ButtonStyle(
                                    backgroundColor:
                                        MaterialStateProperty.all(Colors.blue),
                                  ),
                                  child: Text(
                                    "查看评论",
                                    style: TextStyle(
                                      fontSize: 12.0.sp,
                                    ),
                                  ),
                                )
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
    );
  }
}
