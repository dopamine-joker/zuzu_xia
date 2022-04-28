import 'package:flutter/material.dart';
import 'package:flutter_demo/utils/dialog.dart';
import 'package:flutter_demo/utils/event.dart';
import 'package:flutter_demo/view/chat/chatList_view.dart';
import 'package:flutter_demo/view/favorites/favorites_view.dart';
import 'package:flutter_demo/view/home/home_view.dart';
import 'package:flutter_demo/view/me/me_view.dart';
import 'package:flutter_demo/viewmodel/chat_viewmodel.dart';
import 'package:flutter_demo/viewmodel/conversation_viewmodel.dart';
import 'package:provider/src/provider.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:tencent_im_sdk_plugin/enum/V2TimAdvancedMsgListener.dart';
import 'package:tencent_im_sdk_plugin/enum/V2TimConversationListener.dart';
import 'package:tencent_im_sdk_plugin/manager/v2_tim_manager.dart';
import 'package:tencent_im_sdk_plugin/models/v2_tim_message.dart';
import 'package:tencent_im_sdk_plugin/models/v2_tim_message_receipt.dart';
import 'package:tencent_im_sdk_plugin/tencent_im_sdk_plugin.dart';

class MenuView extends StatefulWidget {
  V2TIMManager timManager = TencentImSDKPlugin.v2TIMManager;

  List<Widget> widgets = [
    HomeMenu(),
    ChatListMenu(),
    FavoritesView(),
    MeMenu(),
  ];

  MenuView({Key? key}) : super(key: key);

  @override
  _MenuViewState createState() => _MenuViewState();
}

class _MenuViewState extends State<MenuView> {
  int _index = 0;

  @override
  void initState() {
    super.initState();

    eventBus.on<MenuErrEvent>().listen((event) {
      getDialog("系统提示", event.detail).show(context);
    });

    initSDKListener();
  }

  //初始化sdk的监听
  initSDKListener() {
    widget.timManager.getConversationManager().setConversationListener(
          listener: V2TimConversationListener(
            onConversationChanged: (conversationList) {
              try {
                context
                    .read<ChatViewModel>()
                    .setConversionList(conversationList);
                // showToast("有会话改变");
              } catch (e) {
                print("会话改变错误");
                print(e.toString());
              }
            },
            onNewConversation: (conversationList) {
              try {
                context
                    .read<ChatViewModel>()
                    .setConversionList(conversationList);
                // showToast("新会话来啦");
              } catch (e) {
                print("新会话错误");
                print(e.toString());
              }
            },
            onSyncServerFailed: () {
              // showToast("会话同步失败");
            },
            onSyncServerFinish: () {
              // showToast("会话同步完成");
            },
            onSyncServerStart: () {
              // showToast("会话同步开始");
            },
          ),
        );
    widget.timManager.getMessageManager().addAdvancedMsgListener(
          listener: V2TimAdvancedMsgListener(
            onRecvC2CReadReceipt: (receiptList) {
              onRecvC2CReadReceipt(receiptList);
            },
            onRecvMessageRevoked: (msgID) {},
            onRecvNewMessage: (msg) {
              onRecvNewMessage(msg);
            },
            onSendMessageProgress: (message, progress) {
              // showToast("sendMessageProgress回调");
            },
          ),
        );
  }

  //新消息对端已读
  void onRecvC2CReadReceipt(List<V2TimMessageReceipt> list) {
    // showToast("受到新消息 已读回执");
    list.forEach((element) {
      context
          .read<ConversationViewModel>()
          .updateC2CMessageByUserId(element.userID);
    });
  }

  //收到新消息回调
  void onRecvNewMessage(V2TimMessage message) {
    try {
      List<V2TimMessage> messageList = List.empty(growable: true);
      messageList.add(message);
      showToast("受到${message.sender}的新消息");
      String key; //会话Key
      if (message.groupID == null) {
        key = "c2c_${message.sender}";
      } else {
        key = "group_${message.groupID}";
      }
      print("conterkey_$key");
      context.read<ConversationViewModel>().addMessage(key, messageList);
    } catch (e) {
      showToast(e.toString());
      print(e.toString());
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // appBar: getAppBar(_title ?? ""),
      resizeToAvoidBottomInset: false,
      body: widget.widgets[_index],
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        elevation: 1.0.h,
        backgroundColor: Colors.white,
        selectedIconTheme: IconThemeData(
          color: Colors.black,
          opacity: 1.0,
        ),
        selectedItemColor: Colors.black,
        unselectedIconTheme: IconThemeData(
          color: Colors.grey,
          opacity: 0.5,
        ),
        items: [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: "主页",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.message),
            label: "消息",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.star),
            label: "收藏",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: "我的",
          ),
        ],
        currentIndex: _index,
        onTap: (v) {
          setState(() {
            _index = v;
          });
        },
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.redAccent,
        child: Icon(Icons.add),
        onPressed: () {
          Navigator.of(context).pushNamed("upload");
        },
      ),
    );
  }
}
