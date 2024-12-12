import 'package:apartman/announcements.dart';
import 'package:apartman/expense.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class Lock extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
        title: Text('Yetki Ekranı'),
    backgroundColor: Color(0xFF08FFFF),
    elevation: 0,
    )
    );
  }
}