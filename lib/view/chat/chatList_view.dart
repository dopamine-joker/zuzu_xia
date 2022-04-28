import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:flutter_demo/utils/dialog.dart';
import 'package:flutter_demo/view/chat/conversionItem.dart';
import 'package:flutter_demo/viewmodel/chat_viewmodel.dart';
import 'package:provider/provider.dart';
import 'package:tencent_im_sdk_plugin/models/v2_tim_conversation.dart';
import 'package:tencent_im_sdk_plugin/models/v2_tim_conversation_result.dart';
import 'package:tencent_im_sdk_plugin/models/v2_tim_value_callback.dart';
import 'package:tencent_im_sdk_plugin/tencent_im_sdk_plugin.dart';

class ChatListMenu extends StatefulWidget {
  const ChatListMenu({Key? key}) : super(key: key);

  @override
  _ChatListMenuState createState() => _ChatListMenuState();
}

class _ChatListMenuState extends State<ChatListMenu> {
  _ChatListMenuState() {
    getMessage();
  }

  getMessage() async {
    V2TimValueCallback<V2TimConversationResult> data = await TencentImSDKPlugin
        .v2TIMManager
        .getConversationManager()
        .getConversationList(nextSeq: "0", count: 100);
    List<V2TimConversation> newList = [];
    if (data.data != null) {
      newList = data.data!.conversationList!.cast<V2TimConversation>();
    } else {
      newList = [];
    }
    context.read<ChatViewModel>().setConversionList(newList);
  }

  // 筛选一下图片后缀不正确的图片
  String? checkFaceUrl(String? url) {
    String faceUrl = url != null ? url : "";
    RegExp checkUrl =
        new RegExp("\S{0,}.png|.jpg|.jpeg|.gif", caseSensitive: false);

    return checkUrl.hasMatch(faceUrl) ? faceUrl : "";
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    List<V2TimConversation>? conversionList =
        Provider.of<ChatViewModel>(context, listen: true).conversionList;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.grey[800],
        title: Text(
          "消息",
          style: TextStyle(
            fontSize: 15.0.sp,
          ),
        ),
        elevation: 10,
        centerTitle: true,
        automaticallyImplyLeading: false,
      ),
      body: conversionList == null || conversionList.isEmpty
          ? Center(
              child: Text(
                "暂无会话",
                style: TextStyle(
                  fontSize: 12.0.sp,
                  color: Colors.black,
                ),
              ),
            )
          : ListView(
              children: conversionList.map(
                (e) {
                  if (e.lastMessage == null || e.lastMessage!.msgID == '') {
                    return Container();
                  }
                  return Container(
                    height: 70,
                    child: Slidable(
                      key: Key(e.conversationID),
                      child: ConversionItem(
                        name: e.showName ?? "",
                        faceUrl: checkFaceUrl(e.faceUrl),
                        lastMessage: e.lastMessage,
                        unreadCount: e.unreadCount,
                        type: e.type,
                        conversationID: e.conversationID,
                        toUserID: e.userID!,
                      ),
                      endActionPane: ActionPane(
                        motion: StretchMotion(),
                        children: [
                          SlidableAction(
                            flex: 1,
                            label: "删除",
                            icon: Icons.delete,
                            backgroundColor: Colors.red,
                            onPressed: (BuildContext context) {
                              TencentImSDKPlugin.v2TIMManager
                                  .getConversationManager()
                                  .deleteConversation(
                                    conversationID: e.conversationID,
                                  )
                                  .then((value) {
                                if (value.code == 0) {
                                  context
                                      .read<ChatViewModel>()
                                      .removeConversionByConversationId(
                                          e.conversationID);
                                  showToast("删除成功");
                                } else {
                                  showToast("删除失败 ${value.code} ${value.desc}");
                                }
                              });
                            },
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ).toList(),
            ),
    );
  }
}
