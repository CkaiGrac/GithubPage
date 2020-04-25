import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:my_blog/widgets/appbar_widgets.dart';
import 'package:my_blog/widgets/body_widgets.dart';
import 'package:responsive_builder/responsive_builder.dart';

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  String blogContent;
  List<dynamic> noteList;

  @override
  void initState() {
    super.initState();
    getNoteList();
  }

  @override
  Widget build(BuildContext context) {
    ScreenUtil.init(context, width: 1920, height: 1080);

    return Material(
      child: ResponsiveBuilder(
        builder: (context, sizingInformation) {
          if (sizingInformation.deviceScreenType == DeviceScreenType.Desktop) {
            return Scaffold(appBar: appbar(), body: BodyPage(data: noteList));
            //return Container(color: Colors.blue);
          }

          if (sizingInformation.deviceScreenType == DeviceScreenType.Tablet) {
            return Scaffold(
              appBar: appbar(),
              body: Container(color: Colors.red),
            );
          }

          if (sizingInformation.deviceScreenType == DeviceScreenType.Watch) {
            return Center(child: CircularProgressIndicator());
          }

          return Scaffold(
            appBar: appbar(),
            body: Container(color: Colors.purple),
          );
        },
      ),
    );
  }

  void getNoteList() {
    rootBundle.loadString('assets/config.json').then((jsonData) {
      var noteMap = json.decode(jsonData);
      setState(() {
        noteList = noteMap['note_list'];
      });
    });
  }
}
