import 'package:flutter/material.dart';
import 'package:english_words/english_words.dart';
import 'package:flutter_meitou/model/config.dart';
import 'package:flutter_meitou/widget/chat_page.dart';
import 'package:flutter_meitou/widget/login_page.dart';
import 'package:flutter_meitou/widget/user_profile_page.dart';

import 'model/user.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    MeitouConfig.setConfig('wsEndpointUrl',
        'wss://4f6y995d0d.execute-api.us-west-2.amazonaws.com/dev');
    MeitouConfig.setConfig('restEndpointUrl',
        'https://ben62z58pk.execute-api.us-west-2.amazonaws.com');
    MeitouConfig.setConfig(
        'USER#u-0-0-1',
        User(
            'u-0-0-1',
            'UserOne',
            'userone@gmail.com',
            'https://techcrunch.com/wp-content/uploads/2018/07/logo-2.png',
            99));
    MeitouConfig.setConfig(
        'USER#204083d4-5c3c-4039-b7f9-5f2a5358a4c3',
        User(
            '204083d4-5c3c-4039-b7f9-5f2a5358a4c3',
            '匿名股神',
            'rainer.1993@hotmail.com',
            'https://upload.wikimedia.org/wikipedia/commons/thumb/d/d2/Oauth_logo.svg/180px-Oauth_logo.svg.png',
            50));
    MeitouConfig.setConfig(
        'USER#198405c8-ca46-4818-ab51-5b612149d2d1',
        User(
            '198405c8-ca46-4818-ab51-5b612149d2d1',
            'rainergu37',
            'rainergu37@hotmail.com',
            'https://cdn.dribbble.com/users/3641854/screenshots/8201011/shot-cropped-1573712443265.png?compress=1&resize=400x300',
            50));
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
      },
    );
  }
}

class RandomWords extends StatefulWidget {
  @override
  _RandomWordsState createState() => _RandomWordsState();
}

class _RandomWordsState extends State<RandomWords> {
  final _saved = Set<WordPair>();
  final _biggerFont = TextStyle(fontSize: 18.0);
  var _index = 0;
  final List<Widget> children = [ChatPage(), Placeholder(), UserProfile()];

  final List<Widget> appbars = [
    Placeholder(),
    Placeholder(),
    Placeholder(),
  ];

  @override
  void initState() {
    super.initState();
    // children[0] = LoginPage();

    final mainAppBar = AppBar(
      elevation: 0,
      title: Text('美投'),
      actions: [IconButton(icon: Icon(Icons.list), onPressed: _pushSaved)],
    );
    appbars[0] = AppBar(
      elevation: 0,
      title: Text('话题频道'),
      actions: [IconButton(icon: Icon(Icons.add), onPressed: _addChannel)],
    );
    appbars[1] = mainAppBar;
    appbars[2] = AppBar(
      elevation: 0,
      title: Text('我的信息'),
      actions: [IconButton(icon: Icon(Icons.add), onPressed: _moreOnMe)],
    );
  }

  void _moreOnMe() {
    Navigator.of(context)
        .push(MaterialPageRoute<void>(builder: (BuildContext context) {
      return Scaffold(
          appBar: AppBar(
            elevation: 0,
            title: Text('我的其他骚操作'),
          ),
          body: Text('operational excellence'));
    }));
  }

  void _addChannel() {
    Navigator.of(context)
        .push(MaterialPageRoute<void>(builder: (BuildContext context) {
      return Scaffold(
          appBar: AppBar(
            elevation: 0,
            title: Text('开一个新的频道吧'),
          ),
          body: Text('你有什么想说的'));
    }));
  }

  void _pushSaved() {
    Navigator.of(context)
        .push(MaterialPageRoute<void>(builder: (BuildContext context) {
      final tiles = this._saved.map(
        (WordPair pair) {
          return ListTile(
            title: Text(
              pair.asPascalCase,
              style: _biggerFont,
            ),
            onTap: () {
              print("saved item tapped $pair");
            },
          );
        },
      );
      final divided = ListTile.divideTiles(
        context: context,
        tiles: tiles,
      ).toList();

      return Scaffold(
          appBar: AppBar(
            elevation: 0,
            title: Text('Saved Hearted'),
          ),
          body: ListView(children: divided));
    }));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: appbars[_index],
      body: children[_index],
      bottomNavigationBar: new Theme(
          data: Theme.of(context).copyWith(
            canvasColor: Colors.lightGreen,
            primaryColor: Colors.yellow,
            textTheme: Theme.of(context)
                .textTheme
                .copyWith(caption: new TextStyle(color: Colors.white)),
          ),
          child: new BottomNavigationBar(
            elevation: 0,
            onTap: (index) {
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
