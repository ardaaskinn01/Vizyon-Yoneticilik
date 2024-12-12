import 'package:apartman/daireyetkileri.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class YetkiVerme extends StatefulWidget {
  final String userId;

  YetkiVerme({required this.userId});

  @override
  _YetkiVermeState createState() => _YetkiVermeState();
}

class _YetkiVermeState extends State<YetkiVerme> {
  List<Map<String, dynamic>> sites = [];
  Map<String, bool> siteDuyuruSecili = {};
  Map<String, bool> siteHarcamaSecili = {};
  Map<String, List<Map<String, dynamic>>> bloklar = {};

  @override
  void initState() {
    super.initState();
    getSites();
    loadUserPermissions();
  }

  void loadUserPermissions() async {
    var izinlerSnapshot = await FirebaseFirestore.instance
        .collection('users')
        .doc(widget.userId)
        .collection('izinler')
        .get();

    for (var izinDoc in izinlerSnapshot.docs) {
      String siteId = izinDoc.id;
      var izinData = izinDoc.data();

      setState(() {
        siteDuyuruSecili[siteId] = izinData['duyuruSecili'] ?? false;
        siteHarcamaSecili[siteId] = izinData['harcamaSecili'] ?? false;
      });
    }
  }

  void getSites() async {
    QuerySnapshot siteSnapshot = await FirebaseFirestore.instance.collection('site').get();

    for (var siteDoc in siteSnapshot.docs) {
      String siteId = siteDoc.id;
      QuerySnapshot blokSnapshot = await FirebaseFirestore.instance
          .collection('blocks')
          .where('siteId', isEqualTo: siteId)
          .get();

      bloklar[siteId] = blokSnapshot.docs.map((blokDoc) {
        return {
          'id': blokDoc.id,
          'name': blokDoc['name'],
        };
      }).toList();
    }

    setState(() {
      sites = siteSnapshot.docs.map((doc) {
        return {
          'id': doc.id,
          'name': doc['name'],
        };
      }).toList();
    });
  }

  // Checkbox değerini Firebase'e kaydetme
  void savePermission(String siteId, bool duyuruSecili, bool harcamaSecili, String name) async {
    // Kullanıcının izinler koleksiyonuna siteId'yi ve ilgili izin değerlerini ekliyoruz.
    await FirebaseFirestore.instance
        .collection('users')
        .doc(widget.userId)
        .collection('izinler')
        .doc(siteId)
        .set({
      'duyuruSecili': duyuruSecili,
      'harcamaSecili': harcamaSecili,
      'siteName': name,
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Yetki Ver"),
        backgroundColor: Color(0xFFFF8805),
      ),
      body: ListView.builder(
        itemCount: sites.length,
        itemBuilder: (context, index) {
          var site = sites[index];
          String siteId = site['id'];
          return Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: EdgeInsets.symmetric(vertical: 10, horizontal: 20),
                  decoration: BoxDecoration(
                    color: Color(0xFFFF8805), // Başlık arka planı
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Row(
                    children: [
                      Text(
                        site['name'],
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Expanded( // Text ve Checkbox'ların düzgün yerleşebilmesi için Expanded kullanıldı
                        child: Column(
                          mainAxisSize: MainAxisSize.min, // Kolonun boyutunu minimume çekiyoruz
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            CheckboxListTile(
                              title: Text(
                                "Site Duyuru Panosu",
                                style: TextStyle(fontSize: 14),
                              ),
                              value: siteDuyuruSecili[siteId] ?? false, // Varsayılan olarak false
                              onChanged: (value) {
                                setState(() {
                                  siteDuyuruSecili[siteId] = value!;
                                });
                                // Değişiklikleri Firebase'e kaydedin
                                savePermission(siteId, siteDuyuruSecili[siteId]!, siteHarcamaSecili[siteId]!, site["name"]);
                              },
                              controlAffinity: ListTileControlAffinity.leading,
                              contentPadding: EdgeInsets.only(left: 30),
                            ),
                            CheckboxListTile(
                              title: Text(
                                "Site Harcama Listesi",
                                style: TextStyle(fontSize: 14),
                              ),
                              value: siteHarcamaSecili[siteId] ?? false,
                              onChanged: (value) {
                                setState(() {
                                  siteHarcamaSecili[siteId] = value!;
                                });
                                // Checkbox değeri değiştiğinde Firebase'e kaydediyoruz
                                savePermission(siteId, siteDuyuruSecili[siteId]!, siteHarcamaSecili[siteId]!, site["name"]);
                              },
                              controlAffinity: ListTileControlAffinity.leading,
                              contentPadding: EdgeInsets.only(left: 30),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                // Bloklar Listesi
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
                                builder: (context) => BlokSayfasi(
                                    blockId: block.id,
                                    blockName: block['name'],
                                    userId: widget.userId
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
                            margin: EdgeInsets.symmetric(vertical: 2),
                            child: ListTile(
                              contentPadding: EdgeInsets.only(left: 12),
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
