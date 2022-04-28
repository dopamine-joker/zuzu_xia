import 'package:flutter/material.dart';
import 'package:flutter_demo/utils/dialog.dart';
import 'package:flutter_demo/viewmodel/comment_viewmodel.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../global/global.dart';

class CommentListView extends StatefulWidget {
  const CommentListView({Key? key}) : super(key: key);

  @override
  _CommentListViewState createState() => _CommentListViewState();
}

class _CommentListViewState extends State<CommentListView> {
  @override
  void initState() {
    _initData();
    super.initState();
  }

  _initData() async {
    String token = await getToken();
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    int? id = sharedPreferences.getInt("id");
    context.read<CommentViewModel>().getCommentByUserIdModel(token, id!);
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    List<UserComment> list =
        Provider.of<CommentViewModel>(context, listen: true).myCommentList;
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.grey[800],
        title: Text(
          "我的评论",
          style: TextStyle(
            fontSize: 15.0.sp,
          ),
        ),
        elevation: 10,
        centerTitle: true,
      ),
      body: list.isEmpty
          ? const Center(
              child: Text("暂无记录~"),
            )
          : ListView.builder(
              itemCount: list.length,
              itemBuilder: (context, index) {
                UserComment comment = list[index];

                return Slidable(
                  key: Key(comment.id.toString()),
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
                              .read<CommentViewModel>()
                              .deleteCommentModel(_token, comment.id)
                              .then((value) {
                            if (value == true) {
                              showToast("删除成功");
                            } else {
                              showToast("删除失败");
                            }
                          });
                          print("删除 ${comment.id}");
                          setState(() {});
                        },
                      ),
                    ],
                  ),
                  child: Container(
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
                            height: 70.0.h,
                            width: 70.0.w,
                            child: ClipRRect(
                              borderRadius: BorderRadius.all(
                                Radius.circular(10.0.sp),
                              ),
                              child: Image.network(
                                comment.cover,
                                fit: BoxFit.contain,
                              ),
                            ),
                          ),
                          Container(
                            height: 110.0.h,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Container(
                                  margin:
                                      EdgeInsets.only(left: 3.0.w, top: 8.0.h),
                                  child: Text(
                                    comment.goodsName,
                                    style: TextStyle(
                                      fontSize: 12.0.sp,
                                    ),
                                  ),
                                ),
                                Container(
                                  margin: EdgeInsets.only(left: 3.0.w),
                                  child: Text(
                                    "¥ ${comment.price.toString()}",
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
                                      "评论内容: ${comment.content}",
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
                                  width: 200.0.w,
                                  alignment: Alignment.centerLeft,
                                  padding: EdgeInsets.only(left: 3.0.w),
                                  child: Container(
                                    child: Text(
                                      // "222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222",
                                      "评论等级: ${comment.level}",
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
                                    "提交时间: ${DateTime.fromMillisecondsSinceEpoch(comment.time * 1000).toUtc().toString().substring(0, 19)}",
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
                  ),
                );
              },
            ),
    );
  }
}
