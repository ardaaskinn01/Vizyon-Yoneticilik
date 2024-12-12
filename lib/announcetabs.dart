import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:apartman/expense.dart';
import 'package:apartman/announcements.dart';

class Announcements extends StatefulWidget {
  final int id; // İlk default id olabilir
  final String siteId; // İlk default id olabilir

  Announcements({required this.id, required this.siteId});

  @override
  _AnnouncementsState createState() => _AnnouncementsState();
}

class _AnnouncementsState extends State<Announcements> {
  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          automaticallyImplyLeading: false,
          backgroundColor: Color(0xFFFF8805),
          title: TabBar(
            tabs: [
              Tab(text: 'Giderler'),
              Tab(text: 'Duyurular'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            ExpensesScreen(id: widget.id, siteId: widget.siteId), // Harcamalar
            DuyuruScreen(id: widget.id, siteId: widget.siteId),// Duyurular
          ],
        ),
      ),
    );
  }
}
