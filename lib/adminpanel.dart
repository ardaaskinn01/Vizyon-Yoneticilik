import 'package:apartman/about.dart';
import 'package:apartman/blokSelection.dart';
import 'package:apartman/contact.dart';
import 'package:apartman/kullan%C4%B1c%C4%B1lar.dart';
import 'package:apartman/selection.dart';
import 'package:apartman/siteler.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'announcements.dart';
import 'announcetabs.dart';
import 'apartmentprofile.dart';
import 'lock.dart';
import 'main.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class AdminPanel extends StatefulWidget {
  @override
  _AdminPanelState createState() => _AdminPanelState();
}

class _AdminPanelState extends State<AdminPanel> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  String? displayName; // Kullanıcının adını saklamak için bir değişken

  @override
  void initState() {
    super.initState();
    updateDisplayName(); // Kullanıcı adını almak için fonksiyonu çağır
  }

  Future<void> updateDisplayName() async {
    try {
      // Aktif kullanıcıyı alın
      User? currentUser = _auth.currentUser;

      if (currentUser != null) {
        // Firestore'dan kullanıcının kaydını alın
        DocumentSnapshot userDoc = await _firestore
            .collection('users') // Kullanıcı koleksiyonunuzun adı
            .doc(currentUser.uid) // Kullanıcının UID'sini kullanarak belgeyi alın
            .get();

        // Firestore'daki 'name' alanını alın
        setState(() {
          displayName = userDoc['name']; // 'name' alanını alıp displayName'e atıyoruz
        });

        print('Display name güncellendi: $displayName');
      } else {
        print('Aktif kullanıcı bulunamadı.');
      }
    } catch (e) {
      print('Hata: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFEAE8E8), // Arka plan beyaz
      appBar: AppBar(
        title: Text(
          displayName != null
              ? 'Hoşgeldin $displayName!'
              : 'Hoşgeldin Yükleniyor...',
          style: TextStyle(
            color: Colors.white,
            fontSize: 22,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.black,
        actions: [
          IconButton(
            icon: Icon(Icons.logout, color: Colors.red),
            onPressed: () {
              _auth.signOut(); // Çıkış işlemi
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => LoginScreen()),
              );
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(70.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            ElevatedButton.icon(
              icon: Icon(Icons.add_business, color: Colors.black),
              label: Text('Site/Blok/Daire Yönetimi', style: TextStyle(fontSize: 16, color: Colors.white),),
              style: ElevatedButton.styleFrom(
                backgroundColor: Color(0xFFFF8805).withOpacity(0.8),
                padding: EdgeInsets.symmetric(vertical: 24),
              ),
              onPressed: () {
                Navigator.push(context, MaterialPageRoute(builder: (context) => SitelerScreen()));
              },
            ),
            SizedBox(height: 30),
            ElevatedButton.icon(
              icon: Icon(Icons.person, color: Colors.black),
              label: Text('Kullanıcı Yönetimi', style: TextStyle(fontSize: 17, color: Colors.white),),
              style: ElevatedButton.styleFrom(
                backgroundColor: Color(0xFFFF8805).withOpacity(0.8),
                padding: EdgeInsets.symmetric(vertical: 24),
              ),
              onPressed: () {
                Navigator.push(context, MaterialPageRoute(builder: (context) => KullanicilarEkrani()));
              },
            ),
            SizedBox(height: 125),
            ElevatedButton.icon(
              icon: Icon(Icons.attach_money, color: Colors.orange),
              label: Text('Ödeme/Borç Ekle', style: TextStyle(fontSize: 17, color: Colors.black),),
              style: ElevatedButton.styleFrom(
                backgroundColor: Color(0xFF08FFFF).withOpacity(0.8),
                padding: EdgeInsets.symmetric(vertical: 24),
              ),
              onPressed: () {
                Navigator.push(context, MaterialPageRoute(builder: (context) => BlokSelectionScreen(id: 1)));
              },
            ),
            SizedBox(height: 30),
            ElevatedButton.icon(
              icon: Icon(Icons.announcement_rounded, color: Colors.orange),
              label: Text('Duyuru/Harcama Ekle', style: TextStyle(fontSize: 17, color: Colors.black),),
              style: ElevatedButton.styleFrom(
                backgroundColor: Color(0xFF08FFFF).withOpacity(0.8),
                padding: EdgeInsets.symmetric(vertical: 24),
              ),
              onPressed: () {
                Navigator.push(context, MaterialPageRoute(builder: (context) => SiteSelectionScreen(id: 0)));
              },
            ),
          ],
        ),
      ),
    );
  }
}
