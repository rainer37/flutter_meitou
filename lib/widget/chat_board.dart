import 'package:flutter/material.dart';
import 'package:flutter_meitou/model/MessageWarlock.dart';
import 'package:flutter_meitou/model/channel.dart';
import 'package:flutter_meitou/model/config.dart';
import 'package:flutter_meitou/model/message.dart';
import 'package:flutter_meitou/model/socket_warrior.dart';
import 'package:flutter_meitou/widget/message_line.dart';
import 'package:http/http.dart' as http;
import 'dart:convert' as convert;

class ChatBoard extends StatefulWidget {
  final Channel channel;
  ChatBoard(this.channel);
  @override
  _ChatBoardState createState() => _ChatBoardState();
}

List<Message> fakeMessages = [
  Message('0e0cdd58-c7e1-4212-b75c-f27f9c430290', 'u-0-0-1', 'hello A',
      'tag1,wz', '1610930682209'),
  Message('0e0cdd58-c7e1-4212-b75c-f27f9c430290', 'u-0-0-2', 'hello echo A',
      'AZ,wz', '1610930682210'),
  Message('0e0cdd58-c7e1-4212-b75c-f27f9c430290', 'u-0-0-1', 'hello B',
      'tag88,w222,SQ', '1610930682212'),
  Message(
      '0e0cdd58-c7e1-4212-b75c-f27f9c430290',
      'u-0-0-2',
      'hello echo B hello echo B hello echo B hello echo B hello echo B hello echo B hello echo B hello echo B hello echo B hello echo B hello echo B hello echo B hello echo B hello echo B hello echo B',
      'tag1,AZ',
      '1610930682209'),
  Message('0e0cdd58-c7e1-4212-b75c-f27f9c430290', 'u-0-0-1', 'hello C',
      'tag1,wz', '1610930682249'),
  Message('0e0cdd58-c7e1-4212-b75c-f27f9c430290', 'u-0-0-2', 'hello echo C',
      'tag88,wz', '1610930682229'),
  Message('0e0cdd58-c7e1-4212-b75c-f27f9c430290', 'u-0-0-1', 'hello D',
      'tag1,wz,BBB', '1610930682239'),
  Message('0e0cdd58-c7e1-4212-b75c-f27f9c430290', 'u-0-0-2', 'hello echo D',
      'tag1,wz', '1610930682589'),
  Message(
      '0e0cdd58-c7e1-4212-b75c-f27f9c430290',
      'u-0-0-1',
      'https://img.icons8.com/ios/452/flutter.png',
      'tag1,wz,IMG',
      '1610930682259'),
  Message('0e0cdd58-c7e1-4212-b75c-f27f9c430290', 'u-0-0-2', 'hello echo E',
      'tag0,AZ', '1610930682269'),
  Message('0e0cdd58-c7e1-4212-b75c-f27f9c430290', 'u-0-0-1', 'hello F', 'tag0',
      '1610930682279'),
  Message('0e0cdd58-c7e1-4212-b75c-f27f9c430290', 'u-0-0-2', 'hello echo F',
      'tag1,wz', '1610930682230'),
];

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
    // messages = fakeMessages;
    // for (Message m in messages) {
    //   MessageWarlock.summon().addMessageToChannel(widget.channel.id, m);
    // }
    // MessageWarlock.summon().spellMessagesInChannel(widget.channel.id);
    // messages.sort((a, b) => a.lastUpdatedAt.compareTo(b.lastUpdatedAt));
    // print(messages);
    _fetchChatHistory();
    sw = SocketWarrior(widget.channel.id);
    String serverEndpoint = '${MeitouConfig.getConfig('wsEndpointUrl')}';
    sw.open(serverEndpoint);
    sw.openConn.stream.listen(_onMessageCome);
  }

  void _fetchChatHistory() async {
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
    return WillPopScope(
        child: SafeArea(
            bottom: true,
            child: Scaffold(
              endDrawer: Container(
                  width: MediaQuery.of(context).size.width * 0.8,
                  child: Drawer(
                    // Add a ListView to the drawer. This ensures the user can scroll
                    // through the options in the drawer if there isn't enough vertical
                    // space to fit everything.
                    child: ListView(
                      // Important: Remove any padding from the ListView.
                      padding: EdgeInsets.zero,
                      children: <Widget>[
                        Container(
                            height: 60,
                            child: DrawerHeader(
                              child: Text('其他骚操作'),
                              decoration: BoxDecoration(
                                color: Colors.lightGreen,
                              ),
                            )),
                        ListTile(
                          title: Text('所有问题'),
                          onTap: () {
                            // Update the state of the app.
                            // ...
                            print('所有问题 tapped');
                          },
                        ),
                        ListTile(
                          title: Text('所有标签(##)'),
                          onTap: () {
                            // Update the state of the app.
                            print('所有标签 tapped');
                          },
                        ),
                      ],
                    ),
                  )),
              appBar: AppBar(
                title: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(widget.channel.name),
                      Text(
                        widget.channel.desc,
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.yellow,
                        ),
                      )
                    ]),
                // actions: [IconButton(icon: Icon(Icons.menu), onPressed: () => {})]
              ),
              body: Column(
                children: [
                  Expanded(
                      child: Container(
                    color: Colors.black,
                    child: ListView.separated(
                      controller: _scrollController,
                      separatorBuilder: (context, index) => Divider(
                        color: Colors.white,
                        height: 1,
                      ),
                      itemCount: MessageWarlock.summon()
                          .numMessagesInChannel(widget.channel.id),
                      itemBuilder: (context, index) {
                        return MessageLine(
                            MessageWarlock.summon().castMessagesInChannel(
                                widget.channel.id)[index],
                            _addTagToInput);
                      },
                    ),
                  )),
                  Padding(
                    padding: EdgeInsets.only(left: 10, right: 10),
                    child: TextFormField(
                      controller: _controller,
                      decoration: InputDecoration(
                          hintText: '想什么呢，跟我们说说吧',
                          suffixIcon: IconButton(
                              icon: Icon(Icons.delete_forever),
                              onPressed: () {
                                _controller.clear();
                              })),
                      onFieldSubmitted: _sendClicked,
                    ),
                  ),
                  Padding(
                      padding: EdgeInsets.only(left: 10, right: 10),
                      child: Container(
                        height: 40,
                        child: TextFormField(
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
                        ),
                      ))
                ],
              ),
            )),
        onWillPop: _onPageExit);
  }

  Future<bool> _onPageExit() {
    print('exiting channel ${widget.channel.name}');
    if (sw != null) {
      sw.close();
    }
    return Future.value(true);
  }

  void _addTagToInput(tag) {
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

  void _sendClicked(text) {
    if (text == "" || _tagController.text == "") return;
    print('entered [$text] in channel ${widget.channel.name}');
    String curUserId = MeitouConfig.getConfig('user_id');
    if (curUserId == null) {
      print('why not logged in');
      return;
    }
    String msg =
        Message(widget.channel.id, curUserId, text, _tagController.text, '')
            .toJSON();
    sw.sendMessage(msg);
    _controller.clear();
  }

  @override
  void dispose() {
    // widget.channel.sink.close();
    print('disposing chat board');
    super.dispose();
  }
}
