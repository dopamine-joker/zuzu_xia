import 'package:flutter/material.dart';
import 'package:flutter_demo/global/priceType.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_demo/view/home/goods_detail_view.dart';
import 'package:flutter_demo/viewmodel/home_viewmodel.dart';
import 'package:provider/provider.dart';
import 'package:provider/src/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';


class SearchBar extends SearchDelegate<String> {

  bool _voiceSearch = false;
  String _voiceTxt = "";

  String searchHint = "请输入搜索内容";

  var searchList = [
    // "11搜索结果数据1-aa",
    // "11搜索结果数据2-bb",
    // "11搜索结果数据3-cc",
    // "11搜索结果数据4-dd",
    // "22搜索结果数据5-ee",
    // "22搜索结果数据6-ff",
    // "22搜索结果数据7-gg",
    // "22搜索结果数据8-hh"
  ];

  var recentList = [
    "《C/C++程序语言设计》",
    "《第一行代码》",
    "《Go语言程序设计》",
    "《休闲小桌》",
    "《电脑支架》",
  ];

  setVoiceSearch(bool res) {
    _voiceSearch = res;
  }

  setVoiceTxt(String txt) {
    _voiceTxt = txt;
  }

  @override
  String get searchFieldLabel => searchHint;

  void _clear() {
    _voiceSearch = false;
    _voiceTxt = "";
  }

  @override
  List<Widget>? buildActions(BuildContext context) {
    if(_voiceSearch) {
      query = _voiceTxt;
      _clear();
    }
    return [
      //清除按钮
      IconButton(
        icon: const Icon(Icons.clear),
        onPressed: () {
          query = "";
        },
      ),
    ];
  }

  @override
  Widget? buildLeading(BuildContext context) {
    print("lease");
    return IconButton(
      onPressed: () {
        close(context, "");
      },
      icon: AnimatedIcon(
        icon: AnimatedIcons.menu_arrow,
        progress: transitionAnimation,
      ),
    );
  }

  Future<bool> _requestData(query, context) async {
    // bool res = await context.read<HomeViewmodel>().searchList(query.toString());
    return true;
  }

  @override
  Widget buildResults(BuildContext context) {
    print("build result");
    return searchContentView(name: query);
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    final suggestionList = query.isEmpty
        ? recentList
        : searchList.where((input) => input.startsWith(query)).toList();
    return ListView.builder(
      itemCount: suggestionList.length,
      itemBuilder: (context, index) {
        // 创建一个富文本，匹配的内容特别显示
        return ListTile(
          title: Text(
              suggestionList[index],
            style: const TextStyle(
              color: Colors.grey,
            ),
          ),
          onTap: () {
            query = suggestionList[index];
            Scaffold.of(context).showSnackBar(SnackBar(content: Text(query)));
          },
        );
      },
    );
  }
}

class searchContentView extends StatefulWidget {
  String name;

  searchContentView({Key? key, required this.name}) : super(key: key);

  @override
  _searchContentViewState createState() => _searchContentViewState();
}

class _searchContentViewState extends State<searchContentView> {
  @override
  void initState() {
    super.initState();
    initData();
  }

  initData() async {
    context.read<HomeViewmodel>().refreshSearch();
    await _getData();
  }

  _getData() async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    String? token = sharedPreferences.getString("token");
    if (token == null || token == "") {
      return;
    }
    bool res =
        await context.read<HomeViewmodel>().searchList(token, widget.name);
    if (res == true) {}
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
  Widget build(BuildContext context) {
    List<Goods> list = Provider.of<HomeViewmodel>(context, listen: true).sList;
    return list.isEmpty
        ? const Center(
            child: Text("暂无记录~"),
          )
        : ListView.builder(
            itemCount: list.length,
            itemBuilder: (context, index) {
              return InkWell(
                onTap: () {
                  toDetail(list[index].id);
                },
                child: Card(
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadiusDirectional.circular(5.0.sp)),
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
                        height: 130.0.h,
                        width: 130.0.w,
                        child: ClipRRect(
                          borderRadius: BorderRadius.all(
                            Radius.circular(10.0.sp),
                          ),
                          child: Image.network(
                            list[index].cover,
                            fit: BoxFit.contain,
                          ),
                        ),
                      ),
                      Container(
                        height: 130.0.h,
                        // color: Colors.blue,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              flex: 1,
                              child: Container(
                                margin: EdgeInsets.all(3.0.sp),
                                child: Text(
                                  list[index].name,
                                  style: TextStyle(
                                    fontSize: 18.0.sp,
                                  ),
                                ),
                              ),
                            ),
                            Expanded(
                              flex: 1,
                              child: Container(
                                margin: EdgeInsets.all(3.0.sp),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(
                                      "¥${list[index].price.toString()}${priceType.priceH[list[index].type]}",
                                      style: TextStyle(
                                        fontSize: 18.0.sp,
                                        color: Colors.red,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            Expanded(
                              flex: 1,
                              child: Card(
                                color: Colors.grey[100],
                                child: Container(
                                  margin: EdgeInsets.all(3.0.sp),
                                  child: Text("卖家: ${list[index].uname}",
                                      style: TextStyle(
                                        fontSize: 18.0.sp,
                                        color: Colors.black,
                                      )),
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
            },
          );
  }
}