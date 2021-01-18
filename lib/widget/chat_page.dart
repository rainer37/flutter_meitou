import 'package:flutter/material.dart';
import 'package:flutter_meitou/model/channel.dart';
import 'package:flutter_meitou/widget/channel_button.dart';

class ChatPage extends StatefulWidget {
  @override
  _ChatPageState createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  List<Channel> hotChannels = [
    Channel('191cb3bb-8396-4b52-b47c-76a26e645e9a', 'CyberPunk',
        'Channel for 2077', '123-456-abc-222', 5),
    Channel('0e0cdd58-c7e1-4212-b75c-f27f9c430290', 'RainChan',
        'Channel for Rain', '777-888-999-nnn', 2),
  ];

  List<Channel> myChannels = [
    Channel.withSub(
        'rpc-33', 'RainPrivateChan', '神奇的小频道', '123-123-444-aaa', 50, true),
  ];

  @override
  void initState() {
    super.initState();
    _fetchChannels();
  }

  void _fetchChannels() {}

  Widget _buildChannelList(channels) {
    return Container(
        color: Colors.white,
        margin: EdgeInsets.only(top: 10),
        child: SizedBox(
            height: 130,
            child: ListView.separated(
              separatorBuilder: (context, index) => Divider(
                color: Colors.white,
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
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                    padding: EdgeInsets.only(top: 10, left: 10),
                    child: Text('热门频道')),
                _buildChannelList(hotChannels),
                Padding(
                    padding: EdgeInsets.only(top: 10, left: 10),
                    child: Text('我的频道')),
                _buildChannelList(myChannels),
              ],
            )));
  }
}
