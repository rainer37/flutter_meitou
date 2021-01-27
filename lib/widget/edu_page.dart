import 'package:flutter/material.dart';
import 'package:flutter_meitou/model/color_unicorn.dart';

class EduPage extends StatelessWidget {
  Widget _videoCover(String imageUrl, BuildContext context) {
    return GestureDetector(
        onTap: () {
          Navigator.push(context, MaterialPageRoute(builder: (_) {
            return DetailImagePage(imageUrl);
          }));
        },
        child: Container(
            width: double.infinity,
            height: 200,
            padding: EdgeInsets.all(10),
            child: Hero(
                tag: imageUrl,
                child: FadeInImage.assetNetwork(
                    fadeInDuration: Duration(milliseconds: 500),
                    fit: BoxFit.fill,
                    placeholder: 'assets/moneybag.jpg',
                    image: imageUrl))));
  }

  @override
  Widget build(BuildContext context) {
    return Container(
        color: kLightBackground,
        child: SingleChildScrollView(
          child: Column(children: [
            _videoCover('https://i.ytimg.com/vi/uAeBpzWyU2c/maxresdefault.jpg',
                context),
            _videoCover('https://i.ytimg.com/vi/prHUj6frMkY/maxresdefault.jpg',
                context),
            _videoCover('https://i.ytimg.com/vi/WHHRMzcHUTA/maxresdefault.jpg',
                context),
            Container(
                padding: EdgeInsets.only(top: 30, bottom: 30),
                child: Text(
                  "更多惊喜正在酝酿中",
                  style: TextStyle(fontSize: 20),
                ))
          ]),
        ));
  }
}

class DetailImagePage extends StatelessWidget {
  final String srcUrl;
  DetailImagePage(this.srcUrl);
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
        child: Scaffold(
          backgroundColor: kLightBackground,
          body: GestureDetector(
            child: Center(
              child: Hero(
                  tag: srcUrl,
                  child: ClipRRect(
                      borderRadius: BorderRadius.circular(15),
                      child: Image.network(srcUrl))),
            ),
          ),
        ),
        onTap: () {
          Navigator.pop(context);
        });
  }
}
