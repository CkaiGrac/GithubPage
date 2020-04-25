import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:my_blog/pages/home_page.dart';


void main() {
  runApp(MyBlogApp());
}

class MyBlogApp extends StatelessWidget {
  
  @override
  Widget build(BuildContext context) {
    //ScreenUtil.init(context);
    return MaterialApp(
      title: '呜嘤哥\'s Blog',
      theme: ThemeData(
        primarySwatch: Colors.brown,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}
