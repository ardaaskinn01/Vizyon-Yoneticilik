import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'apartmentprofile.dart'; // apartmentprofile.dart sayfasını import edin

class BlokSelectionScreen extends StatefulWidget {
  final int id; // İlk default id olabilir

  BlokSelectionScreen({required this.id});
  @override
  _BlokSelectionScreenState createState() => _BlokSelectionScreenState();
}

class _BlokSelectionScreenState extends State<BlokSelectionScreen> {
  // Bu listeyi Firestore'dan almak için kullanacağız
  List<Map<String, dynamic>> sites = [];

  @override
  void initState() {
    super.initState();
    // Sitelere ait verileri Firestore'dan alıyoruz
    getSites();
  }

  // Firestore'dan site verilerini alalım
  void getSites() async {
    QuerySnapshot snapshot = await FirebaseFirestore.instance.collection('site').get();
    setState(() {
      sites = snapshot.docs.map((doc) {
        return {
          'id': doc.id,
          'name': doc['name'],
        };
      }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Siteler ve Bloklar"),
        backgroundColor: Color(0xFFFF8805),
      ),
      body: ListView.builder(
        itemCount: sites.length,
        itemBuilder: (context, index) {
          var site = sites[index];
          return Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Site başlığını daha estetik hale getirelim
                Container(
                  padding: EdgeInsets.symmetric(vertical: 10, horizontal: 20),
                  decoration: BoxDecoration(
                    color: Color(0xFFFF8805), // Başlık arka planı
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.location_city, color: Colors.white, size: 28), // Site ikon
                      SizedBox(width: 10),
                      Text(
                        site['name'],
                        style: TextStyle(
                          fontSize: 20,
                          color: Colors.black,
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 10),
                FutureBuilder<QuerySnapshot>(
                  future: FirebaseFirestore.instance
                      .collection('blocks')
                      .where('siteId', isEqualTo: site['id'])
                      .get(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return Center(child: CircularProgressIndicator());
                    }

                    if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 20),
                        child: Text('Bu siteye ait blok bulunamadı.'),
                      );
                    }

                    var blocks = snapshot.data!.docs;

                    return ListView.builder(
                      shrinkWrap: true,
                      physics: NeverScrollableScrollPhysics(),
                      itemCount: blocks.length,
                      itemBuilder: (context, blockIndex) {
                        var block = blocks[blockIndex];
                        return GestureDetector(
                          onTap: () {
                            // Blok cardına tıklandığında apartmentprofile.dart sayfasına gidiyoruz
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => ApartmentProfile(
                                  apartmentId: block.id,
                                  apartmentName: block["name"],
                                  id: widget.id
                                ),
                              ),
                            );
                          },
                          child: Card(
                            elevation: 2,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            color: Color(0xFF08FFFF).withOpacity(0.45),
                            margin: EdgeInsets.symmetric(vertical: 8),
                            child: ListTile(
                              contentPadding: EdgeInsets.all(16),
                              title: Text(
                                block['name'] ?? 'Blok Adı Bulunamadı',
                                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
                              ),
                            ),
                          ),
                        );
                      },
                    );
                  },
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
