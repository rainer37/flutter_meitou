import 'package:flutter/material.dart';
import 'package:flutter_meitou/model/channel.dart';
import 'package:flutter_meitou/model/color_unicorn.dart';
import 'package:flutter_meitou/model/config.dart';
import 'package:flutter_meitou/widget/channel_button.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

import 'package:http/http.dart' as http;
import 'dart:convert' as convert;

class ChatPage extends StatefulWidget {
  @override
  _ChatPageState createState() => _ChatPageState();
}

List<Channel> hotChannels = [];

class _ChatPageState extends State<ChatPage> {
  List<Channel> myChannels = [
    Channel.withSub(
        'rpc-33', 'RainPrivateChan', '神奇的小频道', '123-123-444-aaa', 50, true),
  ];

  @override
  void initState() {
    print('chat page init');
    _fetchChannels();
    super.initState();
  }

  void _fetchChannels() async {
    if (MeitouConfig.containsConfig('channelFetched')) return;
    hotChannels.clear();
    var url = "${MeitouConfig.getConfig('restEndpointUrl')}/channels";
    var response = await http.get(url);
    if (response.statusCode == 200) {
      var jsonResponse = convert.jsonDecode(response.body);

      setState(() {
        for (var ch in jsonResponse) {
          hotChannels.add(Channel(ch['channel_id'], ch['channel_name'],
              ch['channel_desc'], ch['owner'], int.parse(ch['sub_fee'])));
        }
        MeitouConfig.setConfig(
            'channelFetched', DateTime.now().millisecondsSinceEpoch);
      });
    } else {
      print(
          'Request failed while fetching channels with status: ${response.statusCode}.');
    }
  }

  Widget _buildChannelList(channels) {
    if (!MeitouConfig.containsConfig('channelFetched')) {
      return Container(
        margin: EdgeInsets.only(top: 10),
        height: MediaQuery.of(context).size.height * 0.33,
        // color: Colors.lightGreen,
        child: SpinKitWave(
          color: kHeavyBackground,
          size: 50.0,
        ),
      );
    }
    return Container(
        height: MediaQuery.of(context).size.height * 0.33,
        margin: EdgeInsets.only(top: 10),
        child: ListView.builder(
          itemCount: channels.length,
          itemBuilder: (context, index) {
            return ChannelButton(
              channel: channels[index],
            );
          },
        ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Container(
            color: Color(0xFFf4ebc1),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                    padding: EdgeInsets.only(top: 10, left: 10),
                    child: Text('热门频道')),
                _buildChannelList(hotChannels),
                Divider(
                  color: Colors.black,
                  height: 1,
                  thickness: 0.5,
                  indent: 10,
                  endIndent: 10,
                ),
                Padding(
                    padding: EdgeInsets.only(top: 10, left: 10, bottom: 10),
                    child: Text('我的频道')),
                ChannelButton(
                  channel: myChannels[0],
                )
              ],
            )));
  }
}
