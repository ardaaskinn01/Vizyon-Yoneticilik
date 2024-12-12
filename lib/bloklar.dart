import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'daireler.dart';

class BloklarScreen extends StatelessWidget {
  final String siteId; // Önceki widgettan gelen siteId

  const BloklarScreen({Key? key, required this.siteId}) : super(key: key);

  // Blok ekleme popup'ı
  void showAddBlockDialog(BuildContext context) {
    final TextEditingController blockNameController = TextEditingController();

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Blok Ekle'),
          content: TextField(
            controller: blockNameController,
            decoration: const InputDecoration(
              labelText: 'Blok İsmi',
            ),
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
                final String blockName = blockNameController.text.trim();

                if (blockName.isNotEmpty) {
                  // Firebase'e yeni blok ekleme
                  await FirebaseFirestore.instance.collection('blocks').add({
                    'name': blockName,
                    'siteId': siteId, // Gelen siteId'yi ekle
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

  // Blok silme popup'ı
  void showDeleteConfirmationDialog(BuildContext context, String blockId) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Blok Sil'),
          content: const Text('Bu bloğu silmek istediğinize emin misiniz?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context); // Popup'ı kapat
              },
              child: const Text('İptal'),
            ),
            ElevatedButton(
              onPressed: () async {
                // Firebase'den blok silme
                await FirebaseFirestore.instance.collection('blocks').doc(blockId).delete();
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
          'Bloklar',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.greenAccent,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('blocks')
            .where('siteId', isEqualTo: siteId) // Gelen siteId'ye göre filtreleme
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(
              child: Text('Henüz blok eklenmedi.'),
            );
          }

          final blocks = snapshot.data!.docs;

          return ListView.builder(
            itemCount: blocks.length,
            itemBuilder: (context, index) {
              final block = blocks[index];
              return GestureDetector(
                onLongPress: () {
                  showDeleteConfirmationDialog(context, block.id);
                },
                child: Card(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  elevation: 5,
                  margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                  child: ListTile(
                    title: Text(
                      block['name'],
                      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => DairelerScreen(
                            blockId: block.id,
                            blockName: block['name'],
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
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          showAddBlockDialog(context);
        },
        backgroundColor: Colors.greenAccent,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}
