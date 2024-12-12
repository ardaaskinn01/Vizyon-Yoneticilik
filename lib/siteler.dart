import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'bloklar.dart'; // Bloklar ekranını göstermek için

class SitelerScreen extends StatelessWidget {
  const SitelerScreen({Key? key}) : super(key: key);

  // Site ekleme popup'ı
  void showAddSiteDialog(BuildContext context) {
    final TextEditingController nameController = TextEditingController();
    final TextEditingController numController = TextEditingController();

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Colors.white,
          title: const Text(
            'Site Ekle',
            style: TextStyle(color: Color(0xFFFF8805)),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: const InputDecoration(
                  labelText: 'Site Adı',
                  focusedBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: Color(0xFFFF8805)),
                  ),
                ),
              ),
              TextField(
                controller: numController,
                decoration: const InputDecoration(
                  labelText: 'Site Numarası',
                  focusedBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: Color(0xFFFF8805)),
                  ),
                ),
                keyboardType: TextInputType.number,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context); // Popup'ı kapat
              },
              child: const Text(
                'İptal',
                style: TextStyle(color: Color(0xFFFF8805)),
              ),
            ),
            ElevatedButton(
              onPressed: () async {
                final String siteName = nameController.text.trim();
                final String siteNum = numController.text.trim();

                if (siteName.isNotEmpty && siteNum.isNotEmpty) {
                  // Firebase'e yeni site ekleme
                  await FirebaseFirestore.instance.collection('site').add({
                    'name': siteName,
                    'num': siteNum,
                  });
                  Navigator.pop(context); // Popup'ı kapat
                }
              },
              style: ElevatedButton.styleFrom(
                foregroundColor: Colors.white, backgroundColor: Color(0xFFFF8805),
              ),
              child: const Text('Kaydet'),
            ),
          ],
        );
      },
    );
  }

  // Site silme popup'ı
  void showDeleteConfirmationDialog(BuildContext context, String siteId) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Colors.white,
          title: const Text(
            'Silmek İstediğinize Emin misiniz?',
            style: TextStyle(color: Color(0xFFFF8805)),
          ),
          content: const Text(
            'Bu siteyi silmek istediğinizden emin misiniz?',
            style: TextStyle(color: Colors.black54),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context); // Popup'ı kapat
              },
              child: const Text(
                'İptal',
                style: TextStyle(color: Color(0xFFFF8805)),
              ),
            ),
            ElevatedButton(
              onPressed: () async {
                // Firebase'den site silme
                await FirebaseFirestore.instance.collection('site').doc(siteId).delete();
                Navigator.pop(context); // Popup'ı kapat
              },
              style: ElevatedButton.styleFrom(
                foregroundColor: Colors.white, backgroundColor: Color(0xFFFF8805),
              ),
              child: const Text('Sil'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Siteler',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Color(0xFFFF8805),
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
                onLongPress: () {
                  showDeleteConfirmationDialog(context, site.id);
                },
                child: Card(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                  elevation: 5,
                  margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                  color: Color(0xFFFF8805).withOpacity(0.8),
                  child: ListTile(
                    contentPadding: const EdgeInsets.all(16),
                    title: Text(
                      site['name'],
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    subtitle: Text(
                      'Site No: ${site['num']}',
                      style: const TextStyle(
                        color: Colors.black54,
                      ),
                    ),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => BloklarScreen(siteId: site.id),
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
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          showAddSiteDialog(context);
        },
        backgroundColor: Color(0xFF08FFFF).withOpacity(0.8),
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}
