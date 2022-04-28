import 'package:flutter/material.dart';
import 'package:flutter_demo/viewmodel/comment_viewmodel.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../global/global.dart';

class GoodsCommentListView extends StatefulWidget {
  int gid;

  GoodsCommentListView({Key? key, required this.gid}) : super(key: key);

  @override
  _GoodsCommentListViewState createState() => _GoodsCommentListViewState();
}

class _GoodsCommentListViewState extends State<GoodsCommentListView> {
  @override
  void initState() {
    _initData();
    super.initState();
  }


  @override
  void dispose() {
    super.dispose();
  }

  _initData() async {
    String token = await getToken();
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    int? id = sharedPreferences.getInt("id");
    context
        .read<CommentViewModel>()
        .getCommentByGoodsIdModel(token, widget.gid);
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    List<GoodsComment> commentList =
        Provider.of<CommentViewModel>(context, listen: true).goodsCommentList;
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.grey[800],
        title: Text(
          "评论",
          style: TextStyle(
            fontSize: 15.0.sp,
          ),
        ),
        elevation: 10,
        centerTitle: true,
      ),
      body: commentList.isNotEmpty
          ? ListView.builder(
              shrinkWrap: true,
              physics: NeverScrollableScrollPhysics(),
              itemCount: commentList.length,
              itemBuilder: (context, index) {
                GoodsComment comment = commentList[index];
                return Container(
                  margin: EdgeInsets.all(10.0.w),
                  child: Card(
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadiusDirectional.circular(5.0.sp)),
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
                            borderRadius: BorderRadius.all(
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
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Container(
                                    margin: EdgeInsets.only(left: 3.0.w),
                                    child: Text(
                                      comment.userName,
                                      style: TextStyle(
                                        fontSize: 14.0.sp,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              Row(
                                children: [
                                  Container(
                                    margin: EdgeInsets.only(left: 3.0.w),
                                    child: Text(
                                      "评价等级: ${comment.level}",
                                      style: TextStyle(
                                        fontSize: 12.0.sp,
                                        color: Colors.grey,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                  Container(
                                    margin: EdgeInsets.only(left: 3.0.w),
                                    child: Text(
                                      "提交时间: ${DateTime.fromMillisecondsSinceEpoch(comment.time * 1000).toUtc().toString().substring(0, 19)}",
                                      style: TextStyle(
                                        fontSize: 12.0.sp,
                                        color: Colors.grey,
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
                                      left: 3.0.w, right: 3.0.w),
                                  width: MediaQuery.of(context).size.width,
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
            )
          : const Center(
              child: Text("暂无评论~"),
            ),
    );
  }
}
