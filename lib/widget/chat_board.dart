import 'package:flutter/material.dart';
import 'package:flutter_meitou/model/channel.dart';
import 'package:flutter_meitou/model/message.dart';
import 'package:flutter_meitou/model/socket_warrior.dart';

class ChatBoard extends StatefulWidget {
  final Channel channel;
  ChatBoard(this.channel);
  @override
  _ChatBoardState createState() => _ChatBoardState();
}

class _ChatBoardState extends State<ChatBoard> {
  var _controller = TextEditingController();
  SocketWarrior sw;

  @override
  void initState() {
    super.initState();
    sw = SocketWarrior(widget.channel.id);
    String serverEndpoint =
        'wss://4f6y995d0d.execute-api.us-west-2.amazonaws.com/dev';
    sw.open(serverEndpoint);
  }

  @override
  Widget build(BuildContext context) {
    print('current channel ' + widget.channel.name);
    return WillPopScope(
        child: Scaffold(
          endDrawer: Container(
              width: 150,
              child: Drawer(
                // Add a ListView to the drawer. This ensures the user can scroll
                // through the options in the drawer if there isn't enough vertical
                // space to fit everything.
                child: ListView(
                  // Important: Remove any padding from the ListView.
                  padding: EdgeInsets.zero,
                  children: <Widget>[
                    Container(
                        height: 120,
                        child: DrawerHeader(
                          child: Text('额外操作'),
                          decoration: BoxDecoration(
                            color: Colors.lightGreen,
                          ),
                        )),
                    ListTile(
                      title: Text('所有问题'),
                      onTap: () {
                        // Update the state of the app.
                        // ...
                      },
                    ),
                    ListTile(
                      title: Text('所有标签'),
                      onTap: () {
                        // Update the state of the app.
                        // ...
                      },
                    ),
                  ],
                ),
              )),
          appBar: AppBar(
            title:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
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
          floatingActionButton: new FloatingActionButton(
            child: new Icon(Icons.add),
            onPressed: () {
              print('floating button clicked');
              //_focusNode.unfocus(); //3 - call this method here
            },
          ),
          body: Column(
            children: [
              Expanded(
                  child: Container(
                color: Colors.black,
              )),
              Container(
                height: 30,
                color: Colors.lightGreen,
              ),
              Padding(
                padding: EdgeInsets.only(left: 10, right: 10),
                child: TextFormField(
                  controller: _controller,
                  decoration: InputDecoration(
                      labelText: '想什么呢，跟我们说说吧',
                      suffixIcon: IconButton(
                          icon: Icon(Icons.delete_forever),
                          onPressed: () {
                            _controller.clear();
                          })),
                  onFieldSubmitted: _sendClicked,
                ),
              )
            ],
          ),
        ),
        onWillPop: _onPageExit);
  }

  Future<bool> _onPageExit() {
    print('exiting channel ${widget.channel.name}');
    if (sw != null) {
      sw.close();
    }
    return Future.value(true);
  }

  void _sendClicked(text) {
    print('entered [$text] in channel ${widget.channel.name}');
    String msg =
        Message(widget.channel.id, 'rain-0-0-1', text, 't1,t2', '').toJSON();
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
