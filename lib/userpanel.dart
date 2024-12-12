import 'package:apartman/about.dart';
import 'package:apartman/blokSelection.dart';
import 'package:apartman/contact.dart';
import 'package:apartman/selection.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'announcetabs.dart';
import 'passwordChange.dart';
import 'main.dart';

class UserPanel extends StatefulWidget {
  @override
  _UserPanelState createState() => _UserPanelState();
}

class _UserPanelState extends State<UserPanel> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  String? displayName;

  @override
  void initState() {
    super.initState();
    updateDisplayName();
  }

  Future<void> updateDisplayName() async {
    try {
      User? currentUser = _auth.currentUser;

      if (currentUser != null) {
        DocumentSnapshot userDoc = await _firestore
            .collection('users')
            .doc(currentUser.uid)
            .get();

        setState(() {
          displayName = userDoc['name'];
        });

        print('Display name güncellendi: $displayName');
      } else {
        print('Aktif kullanıcı bulunamadı.');
      }
    } catch (e) {
      print('Hata: $e');
    }
  }

  void logout(BuildContext context) {
    FirebaseAuth.instance.signOut().then((_) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => LoginScreen()),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFEAE8E8),
      appBar: AppBar(
        title: Text(
          displayName != null
              ? 'Hoşgeldin $displayName!'
              : 'Hoşgeldin Yükleniyor...',
          style: TextStyle(
            color: Colors.black,
            fontSize: 24,
            fontStyle: FontStyle.italic,
          ),
        ),
        backgroundColor: Color(0xFF08FFFF),
        leading: Builder(
          builder: (BuildContext context) {
            return IconButton(
              icon: Icon(Icons.menu, color: Colors.black),
              onPressed: () {
                Scaffold.of(context).openDrawer();
              },
            );
          },
        ),
      ),
      drawer: Drawer(
        backgroundColor: Color(0xFF08FFFF),
        child: ListView(
          children: [
            UserAccountsDrawerHeader(
              decoration: BoxDecoration(
                color: Color(0xFFFF8805),
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(20),
                  bottomRight: Radius.circular(20),
                ),
              ),
              accountName: Text(
                displayName ?? 'Yükleniyor...',
                style: TextStyle(
                  color: Colors.black,
                  fontWeight: FontWeight.bold,
                ),
              ),
              accountEmail: Text(
                "",
                style: TextStyle(color: Colors.black),
              ),
            ),
            _buildDrawerItem(
              icon: Icons.home,
              text: 'Ana Sayfa',
              context: context,
              onTap: () {
                Navigator.pop(context);
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => UserPanel()),
                );
              },
            ),
            _buildDrawerItem(
              icon: Icons.info_outline,
              text: 'Hakkımızda',
              context: context,
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => AboutPage()),
                );
              },
            ),
            _buildDrawerItem(
              icon: Icons.contact_mail,
              text: 'İletişim Bilgileri',
              context: context,
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => ContactPage()),
                );
              },
            ),
            _buildDrawerItem(
              icon: Icons.password,
              text: 'Şifre Değiştir',
              context: context,
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => PasswordChangeScreen()),
                );
              },
            ),
            _buildDrawerItem(
              icon: Icons.logout,
              text: 'Çıkış Yap',
              context: context,
              onTap: () {
                Navigator.pop(context);
                logout(context);
              },
            ),
          ],
        ),
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(height: 100),
          // Borç bilgileri butonu
          ElevatedButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => BlokSelectionScreen(id: 0)),
              );
            },
            child: Text(
              'Borç Bilgileri',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: Color(0xFFFF8805),
              padding: EdgeInsets.symmetric(vertical: 27, horizontal: 70),
            ),
          ),
          SizedBox(height: 60),
          // Duyurular/Giderler butonu
          ElevatedButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => SiteSelectionScreen(id: 1)),
              );
            },
            child: Text(
              'Duyurular/Giderler',
              style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold, color: Colors.black),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: Color(0xFF08FFFF).withOpacity(0.9),
              padding: EdgeInsets.symmetric(vertical: 27, horizontal: 55),
            ),
          ),
          Spacer(),
          // Alt kısımda görsel ekleme
          Image.asset(
            'assets/images/vizyon2.png',
            height: 160, // Görselin boyutunu ayarlıyoruz
            width: double.infinity,
            fit: BoxFit.contain,
          ),
        ],
      ),
    );
  }

  Widget _buildDrawerItem({
    required IconData icon,
    required String text,
    required BuildContext context,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Icon(icon, color: Colors.black),
      title: Text(
        text,
        style: TextStyle(
          color: Colors.black,
          fontWeight: FontWeight.bold,
        ),
      ),
      onTap: onTap,
    );
  }
}
