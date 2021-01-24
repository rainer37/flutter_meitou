import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_meitou/model/color_unicorn.dart';
import 'package:http/http.dart' as http;
import 'dart:convert' as convert;

import 'package:amplify_core/amplify_core.dart';
import 'package:amplify_auth_cognito/amplify_auth_cognito.dart';
import 'package:flutter_meitou/model/config.dart';
import '../amplifyconfiguration.dart';

class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  TextEditingController _emailController = TextEditingController();
  TextEditingController _codeController = TextEditingController();
  TextEditingController _passwordController = TextEditingController();

  void _showAlertDialog(BuildContext context, String action, title, content) {
    // Create button
    Widget okButton = FlatButton(
      child: Text(action),
      onPressed: () {
        Navigator.of(context).pop();
      },
    );

    // Create AlertDialog
    AlertDialog alert = AlertDialog(
      title: Text(title),
      content: Text(content),
      actions: [
        okButton,
      ],
    );

    // show the dialog
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return alert;
      },
    );
  }

  void _hasUserLoggedIn() async {
    try {
      CognitoAuthSession sess = await Amplify.Auth.fetchAuthSession(
          options: CognitoSessionOptions(getAWSCredentials: true));
      print('${sess.userSub} already signed in');
      _fetchUserInfo(sess.userSub);
      Navigator.of(context).pushReplacementNamed('/home');
    } on AuthError catch (e) {
      print('not logged in, proceed to sign in');
      setState(() {
        loginStateCheckInProgress = false;
      });
    }
  }

  void _signIn() async {
    try {
      CognitoAuthSession sess = await Amplify.Auth.fetchAuthSession(
          options: CognitoSessionOptions(getAWSCredentials: true));
      print('${sess.userSub} already signed in');
      _fetchUserInfo(sess.userSub);
      Navigator.of(context).pushReplacementNamed('/home');
      return;
    } on AuthError catch (e) {
      print('not logged in, proceed to sign in');
    }

    try {
      SignInResult res = await Amplify.Auth.signIn(
        username: _emailController.text,
        password: _passwordController.text,
      );
      // print('[${_emailController.text}][${_passwordController.text}]');
      print('has user logged in ? ${res.isSignedIn}');
      CognitoAuthSession sess = await Amplify.Auth.fetchAuthSession(
          options: CognitoSessionOptions(getAWSCredentials: true));
      print('${sess.userSub} just signed in');

      _fetchUserInfo(sess.userSub);
      // _showAlertDialog(context, '好嘞', '登陆成功', '开始探索美投吧！');
      Navigator.of(context).pushReplacementNamed('/home');
    } on AuthError catch (e) {
      print(e);
      _showAlertDialog(context, '谢谢', '登陆失败', '请检查你的邮箱密码...');
    }
  }

  void _configureAmplify() async {
    print('configuring amplify');
    // Add Pinpoint and Cognito Plugins, or any other plugins you want to use
    if (MeitouConfig.containsConfig('amplifyConfigured')) {
      print('amplify configured');
      return;
    }

    try {
      Amplify amplifyInstance = Amplify();
      AmplifyAuthCognito authPlugin = AmplifyAuthCognito();
      amplifyInstance
          .addPlugin(authPlugins: [authPlugin], analyticsPlugins: []);

      // Once Plugins are added, configure Amplify
      await amplifyInstance.configure(amplifyconfig);
      // AmplifyAuthCognito auth = AmplifyAuthCognito();
      setState(() {
        MeitouConfig.setConfig('amplifyConfigured', true);
      });
    } on AuthError catch (e) {
      print(e.exceptionList);
    }
  }

  @override
  void initState() {
    super.initState();
    _configureAmplify();
    _hasUserLoggedIn();
  }

  bool loginStateCheckInProgress = true;

  @override
  Widget build(BuildContext context) {
    return loginStateCheckInProgress
        ? Container()
        : Scaffold(
            body: GestureDetector(
                onTap: () {
                  FocusScope.of(context).requestFocus(new FocusNode());
                },
                child: Container(
                  color: kHeavyBackground,
                  child: Column(
                    children: [
                      Container(
                        height: MediaQuery.of(context).size.height * 0.3,
                        child: CircleAvatar(
                          radius: 100,
                          backgroundImage: NetworkImage(
                              'https://yt3.ggpht.com/ytc/AAUvwnh90LNf2_wRdm3PPbWtSL7I-h0jOIV0D9P7lqF7=s88-c-k-c0x00ffffff-no-rj'),
                        ),
                      ),
                      Container(
                        child: Padding(
                          padding: EdgeInsets.only(left: 40, right: 40),
                          child: TextField(
                            autofocus: true,
                            autocorrect: false,
                            enableSuggestions: false,
                            style: TextStyle(color: Colors.white),
                            controller: _emailController,
                            decoration: InputDecoration(
                              hintText: '请输入您的邮箱地址',
                              hintStyle: TextStyle(color: Colors.white),
                              enabledBorder: UnderlineInputBorder(
                                  borderSide: BorderSide(
                                      color: Colors.white, width: 1.0)),
                              focusedBorder: UnderlineInputBorder(
                                  borderSide: BorderSide(
                                      color: Colors.white, width: 1.0)),
                              prefixIcon: const Icon(
                                Icons.email,
                                color: Colors.white,
                              ),
                            ),
                            obscureText: false,
                          ),
                        ),
                      ),
                      Container(
                        child: Padding(
                          padding: EdgeInsets.only(left: 40, right: 40),
                          child: TextField(
                            autocorrect: false,
                            enableSuggestions: false,
                            style: TextStyle(color: Colors.white),
                            controller: _passwordController,
                            decoration: InputDecoration(
                              hintText: '请输入您的超级密码',
                              hintStyle: TextStyle(color: Colors.white),
                              enabledBorder: UnderlineInputBorder(
                                  borderSide: BorderSide(
                                      color: Colors.white, width: 1.0)),
                              focusedBorder: UnderlineInputBorder(
                                  borderSide: BorderSide(
                                      color: Colors.white, width: 1.0)),
                              prefixIcon: const Icon(
                                Icons.lock,
                                color: Colors.white,
                              ),
                            ),
                            obscureText: true,
                          ),
                        ),
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          waitingForVeriCode
                              ? Container(
                                  margin: EdgeInsets.only(top: 30),
                                  width:
                                      MediaQuery.of(context).size.width * 0.4,
                                  child: TextField(
                                    keyboardType: TextInputType.number,
                                    cursorColor: Colors.white,
                                    autocorrect: false,
                                    enableSuggestions: false,
                                    style: TextStyle(
                                        color: Colors.white, fontSize: 20),
                                    controller: _codeController,
                                    textAlign: TextAlign.center,
                                    decoration: InputDecoration(
                                      hintText: '验证码',
                                      hintStyle: TextStyle(
                                          color: Colors.white, fontSize: 20),
                                      border: OutlineInputBorder(
                                          borderSide: BorderSide(
                                              color: Colors.white, width: 1.0)),
                                      enabledBorder: OutlineInputBorder(
                                          borderSide: BorderSide(
                                              color: Colors.white, width: 1.0)),
                                      focusedBorder: OutlineInputBorder(
                                          borderSide: BorderSide(
                                              color: Colors.white, width: 1.0)),
                                    ),
                                  ),
                                )
                              : Container(
                                  width:
                                      MediaQuery.of(context).size.width * 0.4,
                                  padding: EdgeInsets.only(right: 5),
                                  margin: EdgeInsets.only(top: 30),
                                  child: RaisedButton(
                                    padding: EdgeInsets.all(20),
                                    onPressed: _loginClick,
                                    color: Colors.white,
                                    textColor: Colors.lightGreen,
                                    child: Text(
                                      '登录',
                                      style: TextStyle(
                                          fontSize: 20,
                                          fontWeight: FontWeight.bold),
                                    ),
                                  ),
                                ),
                          Container(
                            width: MediaQuery.of(context).size.width * 0.4,
                            padding: EdgeInsets.only(left: 5),
                            margin: EdgeInsets.only(top: 30),
                            child: RaisedButton(
                              padding: EdgeInsets.all(20),
                              onPressed:
                                  waitingForVeriCode ? _verifyCode : _signUp,
                              color: Colors.white,
                              textColor: Colors.lightGreen,
                              child: Text(
                                waitingForVeriCode ? '验证' : '注册',
                                style: TextStyle(
                                    fontSize: 20, fontWeight: FontWeight.bold),
                              ),
                            ),
                          )
                        ],
                      ),
                    ],
                  ),
                )));
  }

  bool waitingForVeriCode = false;

  void _verifyCode() async {
    print('verifying code');
    if (_codeController.text == "") {
      _showAlertDialog(context, '得嘞', '信息缺失', '请输入邮箱中的验证码');
      return;
    }
    try {
      SignUpResult res = await Amplify.Auth.confirmSignUp(
          username: _emailController.text,
          confirmationCode: _codeController.text);
      print('is sign up confirmed ? ${res.isSignUpComplete}');
      _signIn();
    } on AuthError catch (e) {
      print(e);
    }
  }

  void _signUp() async {
    print('signing up');
    if (_emailController.text == "" || _passwordController.text == "") {
      _showAlertDialog(context, '中！', '信息缺失', '请输入邮箱和密码来进行注册');
      return;
    }
    try {
      Map<String, dynamic> userAttributes = {
        "email": _emailController.text,
        "phone_number": '+11111111',
        // additional attributes as needed
      };
      SignUpResult res = await Amplify.Auth.signUp(
          username: _emailController.text,
          password: _passwordController.text,
          options: CognitoSignUpOptions(userAttributes: userAttributes));
      print('is sign up in progress ? ${res.isSignUpComplete}');
      setState(() {
        waitingForVeriCode = true;
      });
    } on AuthError catch (e) {
      print(e);
    }
  }

  void _loginClick() {
    if (_emailController.text == "" || _passwordController.text == "") {
      _showAlertDialog(context, '懂了', '信息缺失', '请输入邮箱和密码以登录');
      return;
    }
    _signIn();
  }

  void _fetchUserInfo(String userId) async {
    if (MeitouConfig.containsConfig('user_name') &&
        MeitouConfig.containsConfig('coins')) {
      print('already has user info??/');
      return;
    }
    print('fetching user info $userId');
    var url = "${MeitouConfig.getConfig('restEndpointUrl')}/user/$userId";
    http.Response response = await http.get(url);
    if (response.statusCode == 200) {
      dynamic jsonResponse = convert.jsonDecode(response.body);
      // var itemCount = jsonResponse['totalItems'];
      // print('Number of books about http: $jsonResponse.');
      // print("${jsonResponse}");
      MeitouConfig.setConfig('user_id', jsonResponse['user_id']);
      MeitouConfig.setConfig('user_name', jsonResponse['user_name']);
      MeitouConfig.setConfig('email', jsonResponse['email']);
      MeitouConfig.setConfig('avatar_url', jsonResponse['avatar_url']);
      MeitouConfig.setConfig('coins', int.parse(jsonResponse['coins']));
      print('user info fetched!');
    } else {
      print(
          'Request failed while fetching user info with status: ${response.statusCode}.');
    }
  }
}
