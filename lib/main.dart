import 'package:flutter/material.dart';
import 'package:english_words/english_words.dart';
import 'package:flutter_meitou/widget/chat_page.dart';
import 'package:flutter_meitou/widget/user_profile_page.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Welcome to MeiTou',
      home: RandomWords(),
      theme: ThemeData(primaryColor: Colors.lightGreen),
    );
  }
}

class RandomWords extends StatefulWidget {
  @override
  _RandomWordsState createState() => _RandomWordsState();
}

class _RandomWordsState extends State<RandomWords> {
  final _suggestions = <WordPair>[];
  final _saved = Set<WordPair>();
  final _biggerFont = TextStyle(fontSize: 18.0);
  var _index = 0;
  final List<Widget> children = [
    Placeholder(),
    ChatPage(),
    Placeholder(),
    UserProfile()
  ];

  final List<Widget> appbars = [
    Placeholder(),
    Placeholder(),
    Placeholder(),
    Placeholder(),
  ];

  @override
  void initState() {
    super.initState();
    children[0] = DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          title: Text("美投平台"),
          bottom: TabBar(
            tabs: [
              Tab(
                  icon: Icon(Icons.bar_chart),
                  child: Container(
                    child: Text('财经头条'),
                  )),
              Tab(
                  icon: Icon(Icons.mail_outline),
                  child: Container(
                    child: Text('机密信息'),
                  )),
              Tab(
                  icon: Icon(Icons.cloud_queue_sharp),
                  child: Container(
                    child: Text('云计算'),
                  )),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            Icon(Icons.bar_chart, size: 200),
            Icon(Icons.mail_outline, size: 200),
            Icon(Icons.cloud_queue_sharp, size: 200),
          ],
        ),
      ),
    );

    final mainAppBar = AppBar(
      title: Text('美投'),
      actions: [IconButton(icon: Icon(Icons.list), onPressed: _pushSaved)],
    );
    appbars[0] = null;
    appbars[1] = AppBar(
      title: Text('话题频道'),
      actions: [IconButton(icon: Icon(Icons.add), onPressed: _addChannel)],
    );
    appbars[2] = mainAppBar;
    appbars[3] = AppBar(
      title: Text('我的信息'),
      actions: [IconButton(icon: Icon(Icons.add), onPressed: _moreOnMe)],
    );
  }

  void _moreOnMe() {
    Navigator.of(context)
        .push(MaterialPageRoute<void>(builder: (BuildContext context) {
      return Scaffold(
          appBar: AppBar(
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
            onTap: (index) {
              setState(() {
                _index = index;
              });
            },
            type: BottomNavigationBarType.fixed,
            currentIndex: _index,
            items: const <BottomNavigationBarItem>[
              BottomNavigationBarItem(
                  icon: Icon(Icons.accessibility), label: '搞社交'),
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
