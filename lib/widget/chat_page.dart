import 'package:flutter/material.dart';
import 'package:flutter_meitou/model/channel.dart';
import 'package:flutter_meitou/widget/channel_button.dart';

class ChatPage extends StatefulWidget {
  @override
  _ChatPageState createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  final List<Channel> channels = [
    Channel('cb-12', 'CyberPunk', 'Channel for 2077', '123-456-abc-222', 5),
    Channel('rpc-33', 'RainPrivateChan', '神奇的小频道', '123-123-444-aaa', 50),
    Channel('rc-29', 'RainChan', 'Channel for Rain', '777-888-999-nnn', 2),
  ];

  Widget _buildChannelList() {
    return Container(
        color: Colors.white,
        margin: EdgeInsets.only(top: 10),
        child: SizedBox(
            height: 360,
            child: ListView.separated(
              separatorBuilder: (context, index) => Divider(
                color: Colors.black,
                height: 3,
              ),
              itemCount: channels.length,
              itemBuilder: (context, index) {
                return ChannelButton(
                  channel: channels[index],
                );
              },
            )));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Container(
            color: Colors.white,
            child: Column(
              children: [
                _buildChannelList(),
              ],
            )));
  }
}
