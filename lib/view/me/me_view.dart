import 'package:flutter/material.dart';
import 'package:flutter_chat_ui/flutter_chat_ui.dart';
import 'package:flutter_demo/config/config.dart';
import 'package:flutter_demo/view/me/commentList_view.dart';
import 'package:flutter_demo/view/me/record.view.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter_demo/common/view.dart';
import 'package:flutter_demo/global/global.dart';
import 'package:flutter_demo/utils/dialog.dart';
import 'package:flutter_demo/utils/event.dart';
import 'package:flutter_demo/view/me/info_view.dart';
import 'package:flutter_demo/view/me/my_goods_view.dart';
import 'package:flutter_demo/view/me/order_view.dart';
import 'package:flutter_demo/viewmodel/chat_viewmodel.dart';
import 'package:flutter_demo/viewmodel/conversation_viewmodel.dart';
import 'package:flutter_demo/viewmodel/goods_viewmodel.dart';
import 'package:flutter_demo/viewmodel/login_viewmodel.dart';
import 'package:flutter_demo/viewmodel/upload_viewmodel.dart';
import 'package:provider/provider.dart';
import 'package:provider/src/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tencent_im_sdk_plugin/models/v2_tim_user_full_info.dart';
import 'package:tencent_im_sdk_plugin/tencent_im_sdk_plugin.dart';

class MeMenu extends StatefulWidget {
  const MeMenu({Key? key}) : super(key: key);

  @override
  _MeMenuState createState() => _MeMenuState();
}

class _MeMenuState extends State<MeMenu> {
  String? _name;

  List<String> _lists = ["我的商品", "我租出的", "我租入的", "我的评论" ,"信息修改"];

  Map<int, Widget> widgets = {
    0: MyGoodsView(),
    1: OrderView(),
    2: RecordView(),
    3: CommentListView(),
    4: UserInfoView(),
  };

  //找不到界面的默认界面
  Scaffold defaultWidget = Scaffold(
    appBar: AppBar(
      backgroundColor: Colors.grey[800],
      title: Text(
        "",
        style: TextStyle(
          fontSize: 15.0.sp,
        ),
      ),
      elevation: 10,
      centerTitle: true,
    ),
    body: Center(
      child: Text("暂时没有该界面~"),
    ),
  );

  @override
  void initState() {
    super.initState();

    eventBus.on<MeErrEvent>().listen((event) {
      getDialog("系统提示", event.detail).show(context);
    });
  }

  void loadData() async {
    SharedPreferences sp = await SharedPreferences.getInstance();
    setState(() {
      _name = sp.getString("name") ?? "";
    });
  }

  @override
  Widget build(BuildContext context) {
    //build时调用，保证数据最新
    loadData();
    return CustomScrollView(
      reverse: false,
      shrinkWrap: false,
      slivers: [
        SliverAppBar(
          pinned: false,
          backgroundColor: Colors.grey[800],
          expandedHeight: 200.0.h,
          iconTheme: IconThemeData(color: Colors.transparent),
          actions: [
            IconButton(
              onPressed: _logoutDialog,
              icon: Icon(
                Icons.logout,
                color: Colors.white,
              ),
            ),
          ],
          flexibleSpace: InkWell(
            onTap: () async {
              final result = await ImagePicker().pickImage(
                imageQuality: 70,
                maxWidth: 1440,
                source: ImageSource.gallery,
              );

              if (result != null) {
                int size = await result.length();
                print("size:" + size.toString());
                //头像不能大于1MB
                if(size > Config.facePicN * 1024 * 1024) {
                  showToast("文件不能大于${Config.facePicN}MB");
                  return ;
                }
                String token = await getToken();
                int uid = await getUserId();
                bool res = await context
                    .read<LoginViewmodel>()
                    .UpdataFace(token, uid, result);
                if (res == true) {
                  String path = Provider.of<LoginViewmodel>(context, listen: false).face;
                  TencentImSDKPlugin.v2TIMManager.setSelfInfo(
                    userFullInfo: V2TimUserFullInfo.fromJson(
                      {
                        "faceUrl": path,
                      },
                    ),
                  );
                  print("upload success");
                }
              }
              print("修改头像");
            },
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ClipOval(
                  child: Image.network(
                    Provider.of<LoginViewmodel>(context).face,
                    width: 60.0.w,
                    height: 60.0.w,
                    fit: BoxFit.cover,
                  ),
                ),
                Container(
                  margin: EdgeInsets.fromLTRB(0.0, 20.0.h, 0.0, 0.0),
                  child: Text(
                    _name ?? "",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16.0.sp,
                    ),
                  ),
                )
              ],
            ),
          ),
        ),
        SliverFixedExtentList(
          itemExtent: 50.0.h,
          delegate: SliverChildBuilderDelegate(
            (BuildContext context, int index) {
              String title = _lists[index];
              return Container(
                child: InkWell(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => widgets[index] ?? defaultWidget,
                      ),
                    );
                  },
                  child: Container(
                    margin: EdgeInsets.all(10.0.sp),
                    child: Column(
                      children: [
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Expanded(
                              child: Text(
                                title,
                                style: TextStyle(
                                  fontSize: 14.0.sp,
                                ),
                              ),
                            ),
                            Icon(Icons.chevron_right),
                          ],
                        ),
                        Padding(
                          padding: EdgeInsets.only(top: 1.0.h),
                          child: Divider(
                            height: 1.0.h,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
            childCount: _lists.length,
          ),
        )
      ],
    );
  }

  void _logoutDialog() {
    getChoiceDialog("退出帐号", "真的要在此告别吗", _logout, () {
      Navigator.pop(context); //取消弹窗
    }).show(context);
  }

  void _logout() async {
    Provider.of<LoginViewmodel>(context, listen: false).clear();
    Provider.of<ConversationViewModel>(context, listen: false).clear();
    Provider.of<ChatViewModel>(context, listen: false).clear();
    Provider.of<GoodsViewModel>(context, listen: false).clear();
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    String? token = sharedPreferences.getString("token");
    if (token == null || token == "") {
      return;
    }
    bool result = await context.read<LoginViewmodel>().logout(token);
    if (result == true) {
      Navigator.of(context).popAndPushNamed("/");
    }
  }
}

class DrawerHead extends StatelessWidget {
  late String name;

  DrawerHead({Key? key, required this.name}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return DrawerHeader(
      margin: EdgeInsets.only(bottom: 10.0.h),
      padding: EdgeInsets.only(bottom: 10.0.h),
      child: Column(
        children: <Widget>[
          ClipOval(
            child: Image.network(
              "https://gimg2.baidu.com/image_search/src=http%3A%2F%2Fup.enterdesk.com%2Fedpic%2F3c%2F12%2F4c%2F3c124c5277386c897dad2977bb964ea1.jpg&refer=http%3A%2F%2Fup.enterdesk.com&app=2002&size=f9999,10000&q=a80&n=0&g=0n&fmt=jpeg?sec=1641974965&t=13f3d0f0bb0d6d625d43b8dc21903ce1",
              width: 40.0.w,
              height: 40.0.w,
              fit: BoxFit.cover,
            ),
          ),
          SizedBox(height: 12.0.h),
          Center(
            child: Text(
              name,
              style: TextStyle(
                color: Colors.white,
                fontSize: 10.0.sp,
              ),
            ),
          ),
          SizedBox(height: 12.0.h),
          Center(
            child: Text(
              '没有任何描述~',
              style: TextStyle(
                color: Colors.white,
                fontSize: 10.0.sp,
              ),
            ),
          ),
          // SizedBox(
          //   height: 20.0.h,
          // ),
        ],
      ),
      // 头像框背景
      decoration: BoxDecoration(
        color: Colors.grey[350],
        image: DecorationImage(
          image: NetworkImage(
              "https://gimg2.baidu.com/image_search/src=http%3A%2F%2Fhbimg.b0.upaiyun.com%2F9ce7a4c6bae45cb42d0c86eb64e3de069129b3ef10ced-EBZVvR_fw658&refer=http%3A%2F%2Fhbimg.b0.upaiyun.com&app=2002&size=f9999,10000&q=a80&n=0&g=0n&fmt=jpeg?sec=1641974851&t=140e8090e52fb000178df93125a4c42c"),
          fit: BoxFit.cover,
        ),
      ),
    );
  }
}
