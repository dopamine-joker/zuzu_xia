import 'package:flutter/foundation.dart';
import 'package:tencent_im_sdk_plugin/enum/message_elem_type.dart';
import 'package:tencent_im_sdk_plugin/models/v2_tim_message.dart';
import 'package:flutter_chat_types/flutter_chat_types.dart' as types;
import 'package:uuid/uuid.dart';

class ConversationViewModel extends ChangeNotifier {
  // key: c2c_$userId
  Map<String, List<V2TimMessage>> _messageMap = Map();
  Map<String, List<types.Message>> _typeMessageMap = Map();

  get messageMap => _messageMap;
  get typeMessageMap => _typeMessageMap;

  clear() {
    _messageMap = Map();
    _typeMessageMap = Map();
    notifyListeners();
  }

  //如果有消息已读时回调，设置对端已读
  updateC2CMessageByUserId(String userId) {
    String key = "c2c_$userId";
    if (_messageMap.containsKey(key)) {
      List<V2TimMessage>? msgList = _messageMap[key];
      msgList!.forEach((element) {
        element.isPeerRead = true;
      });
      _messageMap[key] = msgList;
      notifyListeners();
    } else {
      print("会话列表不存在这个user key");
    }
  }

  //新消息回调，把新消息加到对应的会话conversation里面
  addMessage(String key, List<V2TimMessage> value) {
    if (_messageMap.containsKey(key)) {
      _messageMap[key]!.addAll(value);
    } else {
      List<V2TimMessage> messageList = List.empty(growable: true);
      messageList.addAll(value);
      _messageMap[key] = messageList;
    }
    //去重
    Map<String, V2TimMessage> rebuildMap = Map<String, V2TimMessage>();
    _messageMap[key]!.forEach((element) {
      rebuildMap[element.msgID!] = element;
    });
    _messageMap[key] = rebuildMap.values.toList();
    rebuildMap.clear();
    _messageMap[key]!
        .sort((left, right) => left.timestamp!.compareTo(right.timestamp!));

    //生成对应的插件list,给插件的messagelist添加消息
    //直接根据上述排序好的结果再生成一次types.message 的 list
    List<types.Message> newList = List.empty(growable: true);
    _messageMap[key]!.toList().forEach((e) {
      types.Message? t = getTypeMsg(key, e);
      if (t != null) {
        newList.insert(0, t);
      }
    });
    // 直接覆盖原来的list
    _typeMessageMap[key] = newList;

    // List<types.Message> newList = List.empty(growable: true);
    // value.forEach((e) {
    //   types.Message? t = getTypeMsg(key, e);
    //   if (t != null) {
    //     newList.add(t);
    //   }
    // });
    // //同上述一样操作
    // if (_typeMessageMap.containsKey(key)) {
    //   _typeMessageMap[key]!.addAll(newList);
    // } else {
    //   _typeMessageMap[key] = newList;
    // }
    // //同样需要去重
    // Map<String, types.Message> rebuildTypeMap = Map<String, types.Message>();
    // _typeMessageMap[key]!.forEach((element) {
    //   rebuildTypeMap[element.id] = element;
    // });
    // _typeMessageMap[key] = rebuildTypeMap.values.toList();
    // rebuildTypeMap.clear();
    // _typeMessageMap[key]!
    //     .sort((left, right) => left.createdAt!.compareTo(right.createdAt!));

    // if (_typeMessageMap.containsKey(key)) {}

    notifyListeners();
  }

  types.Message? getTypeMsg(String key, V2TimMessage v2timMessage) {
    List<types.Message> newList = List.empty(growable: true);
    Uuid uuid = Uuid();
    types.Message? msg;
    if (v2timMessage.elemType == MessageElemType.V2TIM_ELEM_TYPE_TEXT) {
      msg = types.TextMessage(
        author: types.User(id: v2timMessage.sender!),
        id: uuid.v4(),
        text: v2timMessage.textElem!.text!,
        createdAt: v2timMessage.timestamp,
      );
    } else if (v2timMessage.elemType == MessageElemType.V2TIM_ELEM_TYPE_IMAGE) {
      v2timMessage.imageElem!.imageList!.forEach((element) {
        if (element!.type == 2) {
          msg = types.ImageMessage(
            author: types.User(id: v2timMessage.sender!),
            createdAt: v2timMessage.timestamp,
            height: element.height!.toDouble(),
            width: element.width!.toDouble(),
            id: uuid.v4(),
            size: element.size!,
            name: element.uuid!,
            uri: element.url!,
          );
        }
      });
    }
    return msg;
  }

  addOneMessageIfNotExits(String key, V2TimMessage message) {
    if (_messageMap.containsKey(key)) {
      bool hasMessage =
          _messageMap[key]!.any((element) => element.msgID == message.msgID);
      if (hasMessage) {
        int idx = _messageMap[key]!
            .indexWhere((element) => element.msgID == message.msgID);
        _messageMap[key]![idx] = message;
      } else {
        _messageMap[key]!.add(message);
      }
    } else {
      List<V2TimMessage> messageList = List.empty(growable: true);
      messageList.add(message);
      _messageMap[key] = messageList;
    }
    _messageMap[key]!
        .sort((left, right) => left.timestamp!.compareTo(right.timestamp!));
    return _messageMap;
  }

  deleteMessage(String key) {
    _messageMap.remove(key);
    notifyListeners();
  }
}
