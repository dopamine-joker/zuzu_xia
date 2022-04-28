import 'package:card_swiper/card_swiper.dart';
import 'package:flutter/material.dart';
import 'package:flutter_demo/global/global.dart';
import 'package:flutter_demo/global/priceType.dart';
import 'package:flutter_demo/viewmodel/comment_viewmodel.dart';
import 'package:flutter_demo/viewmodel/favorites_viewmodel.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_demo/utils/dialog.dart';
import 'package:flutter_demo/utils/event.dart';
import 'package:flutter_demo/view/chat/chat_view.dart';
import 'package:flutter_demo/viewmodel/goods_viewmodel.dart';
import 'package:flutter_demo/viewmodel/home_viewmodel.dart';
import 'package:flutter_demo/viewmodel/order_viewmodel.dart';
import 'package:provider/src/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../me/goods_comment_view.dart';

class GoodsDetail extends StatefulWidget {
  int goodsId;

  GoodsDetail({Key? key, required this.goodsId}) : super(key: key);

  @override
  _GoodsDetailState createState() => _GoodsDetailState();
}

class _GoodsDetailState extends State<GoodsDetail> {
  List<Image> _imgs = List.empty(growable: true);

  @override
  void initState() {
    super.initState();

    eventBus.on<DetailErrEvenet>().listen((e) {
      getDialog("提示", e.detail).show(context);
    });

    // 调用接口获取信息
    initData();
  }

  initData() async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    String token = sharedPreferences.getString("token") ?? "";
    context
        .read<GoodsViewModel>()
        .getDetail(token, widget.goodsId)
        .then((value) {
      if (value == false) {
        Navigator.pop(context);
      }
    });
    context
        .read<CommentViewModel>()
        .getCommentByGoodsIdModel(token, widget.goodsId)
        .then((value) {
      if (value == false) {
        Navigator.pop(context);
      }
    });
    setState(() {});
  }

  _chat(context, String uid) async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    int id = sharedPreferences.getInt("id") ?? 0;
    if (id.toString() == uid) {
      showToast("不能联系自己!");
      return;
    }

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => chatView(
          conversationId: "c2c_${uid}",
          toUserName: context.read<GoodsViewModel>().gDetail.uname!,
          toUserId: uid,
        ),
      ),
    );
  }

  _commitOrder(int sellid, int gid, String school) async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    String token = sharedPreferences.getString("token") ?? "";
    int? id = sharedPreferences.getInt("id");
    if (id == null) {
      eventBus.fire(DetailErrEvenet("未登陆，请重新登陆"));
      return;
    }
    if (id == sellid) {
      eventBus.fire(DetailErrEvenet("不能购买自己的物品"));
      Navigator.pop(context);
      return;
    }
    await context
        .read<OrderViewModel>()
        .addOrder(token, id, sellid, gid, school)
        .then((value) {
      if (value == true) {
        showToast("提交成功,等待卖家确认");
        Navigator.pop(context);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    dynamic gDetail =
        Provider.of<GoodsViewModel>(context, listen: true).gDetail;

    List<GoodsComment> commentList =
        Provider.of<CommentViewModel>(context, listen: true).goodsCommentList;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.grey[800],
        title: Text(
          gDetail == null ? "" : gDetail.name,
          style: TextStyle(
            fontSize: 15.0.sp,
          ),
        ),
        elevation: 10,
        actions: [
          Provider.of<FavoritesViewModel>(context, listen: true)
                  .myFavoritesGoodsIdsSet
                  .contains(gDetail == null ? -1 : gDetail.gid)
              ? IconButton(
                  onPressed: () async {
                    String token = await getToken();
                    SharedPreferences sharedPreferences =
                        await SharedPreferences.getInstance();
                    int id = sharedPreferences.getInt("id") ?? 0;
                    context
                        .read<FavoritesViewModel>()
                        .deleteFavoriteByGid(token, gDetail.gid)
                        .then((value) {
                      print(value);
                      if (value == true) {
                        showToast("收藏夹取消成功");
                      } else {
                        showToast("重复取消");
                      }
                    });
                  },
                  icon: Icon(Icons.star),
                )
              : IconButton(
                  onPressed: () async {
                    String token = await getToken();
                    SharedPreferences sharedPreferences =
                        await SharedPreferences.getInstance();
                    int id = sharedPreferences.getInt("id") ?? 0;
                    context
                        .read<FavoritesViewModel>()
                        .addFavorites(token, id, gDetail.gid, gDetail.name,
                            gDetail.price, gDetail.type, gDetail.cover)
                        .then((value) {
                      print(value);
                      if (value == true) {
                        showToast("收藏夹添加成功");
                      } else {
                        showToast("重复添加");
                      }
                    });
                  },
                  icon: Icon(Icons.star_border),
                ),
        ],
      ),
      body: gDetail == null
          ? Center(
              child: Text("数据正在快马加鞭加载中~"),
            )
          : Container(
              height: MediaQuery.of(context).size.height,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Expanded(
                    child: ListView(
                      children: [
                        Container(
                          margin: EdgeInsets.all(5.0.sp),
                          height: 300.0.h,
                          child: Swiper(
                            itemBuilder: (context, index) {
                              return Image.network(
                                gDetail.picList![index].path,
                                fit: BoxFit.contain,
                              );
                            },
                            itemCount: gDetail.picList!.length,
                            autoplay: true,
                            pagination: SwiperPagination(),
                            control: SwiperControl(),
                            // itemWidth: 300.0.w,
                            layout: SwiperLayout.DEFAULT,
                          ),
                        ),
                        Row(
                          children: [
                            Container(
                              alignment: Alignment.centerLeft,
                              height: 40.0.h,
                              width: 70.0.w,
                              margin: EdgeInsets.all(5.0.sp),
                              padding:
                                  EdgeInsets.only(left: 5.0.w, right: 5.0.w),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.all(
                                  Radius.circular(8.0.sp),
                                ),
                                border: Border.all(
                                  width: 2.0.sp,
                                  color: Colors.blue,
                                ),
                              ),
                              child: Text(
                                "物品名",
                                style: TextStyle(
                                  fontSize: 15.0.sp,
                                ),
                              ),
                            ),
                            Text(
                              gDetail.name,
                              style: TextStyle(
                                fontSize: 15.0.sp,
                              ),
                            ),
                          ],
                        ),
                        Row(
                          children: [
                            Container(
                              alignment: Alignment.centerLeft,
                              height: 40.0.h,
                              width: 70.0.w,
                              margin: EdgeInsets.all(5.0.sp),
                              padding:
                                  EdgeInsets.only(left: 5.0.w, right: 5.0.w),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.all(
                                  Radius.circular(8.0.sp),
                                ),
                                border: Border.all(
                                  width: 2.0.sp,
                                  color: Colors.blue,
                                ),
                              ),
                              child: Text(
                                "卖家",
                                style: TextStyle(
                                  fontSize: 15.0.sp,
                                ),
                              ),
                            ),
                            Text(
                              gDetail.uname,
                              style: TextStyle(
                                fontSize: 15.0.sp,
                              ),
                            ),
                          ],
                        ),
                        Row(
                          children: [
                            Container(
                              alignment: Alignment.centerLeft,
                              height: 40.0.h,
                              width: 70.0.w,
                              margin: EdgeInsets.all(5.0.sp),
                              padding:
                                  EdgeInsets.only(left: 5.0.w, right: 5.0.w),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.all(
                                  Radius.circular(8.0.sp),
                                ),
                                border: Border.all(
                                  width: 2.0.sp,
                                  color: Colors.blue,
                                ),
                              ),
                              child: Text(
                                "价格",
                                style: TextStyle(
                                  fontSize: 15.0.sp,
                                ),
                              ),
                            ),
                            Text(
                              "${gDetail.price.toString()}元${priceType.priceH[gDetail.type]}",
                              style: TextStyle(
                                fontSize: 15.0.sp,
                              ),
                            ),
                          ],
                        ),
                        Row(
                          children: [
                            Container(
                              alignment: Alignment.centerLeft,
                              height: 40.0.h,
                              width: 70.0.w,
                              margin: EdgeInsets.all(5.0.sp),
                              padding:
                                  EdgeInsets.only(left: 5.0.w, right: 5.0.w),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.all(
                                  Radius.circular(8.0.sp),
                                ),
                                border: Border.all(
                                  width: 2.0.sp,
                                  color: Colors.blue,
                                ),
                              ),
                              child: Text(
                                "学校",
                                style: TextStyle(
                                  fontSize: 15.0.sp,
                                ),
                              ),
                            ),
                            Text(
                              gDetail.school.toString(),
                              style: TextStyle(
                                fontSize: 15.0.sp,
                              ),
                            ),
                          ],
                        ),
                        Row(
                          children: [
                            Container(
                              alignment: Alignment.centerLeft,
                              height: 40.0.h,
                              width: 70.0.w,
                              margin: EdgeInsets.all(5.0.sp),
                              padding:
                                  EdgeInsets.only(left: 5.0.w, right: 5.0.w),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.all(
                                  Radius.circular(8.0.sp),
                                ),
                                border: Border.all(
                                  width: 2.0.sp,
                                  color: Colors.blue,
                                ),
                              ),
                              child: Text(
                                "上传时间",
                                style: TextStyle(
                                  fontSize: 12.0.sp,
                                ),
                              ),
                            ),
                            Text(
                              DateTime.fromMillisecondsSinceEpoch(
                                      gDetail.create_time * 1000)
                                  .toUtc()
                                  .toString()
                                  .substring(0, 19),
                              style: TextStyle(
                                fontSize: 15.0.sp,
                              ),
                            ),
                          ],
                        ),
                        Row(
                          children: [
                            Container(
                              width: MediaQuery.of(context).size.width,
                              alignment: Alignment.centerLeft,
                              padding: EdgeInsets.all(7.0.sp),
                              child: Container(
                                child: Text(
                                  "卖家描述: ${gDetail.detail}",
                                  maxLines: 100,
                                  softWrap: true,
                                  style: TextStyle(
                                    fontSize: 12.0.sp,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                        Container(
                          width: MediaQuery.of(context).size.width,
                          margin: EdgeInsets.only(
                              left: 5.0.w, right: 5.0.w, top: 10.0.h),
                          alignment: Alignment.center,
                          child: Row(
                            children: <Widget>[
                              Expanded(
                                child: Container(
                                  margin: EdgeInsets.all(8.0.r),
                                  decoration: BoxDecoration(
                                      border: Border.all(width: 0.25)),
                                ),
                              ),
                              Text(
                                "图片详情",
                                style: TextStyle(
                                  fontSize: 18.0.sp,
                                  color: Colors.black,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Expanded(
                                child: Container(
                                  margin: EdgeInsets.all(8.0),
                                  decoration: BoxDecoration(
                                      border: Border.all(width: 0.25)),
                                ),
                              ),
                            ],
                          ),
                        ),
                        ListView.builder(
                          shrinkWrap: true,
                          physics: NeverScrollableScrollPhysics(),
                          itemCount: gDetail.picList?.length,
                          itemBuilder: (context, index) {
                            return Container(
                              margin: EdgeInsets.all(10.0.w),
                              child: Image.network(
                                gDetail.picList![index].path,
                                fit: BoxFit.fitWidth,
                              ),
                            );
                          },
                        ),
                        Container(
                          width: MediaQuery.of(context).size.width,
                          margin: EdgeInsets.only(
                              left: 5.0.w, right: 5.0.w, top: 10.0.h),
                          alignment: Alignment.center,
                          child: Row(
                            children: <Widget>[
                              Expanded(
                                child: Container(
                                  margin: EdgeInsets.all(8.0.r),
                                  decoration: BoxDecoration(
                                      border: Border.all(width: 0.25)),
                                ),
                              ),
                              Text(
                                "评论",
                                style: TextStyle(
                                  fontSize: 18.0.sp,
                                  color: Colors.black,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Expanded(
                                child: Container(
                                  margin: EdgeInsets.all(8.0),
                                  decoration: BoxDecoration(
                                      border: Border.all(width: 0.25)),
                                ),
                              ),
                            ],
                          ),
                        ),
                        commentList.isNotEmpty
                            ? Column(
                                children: [
                                  ListView.builder(
                                    shrinkWrap: true,
                                    physics: NeverScrollableScrollPhysics(),
                                    itemCount: commentList.length > 5
                                        ? 5
                                        : commentList.length,
                                    itemBuilder: (context, index) {
                                      GoodsComment comment = commentList[index];
                                      return Container(
                                        margin: EdgeInsets.all(10.0.w),
                                        child: Card(
                                          shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadiusDirectional
                                                      .circular(5.0.sp)),
                                          margin: EdgeInsets.only(
                                            left: 5.0.w,
                                            right: 5.0.w,
                                            top: 3.0.h,
                                            // bottom: 3.0.w,
                                          ),
                                          color: Colors.grey[100],
                                          child: Row(
                                            children: [
                                              Container(
                                                color: Colors.grey[200],
                                                margin: EdgeInsets.all(3.0.w),
                                                height: 40.0.h,
                                                width: 40.0.w,
                                                child: ClipRRect(
                                                  borderRadius:
                                                      BorderRadius.all(
                                                    Radius.circular(10.0.sp),
                                                  ),
                                                  child: Image.network(
                                                    comment.userFace,
                                                    fit: BoxFit.contain,
                                                  ),
                                                ),
                                              ),
                                              Expanded(
                                                // height: 80.0.h,
                                                child: Column(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  children: [
                                                    Row(
                                                      children: [
                                                        Container(
                                                          margin:
                                                              EdgeInsets.only(
                                                                  left: 3.0.w),
                                                          child: Text(
                                                            comment.userName,
                                                            style: TextStyle(
                                                              fontSize: 14.0.sp,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .bold,
                                                            ),
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                    Row(
                                                      children: [
                                                        Container(
                                                          margin:
                                                              EdgeInsets.only(
                                                                  left: 3.0.w),
                                                          child: Text(
                                                            "评价等级: ${comment.level}",
                                                            style: TextStyle(
                                                              fontSize: 12.0.sp,
                                                              color:
                                                                  Colors.grey,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .bold,
                                                            ),
                                                          ),
                                                        ),
                                                        Container(
                                                          margin:
                                                              EdgeInsets.only(
                                                                  left: 3.0.w),
                                                          child: Text(
                                                            "评论时间: ${DateTime.fromMillisecondsSinceEpoch(comment.time * 1000).toUtc().toString().substring(0, 19)}",
                                                            style: TextStyle(
                                                              fontSize: 12.0.sp,
                                                              color:
                                                                  Colors.grey,
                                                            ),
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                    SizedBox(
                                                      height: 10.h,
                                                    ),
                                                    Container(
                                                      color: Colors.grey[100],
                                                      child: Container(
                                                        margin: EdgeInsets.only(
                                                            left: 3.0.w,
                                                            right: 3.0.w),
                                                        width: MediaQuery.of(
                                                                context)
                                                            .size
                                                            .width,
                                                        child: Text(
                                                          "${comment.content}",
                                                          maxLines: 10,
                                                          // overflow: TextOverflow.ellipsis,
                                                          softWrap: true,
                                                          style: TextStyle(
                                                            fontSize: 12.0.sp,
                                                          ),
                                                        ),
                                                      ),
                                                    ),
                                                    SizedBox(
                                                      height: 10.h,
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      );
                                    },
                                  ),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.end,
                                    children: <Widget>[
                                      Padding(
                                        padding: EdgeInsets.only(right: 15.0.w),
                                        child: FlatButton(
                                          child: Text(
                                            "查看更多评论",
                                            style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                              color: Colors.blue,
                                              fontSize: 10.sp,
                                            ),
                                            textAlign: TextAlign.end,
                                          ),
                                          onPressed: () {
                                            Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                builder: (context) =>
                                                    GoodsCommentListView(
                                                  gid: gDetail.gid,
                                                ),
                                              ),
                                            );
                                          },
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              )
                            : const Center(
                                child: Text("暂无评论~"),
                              ),
                      ],
                    ),
                  ),
                  Container(
                    color: Colors.grey[100],
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Container(
                          margin: EdgeInsets.only(left: 7.0.w, right: 7.0.w),
                          child: ElevatedButton(
                            onPressed: () {
                              getChoiceDialog("确定", "确定购买吗?请和卖家提前联系好", () {
                                _commitOrder(
                                    gDetail.uid, gDetail.gid, gDetail.school);
                              }, () {
                                Navigator.pop(context);
                              }).show(context);
                            },
                            style: ButtonStyle(
                              backgroundColor:
                                  MaterialStateProperty.all(Colors.red),
                              shape: MaterialStateProperty.all(
                                RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(15.0.sp),
                                ),
                              ),
                            ),
                            child: Container(
                              padding:
                                  EdgeInsets.only(left: 5.0.w, right: 5.0.w),
                              child: Text("立刻购买"),
                            ),
                          ),
                        ),
                        Container(
                          margin: EdgeInsets.only(left: 7.0.w, right: 7.0.w),
                          child: ElevatedButton(
                            onPressed: () {
                              _chat(context, gDetail.uid.toString());
                            },
                            style: ButtonStyle(
                              shape: MaterialStateProperty.all(
                                RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(15.0.sp),
                                ),
                              ),
                            ),
                            child: Container(
                              padding:
                                  EdgeInsets.only(left: 5.0.w, right: 5.0.w),
                              child: Text("联系卖家"),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}

class _imgDetailWidget extends StatelessWidget {
  dynamic gDetail;

  _imgDetailWidget({Key? key, required this.gDetail}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      shrinkWrap: true,
      itemCount: gDetail.picList.length,
      itemBuilder: (context, index) {
        return Image.network(
          gDetail.picList[index].path,
          fit: BoxFit.fitWidth,
        );
      },
    );
  }
}
