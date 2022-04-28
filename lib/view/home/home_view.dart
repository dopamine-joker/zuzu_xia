import 'dart:ffi';
import 'dart:math';
import 'dart:typed_data';
import 'dart:io';

import 'package:event_bus/event_bus.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_demo/global/priceType.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:material_floating_search_bar/material_floating_search_bar.dart';
import 'package:flutter_demo/view/home/search_bar.dart';
import 'package:flutter_demo/utils/dialog.dart';
import 'package:flutter_demo/utils/event.dart';
import 'package:flutter_demo/view/home/goods_detail_view.dart';
import 'package:flutter_demo/viewmodel/home_viewmodel.dart';
import 'package:provider/provider.dart';
import 'package:provider/src/provider.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:dialogs/dialogs/progress_dialog.dart';

import 'package:flutter_sound/flutter_sound.dart';
import 'package:flutter_sound_platform_interface/flutter_sound_recorder_platform_interface.dart';
import 'package:permission_handler/permission_handler.dart';

import 'package:audio_session/audio_session.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter_demo/global/global.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';

typedef _Fn = void Function();

const theSource = AudioSource.microphone;

class HomeMenu extends StatefulWidget {
  @override
  _HomeMenuState createState() => _HomeMenuState();
}

class _HomeMenuState extends State<HomeMenu> {

  RefreshController _refreshController = RefreshController();
  bool _load = true;

  FlutterSoundRecorder? _mRecorder = FlutterSoundRecorder();
  Codec _codec = Codec.aacMP4;
  String _baseUrl = "";
  String _mPath = 'tau_file.mp4';
  bool _mRecorderIsInited = false;
  bool _isProcessing = false; //后台是否在处理语音
  String token = "";

  Future<void> _onRefresh() async {
    _refreshController.refreshCompleted();
    await Future.delayed(Duration(milliseconds: 500));
    context.read<HomeViewmodel>().clear();
    _initData();
    print("_onRefresh");
  }

  @override
  void initState() {
    eventBus.on<HomeErrEvent>().listen((event) {
      getDialog("提示", event.detail).show(context);
    });

    _initMember();
    _initData();

    super.initState();
  }

  void _initMember() async {
    Directory tempDir = await getTemporaryDirectory();
    _baseUrl = tempDir.path;
    token = await getToken();
    openTheRecorder().then((value) {
      setState(() {
        _mRecorderIsInited = true;
      });
    });
  }

  // @override
  // void dispose() {
  //   super.dispose();
  //   context.read<HomeViewmodel>().clear();
  // }

  Future<void> openTheRecorder() async {
    if (!kIsWeb) {
      var status = await Permission.microphone.request();
      if (status != PermissionStatus.granted) {
        throw RecordingPermissionException('Microphone permission not granted');
      }
    }
    await _mRecorder!.openRecorder();
    if (!await _mRecorder!.isEncoderSupported(_codec) && kIsWeb) {
      _codec = Codec.opusWebM;
      _mPath = 'tmp_voice.webm';
      if (!await _mRecorder!.isEncoderSupported(_codec) && kIsWeb) {
        _mRecorderIsInited = true;
        return;
      }
    }
    final session = await AudioSession.instance;
    await session.configure(AudioSessionConfiguration(
      avAudioSessionCategory: AVAudioSessionCategory.playAndRecord,
      avAudioSessionCategoryOptions:
          AVAudioSessionCategoryOptions.allowBluetooth |
              AVAudioSessionCategoryOptions.defaultToSpeaker,
      avAudioSessionMode: AVAudioSessionMode.spokenAudio,
      avAudioSessionRouteSharingPolicy:
          AVAudioSessionRouteSharingPolicy.defaultPolicy,
      avAudioSessionSetActiveOptions: AVAudioSessionSetActiveOptions.none,
      androidAudioAttributes: const AndroidAudioAttributes(
        contentType: AndroidAudioContentType.speech,
        flags: AndroidAudioFlags.none,
        usage: AndroidAudioUsage.voiceCommunication,
      ),
      androidAudioFocusGainType: AndroidAudioFocusGainType.gain,
      androidWillPauseWhenDucked: true,
    ));
    _mRecorderIsInited = true;
  }

  Future<void> _initData() async {
    // context.read<HomeViewmodel>().clear();
    //先拉一次数据
    _getGoods();
  }

  Future _onLoading() async {
    await Future.delayed(Duration(milliseconds: 500));
    _getGoods();
    _refreshController.loadComplete();
    print("loadMore");
  }

  void _getGoods() async {
    token = await getToken();
    bool result = await context.read<HomeViewmodel>().getGoods(token, 5);
    if (result == true) {}
    print(result);
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
  void dispose() {
    _mRecorder!.closeRecorder();
    _mRecorder = null;
    super.dispose();
  }

  void record() {
    showToast("开始录音");
    _mRecorder!
        .startRecorder(
      toFile: _baseUrl + _mPath,
      codec: _codec,
      audioSource: theSource,
    )
        .then((value) {
      setState(() {});
    });
  }

  void stopRecorder() async {
    showToast("停止录音");
    await _mRecorder!.stopRecorder().then((value) {
      sleep(Duration(milliseconds: 500));
      final XFile voiceFile = XFile(_baseUrl + _mPath);
      context.read<HomeViewmodel>().VoiceToTxt(token, voiceFile).then((txt) {
        if(txt != "") {
          SearchBar searchBar = SearchBar();
          searchBar.setVoiceTxt(txt);
          searchBar.setVoiceSearch(true);
          showSearch(context: context, delegate: searchBar);
        }
      });

      setState(() {
        //var url = value;
        // _mplaybackReady = true;
      });
    });
  }

  _Fn? getRecorderFn() {
    if (!_mRecorderIsInited || _isProcessing) {
      return null;
    }
    return _mRecorder!.isStopped ? record : stopRecorder;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton(
        onPressed: getRecorderFn(),
        tooltip: 'record',
        child: _mRecorder!.isRecording
            ? const Icon(Icons.stop)
            : const Icon(Icons.play_arrow),
        heroTag: "recordBtn",
      ),
      appBar: AppBar(
        backgroundColor: Colors.grey[800],
        title: Text(
          "主页",
          style: TextStyle(
            fontSize: 15.0.sp,
          ),
        ),
        elevation: 10,
        // centerTitle: true,
        automaticallyImplyLeading: false,
        actions: [
          // IconButton(
          //   onPressed: getRecorderFn(),
          //   icon: _mRecorder!.isRecording
          //       ? const Icon(Icons.stop)
          //       : const Icon(Icons.play_arrow),
          // ),
          IconButton(
            icon: Icon(Icons.search),
            onPressed: () {
              showSearch(context: context, delegate: SearchBar());
            },
          )
        ],
      ),
      body: Column(
        children: [
          // ElevatedButton(
          //   onPressed: () {
          //     _getGoods();
          //   },
          //   child: Text("press"),
          // ),
          Expanded(
            child: SmartRefresher(
              enablePullDown: true,
              enablePullUp: true,
              header: const ClassicHeader(
                idleText: "下拉刷新",
                refreshingText: "刷新中",
                completeText: "ok",
                releaseText: "释放刷新",
                failedText: "刷新失败",
              ),
              footer: CustomFooter(
                builder: (context, mode) {
                  Widget body;
                  if (mode == LoadStatus.idle) {
                    body = Text("pull up load");
                  } else if (mode == LoadStatus.loading) {
                    body = CupertinoActivityIndicator();
                  } else if (mode == LoadStatus.failed) {
                    body = Text("Load Failed!Click retry!");
                  } else if (mode == LoadStatus.canLoading) {
                    body = Text("release to load more");
                  } else {
                    body = Text("No more Data");
                  }
                  return Container(
                    height: 55.0,
                    child:
                        Provider.of<HomeViewmodel>(context, listen: true).finish
                            ? Center(
                                child: Text("没有更多数据"),
                              )
                            : Center(child: body),
                  );
                },
              ),
              controller: _refreshController,
              onRefresh: _onRefresh,
              onLoading: _onLoading,
              child: MasonryGridView.count(
                crossAxisCount: 2,
                itemCount: Provider.of<HomeViewmodel>(context, listen: true)
                    .list
                    .length,
                padding: EdgeInsets.all(4.0.w),
                itemBuilder: (context, index) {
                  Goods goods =
                      Provider.of<HomeViewmodel>(context, listen: true)
                          .list[index];
                  return InkWell(
                    onTap: () {
                      toDetail(goods.id);
                    },
                    child: Card(
                      shape: RoundedRectangleBorder(
                          borderRadius:
                              BorderRadiusDirectional.circular(5.0.sp)),
                      margin: EdgeInsets.only(
                          left: 4.0.w, right: 4.0.w, top: 7.0.h, bottom: 7.0.h),
                      color: Colors.grey[300],
                      child: Column(
                        children: [
                          Container(
                            child: ClipRRect(
                              borderRadius: BorderRadius.only(
                                  topLeft: Radius.circular(5.0.sp),
                                  topRight: Radius.circular(5.0.sp)),
                              child: Image.network(
                                goods.cover,
                                fit: BoxFit.fill,
                              ),
                            ),
                          ),
                          Container(
                            margin: EdgeInsets.only(
                              left: 6.0.w,
                              right: 6.0.w,
                              bottom: 10.0.h,
                              top: 10.0.h,
                            ),
                            width: double.infinity,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  goods.name,
                                  style: TextStyle(
                                    color: Colors.grey[900],
                                    fontSize: 16.0.sp,
                                    // backgroundColor: Colors.green,
                                  ),
                                ),
                                Row(
                                  children: [
                                    Text(
                                      "¥ ",
                                      style: TextStyle(
                                        color: Colors.red,
                                        fontSize: 15.0.sp,
                                        // backgroundColor: Colors.green,
                                      ),
                                    ),
                                    Text(
                                      "${goods.price.toString()}元${priceType.priceH[goods.type]}",
                                      style: TextStyle(
                                        color: Colors.red,
                                        fontSize: 17.0.sp,
                                        // backgroundColor: Colors.green,
                                      ),
                                    ),
                                  ],
                                ),
                                Text(
                                  "上传者: ${goods.uname.toString()}",
                                  style: TextStyle(
                                    color: Colors.grey[800],
                                    fontSize: 12.0.sp,
                                    // backgroundColor: Colors.green,
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
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget buildFloatingSearchBar() {
    final isPortrait =
        MediaQuery.of(context).orientation == Orientation.portrait;

    return FloatingSearchBar(
      hint: 'Search...',
      scrollPadding: const EdgeInsets.only(top: 16, bottom: 56),
      transitionDuration: const Duration(milliseconds: 800),
      transitionCurve: Curves.easeInOut,
      physics: const BouncingScrollPhysics(),
      axisAlignment: isPortrait ? 0.0 : -1.0,
      openAxisAlignment: 0.0,
      width: isPortrait ? 600 : 500,
      debounceDelay: const Duration(milliseconds: 500),
      onQueryChanged: (query) {
        // Call your model, bloc, controller here.
      },
      // Specify a custom transition to be used for
      // animating between opened and closed stated.
      transition: CircularFloatingSearchBarTransition(),
      actions: [
        FloatingSearchBarAction(
          showIfOpened: false,
          child: CircularButton(
            icon: const Icon(Icons.place),
            onPressed: () {},
          ),
        ),
        FloatingSearchBarAction.searchToClear(
          showIfClosed: false,
        ),
      ],
      builder: (context, transition) {
        return ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: Material(
            color: Colors.white,
            elevation: 4.0,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: Colors.accents.map((color) {
                return Container(height: 112, color: color);
              }).toList(),
            ),
          ),
        );
      },
    );
  }
}
