import 'package:flutter/material.dart';
import 'package:flutter_demo/global/priceType.dart';
import 'package:flutter_demo/view/me/comment_view.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_demo/global/global.dart';
import 'package:flutter_demo/utils/dialog.dart';
import 'package:flutter_demo/utils/event.dart';
import 'package:flutter_demo/viewmodel/order_viewmodel.dart';
import 'package:provider/src/provider.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:shared_preferences/shared_preferences.dart';

class RecordView extends StatefulWidget {
  List widgets = [_unfinishWidget(), _finishWidget()];

  RecordView({Key? key}) : super(key: key);

  @override
  _RecordViewState createState() => _RecordViewState();
}

class _RecordViewState extends State<RecordView>
    with SingleTickerProviderStateMixin {
  List tabs = ["未完成的", "已完成的"];

  late TabController _controller;
  int _index = 0;

  @override
  void initState() {
    super.initState();

    eventBus.on<RecordErrEvenet>().listen((e) {
      getDialog("提示", e.detail).show(context);
    });

    _controller = TabController(
      initialIndex: _index,
      length: tabs.length,
      vsync: this,
    );
    _controller.addListener(() {
      setState(() {
        _index = _controller.index;
      });
    });
  }

  @override
  void dispose() {
    super.dispose();
    _controller.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.grey[800],
        title: Text(
          "租赁记录",
          style: TextStyle(
            fontSize: 15.0.sp,
          ),
        ),
        elevation: 10,
        centerTitle: true,
        bottom: TabBar(
          controller: _controller,
          tabs: tabs.map((e) => Tab(text: e)).toList(),
        ),
      ),
      body: widget.widgets[_index],
    );
  }
}

class _unfinishWidget extends StatefulWidget {
  const _unfinishWidget({Key? key}) : super(key: key);

  @override
  __unfinishWidgetState createState() => __unfinishWidgetState();
}

class __unfinishWidgetState extends State<_unfinishWidget> {
  RefreshController _refreshController = RefreshController();
  int? buyid;

  @override
  void initState() {
    super.initState();
    context.read<OrderViewModel>().clear();
    _initData();
  }

  Future<void> _onRefresh() async {
    _refreshController.refreshCompleted();
    await Future.delayed(Duration(milliseconds: 500));
    _initData();
  }

  _initData() async {
    context.read<OrderViewModel>().clear();
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    String token = await getToken();
    buyid = sharedPreferences.getInt("id");
    if (buyid == null) {
      eventBus.fire(RecordErrEvenet("未登陆，请重新登陆"));
      return;
    }

    context.read<OrderViewModel>().getBuyOrder(token, buyid!).then((value) {
      if (value == true) {
        showToast("订单拉取成功");
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    List<Order> list =
        Provider.of<OrderViewModel>(context, listen: true).unfinishList;
    return Column(
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
                ? const Center(
                    child: Text("暂无记录~"),
                  )
                : ListView.builder(
                    itemCount:
                        Provider.of<OrderViewModel>(context, listen: true)
                            .unfinishList
                            .length,
                    itemBuilder: (context, index) {
                      Order order =
                          Provider.of<OrderViewModel>(context, listen: true)
                              .unfinishList[index];

                      return Container(
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
                                    order.cover,
                                    fit: BoxFit.contain,
                                  ),
                                ),
                              ),
                              Container(
                                height: 130.0.h,
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Container(
                                      margin: EdgeInsets.only(
                                        bottom: 3.0.sp,
                                        left: 3.0.sp,
                                        right: 3.0.sp,
                                        top: 8.0.h,
                                      ),
                                      child: Text(
                                        order.gname,
                                        style: TextStyle(
                                          fontSize: 12.0.sp,
                                        ),
                                      ),
                                    ),
                                    Container(
                                      margin: EdgeInsets.all(3.0.sp),
                                      child: Text(
                                        "¥ ${order.price}元${priceType.priceH[order.type]}",
                                        style: TextStyle(
                                          fontSize: 12.0.sp,
                                          color: Colors.red,
                                        ),
                                      ),
                                    ),
                                    Container(
                                      margin: EdgeInsets.all(3.0.sp),
                                      child: Text(
                                        "提交时间: ${DateTime.fromMillisecondsSinceEpoch(order.time * 1000).toUtc().toString().substring(0, 19)}",
                                        style: TextStyle(
                                          fontSize: 12.0.sp,
                                        ),
                                      ),
                                    ),
                                    Container(
                                      margin: EdgeInsets.all(3.0.sp),
                                      child: Text(
                                        "学校: ${order.school}",
                                        style: TextStyle(
                                          fontSize: 12.0.sp,
                                        ),
                                      ),
                                    ),
                                    Row(
                                      children: [
                                        Card(
                                          color: Colors.grey[100],
                                          child: Container(
                                            margin: EdgeInsets.all(3.0.sp),
                                            child: Text(
                                              "卖家: ${order.sellName}",
                                              style: TextStyle(
                                                fontSize: 12.0.sp,
                                                color: Colors.black,
                                              ),
                                            ),
                                          ),
                                        ),
                                        order.status == OrderStatus.CHECK
                                            ? ElevatedButton(
                                                onPressed: () async {
                                                  String token =
                                                      await getToken();
                                                  context
                                                      .read<OrderViewModel>()
                                                      .updateOrder(
                                                          token,
                                                          order.id,
                                                          order.sellid,
                                                          order.buyid,
                                                          buyid!,
                                                          OrderStatus.SUCCESS)
                                                      .then((value) {
                                                    if (value) {
                                                      showToast("操作成功");
                                                    }
                                                  });
                                                },
                                                style: ButtonStyle(
                                                  backgroundColor:
                                                      MaterialStateProperty.all(
                                                          Colors.blue),
                                                ),
                                                child: Text(
                                                  "确认收货",
                                                  style: TextStyle(
                                                    fontSize: 10.0.sp,
                                                  ),
                                                ),
                                              )
                                            : Text("等待商家确认"),
                                      ],
                                    ),
                                  ],
                                ),
                              )
                            ],
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ),
      ],
    );
  }
}

class _finishWidget extends StatefulWidget {
  _finishWidget({Key? key}) : super(key: key);

  @override
  __finishWidgetState createState() => __finishWidgetState();
}

class __finishWidgetState extends State<_finishWidget> {
  RefreshController _refreshController = RefreshController();


  @override
  void didChangeDependencies() {
    print("change!");
  }

  @override
  void didUpdateWidget(_finishWidget oldWidget) {
    print("update");
  }

  @override
  void initState() {
    super.initState();
    context.read<OrderViewModel>().clear();
    _initData();
  }

  Future<void> _onRefresh() async {
    _refreshController.refreshCompleted();
    await Future.delayed(Duration(milliseconds: 500));
    _initData();
  }

  _initData() async {
    print("init!");
    context.read<OrderViewModel>().clear();
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    String token = await getToken();
    int? buyid = sharedPreferences.getInt("id");
    if (buyid == null) {
      eventBus.fire(RecordErrEvenet("未登陆，请重新登陆"));
      return;
    }

    context.read<OrderViewModel>().getBuyOrder(token, buyid).then((value) {
      if (value == true) {
        showToast("订单拉取成功");
      }
    });
  }

  @override
  Widget build(BuildContext context) {

    print("build");

    List<Order> list =
        Provider.of<OrderViewModel>(context, listen: true).finishList;

    return Column(
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
                    itemCount:
                        Provider.of<OrderViewModel>(context, listen: true)
                            .finishList
                            .length,
                    itemBuilder: (context, index) {
                      Order order =
                          Provider.of<OrderViewModel>(context, listen: true)
                              .finishList[index];

                      return Container(
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
                                    order.cover,
                                    fit: BoxFit.contain,
                                  ),
                                ),
                              ),
                              Container(
                                height: 140.0.h,
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Container(
                                      margin: EdgeInsets.only(
                                          left: 3.0.w, top: 8.0.h),
                                      child: Text(
                                        order.gname,
                                        style: TextStyle(
                                          fontSize: 12.0.sp,
                                        ),
                                      ),
                                    ),
                                    Container(
                                      margin: EdgeInsets.only(left: 3.0.w),
                                      child: Text(
                                        "¥ ${order.price}元${priceType.priceH[order.type]}",
                                        style: TextStyle(
                                          fontSize: 12.0.sp,
                                          color: Colors.red,
                                        ),
                                      ),
                                    ),
                                    Container(
                                      margin: EdgeInsets.only(left: 3.0.w),
                                      child: Text(
                                        "提交时间: ${DateTime.fromMillisecondsSinceEpoch(order.time * 1000).toUtc().toString().substring(0, 19)}",
                                        style: TextStyle(
                                          fontSize: 12.0.sp,
                                        ),
                                      ),
                                    ),
                                    Container(
                                      margin: EdgeInsets.only(left: 3.0.w),
                                      child: Text(
                                        "学校: ${order.school}",
                                        style: TextStyle(
                                          fontSize: 12.0.sp,
                                        ),
                                      ),
                                    ),
                                    Card(
                                      color: Colors.grey[100],
                                      child: Container(
                                        margin: EdgeInsets.only(left: 3.0.w),
                                        child: Text(
                                          "卖家: ${order.sellName}",
                                          style: TextStyle(
                                            fontSize: 12.0.sp,
                                            color: Colors.black,
                                          ),
                                        ),
                                      ),
                                    ),
                                    Container(
                                      margin: EdgeInsets.only(left: 3.0.w),
                                      child: Row(
                                        children: [
                                          Text(
                                            "当前状态: ",
                                            style: TextStyle(
                                              fontSize: 12.0.sp,
                                            ),
                                          ),
                                          Text(
                                            order.status == 1 ? "交易成功" : order.status == 2 ? "交易失败" : "已评论",
                                            style: TextStyle(
                                              fontSize: 12.0.sp,
                                              color: Colors.red,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    order.status == OrderStatus.SUCCESS
                                        ? ElevatedButton(
                                            onPressed: () async {
                                              Navigator.push(
                                                context,
                                                MaterialPageRoute(
                                                  builder: (context) => CommentView(
                                                    oid: order.id,
                                                    gid: order.gid,
                                                  ),
                                                ),
                                              );
                                            },
                                            style: ButtonStyle(
                                              backgroundColor:
                                                  MaterialStateProperty.all(
                                                      Colors.blue),
                                            ),
                                            child: Text(
                                              "去评论",
                                              style: TextStyle(
                                                fontSize: 12.0.sp,
                                              ),
                                            ),
                                          )
                                        : Container(),
                                  ],
                                ),
                              )
                            ],
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ),
      ],
    );
  }
}
