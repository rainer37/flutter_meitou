import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_meitou/model/config.dart';
import 'package:flutter_meitou/widget/edu_page.dart';
import 'package:flutter_meitou/widget/chat_page.dart';
import 'package:flutter_meitou/widget/login_page.dart';
import 'package:flutter_meitou/widget/user_profile_page.dart';

import 'model/color_unicorn.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

void main() async {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    MeitouConfig.setConfig('wsEndpointUrl',
        'wss://4f6y995d0d.execute-api.us-west-2.amazonaws.com/dev');
    MeitouConfig.setConfig('restEndpointUrl',
        'https://ben62z58pk.execute-api.us-west-2.amazonaws.com');
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Welcome to MeiTou',
      home: Container(
        color: Colors.lightGreen,
        child: SafeArea(
          // child: RandomWords(),
          child: LoginPage(),
        ),
      ),
      theme: ThemeData(
        primaryColor: Colors.lightGreen,
        scaffoldBackgroundColor: Colors.white,
      ),
      routes: {
        '/home': (context) => RandomWords(),
        '/chat': (context) => ChatPage(),
        '/login': (context) => LoginPage(),
      },
    );
  }
}

class RandomWords extends StatefulWidget {
  @override
  _RandomWordsState createState() => _RandomWordsState();
}

class _RandomWordsState extends State<RandomWords> {
  final FirebaseMessaging _fcm = FirebaseMessaging();

  var _index = 0;
  final List<Widget> children = [ChatPage(), EduPage(), UserProfile()];

  final List<Widget> appBars = [
    Placeholder(),
    Placeholder(),
    Placeholder(),
  ];

  void configureFCM() async {
    _fcm.configure(
      onMessage: (Map<String, dynamic> message) async {
        print("onMessage: $message");
        print("${message['data']['default']}");
        dynamic msgObj = jsonDecode(message['data']['default']);
        print(msgObj['notification']);
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            content: ListTile(
              title: Text(msgObj['notification']['title']),
              subtitle: Text(msgObj['notification']['body']),
            ),
            actions: <Widget>[
              FlatButton(
                child: Text('Ok'),
                onPressed: () => Navigator.of(context).pop(),
              ),
            ],
          ),
        );
      },
      onLaunch: (Map<String, dynamic> message) async {
        print("onLaunch: $message");
        // TODO optional
      },
      onResume: (Map<String, dynamic> message) async {
        print("onResume: $message");
        // TODO optional
      },
    );
    print(await _fcm.getToken());
  }

  @override
  void initState() {
    super.initState();
    configureFCM();
    final mainAppBar = AppBar(
      elevation: 0,
      title: Text('美投'),
      actions: [IconButton(icon: Icon(Icons.list), onPressed: _pushSaved)],
    );
    appBars[0] = AppBar(
      elevation: 0,
      title: Text('来看看大家都在聊个啥'),
      actions: [
        IconButton(
            icon: Icon(
              Icons.add_circle,
              color: kLightIcon,
            ),
            onPressed: _addChannel)
      ],
    );
    appBars[1] = AppBar(
      elevation: 0,
      title: Text(
        '美投君的精选视频',
        style: TextStyle(color: kLightTextTitle),
      ),
    );
    appBars[2] = AppBar(
      elevation: 0,
      title: Text('我的信息'),
      actions: [
        IconButton(
            icon: Icon(
              Icons.settings,
              color: kLightIcon,
            ),
            onPressed: _moreOnMe)
      ],
    );
  }

  void _moreOnMe() async {
    Navigator.of(context)
        .push(MaterialPageRoute<void>(builder: (BuildContext context) {
      return Scaffold(
          appBar: AppBar(
            elevation: 0,
            title: Text('我的其他骚操作'),
          ),
          body: Container(
              color: kLightBackground,
              child: Column(
                children: [
                  FlatButton(
                      onPressed: () {
                        print('one pressed');
                        _fcm.subscribeToTopic('puppies');
                      },
                      child: Text('One')),
                  FlatButton(onPressed: () {}, child: Text('Two'))
                ],
              )));
    }));
  }

  void _addChannel() async {
    Navigator.of(context)
        .push(MaterialPageRoute<void>(builder: (BuildContext context) {
      return Scaffold(
          appBar: AppBar(
            elevation: 0,
            title: Text('开一个新的频道吧'),
          ),
          body: Container(
              color: kLightBackground, child: Center(child: Text('你有什么想说的'))));
    }));
  }

  void _pushSaved() {
    Navigator.of(context)
        .push(MaterialPageRoute<void>(builder: (BuildContext context) {
      return Scaffold(
          appBar: AppBar(
            elevation: 0,
            title: Text('Saved Hearted'),
          ),
          body: Container());
    }));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: appBars[_index],
      body: children[_index],
      bottomNavigationBar: new Theme(
          data: Theme.of(context).copyWith(
            canvasColor: kHeavyBackground,
            primaryColor: Colors.yellow,
            textTheme: Theme.of(context)
                .textTheme
                .copyWith(caption: new TextStyle(color: kLightBackground)),
          ),
          child: new BottomNavigationBar(
            elevation: 0,
            onTap: (index) {
              HapticFeedback.mediumImpact();
              setState(() {
                _index = index;
              });
            },
            type: BottomNavigationBarType.fixed,
            currentIndex: _index,
            items: const <BottomNavigationBarItem>[
              BottomNavigationBarItem(icon: Icon(Icons.chat), label: '去聊天'),
              BottomNavigationBarItem(icon: Icon(Icons.book), label: '受教育'),
              BottomNavigationBarItem(
                icon: Icon(Icons.account_circle),
                label: '我的',
              ),
            ],
          )),
    );
  }
}
