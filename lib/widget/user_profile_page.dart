import 'package:amplify_auth_cognito/amplify_auth_cognito.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_meitou/model/color_unicorn.dart';
import 'package:flutter_meitou/model/config.dart';

import 'package:amplify_core/amplify_core.dart';

const defaultAvatarUrl =
    'https://i1.sndcdn.com/avatars-000617335083-cmq67l-t500x500.jpg';

class UserProfile extends StatefulWidget {
  @override
  _UserProfileState createState() => _UserProfileState();
}

class _UserProfileState extends State<UserProfile> {
  var _userName = '', _avatar = defaultAvatarUrl;
  var _coin = 0;

  @override
  void initState() {
    super.initState();
    setState(() {
      _userName = 'Loading';
      _coin = 0;
    });
    _fetchUserInfo();
  }

  void _fetchUserInfo() async {
    if (MeitouConfig.containsConfig('user_name') &&
        MeitouConfig.containsConfig('coins') &&
        MeitouConfig.containsConfig('avatar_url')) {
      setState(() {
        _userName = MeitouConfig.getConfig('user_name');
        _coin = MeitouConfig.getConfig('coins');
        _avatar = MeitouConfig.getConfig('avatar_url') == ''
            ? defaultAvatarUrl
            : MeitouConfig.getConfig('avatar_url');
      });
      return;
    } else {
      print('no logged in user detected!!!');
      _logOut();
    }
  }

  Widget _buildUserInfo() {
    return Container(
      height: MediaQuery.of(context).size.height * 0.15 + 20,
      padding: EdgeInsets.all(10),
      child: Column(
        children: [
          Container(
              height: MediaQuery.of(context).size.height * 0.15,
              child: Row(
                children: [
                  Container(
                    width: MediaQuery.of(context).size.width * 0.3,
                    child: CircleAvatar(
                      radius: MediaQuery.of(context).size.height * 0.15,
                      backgroundImage: NetworkImage(_avatar),
                    ),
                  ),
                  Container(
                    width: MediaQuery.of(context).size.width * 0.7 - 20,
                    padding: EdgeInsets.only(left: 20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          padding: EdgeInsets.only(top: 10, bottom: 5),
                          child: Text(
                            "$_userName",
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        Container(
                          decoration: new BoxDecoration(
                              color: Colors.lightGreen,
                              borderRadius:
                                  new BorderRadius.all(Radius.circular(10.0))),
                          padding: EdgeInsets.all(5),
                          child: Text(
                            "初级股民",
                            style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFFf4ebc1)),
                          ),
                        ),
                        Container(
                          child: Text(
                            '美投币 $_coin',
                            style: TextStyle(
                              fontSize: 25,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        )
                      ],
                    ),
                  ),
                ],
              )),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Container(
            color: kLightBackground,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildUserInfo(),
                Divider(),
                Padding(
                    padding: EdgeInsets.only(left: 10), child: Text('我的订阅频道们')),
                _buildSubscriptionList(),
                Container(
                  height: 150,
                  width: double.infinity,
                  margin: EdgeInsets.only(top: 50),
                  child: RaisedButton(
                    padding: EdgeInsets.all(20),
                    onPressed: _logOut,
                    color: Colors.white,
                    textColor: Colors.lightGreen,
                    child: Text(
                      '退出当前神奇的账号然后换一个登录',
                      style:
                          TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                  ),
                )
              ],
            )));
  }

  void _logOut() async {
    print('logging out');
    try {
      await Amplify.Auth.signOut();
      Navigator.of(context).pushNamedAndRemoveUntil('/login', (route) => false);
      MeitouConfig.removeConfig('user_name');
      MeitouConfig.removeConfig('user_id');
      MeitouConfig.removeConfig('avatar_url');
      MeitouConfig.removeConfig('coins');
    } on AuthError catch (e) {
      print(e);
    }
  }

  List<String> myChannels = [
    '## 某一个神奇的频道 \$5/month',
    '## 成功人士会所 \$100/month',
    '## NetFlex网非 \$12/month'
  ];

  Widget _buildSubscriptionList() {
    return Container(
        // height: MediaQuery.of(context).size.height * 0.2,
        margin: EdgeInsets.only(top: 10),
        child: SizedBox(
            height: MediaQuery.of(context).size.height * 0.25,
            child: ListView.builder(
              itemCount: myChannels.length,
              itemBuilder: (context, index) {
                return Container(
                  padding: EdgeInsets.symmetric(vertical: 15),
                  color: Colors.lightGreen,
                  margin: EdgeInsets.all(1),
                  child: Row(children: [
                    Padding(
                        padding: EdgeInsets.only(left: 10, right: 5),
                        child: Text(
                          myChannels[index],
                        )),
                  ]),
                );
              },
            )));
  }
}
