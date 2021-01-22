import 'package:flutter/material.dart';
import 'package:flutter_meitou/model/config.dart';
import 'package:flutter_meitou/model/message.dart';
import 'package:flutter_meitou/model/user.dart';
import 'package:http/http.dart' as http;
import 'dart:convert' as convert;

const defaultAvatarUrl =
    'https://i1.sndcdn.com/avatars-000617335083-cmq67l-t500x500.jpg';

class MessageLine extends StatefulWidget {
  final Message msg;
  final Function(String) addTagCallBack;

  MessageLine(this.msg, this.addTagCallBack);
  @override
  _MessageLineState createState() => _MessageLineState();
}

class _MessageLineState extends State<MessageLine> {
  User sender;

  @override
  void initState() {
    super.initState();
    if (!MeitouConfig.containsConfig('USER#${widget.msg.senderId}')) {
      if (sender == null) {
        // no local cache
        if (!MeitouConfig.containsConfig(
            'USER_FETCHING#${widget.msg.senderId}')) {
          _fetchUserInfo(widget.msg.senderId);
        }
      }
      sender = User('0', '神秘股民', '', defaultAvatarUrl, 0);
    } else {
      sender = MeitouConfig.getConfig('USER#${widget.msg.senderId}');
    }
  }

  void _fetchUserInfo(senderId) async {
    MeitouConfig.setConfig('USER_FETCHING#$senderId', 0);
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

      setState(() {
        sender = user;
      });
    } else {
      print(
          'Request failed with while fetching sender info status: ${response.statusCode}.');
    }
    MeitouConfig.removeConfig('USER_FETCHING#$senderId');
  }

  Row _buildHashTagRow() {
    List<String> hashTags = widget.msg.hashtags.split(',');
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

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(bottom: 10, top: 10, left: 10, right: 20),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
              child: GestureDetector(
                  onTap: () {
                    print('${sender.name} avatar clicked');
                    FocusScope.of(context).requestFocus(new FocusNode());
                    showMenu();
                  },
                  child: CircleAvatar(
                    backgroundImage: NetworkImage(sender.avatarUrl),
                    backgroundColor: Colors.black,
                    radius: 30,
                  )),
              flex: 1),
          Expanded(
              child: GestureDetector(
                  onLongPress: () {
                    print('long pressing message');
                    showModalBottomSheet(
                        context: context,
                        builder: (BuildContext context) {
                          return Container(
                            height: MediaQuery.of(context).size.height * 0.3,
                            color: Colors.lightGreen,
                            child: Column(
                              children: [
                                Expanded(
                                    flex: 1,
                                    child: FlatButton(
                                        child: Text(
                                      '打赏',
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 20,
                                          color: Color(0xFFf4ebc1)),
                                    ))),
                                Divider(),
                                Expanded(
                                    flex: 1,
                                    child: FlatButton(
                                        child: Text(
                                      '我看行!!!',
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 20,
                                          color: Color(0xFFf4ebc1)),
                                    ))),
                                Divider(),
                                Expanded(
                                    flex: 1,
                                    child: FlatButton(
                                        child: Text(
                                      '不懂???',
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 20,
                                          color: Color(0xFFf4ebc1)),
                                    )))
                              ],
                            ),
                          );
                        });
                  },
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
                            ),
                            child: Text(
                              widget.msg.content,
                              style:
                                  TextStyle(color: Colors.black, fontSize: 15),
                            ),
                          ),
                        ),
                        Padding(
                            padding: EdgeInsets.only(top: 3, left: 15),
                            child: _buildHashTagRow())
                      ])),
              flex: 5),
          Expanded(flex: 1, child: Container())
        ],
      ),
    );
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
                    height: MediaQuery.of(context).size.width * 0.3,
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
                              top: -36,
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
                                      style: TextStyle(color: Colors.white),
                                    ),
                                    leading: Icon(
                                      Icons.account_circle,
                                      color: Colors.white,
                                    ),
                                    onTap: () {},
                                  ),
                                  ListTile(
                                    title: Text(
                                      '${sender.coins}',
                                      style: TextStyle(color: Colors.white),
                                    ),
                                    leading: Icon(
                                      Icons.money,
                                      color: Colors.white,
                                    ),
                                    onTap: () {},
                                  ),
                                ],
                              ),
                            )
                          ],
                        ))),
                Container(
                  height: 36,
                  color: Colors.green,
                )
              ],
            ),
          );
        });
  }
}
