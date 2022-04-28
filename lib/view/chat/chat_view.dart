import 'dart:convert';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_chat_ui/flutter_chat_ui.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_chat_types/flutter_chat_types.dart' as types;
import 'package:image_picker/image_picker.dart';
import 'package:flutter_demo/utils/dialog.dart';
import 'package:flutter_demo/viewmodel/conversation_viewmodel.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:provider/src/provider.dart';
import 'package:tencent_im_sdk_plugin/models/v2_tim_conversation.dart';
import 'package:tencent_im_sdk_plugin/models/v2_tim_message.dart';
import 'package:tencent_im_sdk_plugin/models/v2_tim_value_callback.dart';
import 'package:tencent_im_sdk_plugin/tencent_im_sdk_plugin.dart';
import 'package:uuid/uuid.dart';

class chatView extends StatefulWidget {
  final String conversationId;
  final String toUserName;
  final String toUserId;

  chatView({
    Key? key,
    required this.conversationId,
    required this.toUserName,
    required this.toUserId,
  }) : super(key: key);

  @override
  _chatViewState createState() => _chatViewState(conversationId);
}

class _chatViewState extends State<chatView> {
  String conversationID;
  late Uuid uuid;

  //先初始化为一个不存在的值
  types.User _fromuser = types.User(id: "-1");

  _chatViewState(this.conversationID);

  @override
  void initState() {
    super.initState();
    initData();
  }

  getHistoryList(Map<String, List<V2TimMessage>> currentMessageMap,
      Map<String, List<types.Message>> currentTypeMessageMap) {
    List<V2TimMessage> messageList = List.empty(growable: true);
    messageList =
        currentMessageMap[conversationID] ?? List.empty(growable: true);
    // 查询是否有未读消息
    bool hasNoRead = messageList.any((element) {
      return element.isPeerRead! && element.isRead!;
    });
    print("hasNoRead? " + hasNoRead.toString());
    // if (hasNoRead) {
    // showToast("设置会话已读");
    TencentImSDKPlugin.v2TIMManager
        .getMessageManager()
        .markC2CMessageAsRead(userID: widget.toUserId)
        .then((res) {
      if (res.code == 0) {
        // showToast("设置会话已读成功");
      } else {
        // showToast("设置会话已读失败");
      }
    });
    // }
  }

  void initData() async {
    uuid = Uuid();

    //获得自己的id
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    int fromUserId = sharedPreferences.getInt("id") ?? -1;
    print("自己的id: " + fromUserId.toString());
    print("会话的id: " + conversationID.toString());
    // 获得对端id和消息
    V2TimValueCallback<V2TimConversation> data = await TencentImSDKPlugin
        .v2TIMManager
        .getConversationManager()
        .getConversation(conversationID: conversationID);
    String _toUserID = "";
    int _type = -1;
    if (data.code == 0) {
      _toUserID = data.data!.userID ?? "";
      _type = data.data!.type!;
      print("对端userId: " + _toUserID.toString());
      print("会话类型: " + _type.toString());
    }
    // 会话为c2c,这里不考虑群聊
    List<V2TimMessage> list = List.empty(growable: true);
    if (_type == 1) {
      //c2c
      TencentImSDKPlugin.v2TIMManager
          .getMessageManager()
          .getC2CHistoryMessageList(
            userID: _toUserID,
            count: 100,
          )
          .then((listRes) {
        if (listRes.code == 0) {
          list = listRes.data!;
          //TODO: 标记已读
          // list.forEach((e) {
          //   print(e.textElem!.text.toString());
          // });
          if (list.length == 0) {
            print("没有任何消息");
            list = List.empty(growable: true);
          }
          print(conversationID);
          context
              .read<ConversationViewModel>()
              .addMessage(conversationID, list);

          /**
           * 在异步回调里根据回调数据，刷新状态
           */
          setState(() {
            _fromuser = types.User(id: fromUserId.toString());
          });
        } else {
          showToast("获取历史消息失败");
          print("conversationID 获取历史消息失败 ${listRes.desc}");
        }
      });
    }
  }

  void _handleSendPressed(types.PartialText message) async {
    // 发送消息
    String text = message.text;
    if (text == "") {
      return;
    }
    V2TimValueCallback<V2TimMessage> sendRes = await TencentImSDKPlugin
        .v2TIMManager
        .sendC2CTextMessage(text: text, userID: widget.toUserId);
    if (sendRes.code == 0) {
      showToast("发送成功");
      String key = "c2c_${widget.toUserId}";
      List<V2TimMessage> list = List.empty(growable: true);
      list.add(sendRes.data!);
      context.read<ConversationViewModel>().addMessage(key, list);
    } else {
      showToast("发送失败");
      print(sendRes.desc);
    }
  }

  void _handleImageSelection() async {
    final result = await ImagePicker().pickImage(
      imageQuality: 70,
      maxWidth: 1440,
      source: ImageSource.gallery,
    );

    if (result != null) {
      final bytes = await result.readAsBytes();
      final image = await decodeImageFromList(bytes);

      final message = types.ImageMessage(
        author: _fromuser,
        createdAt: DateTime.now().millisecondsSinceEpoch,
        height: image.height.toDouble(),
        id: uuid.v4(),
        name: result.name,
        size: bytes.length,
        uri: result.path,
        width: image.width.toDouble(),
      );

      V2TimValueCallback<V2TimMessage> res = await TencentImSDKPlugin
          .v2TIMManager
          .getMessageManager()
          .sendImageMessage(
            fileName: result.name,
            imagePath: result.path,
            receiver: widget.toUserId,
            groupID: "",
            onlineUserOnly: false,
          );
      if (res.code == 0) {
        String key = "c2c_${widget.toUserId}";
        List<V2TimMessage> list = List.empty(growable: true);
        list.add(res.data!);
        context.read<ConversationViewModel>().addMessage(key, list);
        showToast("发送成功");
      } else {
        showToast("图片发送失败");
        print(res.desc);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    Map<String, List<V2TimMessage>> currentMessageMap =
        Provider.of<ConversationViewModel>(context, listen: true).messageMap;

    Map<String, List<types.Message>> currentTypeMessageMap =
        Provider.of<ConversationViewModel>(context, listen: true)
            .typeMessageMap;

    getHistoryList(currentMessageMap, currentTypeMessageMap);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.grey[800],
        title: Text(
          widget.toUserName,
          style: TextStyle(
            fontSize: 15.0.sp,
          ),
        ),
        elevation: 10,
        centerTitle: true,
      ),
      body: SafeArea(
        bottom: false,
        child: Chat(
          messages: Provider.of<ConversationViewModel>(context, listen: true)
                  .typeMessageMap[conversationID] ??
              List.empty(),
          onSendPressed: _handleSendPressed,
          onAttachmentPressed: _handleImageSelection,
          user: _fromuser,
        ),
      ),
    );
  }
}
