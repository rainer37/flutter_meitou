import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_meitou/model/color_unicorn.dart';
import 'package:flutter_meitou/model/config.dart';
import 'package:flutter_meitou/model/message.dart';
import 'package:flutter_meitou/model/message_warlock.dart';
import 'package:flutter_meitou/model/user.dart';
import 'package:http/http.dart' as http;
import 'dart:convert' as convert;

class MessageLine extends StatefulWidget {
  final Message msg;
  final Function(String) addTagCallBack;
  final Function(Message) likeMessage;

  MessageLine(this.msg, this.addTagCallBack, this.likeMessage);
  @override
  _MessageLineState createState() => _MessageLineState();
}

class _MessageLineState extends State<MessageLine> {
  User sender;
  String msgType;
  Color checkMarkColor = kLightBackground;

  @override
  void initState() {
    super.initState();
    // checkMarkColor = kLightBackground;
    msgType =
        widget.msg.hashtags.split(',').contains(SQ_TAG) ? SQ_TAG : MSG_TAG;
    if (msgType == SQ_TAG) checkMarkColor = Colors.amber;
    // print('init messageLine ${widget.msg}');
    if (!MeitouConfig.containsConfig('USER#${widget.msg.senderId}')) {
      if (sender == null) {
        // no local cache
        // if (!MeitouConfig.containsConfig(
        //     'USER_FETCHING#${widget.msg.senderId}')) {
        _fetchUserInfo(widget.msg.senderId);
//        }
      }
      sender = User('0', '神秘股民', '', defaultAvatarUrl, 0);
    } else {
      sender = MeitouConfig.getConfig('USER#${widget.msg.senderId}');
    }
  }

  void _fetchUserInfo(senderId) async {
    if (MeitouConfig.containsConfig('USER_FETCHING#$senderId')) {
      // while (!MeitouConfig.containsConfig('USER${widget.msg.senderId}')) {
      //   Future.delayed(Duration(seconds: 1000));
      //   print('delayed');
      // }
      print('fetching');
      Timer.periodic(Duration(milliseconds: 500), (timer) {
        print('delayed');
        if (MeitouConfig.containsConfig('USER#$senderId')) {
          User user = MeitouConfig.getConfig('USER#$senderId');
          setState(() {
            sender = user;
            sender.name = user.name;
            sender.avatarUrl = user.avatarUrl;
          });
          timer.cancel();
        }
      });
      return;
    }
    MeitouConfig.setConfig('USER_FETCHING#$senderId', 0); // simple locking
    print('fetching user id $senderId');
    var url = "${MeitouConfig.getConfig('restEndpointUrl')}/user/$senderId";
    http.Response response = await http.get(url);
    if (response.statusCode == 200) {
      dynamic jsonResponse = convert.jsonDecode(response.body);
      // print("got user ${jsonResponse}");
      // print('sender info fetched!');

      String avatarUrl = jsonResponse['avatar_url'] == null
          ? defaultAvatarUrl
          : jsonResponse['avatar_url'];

      User user = User(jsonResponse['user_id'], jsonResponse['user_name'],
          jsonResponse['email'], avatarUrl, int.parse(jsonResponse['coins']));
      MeitouConfig.setConfig('USER#${jsonResponse['user_id']}', user);

      print('user info fetched $jsonResponse');

      setState(() {
        sender = user;
        sender.name = user.name;
        sender.avatarUrl = user.avatarUrl;
      });
    } else {
      print(
          'Request failed with while fetching sender info status: ${response.statusCode}.');
    }
    MeitouConfig.removeConfig('USER_FETCHING#$senderId');
  }

  Widget _buildHashTagRow() {
    List<String> hashTags = widget.msg.hashtags
        .split(',')
        .where((tag) => !reversedTags.contains(tag))
        .toList();
    return Row(
        children: List<Widget>.generate(hashTags.length, (int index) {
      return GestureDetector(
          onDoubleTap: () {
            print('clicked on tag ' + hashTags[index]);
            widget.addTagCallBack(hashTags[index]);
          },
          child: Container(
              margin: EdgeInsets.only(right: 3, top: 1),
              padding: EdgeInsets.only(top: 2, left: 5, right: 5, bottom: 2),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                color: Colors.green,
              ),
              child: Text(
                '#' + hashTags[index].toString(),
                style: TextStyle(color: Colors.black, fontSize: 10),
              )));
    }));
  }

  void _actionLike() {
    HapticFeedback.mediumImpact();
    Message target = MessageWarlock.summon()
        .morphMessage(widget.msg.channelId, widget.msg, 'like');
    widget.likeMessage(target);
    setState(() {
      // update action icon
      widget.msg.likes = target.likes;
    });
    Navigator.pop(context);
  }

  void _actionTip() async {
    HapticFeedback.lightImpact();
    int amount = 1;
    print('tipping message ${widget.msg}');
    if (MeitouConfig.getConfig('coins') < amount) {
      Navigator.pop(context);
      _showAlertDialog(context, '好吧', '资金不足', '感谢你的好意，快去充美投币吧');
      return;
    }
    var url = "${MeitouConfig.getConfig('restEndpointUrl')}/user/charge";

    http.Response response = await http.post(url,
        body: convert.jsonEncode(<String, String>{
          'user_id': MeitouConfig.getConfig('user_id'),
          'user_name': MeitouConfig.getConfig('user_name'),
          'email': MeitouConfig.getConfig('email'),
          'avatar_url': MeitouConfig.getConfig('avatar_url'),
          'coins': (MeitouConfig.getConfig('coins') - 1).toString(),
        }));
    if (response.statusCode == 200) {
      dynamic jsonResponse =
          response.body; // convert.jsonDecode(response.body);
      print("got resp on charge $jsonResponse");
      // print('sender info fetched!');

      setState(() {
        MeitouConfig.setConfig('coins', MeitouConfig.getConfig('coins') - 1);
      });
    } else {
      print(
          'Request failed with while tipping message status: ${response.statusCode}.');
    }
    Navigator.pop(context);
  }

  void _actionDislike() {
    final snackBar = SnackBar(
      content: Container(
        height: MediaQuery.of(context).size.height * 0.10,
        child: Center(
          child: Text(
            'Don\'t be so mean, pleeeeeease',
            style: TextStyle(color: kLightTextTitle, fontSize: 15),
          ),
        ),
      ),
      backgroundColor: kHeavyBackground,
      action: SnackBarAction(
        label: '好的',
        textColor: kLightTextTitle,
        onPressed: () {
          // Some code to undo the change.
          Scaffold.of(context).hideCurrentSnackBar();
        },
      ),
    );
    Navigator.pop(context);
    Scaffold.of(context).showSnackBar(snackBar);
  }

  Widget _buildMessageAction(String actionName, Function actionFunc) {
    return Expanded(
        flex: 1,
        child: FlatButton(
            minWidth: double.infinity,
            onPressed: actionFunc,
            child: Text(
              actionName,
              style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 20,
                  color: Color(0xFFf4ebc1)),
            )));
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
        onTap: () {
          if (checkMarkColor == kLightBackground ||
              checkMarkColor == Colors.amber) {
            setState(() {
              checkMarkColor = Colors.green;
            });
          } else {
            setState(() {
              checkMarkColor = kLightBackground;
              if (msgType == SQ_TAG) checkMarkColor = Colors.amber;
            });
          }
        },
        onLongPress: () {
          print('long pressing message');
          if (checkMarkColor == kLightBackground ||
              checkMarkColor == Colors.amber) {
            setState(() {
              checkMarkColor = Colors.green;
            });
          }
          // else {
          //   setState(() {
          //     checkMarkColor = kLightBackground;
          //   });
          // }
          HapticFeedback.heavyImpact();
          showModalBottomSheet(
              context: context,
              builder: (BuildContext context) {
                return Container(
                  color: Colors.lightGreen,
                  child: SafeArea(
                      child: Container(
                    height: MediaQuery.of(context).size.height * 0.35,
                    color: Colors.lightGreen,
                    child: Column(
                      children: [
                        _buildMessageAction('打赏', _actionTip),
                        Divider(
                          height: 1,
                        ),
                        _buildMessageAction('我看行!!!', _actionLike),
                        Divider(
                          height: 1,
                        ),
                        _buildMessageAction('不懂???', _actionLike),
                        Divider(
                          height: 1,
                        ),
                        _buildMessageAction('什么玩意儿?!', _actionDislike),
                      ],
                    ),
                  )),
                );
              });
        },
        child: Container(
          color: msgType == SQ_TAG ? Colors.amber : kLightBackground,
          padding: EdgeInsets.only(bottom: 10, top: 10, left: 10, right: 10),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                  child: GestureDetector(
                      onDoubleTap: () {
                        print('拍一拍');
                      },
                      onTap: () {
                        print('${sender.name} avatar clicked');
                        // FocusScope.of(context).requestFocus(new FocusNode());
                        showMenu();
                      },
                      child: CircleAvatar(
                        backgroundImage: NetworkImage(sender.avatarUrl),
                        backgroundColor: kHeavyBackground,
                        radius: 30,
                      )),
                  flex: 1),
              Expanded(
                  child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // sender name + time
                        Padding(
                          padding: EdgeInsets.only(left: 15, bottom: 5),
                          child: Row(
                            children: [
                              Padding(
                                  padding: EdgeInsets.only(right: 5),
                                  child: Text(
                                    sender.name,
                                    style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 10),
                                  )),
                              Text(
                                new DateTime.fromMillisecondsSinceEpoch(
                                        int.parse(widget.msg.lastUpdatedAt))
                                    .toString(),
                                style: TextStyle(fontSize: 10),
                              ),
                            ],
                          ),
                        ),
                        // actual content
                        Padding(
                          padding: EdgeInsets.only(left: 15),
                          child: Container(
                            padding: EdgeInsets.only(
                                top: 5, left: 8, right: 8, bottom: 5),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(10),
                              color: Colors.lightGreen,
                              // border: Border.all(
                              //     width: 2.0, color: Colors.amber)
                            ),
                            child: Text(
                              widget.msg.content +
                                  (widget.msg.likes == 0
                                      ? ''
                                      : ' 🖤 ${widget.msg.likes}'),
                              style:
                                  TextStyle(color: Colors.black, fontSize: 15),
                            ),
                          ),
                        ),
                        Row(
                          children: [
                            Padding(
                                padding: EdgeInsets.only(top: 3, left: 15),
                                child: _buildHashTagRow()),
                          ],
                        )
                      ]),
                  flex: 5),
              Expanded(
                flex: 1,
                child: Center(
                  child: Container(
                      padding: EdgeInsets.only(top: 25),
                      child: Icon(
                        Icons.done,
                        color: checkMarkColor,
                      )),
                ),
              )
            ],
          ),
        ));
  }

  showMenu() {
    showModalBottomSheet(
        context: context,
        builder: (BuildContext context) {
          return Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(0.0),
                topRight: Radius.circular(0.0),
              ),
              color: Colors.green,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: <Widget>[
                Container(
                  height: 36,
                ),
                SizedBox(
                    height: MediaQuery.of(context).size.width * 0.45,
                    child: Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(0.0),
                            topRight: Radius.circular(0.0),
                          ),
                          color: Colors.lightGreen,
                        ),
                        child: Stack(
                          alignment: Alignment(0, 0),
                          overflow: Overflow.visible,
                          children: <Widget>[
                            Positioned(
                              top: -56,
                              child: Container(
                                decoration: BoxDecoration(
                                    borderRadius:
                                        BorderRadius.all(Radius.circular(50)),
                                    border: Border.all(
                                        color: Colors.green, width: 10)),
                                child: Center(
                                  child: ClipOval(
                                    child: Image.network(
                                      sender.avatarUrl,
                                      fit: BoxFit.cover,
                                      height: 56,
                                      width: 56,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            Positioned(
                              child: ListView(
                                physics: NeverScrollableScrollPhysics(),
                                children: <Widget>[
                                  ListTile(
                                    title: Text(
                                      sender.name,
                                      style: TextStyle(color: kLightTextTitle),
                                    ),
                                    leading: Icon(
                                      Icons.account_circle,
                                      color: kLightIcon,
                                    ),
                                  ),
                                  ListTile(
                                    title: Text(
                                      '${sender.coins}',
                                      style: TextStyle(color: kLightTextTitle),
                                    ),
                                    leading: Icon(
                                      Icons.money,
                                      color: kLightIcon,
                                    ),
                                  ),
                                  ListTile(
                                    title: Text(
                                      '${sender.email}',
                                      style: TextStyle(color: kLightTextTitle),
                                    ),
                                    leading: Icon(
                                      Icons.mail,
                                      color: kLightTextTitle,
                                    ),
                                  ),
                                ],
                              ),
                            )
                          ],
                        ))),
                Container(
                  height: 16,
                  color: Colors.green,
                )
              ],
            ),
          );
        });
  }

  void _showAlertDialog(BuildContext context, String action, title, content) {
    // Create button
    Widget okButton = FlatButton(
      child: Text(action),
      onPressed: () {
        Navigator.of(context).pop();
      },
    );

    // Create AlertDialog
    AlertDialog alert = AlertDialog(
      title: Text(title),
      content: Text(content),
      actions: [
        okButton,
      ],
    );

    // show the dialog
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return alert;
      },
    );
  }
}
