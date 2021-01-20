import 'dart:ffi';
import 'dart:io';
import 'package:flutter/material.dart';
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
    print('fetching chat history');
    String lastMessageSeen =
        MessageWarlock.summon().lastSeenInChannel(widget.channel.id);
    var url =
        "https://ben62z58pk.execute-api.us-west-2.amazonaws.com/chats/${widget.channel.id}/$lastMessageSeen";
    var response = await http.get(url);
    if (response.statusCode == 200) {
      var jsonResponse = convert.jsonDecode(response.body);
      // print(jsonResponse);

      // var itemCount = jsonResponse['totalItems'];
      // print('Number of books about http: $jsonResponse.');
      // print("${jsonResponse}");
      // messages.clear();
      setState(() {
        for (var msg in jsonResponse) {
          MessageWarlock.summon().addMessageToChannel(
              widget.channel.id,
              Message(msg['channel_id'], msg['sender_id'], msg['content'],
                  msg['hashtags'], msg['last_updated_at']));
        }
        // MeitouConfig.setConfig('channelFetched', true);
      });
    } else {
      print('Request failed with status: ${response.statusCode}.');
    }
  }

  _onMessageCome(event) {
    print(event);
    Message msg = Message.fromJSON(event);
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
      color: Colors.lightGreen,
      child: SafeArea(
          child: Scaffold(
              endDrawer: Container(
                  width: MediaQuery.of(context).size.width * 0.8,
                  child: Drawer(
                    child: Container(
                      color: Color(0xFFf4ebc1),
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
                            onTap: () {
                              // Update the state of the app.
                              // ...
                              print('所有问题 tapped');
                            },
                          ),
                          Divider(),
                          ListTile(
                            title: Text('所有标签(#######)'),
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
                              color: Color(0xFFf4ebc1),
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
                                      _addTagToInput);
                                },
                              ),
                            ))),
                    Row(
                      children: [
                        Container(
                            color: Colors.lightGreen,
                            width: MediaQuery.of(context).size.width * 0.8,
                            child: Padding(
                              padding: EdgeInsets.only(left: 10, right: 10),
                              child: TextFormField(
                                textAlignVertical: TextAlignVertical.bottom,
                                maxLines: null,
                                keyboardType: TextInputType.multiline,
                                controller: _controller,
                                style: TextStyle(
                                    backgroundColor: Colors.lightGreen),
                                decoration: InputDecoration(
                                    hintText: '想什么呢，跟我们说说吧',
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
                              color: Color(0xFFf4ebc1),
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
                            color: Colors.lightGreen,
                            width: MediaQuery.of(context).size.width * 0.6,
                            child: Padding(
                                padding: EdgeInsets.only(left: 10, right: 10),
                                child: TextFormField(
                                  textAlignVertical: TextAlignVertical.bottom,
                                  controller: _tagController,
                                  decoration: InputDecoration(
                                      hintText: '加上标签吧，找起来更方便',
                                      suffixIcon: IconButton(
                                          icon: Icon(Icons.delete_forever),
                                          onPressed: () {
                                            _tagController.clear();
                                          })),
                                  onFieldSubmitted: _updateTags,
                                  style: TextStyle(fontSize: 10),
                                ))),
                        Container(
                          padding: EdgeInsets.only(right: 10, top: 5),
                          width: MediaQuery.of(context).size.width * 0.2,
                          child: FlatButton(
                              color: Color(0xFFf4ebc1),
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
                              color: Color(0xFFf4ebc1),
                              onPressed: () {
                                print('SQ button');
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
      if (_tagController.text == "")
        _tagController.text += tag;
      else {
        if (!_tagController.text.contains(',$tag') &&
            !_tagController.text.contains('$tag,') &&
            _tagController.text != tag) _tagController.text += ',$tag';
      }
    });
  }

  void _updateTags(text) {
    if (!RegExp(r"^[a-zA-Z]+(,[a-zA-Z]+)*$").hasMatch(text)) {
      // show the dialog
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text("标签格式不合格"),
            content: Text("请输入以逗号隔开的标签序列。例如：TLSA,AMZ,GOOG"),
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
    } else {
      print('tags entered: $text');
    }
  }

  void _sendClicked() {
    if (_controller.text == "" || _tagController.text == "") return;
    print('entered [$_controller.text] in channel ${widget.channel.name}');
    String curUserId = MeitouConfig.getConfig('user_id');
    if (curUserId == null) {
      print('why not logged in');
      return;
    }
    String msg = Message(widget.channel.id, curUserId, _controller.text,
            _tagController.text, '')
        .toJSON();
    sw.sendMessage(msg);
    _controller.clear();
    FocusScope.of(context).requestFocus(new FocusNode());
  }

  Widget _buildChip(String text, Color color) {
    return ActionChip(
      label: new Text(text),
      backgroundColor: color,
      onPressed: () {
        print(MessageWarlock.summon()
            .summonTaggedMessages(widget.channel.id, text));
      },
    );
  }

  List<Widget> _buildHashTagChips() {
    return MessageWarlock.summon()
        .releaseTheRageOfTags(widget.channel.id)
        .map((e) => _buildChip(e, Colors.green))
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
