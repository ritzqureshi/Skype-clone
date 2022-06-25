import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:emoji_picker_flutter/emoji_picker_flutter.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

import '../../constants/strings.dart';
import '../../enum/view_state.dart';
import '../../models/message.dart';
import '../../models/person.dart';
import '../../provider/image_upload_provider.dart';
import '../../resources/firebase_methods.dart';
import '../../utils/call_utilities.dart';
import '../../utils/universal_variables.dart';
import '../../utils/utilities.dart';
import '../../widgets/appbar.dart';
import '../../widgets/custom_tile.dart';
import 'widget/cached_image.dart';

class ChatScreen extends StatefulWidget {
  final Person receiver;
  const ChatScreen({Key? key, required this.receiver}) : super(key: key);

  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  TextEditingController textFieldController = TextEditingController();
  final FirebaseMethods _firebaseMethods = FirebaseMethods();
  final ScrollController _listScrollController = ScrollController();
  late ImageUploadProvider _imageUploadProvider;
  bool _showEmojiPicker = false;
  Person _senderUser = Person();
  String _currentUserId = "";
  bool _isWriting = false;
  final FocusNode _textFieldFocus = FocusNode();

  @override
  void initState() {
    _firebaseMethods.getCurrentUser().then((user) {
      setState(() {
        _currentUserId = user.uid;
        _senderUser = Person(
            uid: user.uid, name: user.displayName, profilePhoto: user.photoURL);
      });
    });
    super.initState();
  }

  @override
  void dispose() {
    _listScrollController.dispose();
    _textFieldFocus.dispose();
    super.dispose();
  }

  sendMessage() {
    Message _message = Message(
        senderId: _senderUser.uid,
        receiverId: widget.receiver.uid!,
        type: "text",
        message: textFieldController.text,
        timestamp: Timestamp.now());
    setState(() {
      _isWriting = false;
    });
    textFieldController.text = "";
    _firebaseMethods.addMessageToDb(_message);
  }

  pickImage({required ImageSource source}) async {
    File selectedImage = await Utils.pickImage(source: source);
    _firebaseMethods.uploadImage(selectedImage, widget.receiver.uid!,
        _currentUserId, _imageUploadProvider);
  }

  bool emojiShowing = false;

  emojiContainer() {
    return EmojiPicker(
      onEmojiSelected: (Category category, Emoji emoji) {
        setState(() {
          _isWriting = false;
        });
        textFieldController.text += emoji.emoji;
      },
      config: const Config(
        columns: 7,
        bgColor: UniversalVariables.separatorColor,
        indicatorColor: UniversalVariables.blueColor,
      ),
    );
  }

  showKeyboard() => _textFieldFocus.requestFocus();

  hideKeyboard() => _textFieldFocus.unfocus();

  hideEmojiContainer() {
    setState(() {
      _showEmojiPicker = false;
    });
  }

  showEmojiContainer() {
    setState(() {
      _showEmojiPicker = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    _imageUploadProvider = Provider.of<ImageUploadProvider>(context);
    return Scaffold(
      backgroundColor: UniversalVariables.blackColor,
      appBar: customAppBar(context),
      body: Column(
        children: [
          Flexible(child: messageList()),
          _imageUploadProvider.getViewState == ViewState.loading
              ? Container(
                  alignment: Alignment.centerRight,
                  margin: const EdgeInsets.only(right: 15),
                  child: const CircularProgressIndicator(),
                )
              : Container(),
          chatControls(),
          if (_showEmojiPicker)
            SizedBox(
              height: MediaQuery.of(context).size.height * 0.35,
              child: emojiContainer(),
            )
        ],
      ),
    );
  }

  Widget messageList() {
    return StreamBuilder(
        stream: FirebaseFirestore.instance
            .collection(messageCollection)
            .doc(_currentUserId)
            .collection(widget.receiver.uid.toString())
            .orderBy(timestampField, descending: true)
            .snapshots(),
        builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (snapshot.hasData) {
            SchedulerBinding.instance?.addPostFrameCallback((_) {
              _listScrollController.animateTo(
                _listScrollController.position.minScrollExtent,
                duration: const Duration(milliseconds: 250),
                curve: Curves.easeInOut,
              );
            });
            return ListView.builder(
              reverse: true,
              controller: _listScrollController,
              itemCount: snapshot.data!.docs.length,
              itemBuilder: (BuildContext context, int index) {
                return chatMessageItem(snapshot.data!.docs[index]);
              },
            );
          } else {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }
        });
  }

  Widget chatMessageItem(DocumentSnapshot snapshot) {
    Message _msg = Message.fromMap(snapshot.data() as Map<String, dynamic>);
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 15),
      child: Container(child: messageLayout(_msg)),
    );
  }

  Widget messageLayout(Message msg) {
    Radius messageRadius = const Radius.circular(10);
    return Align(
      alignment: msg.senderId == _currentUserId
          ? Alignment.centerRight
          : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(top: 6),
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.65,
        ),
        decoration: BoxDecoration(
          color: UniversalVariables.senderColor,
          borderRadius: msg.senderId == _currentUserId
              ? BorderRadius.only(
                  topLeft: messageRadius,
                  topRight: messageRadius,
                  bottomLeft: messageRadius)
              : BorderRadius.only(
                  bottomRight: messageRadius,
                  topRight: messageRadius,
                  bottomLeft: messageRadius),
        ),
        child: msg.type != messageType
            ? Padding(
                padding: const EdgeInsets.all(10),
                child: Text(
                  msg.message!,
                  style: const TextStyle(color: Colors.white, fontSize: 16),
                ))
            : msg.photoUrl != null
                ? CachedImage(
                    msg.photoUrl!,
                    height: 250,
                    width: 250,
                    radius: 10,
                  )
                : const Text("url was null"),
      ),
    );
  }

  Widget chatControls() {
    setWritingTo(bool val) {
      setState(() {
        _isWriting = val;
      });
    }

    _addMediaModel(BuildContext context) {
      showModalBottomSheet(
          context: context,
          builder: (context) {
            return Column(
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 15),
                  child: Row(
                    children: [
                      TextButton(
                          onPressed: () => Navigator.maybePop(context),
                          child: const Icon(Icons.close)),
                      const Expanded(
                          child: Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          "Context and tools",
                          style: TextStyle(
                              color: Colors.white,
                              fontSize: 20,
                              fontWeight: FontWeight.bold),
                        ),
                      ))
                    ],
                  ),
                ),
                Flexible(
                    child: ListView(
                  children: [
                    ModalTile(
                      title: "Media",
                      subtitle: "Share Photos and Video",
                      icon: Icons.image,
                      onTap: () => pickImage(source: ImageSource.gallery),
                    ),
                    ModalTile(
                        title: "File",
                        subtitle: "Share files",
                        onTap: () {},
                        icon: Icons.tab),
                    ModalTile(
                        title: "Contact",
                        subtitle: "Share Contacts",
                        onTap: () {},
                        icon: Icons.contacts),
                    ModalTile(
                        title: "Location",
                        subtitle: "Share a Location",
                        onTap: () {},
                        icon: Icons.add_location),
                    ModalTile(
                        title: "Schedule Call",
                        subtitle: "Arrange a skype call and get reminders",
                        onTap: () {},
                        icon: Icons.schedule),
                    ModalTile(
                        title: "Create Poll",
                        subtitle: "Share Polls",
                        onTap: () {},
                        icon: Icons.poll),
                  ],
                ))
              ],
            );
          });
    }

    return Container(
      padding: const EdgeInsets.all(10),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => _addMediaModel(context),
            child: Container(
              padding: const EdgeInsets.all(5),
              decoration: const BoxDecoration(
                gradient: UniversalVariables.fabGradient,
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.add),
            ),
          ),
          const SizedBox(
            width: 5,
          ),
          Expanded(
            child: Stack(
              children: [
                TextField(
                  focusNode: _textFieldFocus,
                  controller: textFieldController,
                  onTap: () => hideEmojiContainer(),
                  onChanged: (val) => val.isNotEmpty && val.trim() != ""
                      ? setWritingTo(true)
                      : setWritingTo(false),
                  style: const TextStyle(color: Colors.white),
                  decoration: const InputDecoration(
                    hintText: "Type a message",
                    hintStyle: TextStyle(
                      color: UniversalVariables.greyColor,
                    ),
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(50)),
                        borderSide: BorderSide.none),
                    contentPadding:
                        EdgeInsets.symmetric(horizontal: 20, vertical: 5),
                    filled: true,
                    fillColor: UniversalVariables.separatorColor,
                  ),
                ),
                Container(
                  alignment: Alignment.centerRight,
                  child: IconButton(
                    splashColor: Colors.transparent,
                    highlightColor: Colors.transparent,
                    onPressed: () {
                      if (_showEmojiPicker) {
                        showKeyboard();
                        hideEmojiContainer();
                      } else {
                        hideKeyboard();
                        showEmojiContainer();
                      }
                    },
                    icon: const Icon(Icons.face),
                  ),
                )
              ],
            ),
          ),
          if (!_isWriting)
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 10),
              child: Icon(Icons.record_voice_over),
            ),
          if (!_isWriting)
            GestureDetector(
              child: const Icon(Icons.camera_alt),
              onTap: () => pickImage(source: ImageSource.camera),
            ),
          if (_isWriting)
            Container(
              margin: const EdgeInsets.only(left: 10),
              decoration: const BoxDecoration(
                  gradient: UniversalVariables.fabGradient,
                  shape: BoxShape.circle),
              child: IconButton(
                icon: const Icon(
                  Icons.send,
                  size: 15,
                ),
                onPressed: () {
                  sendMessage();
                },
              ),
            )
        ],
      ),
    );
  }

  CustomAppBar customAppBar(BuildContext context) {
    return CustomAppBar(
      leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context)),
      centerTitle: true,
      title: Text(widget.receiver.name ?? ""),
      actions: [
        IconButton(
            onPressed: () {
              CallUtils.dial(
                  from: _senderUser, to: widget.receiver, context: context);
            },
            icon: const Icon(Icons.video_call)),
        IconButton(onPressed: () {}, icon: const Icon(Icons.phone)),
      ],
    );
  }
}

class ModalTile extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final Function onTap;

  const ModalTile(
      {Key? key,
      required this.title,
      required this.subtitle,
      required this.icon,
      required this.onTap})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 15),
      child: CustomTile(
        onTap: () {
          onTap();
        },
        title: Text(
          title,
          style: const TextStyle(
              fontWeight: FontWeight.bold, color: Colors.white, fontSize: 18),
        ),
        mini: false,
        leading: Container(
          margin: const EdgeInsets.only(right: 10),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(15),
            color: UniversalVariables.receiverColor,
          ),
          padding: const EdgeInsets.all(10),
          child: Icon(
            icon,
            color: UniversalVariables.greyColor,
            size: 38,
          ),
        ),
        subtitle: Text(
          subtitle,
          style: const TextStyle(color: UniversalVariables.greyColor),
        ),
      ),
    );
  }
}
