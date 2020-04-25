import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/screenutil.dart';
import 'package:flutter_markdown/flutter_markdown.dart';

class BodyPage extends StatefulWidget {
  BodyPage({Key key, this.data}) : super(key: key);

  final List<dynamic> data;

  @override
  _BodyPageState createState() => _BodyPageState();
}

class _BodyPageState extends State<BodyPage> {
  String content;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: <Widget>[
        widget.data == null
            ? leftBody(loadingWidget())
            : leftBody(noteLayout(widget.data)),
        rightBody()
      ],
    );
  }

  Widget noteLayout(List<dynamic> noteList) {
    return ListView.builder(
        itemCount: noteList.length,
        itemBuilder: (context, position) {
          return FlatButton(
            onPressed: () {
              getContent(noteList[position]['num']);
            },
            child: Container(
              alignment: Alignment.centerLeft,
              height: ScreenUtil().setHeight(100),
              child: Text(
                noteList[position]['title'],
                style: TextStyle(
                    color: Colors.brown[700], fontSize: ScreenUtil().setSp(25)),
              ),
            ),
          );
        });
  }

  Widget loadingWidget() {
    return Center(
      child: CircularProgressIndicator(),
    );
  }

  Widget leftBody(Widget loadWidget) {
    return Container(
      width: ScreenUtil().setWidth(480),
      color: Colors.amber[100],
      child: loadWidget,
    );
  }

  Widget rightBody() {
    return Stack(
      alignment: Alignment.center,
      children: <Widget>[
        Container(
          width: ScreenUtil().setWidth(1440),
          color: Colors.amber[200],
        ),
        SingleChildScrollView(
          child: content == null
              ? Center(
                  child: Container(
                      width: ScreenUtil().setWidth(1400),
                      height: ScreenUtil().setHeight(935),
                      decoration: getBoxDecoration()),
                )
              : Container(
                  margin: EdgeInsets.only(top: 20, bottom: 20),
                  width: ScreenUtil().setWidth(1400),
                  decoration: getBoxDecoration(),
                  child: Column(
                    children: <Widget>[
                      Padding(
                        padding: EdgeInsets.all(20),
                        child: MarkdownBody(
                          data: content,
                          shrinkWrap: true,
                          selectable: true,
                        ),
                      ),
                    ],
                  ),
                ),
        ),
      ],
    );
  }

  void getContent(int noteName) {
    try {
      rootBundle.loadString('assets/note/0$noteName.md').then((value) {
        print('note/0$noteName.md');
        setState(() {
          content = value;
        });
      });
    } catch (e) {
      print(e);
    }
  }
}

BoxDecoration getBoxDecoration() {
  return BoxDecoration(
      color: Colors.amber[100],
      borderRadius: BorderRadius.all(Radius.circular(2.0)),
      border: Border.all(color: Colors.white12),
      boxShadow: <BoxShadow>[
        BoxShadow(color: Colors.black12, offset: Offset(0, 1.4))
      ]);
}
