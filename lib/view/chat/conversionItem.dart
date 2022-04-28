import 'package:flutter/material.dart';
import 'package:flutter_demo/common/avatar.dart';
import 'package:flutter_demo/common/colors.dart';
import 'package:flutter_demo/common/hexToColor.dart';
import 'package:flutter_demo/view/chat/chat_view.dart';
import 'package:tencent_im_sdk_plugin/enum/message_elem_type.dart';
import 'package:tencent_im_sdk_plugin/models/v2_tim_message.dart';

class ConversionItem extends StatelessWidget {
  String name;
  final String? faceUrl;
  final V2TimMessage? lastMessage;
  final int? unreadCount;
  final int? type;
  final String conversationID;
  // final String fromUserID;
  final String toUserID;

  ConversionItem(
      {Key? key,
      required this.name,
      this.faceUrl,
      this.lastMessage,
      this.unreadCount,
      this.type,
      required this.conversationID,
      // required this.fromUserID,
      required this.toUserID})
      : super(key: key);

  String formatTime() {
    int timestamp = lastMessage!.timestamp! * 1000;
    DateTime time = DateTime.fromMillisecondsSinceEpoch(timestamp).toUtc();
    DateTime now = DateTime.now();

    if (now.day == time.day) {
      return "${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}:${time.second.toString().padLeft(2, '0')}";
    } else {
      return "${time.month.toString().padLeft(2, '0')}-${time.day.toString().padLeft(2, '0')}";
    }
  }

  String? getFaceUrl() {
    return (faceUrl == null || faceUrl == '')
        ? type == 1
            ? 'assets/images/person.png'
            : 'assets/images/logo.png'
        : faceUrl;
  }

  _chat(context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => chatView(
          conversationId: conversationID,
          toUserName: name,
          toUserId: toUserID,
        ),
      ),
    );
    print("调用调用调用调用调用调用调用");
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => {_chat(context)},
      child: Container(
        height: 70,
        child: Row(
          children: [
            Container(
              width: 70,
              height: 70,
              child: Padding(
                padding: EdgeInsets.all(11),
                child: PhysicalModel(
                  color: Colors.transparent,
                  borderRadius: BorderRadius.circular(4.8),
                  clipBehavior: Clip.antiAlias,
                  child: Avatar(
                    width: 48,
                    height: 48,
                    radius: 0,
                    avtarUrl: getFaceUrl(),
                  ),
                ),
              ),
            ),
            Expanded(
              child: Container(
                height: 70,
                decoration: BoxDecoration(
                  border: Border(
                    bottom: BorderSide(
                      color: hexToColor("ededed"),
                      width: 1,
                      style: BorderStyle.solid,
                    ),
                  ),
                ),
                child: Column(
                  children: [
                    Container(
                      height: 24,
                      margin: EdgeInsets.only(top: 11),
                      child: Row(
                        children: [
                          Expanded(
                            child: Text(
                              name,
                              style: TextStyle(
                                color: hexToColor("111111"),
                                fontSize: 18,
                                height: 1,
                              ),
                              textAlign: TextAlign.left,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          Container(
                            child: Text(
                              formatTime(),
                              textAlign: TextAlign.right,
                              style: TextStyle(
                                color: Color(int.parse('b0b0b0', radix: 16))
                                    .withAlpha(255),
                                fontSize: 12,
                              ),
                            ),
                            width: 105,
                            padding: EdgeInsets.only(right: 16),
                          )
                        ],
                      ),
                    ),
                    Container(
                      height: 20,
                      margin: EdgeInsets.only(top: 2),
                      child: Row(
                        children: [
                          Expanded(
                            child: Text(
                              lastMessage!.elemType ==
                                      MessageElemType.V2TIM_ELEM_TYPE_TEXT
                                  ? lastMessage!.textElem!.text!
                                  : lastMessage!.elemType ==
                                          MessageElemType
                                              .V2TIM_ELEM_TYPE_GROUP_TIPS
                                      ? '【系统消息】'
                                      : lastMessage!.elemType ==
                                              MessageElemType
                                                  .V2TIM_ELEM_TYPE_SOUND
                                          ? '【语音消息】'
                                          : lastMessage!.elemType ==
                                                  MessageElemType
                                                      .V2TIM_ELEM_TYPE_CUSTOM
                                              ? '【自定义消息】'
                                              : lastMessage!.elemType ==
                                                      MessageElemType
                                                          .V2TIM_ELEM_TYPE_IMAGE
                                                  ? '【图片】'
                                                  : lastMessage!.elemType ==
                                                          MessageElemType
                                                              .V2TIM_ELEM_TYPE_VIDEO
                                                      ? '【视频】'
                                                      : lastMessage!.elemType ==
                                                              MessageElemType
                                                                  .V2TIM_ELEM_TYPE_FILE
                                                          ? '【文件】'
                                                          : lastMessage!
                                                                      .elemType ==
                                                                  MessageElemType
                                                                      .V2TIM_ELEM_TYPE_FACE
                                                              ? '【表情】'
                                                              : '',
                              style: TextStyle(
                                color: CommonColors.getTextWeakColor(),
                                fontSize: 14,
                              ),
                            ),
                          ),
                          Container(
                            child: unreadCount! > 0
                                ? PhysicalModel(
                                    color: Colors.transparent,
                                    borderRadius: BorderRadius.circular(9),
                                    clipBehavior: Clip.antiAlias,
                                    child: Container(
                                      color: CommonColors.getReadColor(),
                                      width: 18,
                                      height: 18,
                                      child: Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        crossAxisAlignment:
                                            CrossAxisAlignment.center,
                                        children: [
                                          Text(
                                            unreadCount! > 99
                                                ? '...'
                                                : unreadCount.toString(),
                                            textAlign: TextAlign.center,
                                            textWidthBasis:
                                                TextWidthBasis.parent,
                                            style: TextStyle(
                                              color: Colors.white,
                                              fontSize: 12,
                                              fontWeight: FontWeight.w500,
                                            ),
                                          )
                                        ],
                                      ),
                                    ),
                                  )
                                : null,
                            width: 18,
                            height: 18,
                            margin: EdgeInsets.only(right: 16),
                          )
                        ],
                      ),
                    )
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
