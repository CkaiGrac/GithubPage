import 'package:flutter/material.dart';

Widget appbar() => AppBar(
      title: appbar_text(),
      centerTitle: true,
      elevation: 1.0,
    );

Widget appbar_text() => Text('全部笔记',
    style: TextStyle(
      color: Colors.white,
      shadows: <Shadow>[Shadow(color: Colors.black54, offset: Offset(0, 0.8))],
    ));
