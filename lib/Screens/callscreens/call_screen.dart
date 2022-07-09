import 'dart:async';

import 'package:agora_rtc_engine/rtc_engine.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';

import '../../configs/agora_configs.dart';
import '../../models/call.dart';
import '../../provider/user_provider.dart';
import '../../resources/call_methods.dart';

class CallScreen extends StatefulWidget {
  final Call call;

  const CallScreen({
    Key? key,
    required this.call,
  }) : super(key: key);

  @override
  _CallScreenState createState() => _CallScreenState();
}

class _CallScreenState extends State<CallScreen> {
  final CallMethods callMethods = CallMethods();

  late UserProvider userProvider;
  late StreamSubscription callStreamSubscription;

  static final _users = <int>[];
  final _infoStrings = <String>[];
  bool muted = false;
  late RtcEngine _engine;

  @override
  void initState() {
    super.initState();
    addPostFrameCallback();
    initializeAgora();
  }

  Future<void> initializeAgora() async {
    if (appID.isEmpty) {
      setState(() {
        _infoStrings.add(
          'APP_ID missing, please provide your APP_ID in settings.dart',
        );
        _infoStrings.add('Agora Engine is not starting');
      });
      print("appID is missing");
      return;
    }

    await _initAgoraRtcEngine();
    _addAgoraEventHandlers();
    await _engine.setParameters(
        '''{"che.video.lowBitRateStreamParameter":{"width":320,"height":180,"frameRate":15,"bitRate":140}}''');
    await _engine.joinChannel(token, widget.call.callerId, null, 0);
  }

  addPostFrameCallback() {
    SchedulerBinding.instance?.addPostFrameCallback((_) {
      userProvider = Provider.of<UserProvider>(context, listen: false);

      callStreamSubscription = callMethods
          .callStream(uid: userProvider.getUser.uid)
          .listen((DocumentSnapshot? ds) {
        // defining the logic
        switch (ds?.data()) {
          case null:
            Navigator.pop(context);
            break;
          default:
            break;
        }
      });
    });
  }

  /// Create agora sdk instance and initialize
  Future<void> _initAgoraRtcEngine() async {
    await [Permission.microphone, Permission.camera].request();

    _engine = await RtcEngine.create(appID);
    await _engine.enableAudio();
  }

  /// Add agora event handlers
  void _addAgoraEventHandlers() {
    _engine.setEventHandler(
      RtcEngineEventHandler(
        joinChannelSuccess: (
          String channel,
          int uid,
          int elapsed,
        ) {
          setState(() {
            final info = 'onJoinChannel: $channel, uid: $uid';
            _infoStrings.add(info);
          });
        },
        error: (dynamic code) {
          setState(() {
            final info = 'onError: $code';
            _infoStrings.add(info);
          });
        },
        userJoined: (int uid, int elapsed) {
          setState(() {
            final info = 'onUserJoined: $uid';
            _infoStrings.add(info);
            _users.add(uid);
          });
        },
        userOffline: (int uid, UserOfflineReason reason) {
          callMethods.endCall(call: widget.call);
          setState(() {
            final info =
                'onUserOffline: a: ${uid.toString()}, b: ${reason.toString()}';
            _infoStrings.add(info);
          });
        },
        rejoinChannelSuccess: (String string, int a, int b) {
          setState(() {
            final info = 'onRejoinChannelSuccess: $string';
            _infoStrings.add(info);
          });
        },
        leaveChannel: (RtcStats) {
          setState(() {
            _infoStrings.add('onLeaveChannel');
            _users.clear();
          });
        },
        connectionLost: () {
          setState(() {
            const info = 'onConnectionLost';
            _infoStrings.add(info);
          });
        },
        // firstRemoteVideoFrame: (
        //   int uid,
        //   int width,
        //   int height,
        //   int elapsed,
        // ) {
        //   setState(() {
        //     final info = 'firstRemoteVideo: $uid ${width}x $height';
        //     _infoStrings.add(info);
        //   });
        // },
      ),
    );
  }

  /// Helper function to get list of native views
  // List<Widget> _getRenderViews() {
  //   final List<AgoraRenderWidget> list = [
  //     AgoraRenderWidget(0, local: true, preview: true),
  //   ];
  //   for (var uid in _users) {
  //     list.add(AgoraRenderWidget(uid));
  //   }
  //   return list;
  // }

  /// Video view wrapper
  Widget _videoView(view) {
    return Expanded(child: Container(child: view));
  }

  /// Video view row wrapper
  Widget _expandedVideoRow(List<Widget> views) {
    final wrappedViews = views.map<Widget>(_videoView).toList();
    return Expanded(
      child: Row(
        children: wrappedViews,
      ),
    );
  }

  /// Video layout wrapper
  Widget _viewRows() {
    // final views = _getRenderViews();
    final views = [Container()];
    switch (views.length) {
      case 1:
        return Column(
          children: <Widget>[_videoView(views[0])],
        );
      case 2:
        return Column(
          children: <Widget>[
            _expandedVideoRow([views[0]]),
            _expandedVideoRow([views[1]])
          ],
        );
      case 3:
        return Column(
          children: <Widget>[
            _expandedVideoRow(views.sublist(0, 2)),
            _expandedVideoRow(views.sublist(2, 3))
          ],
        );
      case 4:
        return Column(
          children: <Widget>[
            _expandedVideoRow(views.sublist(0, 2)),
            _expandedVideoRow(views.sublist(2, 4))
          ],
        );
      default:
    }
    return Container();
  }

  Widget _panel() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 48),
      alignment: Alignment.bottomCenter,
      child: FractionallySizedBox(
        heightFactor: 0.5,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 48),
          child: ListView.builder(
            reverse: true,
            itemCount: _infoStrings.length,
            itemBuilder: (BuildContext context, int index) {
              if (_infoStrings.isEmpty) {
                return Container();
              }
              return Padding(
                padding: const EdgeInsets.symmetric(
                  vertical: 3,
                  horizontal: 10,
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Flexible(
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          vertical: 2,
                          horizontal: 5,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.yellowAccent,
                          borderRadius: BorderRadius.circular(5),
                        ),
                        child: Text(
                          _infoStrings[index],
                          style: const TextStyle(color: Colors.blueGrey),
                        ),
                      ),
                    )
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  void _onToggleMute() {
    setState(() {
      muted = !muted;
    });
    _engine.muteLocalAudioStream(muted);
  }

  void _onSwitchCamera() {
    _engine.switchCamera();
  }

  /// Toolbar layout
  Widget _toolbar() {
    return Container(
      alignment: Alignment.bottomCenter,
      padding: const EdgeInsets.symmetric(vertical: 48),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          RawMaterialButton(
            onPressed: _onToggleMute,
            child: Icon(
              muted ? Icons.mic : Icons.mic_off,
              color: muted ? Colors.white : Colors.blueAccent,
              size: 20.0,
            ),
            shape: const CircleBorder(),
            elevation: 2.0,
            fillColor: muted ? Colors.blueAccent : Colors.white,
            padding: const EdgeInsets.all(12.0),
          ),
          RawMaterialButton(
            onPressed: () {
              callMethods.endCall(
                call: widget.call,
              );
              // print('end call');
            },
            child: const Icon(
              Icons.call_end,
              color: Colors.white,
              size: 35.0,
            ),
            shape: const CircleBorder(),
            elevation: 2.0,
            fillColor: Colors.redAccent,
            padding: const EdgeInsets.all(15.0),
          ),
          RawMaterialButton(
            onPressed: _onSwitchCamera,
            child: const Icon(
              Icons.switch_camera,
              color: Colors.blueAccent,
              size: 20.0,
            ),
            shape: const CircleBorder(),
            elevation: 2.0,
            fillColor: Colors.white,
            padding: const EdgeInsets.all(12.0),
          )
        ],
      ),
    );
  }

  @override
  void dispose() {
    _users.clear();
    _engine.leaveChannel();
    _engine.destroy();
    callStreamSubscription.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Center(
        child: Stack(
          children: <Widget>[
            _viewRows(),
            _panel(),
            _toolbar(),
          ],
        ),
      ),
    );
  }
}
