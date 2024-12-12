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
        title: Text('Siteler Listesi'),
        backgroundColor: Color(0xFF08FFFF),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('site').snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(
              child: Text('Henüz site eklenmedi.'),
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
                    borderRadius: BorderRadius.circular(10),
                  ),
                  elevation: 5,
                  margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                  child: ListTile(
                    title: Text(
                      site['name'],
                      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    subtitle: Text('Site No: ${site['num']}'),
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
