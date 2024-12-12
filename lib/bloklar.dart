import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'daireler.dart';

class BloklarScreen extends StatelessWidget {
  final String siteId;

  const BloklarScreen({Key? key, required this.siteId}) : super(key: key);

  void showAddBlockDialog(BuildContext context) {
    final TextEditingController blockNameController = TextEditingController();

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Blok Ekle', style: TextStyle(color: Color(0xFF08FFFF))),
          content: TextField(
            controller: blockNameController,
            decoration: const InputDecoration(
              labelText: 'Blok İsmi',
              labelStyle: TextStyle(color: Color(0xFF08FFFF)),
              focusedBorder: UnderlineInputBorder(
                borderSide: BorderSide(color: Color(0xFF08FFFF)),
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('İptal', style: TextStyle(color: Color(0xFF08FFFF))),
            ),
            ElevatedButton(
              onPressed: () async {
                final String blockName = blockNameController.text.trim();
                if (blockName.isNotEmpty) {
                  await FirebaseFirestore.instance.collection('blocks').add({
                    'name': blockName,
                    'siteId': siteId,
                  });
                  Navigator.pop(context);
                }
              },
              child: const Text('Kaydet'),
              style: ElevatedButton.styleFrom(backgroundColor: Color(0xFF08FFFF)),
            ),
          ],
        );
      },
    );
  }

  void showDeleteConfirmationDialog(BuildContext context, String blockId) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Blok Sil', style: TextStyle(color: Color(0xFF08FFFF))),
          content: const Text('Bu bloğu silmek istediğinize emin misiniz?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('İptal', style: TextStyle(color: Color(0xFF08FFFF))),
            ),
            ElevatedButton(
              onPressed: () async {
                await FirebaseFirestore.instance.collection('blocks').doc(blockId).delete();
                Navigator.pop(context);
              },
              child: const Text('Sil'),
              style: ElevatedButton.styleFrom(backgroundColor: Color(0xFF08FFFF)),
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
          style: TextStyle(color: Colors.black),
        ),
        backgroundColor: Color(0xFF08FFFF),
        elevation: 0,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('blocks')
            .where('siteId', isEqualTo: siteId)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(
              child: Text('Henüz blok eklenmedi.', style: TextStyle(fontSize: 18)),
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
                  color: Color(0xFF08FFFF).withOpacity(0.5),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                  elevation: 4,
                  margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                  child: ListTile(
                    contentPadding: const EdgeInsets.symmetric(vertical: 15, horizontal: 20),
                    title: Text(
                      block['name'],
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
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
        backgroundColor: Color(0xFFFF8805).withOpacity(0.8),
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}
