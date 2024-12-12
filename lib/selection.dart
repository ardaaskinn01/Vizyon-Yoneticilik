import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'announcetabs.dart'; // Tablı ekran

class SiteSelectionScreen extends StatefulWidget {
  final int id; // İlk default id olabilir

  SiteSelectionScreen({required this.id});
  @override
  _SiteSelectionScreenState createState() => _SiteSelectionScreenState();
}

class _SiteSelectionScreenState extends State<SiteSelectionScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  List<Map<String, dynamic>> siteler = []; // Siteler listesi

  @override
  void initState() {
    super.initState();
    fetchSites(); // Siteleri yükle
  }

  Future<void> fetchSites() async {
    try {
      QuerySnapshot querySnapshot = await _firestore.collection('site').get();
      setState(() {
        siteler = querySnapshot.docs
            .map((doc) => {
          'id': doc.id,
          'name': doc['name'], // Sitenin adı
        })
            .toList();
      });
    } catch (e) {
      print('Siteleri yüklerken hata oluştu: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Siteler Listesi',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Color(0xFF08FFFF),  // AppBar rengi
        elevation: 5,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('site').snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(
              child: Text('Henüz site eklenmedi.',
                  style: TextStyle(fontSize: 18, color: Colors.grey)),
            );
          }

          final sites = snapshot.data!.docs;

          return ListView.builder(
            itemCount: sites.length,
            itemBuilder: (context, index) {
              final site = sites[index];
              return GestureDetector(
                child: Card(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),  // Yuvarlatılmış köşeler
                  ),
                  elevation: 8,  // Gölge ekledik
                  margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                  color: Colors.white,  // Arka plan rengini beyaz yaptık
                  child: ListTile(
                    contentPadding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                    title: Text(
                      site['name'],
                      style: TextStyle(
                        fontSize: 20,  // Başlık boyutu
                        fontWeight: FontWeight.bold,
                        color: Color(0xFFFF8805),  // Başlık rengi
                      ),
                    ),
                    subtitle: Text(
                      'Site No: ${site['num']}',
                      style: TextStyle(
                        fontSize: 16,
                        color: Color(0xFFFF8805),  // Alt başlık rengi
                      ),
                    ),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => Announcements(
                            id: widget.id,
                            siteId: site.id,
                          ),
                        ),
                      );
                    },
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
