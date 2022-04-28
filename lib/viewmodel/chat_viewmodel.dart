import 'package:flutter/foundation.dart';
import 'package:tencent_im_sdk_plugin/models/v2_tim_conversation.dart';

class ChatViewModel extends ChangeNotifier {
  //sdk类型的会话列表
  List<V2TimConversation> _conversionList = List.empty(growable: true);
  get conversionList => _conversionList;

  setConversionList(List<V2TimConversation> newList) {
    //如果原有list存在，则更新即可，否则增加
    newList.forEach((element) {
      String cid = element.conversationID;
      if (_conversionList.any((ele) => ele.conversationID == cid)) {
        for (int i = 0; i < _conversionList.length; i++) {
          if (_conversionList[i].conversationID == cid) {
            conversionList[i] = element;
            break;
          }
        }
      } else {
        _conversionList.add(element);
      }
    });
    // 按最新信息进行一个序的排
    try {
      _conversionList.sort((left, right) => right.lastMessage!.timestamp!
          .compareTo(left.lastMessage!.timestamp!));
    } catch (err) {}
    notifyListeners();
    return _conversionList;
  }

  //删除某个对话
  removeConversionByConversationId(String conversionId) {
    _conversionList
        .removeWhere((element) => element.conversationID == conversionId);
    notifyListeners();
  }

  clear() {
    _conversionList = List.empty(growable: true);
    notifyListeners();
  }
}
