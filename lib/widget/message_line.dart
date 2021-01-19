import 'package:flutter/material.dart';
import 'package:flutter_meitou/model/config.dart';
import 'package:flutter_meitou/model/message.dart';
import 'package:flutter_meitou/model/user.dart';

class MessageLine extends StatefulWidget {
  final Message msg;
  final Function(String) addTagCallBack;

  MessageLine(this.msg, this.addTagCallBack);
  @override
  _MessageLineState createState() => _MessageLineState();
}

class _MessageLineState extends State<MessageLine> {
  User sender;

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
    if (sender == null) {
      sender = MeitouConfig.getConfig('USER#${widget.msg.senderId}');
    }
    return Container(
      padding: EdgeInsets.only(bottom: 10, top: 10, left: 10, right: 20),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
              child: GestureDetector(
                  onTap: () {
                    print('${sender.name} avatar clicked');
                    showMenu();
                  },
                  child: CircleAvatar(
                    backgroundImage: NetworkImage(sender.avatarUrl),
                    backgroundColor: Colors.black,
                  )),
              flex: 1),
          Expanded(
              child: GestureDetector(
                  onLongPress: () {
                    print('long pressing message');
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
                                        color: Colors.white,
                                        fontSize: 10),
                                  )),
                              Text(
                                new DateTime.fromMillisecondsSinceEpoch(
                                        int.parse(widget.msg.lastUpdatedAt))
                                    .toString(),
                                style: TextStyle(
                                    color: Colors.white, fontSize: 10),
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
              flex: 8),
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
