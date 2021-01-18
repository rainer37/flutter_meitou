import 'package:flutter/material.dart';
import 'package:flutter_meitou/model/channel.dart';
import 'package:flutter_meitou/widget/channel_button.dart';
import 'package:http/http.dart' as http;
import 'dart:convert' as convert;

class ChatPage extends StatefulWidget {
  @override
  _ChatPageState createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  List<Channel> hotChannels = [];

  List<Channel> myChannels = [
    Channel.withSub(
        'rpc-33', 'RainPrivateChan', '神奇的小频道', '123-123-444-aaa', 50, true),
  ];

  @override
  void initState() {
    super.initState();
    _fetchChannels();
  }

  void _fetchChannels() async {
    var url = "https://ben62z58pk.execute-api.us-west-2.amazonaws.com/channels";
    var response = await http.get(url);
    if (response.statusCode == 200) {
      var jsonResponse = convert.jsonDecode(response.body);
      // print(jsonResponse);

      // var itemCount = jsonResponse['totalItems'];
      // print('Number of books about http: $jsonResponse.');
      // print("${jsonResponse['user_name']['S']}");
      setState(() {
        for (var ch in jsonResponse) {
          hotChannels.add(Channel(ch['channel_id'], ch['channel_name'],
              ch['channel_desc'], ch['owner'], int.parse(ch['sub_fee'])));
        }
      });
    } else {
      print('Request failed with status: ${response.statusCode}.');
    }
  }

  Widget _buildChannelList(channels) {
    return Container(
        color: Colors.white,
        margin: EdgeInsets.only(top: 10),
        child: SizedBox(
            height: 230,
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
