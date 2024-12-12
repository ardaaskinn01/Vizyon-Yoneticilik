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
          title: const Text('Site Ekle'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: const InputDecoration(
                  labelText: 'Site Adı',
                ),
              ),
              TextField(
                controller: numController,
                decoration: const InputDecoration(
                  labelText: 'Site Numarası',
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
              child: const Text('İptal'),
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
          title: const Text('Silmek İstediğinize Emin misiniz?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context); // Popup'ı kapat
              },
              child: const Text('İptal'),
            ),
            ElevatedButton(
              onPressed: () async {
                // Firebase'den site silme
                await FirebaseFirestore.instance.collection('site').doc(siteId).delete();
                Navigator.pop(context); // Popup'ı kapat
              },
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
        backgroundColor: Colors.blueAccent,
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
        backgroundColor: Colors.blueAccent,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}
