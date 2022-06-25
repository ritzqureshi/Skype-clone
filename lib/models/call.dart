class Call {
  String? callerId;
  String? callerName;
  String? callerPic;
  String? receiverId;
  String? receiverName;
  String? receiverPic;
  String? channelId;
  bool? hasDialled;

  Call(
      {required this.callerId,
      required this.callerName,
      required this.callerPic,
      required this.receiverId,
      required this.receiverName,
      required this.receiverPic,
      required this.channelId,
      required this.hasDialled});

  Map<String, dynamic> toMap(Call call) {
    Map<String, dynamic> map = {};
    map['callerId'] = call.callerId;
    map['callerName'] = call.callerName;
    map['callerPic'] = call.callerPic;
    map['receiverId'] = call.receiverId;
    map['receiverName'] = call.receiverName;
    map['receiverPic'] = call.receiverPic;
    map['channelId'] = call.channelId;
    map['hasDialled'] = call.hasDialled;
    return map;
  }

  Call.fromMap(Map<String, dynamic> map) {
    callerId = map['callerId'];
    callerName = map['callerName'];
    callerPic = map['callerPic'];
    receiverId = map['receiverId'];
    receiverName = map['receiverName'];
    receiverPic = map['receiverPic'];
    channelId = map['channelId'];
    hasDialled = map['hasDialled'];
  }
}
