import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_meitou/model/color_unicorn.dart';
import 'package:flutter_meitou/model/message_warlock.dart';
import 'package:flutter_meitou/model/channel.dart';
import 'package:flutter_meitou/model/config.dart';
import 'package:flutter_meitou/model/message.dart';
import 'package:flutter_meitou/model/socket_warrior.dart';
import 'package:flutter_meitou/widget/message_line.dart';
import 'package:http/http.dart' as http;
import 'dart:convert' as convert;

import 'package:image_picker/image_picker.dart';

class ChatBoard extends StatefulWidget {
  final Channel channel;
  ChatBoard(this.channel);
  @override
  _ChatBoardState createState() => _ChatBoardState();
}

class _ChatBoardState extends State<ChatBoard> {
  var _controller = TextEditingController();
  var _tagController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  bool _needsScroll = false;
  SocketWarrior sw;
  var messages = [];

  @override
  void initState() {
    super.initState();
    _fetchChatHistory();
    sw = SocketWarrior(widget.channel.id);
    String serverEndpoint = '${MeitouConfig.getConfig('wsEndpointUrl')}';
    sw.open(serverEndpoint);
    sw.openConn.stream.listen(_onMessageCome);
  }

  void _fetchChatHistory() async {
    String channelId = widget.channel.id;
    String lastMessageSeen =
        MessageWarlock.summon().lastSeenInChannel(channelId);
    print('fetching chat history, last since $lastMessageSeen');
    var url =
        "${MeitouConfig.getConfig('restEndpointUrl')}/chats/$channelId/$lastMessageSeen";
    var response = await http.get(url);
    if (response.statusCode == 200) {
      var jsonResponse = convert.jsonDecode(response.body);

      // print("${jsonResponse}");
      setState(() {
        for (var msg in jsonResponse) {
          MessageWarlock.summon().addMessageToChannel(
              channelId,
              Message(msg['channel_id'], msg['sender_id'], msg['content'],
                  msg['hashtags'], msg['last_updated_at'],
                  likes: msg['likes'] != null ? (int.parse(msg['likes'])) : 0));
        }
        MessageWarlock.summon().rinseChannel(channelId);
        // MeitouConfig.setConfig('channelFetched', true);
      });
    } else {
      print('Request failed with status: ${response.statusCode}.');
    }
  }

  _onMessageCome(incomingMsg) {
    print(incomingMsg);
    Message msg = Message.fromJSON(incomingMsg);
    this.setState(() {
      MessageWarlock.summon().addMessageToChannel(widget.channel.id, msg);
      _needsScroll = true;
    });
  }

  _scrollToEnd() async {
    print('scrolling to the end');
    _scrollController.animateTo(_scrollController.position.maxScrollExtent,
        duration: Duration(milliseconds: 800), curve: Curves.ease);
    _needsScroll = false;
  }

  @override
  Widget build(BuildContext context) {
    print('current channel ' + widget.channel.name);
    if (_needsScroll) {
      print('scrolling');
      // _scrollToEnd();
      WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToEnd());
    }
    return Container(
      color: kHeavyBackground,
      child: SafeArea(
          child: Scaffold(
              endDrawer: Container(
                  width: MediaQuery.of(context).size.width * 0.8,
                  child: Drawer(
                    child: Container(
                      color: kLightBackground,
                      child: ListView(
                        // Important: Remove any padding from the ListView.
                        padding: EdgeInsets.zero,
                        children: <Widget>[
                          DrawerHeader(
                            child: Row(children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Padding(
                                      padding: const EdgeInsets.all(10.0),
                                      child: Text(
                                        widget.channel.name,
                                        style: TextStyle(
                                          fontSize: 20,
                                          color: Colors.black,
                                        ),
                                      ),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 10, vertical: 5),
                                      child: Text(
                                        widget.channel.ownerId,
                                        style: TextStyle(
                                          fontSize: 15,
                                          color: Colors.black,
                                        ),
                                      ),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 10, vertical: 5),
                                      child: Text(
                                        widget.channel.desc,
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: Colors.black,
                                        ),
                                      ),
                                    )
                                  ],
                                ),
                                flex: 12,
                              ),
                              Expanded(
                                child: Column(),
                                flex: 1,
                              )
                            ]),
                            decoration: BoxDecoration(color: Colors.lightGreen),
                          ),
                          ListTile(
                            title: Text('无任何神奇问题'),
                          ),
                          Container(
                            color: kHeavyBackground,
                            height: MediaQuery.of(context).size.height * 0.2,
                          ),
                          Divider(),
                          ListTile(
                            title: Text(
                                '搜索标签(${'#' * MessageWarlock.summon().releaseTheRageOfTags(widget.channel.id).where((tag) => !reversedTags.contains(tag)).length})'),
                            onTap: () {
                              // Update the state of the app.
                              print('所有标签 tapped');
                            },
                          ),
                          Padding(
                            padding: const EdgeInsets.only(
                                bottom: 2.0, left: 10, right: 10),
                            child: new Column(
                              mainAxisSize: MainAxisSize.max,
                              children: <Widget>[
                                new Wrap(
                                  spacing: 2.0,
                                  runSpacing: 5,
                                  direction: Axis.horizontal,
                                  children: _buildHashTagChips(),
                                )
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  )),
              appBar: AppBar(
                elevation: 0,
                title: GestureDetector(
                  child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          widget.channel.name,
                          style: TextStyle(fontWeight: FontWeight.bold),
                        )
                      ]),
                  onTap: () {
                    print('channel info tapped');
                  },
                ),
                // actions: [IconButton(icon: Icon(Icons.menu), onPressed: () => {})]
                actions: [
                  Builder(
                    builder: (context) => IconButton(
                      icon: Icon(
                        Icons.filter_list,
                        color: kLightIcon,
                      ),
                      onPressed: () => Scaffold.of(context).openEndDrawer(),
                      tooltip: MaterialLocalizations.of(context)
                          .openAppDrawerTooltip,
                    ),
                  ),
                ],
              ),
              body: Container(
                color: Colors.lightGreen,
                child: Column(
                  children: [
                    Expanded(
                        child: GestureDetector(
                            onTap: () {
                              FocusScope.of(context)
                                  .requestFocus(new FocusNode());
                            },
                            child: Container(
                              color: kLightBackground,
                              child: ListView.separated(
                                controller: _scrollController,
                                separatorBuilder: (context, index) => Divider(
                                  color: Colors.lightGreen,
                                  height: 1,
                                ),
                                itemCount: MessageWarlock.summon()
                                    .numMessagesInChannel(widget.channel.id),
                                itemBuilder: (context, index) {
                                  return MessageLine(
                                      MessageWarlock.summon()
                                          .castMessagesInChannel(
                                              widget.channel.id)[index],
                                      _addTagToInput,
                                      _likeMessage);
                                },
                              ),
                            ))),
                    Row(
                      children: [
                        Container(
                            color: kHeavyBackground,
                            width: MediaQuery.of(context).size.width * 0.8,
                            child: Padding(
                              padding: EdgeInsets.only(left: 10, right: 10),
                              child: TextFormField(
                                textAlignVertical: TextAlignVertical.bottom,
                                maxLines: null,
                                keyboardType: TextInputType.multiline,
                                controller: _controller,
                                style: TextStyle(
                                    backgroundColor: kHeavyBackground),
                                decoration: InputDecoration(
                                    hintText: '想什么呢，跟我们说说吧',
                                    hintStyle:
                                        TextStyle(color: kLightTextTitle),
                                    suffixIcon: IconButton(
                                        icon: Icon(Icons.delete_forever),
                                        onPressed: () {
                                          _controller.clear();
                                        })),
                              ),
                            )),
                        Container(
                          padding: EdgeInsets.only(right: 10, top: 5),
                          width: MediaQuery.of(context).size.width * 0.2,
                          child: FlatButton(
                              color: kLightIcon,
                              onPressed: () {
                                print('send button');
                                _sendClicked();
                              },
                              child: Icon(
                                Icons.send_rounded,
                                color: Colors.lightGreen,
                              )),
                        )
                      ],
                    ),
                    Row(
                      children: [
                        Container(
                            color: kHeavyBackground,
                            width: MediaQuery.of(context).size.width * 0.6,
                            child: Padding(
                                padding: EdgeInsets.only(left: 10, right: 10),
                                child: TextFormField(
                                  textAlignVertical: TextAlignVertical.bottom,
                                  controller: _tagController,
                                  decoration: InputDecoration(
                                      hintText: '加上标签吧，找起来更方便',
                                      hintStyle:
                                          TextStyle(color: kLightTextTitle),
                                      suffixIcon: IconButton(
                                          icon: Icon(Icons.delete_forever),
                                          onPressed: () {
                                            _tagController.clear();
                                          })),
                                  onFieldSubmitted: _isTagsValid,
                                  style: TextStyle(fontSize: 13),
                                ))),
                        Container(
                          padding: EdgeInsets.only(right: 10, top: 5),
                          width: MediaQuery.of(context).size.width * 0.2,
                          child: FlatButton(
                              color: kLightIcon,
                              onPressed: () {
                                print('IMG button');
                                // _imagePicker();
                              },
                              child: Icon(
                                Icons.image,
                                color: Colors.lightGreen,
                              )),
                        ),
                        Container(
                          padding: EdgeInsets.only(right: 10, top: 5),
                          width: MediaQuery.of(context).size.width * 0.2,
                          child: FlatButton(
                              color: kLightIcon,
                              onPressed: () {
                                print('firing a SQ');
                                _sendSQClicked();
                              },
                              child: Icon(
                                Icons.question_answer,
                                color: Colors.lightGreen,
                              )),
                        )
                      ],
                    )
                  ],
                ),
              ))),
    );
  }

  final picker = ImagePicker();
  File _img;
  void _imagePicker() async {
    final galleryFile = await picker.getImage(
      source: ImageSource.gallery,
    );
    if (galleryFile != null) {
      print(galleryFile.path);
      // setState(() {
      //   _img = File(galleryFile.path);
      // });
    }
  }

  void _likeMessage(Message msg) {
    print('sending $msg likes to server');
    sw.sendMessage(msg.toJSON());
  }

  Future<bool> _onPageExit() {
    print('exiting channel ${widget.channel.name}');
    if (sw != null) {
      sw.close();
    }
    return Future.value(true);
  }

  void _addTagToInput(tag) {
    print('adding tag');
    this.setState(() {
      if (_tagController.text == "") {
        HapticFeedback.lightImpact();
        _tagController.text += tag;
      } else {
        if (!_tagController.text.contains(',$tag') &&
            !_tagController.text.contains('$tag,') &&
            _tagController.text != tag) {
          HapticFeedback.lightImpact();
          _tagController.text += ',$tag';
        }
      }
    });
  }

  void _showTagFormatWarning() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("标签格式不合格"),
          content: Text(
              "请输入一个标签，或多个以逗号隔开的标签序列。每个标签只能包含大小写英文字母，例如：BABA或者TLSA,AMZ,GOOG"),
          actions: [
            FlatButton(
              child: Text("懂了"),
              onPressed: () {
                Navigator.of(context).pop();
                _tagController.clear();
              },
            ),
          ],
        );
      },
    );
  }

  bool _isTagsValid(tags) {
    if (!RegExp(r"^[a-zA-Z]+(,[a-zA-Z]+)*$").hasMatch(tags)) {
      // show the dialog
      return false;
    } else {
      print('tags entered: $tags');
      return true;
    }
  }

  void _sendRaw(String extraTag) {
    if (_controller.text == "" ||
        _tagController.text == "" ||
        !_isTagsValid(_tagController.text)) {
      _showTagFormatWarning();
      return;
    }
    print('entered [$_controller.text] in channel ${widget.channel.name}');
    String curUserId = MeitouConfig.getConfig('user_id');
    if (curUserId == null) {
      print('why not logged in first then send a special message');
      return;
    }
    String msg = Message(widget.channel.id, curUserId, _controller.text,
            _tagController.text + (extraTag != '' ? ',$extraTag' : ''), '')
        .toJSON();
    sw.sendMessage(msg);
    _controller.clear();
    FocusScope.of(context).requestFocus(new FocusNode());
  }

  void _sendSQClicked() {
    _sendRaw('SQ');
  }

  void _sendClicked() {
    _sendRaw('');
  }

  Future<String> _getTagName(String tagRaw) {
    if (tagRaw.startsWith('SENDER->')) {
      String senderId = 'USER#${tagRaw.split('->')[1]}';
      if (MeitouConfig.containsConfig(senderId)) {
        return Future.value(
            '$tagRaw#发送人:' + MeitouConfig.getConfig(senderId)?.name);
      }
      return Future<String>.delayed(Duration(seconds: 2), () {
        return '$tagRaw#发送人:' + MeitouConfig.getConfig(senderId)?.name;
      });
    } else {
      return Future.value(tagRaw);
    }
  }

  Widget _buildChip(String tagRaw, Color color) {
    String tagName = tagRaw;
    if (tagRaw.startsWith('SENDER->')) {
      tagName = tagRaw.split('#')[1];
    }
    return ActionChip(
      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
      label: new Text(tagName),
      backgroundColor: color,
      onPressed: () {
        print('tag $tagRaw is selected');
        if (tagRaw.startsWith('SENDER->')) {
          tagRaw = tagRaw.split('#')[0];
        }
        List<Message> taggedMessages = MessageWarlock.summon()
            .summonTaggedMessages(widget.channel.id, tagRaw);
        // print('tagged messages: $taggedMessages');
        // MessageWarlock.summon().cleanse(widget.channel.id);
        // MessageWarlock.summon().polluteChannel(widget.channel.id);
        // setState(() {
        //   for (Message msg in taggedMessages) {
        //     MessageWarlock.summon().addMessageToChannel(widget.channel.id, msg);
        //   }
        // });
        // Navigator.pop(context);
        // show filtered result in a separate bottom sheet
        showModalBottomSheet(
            isScrollControlled: true,
            context: context,
            builder: (BuildContext context) {
              return Container(
                height: MediaQuery.of(context).size.height * 0.7,
                color: Colors.lightGreen,
                child: Column(
                  children: [
                    Container(
                      color: kHeavyBackground,
                      height: MediaQuery.of(context).size.height * 0.05,
                      child: Center(
                        child: Text(
                          tagName,
                          style:
                              TextStyle(color: kLightTextTitle, fontSize: 15),
                        ),
                      ),
                    ),
                    SafeArea(
                        child: Container(
                      height: MediaQuery.of(context).size.height * 0.65,
                      color: kLightBackground,
                      child: ListView.builder(
                        itemCount: taggedMessages.length,
                        itemBuilder: (context, index) {
                          return MessageLine(taggedMessages[index],
                              _addTagToInput, _likeMessage);
                        },
                      ),
                    )),
                  ],
                ),
              );
            });
      },
    );
  }

  List<FutureBuilder<String>> _buildHashTagChips() {
    return MessageWarlock.summon()
        .releaseTheRageOfTags(widget.channel.id)
        .where((tag) => !reversedTags.contains(tag))
        .map((tagRaw) => FutureBuilder(
            future: _getTagName(tagRaw),
            builder: (BuildContext context, AsyncSnapshot<String> snapshot) {
              if (snapshot.connectionState == ConnectionState.done) {
                Color color = Colors.green;
                if (snapshot.data.startsWith('SENDER-'))
                  color = Colors.amberAccent;
                return _buildChip(snapshot.data, color);
              } else {
                return _buildChip('loading...', Colors.red);
              }
            }))
        .toList();
  }

  @override
  void dispose() {
    // widget.channel.sink.close();
    print('disposing chat board');
    _onPageExit();
    super.dispose();
  }
}
