import 'package:flutter/material.dart';
import 'package:flutter_demo/global/priceType.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_demo/global/global.dart';
import 'package:flutter_demo/utils/dialog.dart';
import 'package:flutter_demo/utils/event.dart';
import 'package:flutter_demo/viewmodel/order_viewmodel.dart';
import 'package:provider/src/provider.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:shared_preferences/shared_preferences.dart';

class OrderView extends StatefulWidget {
  List widgets = [_unfinishWidget(), _finishWidget()];

  OrderView({Key? key}) : super(key: key);

  @override
  _OrderViewState createState() => _OrderViewState();
}

class _OrderViewState extends State<OrderView>
    with SingleTickerProviderStateMixin {
  List tabs = ["未完成的", "已完成的"];

  late TabController _controller;
  int _index = 0;

  @override
  void initState() {
    super.initState();

    eventBus.on<MyOrderErrEvenet>().listen((e) {
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
          "订单",
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
  int? sellid;

  @override
  void initState() {
    super.initState();
    context.read<OrderViewModel>().clearOrder();
    _initData();
  }

  Future<void> _onRefresh() async {
    _refreshController.refreshCompleted();
    await Future.delayed(Duration(milliseconds: 500));
    _initData();
  }

  _initData() async {
    context.read<OrderViewModel>().clearOrder();
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    String token = await getToken();
    sellid = sharedPreferences.getInt("id");
    if (sellid == null) {
      eventBus.fire(RecordErrEvenet("未登陆，请重新登陆"));
      return;
    }

    context.read<OrderViewModel>().getSellOrder(token, sellid!).then((value) {
      if (value == true) {
        showToast("订单拉取成功");
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    List<Order> list =
        Provider.of<OrderViewModel>(context, listen: true).myUnfinishList;
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
                            .myUnfinishList
                            .length,
                    itemBuilder: (context, index) {
                      List<Order> orderList =
                          Provider.of<OrderViewModel>(context, listen: true)
                              .myUnfinishList;

                      if (index >= orderList.length) {
                        return Container();
                      }

                      Order order = orderList[index];

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
                                height: 150.0.h,
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
                                    Card(
                                      color: Colors.grey[100],
                                      child: Container(
                                        margin: EdgeInsets.all(3.0.sp),
                                        child: Text(
                                          "买家: ${order.buyName}",
                                          style: TextStyle(
                                            fontSize: 12.0.sp,
                                            color: Colors.black,
                                          ),
                                        ),
                                      ),
                                    ),
                                    order.status == OrderStatus.COMMIT
                                        ? Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.end,
                                            children: [
                                              Container(
                                                padding: EdgeInsets.only(
                                                    top: 5.0.h, right: 10.0.w),
                                                height: 30.0.h,
                                                child: ElevatedButton(
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
                                                            sellid!,
                                                            OrderStatus.FAIL)
                                                        .then((value) {
                                                      if (value) {
                                                        showToast("操作成功");
                                                      }
                                                    });
                                                  },
                                                  style: ButtonStyle(
                                                    backgroundColor:
                                                        MaterialStateProperty
                                                            .all(Colors.red),
                                                  ),
                                                  child: Text(
                                                    "取消",
                                                    style: TextStyle(
                                                      fontSize: 10.0.sp,
                                                    ),
                                                  ),
                                                ),
                                              ),
                                              Container(
                                                padding:
                                                    EdgeInsets.only(top: 5.0.h),
                                                height: 30.0.h,
                                                child: ElevatedButton(
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
                                                            sellid!,
                                                            OrderStatus.CHECK)
                                                        .then((value) {
                                                      showToast("操作成功");
                                                    });
                                                  },
                                                  style: ButtonStyle(),
                                                  child: Text(
                                                    "确定",
                                                    style: TextStyle(
                                                      fontSize: 10.0.sp,
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ],
                                          )
                                        : Container(
                                            margin: EdgeInsets.all(3.0.sp),
                                            child: Text(
                                              "等待收货确认",
                                              style: TextStyle(
                                                fontSize: 12.0.sp,
                                              ),
                                            ),
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
  void initState() {
    super.initState();
    context.read<OrderViewModel>().clearOrder();
    _initData();
  }

  Future<void> _onRefresh() async {
    _refreshController.refreshCompleted();
    await Future.delayed(Duration(milliseconds: 500));
    _initData();
  }

  _initData() async {
    context.read<OrderViewModel>().clearOrder();
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    String token = await getToken();
    int? sellid = sharedPreferences.getInt("id");
    if (sellid == null) {
      eventBus.fire(RecordErrEvenet("未登陆，请重新登陆"));
      return;
    }

    context.read<OrderViewModel>().getSellOrder(token, sellid).then((value) {
      if (value == true) {
        showToast("订单拉取成功");
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    List<Order> list =
        Provider.of<OrderViewModel>(context, listen: true).myFinishList;
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
                            .myFinishList
                            .length,
                    itemBuilder: (context, index) {
                      Order order =
                          Provider.of<OrderViewModel>(context, listen: true)
                              .myFinishList[index];

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
                                    Card(
                                      color: Colors.grey[100],
                                      child: Container(
                                        margin: EdgeInsets.only(left: 3.0.w),
                                        child: Text(
                                          "买家: ${order.buyName}",
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
                                            order.status == 1 ? "等待评论" : order.status == 2 ? "交易失败" : "已评论",
                                            style: TextStyle(
                                              fontSize: 12.0.sp,
                                              color: Colors.red,
                                            ),
                                          ),
                                        ],
                                      ),
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
