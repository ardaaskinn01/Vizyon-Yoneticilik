import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class DairelerScreen extends StatelessWidget {
  final String blockId;
  final String blockName;

  const DairelerScreen({Key? key, required this.blockId, required this.blockName}) : super(key: key);

  // String ifade ekleme popup'ı
  void showAddSpecialApartmentDialog(BuildContext context) {
    final TextEditingController specialNoteController = TextEditingController();

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Kapıcı/Dükkan Ekle'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: specialNoteController,
                decoration: const InputDecoration(
                  labelText: 'İsim',
                ),
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
                final specialNote = specialNoteController.text.trim();

                if (specialNote.isNotEmpty) {
                  try {
                    await FirebaseFirestore.instance
                        .collection('blocks')
                        .doc(blockId)
                        .collection('apartments')
                        .add({
                      'blockId': blockId,
                      'number': 0, // Varsayılan bir numara
                      'borçlar': 0, // Varsayılan borç miktarı
                      'name': specialNote, // Özel not
                    });

                    Navigator.pop(context); // Popup'ı kapat
                  } catch (e) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Daire eklenirken bir hata oluştu.')),
                    );
                  }
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Lütfen bir not girin.')),
                  );
                }
              },
              child: const Text('Kaydet'),
            ),
          ],
        );
      },
    );
  }

  // Daire ekleme popup'ı (Numaralı)
  void showAddApartmentDialog(BuildContext context) {
    final TextEditingController apartmentNumberController = TextEditingController();

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Daire Ekle'),
          content: TextField(
            controller: apartmentNumberController,
            decoration: const InputDecoration(
              labelText: 'Daire Numarası',
            ),
            keyboardType: TextInputType.number,
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
                final String inputText = apartmentNumberController.text.trim();
                if (inputText.isEmpty || int.tryParse(inputText) == null) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Lütfen geçerli bir daire numarası girin.')),
                  );
                  return;
                }

                final int apartmentNumber = int.parse(inputText);

                try {
                  await FirebaseFirestore.instance
                      .collection('blocks')
                      .doc(blockId)
                      .collection('apartments')
                      .add({
                    'blockId': blockId,
                    'number': apartmentNumber,
                    'borçlar': 0,
                    'name': ""
                  });

                  Navigator.pop(context);
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Daire eklenirken bir hata oluştu.')),
                  );
                }
              },
              child: const Text('Kaydet'),
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
          'Daireler',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Color(0xFFFF8805),
        elevation: 0,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('blocks')
            .doc(blockId)
            .collection('apartments')
            .orderBy('number', descending: false) // Numaralar sıralı
            .snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(
              child: Text(
                'Henüz daire eklenmedi.',
                style: TextStyle(fontSize: 18, color: Colors.grey),
              ),
            );
          }

          final apartments = snapshot.data!.docs;

          return ListView.builder(
            itemCount: apartments.length,
            itemBuilder: (context, index) {
              final apartment = apartments[index];
              return Card(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
                elevation: 10,
                margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
                color: apartment['number'] == 0
                    ? Colors.amber.withOpacity(0.6) // Özel daire rengi
                    : Color(0xFFFF8805).withOpacity(0.6),
                child: ListTile(
                  contentPadding: const EdgeInsets.only(left: 16),
                  title: Text(
                    apartment['number'] == 0
                        ? '${apartment['name']}' // Eğer 'number' 0 ise 'name' göster
                        : 'Daire No: ${apartment['number']}', // Aksi halde 'number' göster
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                  subtitle: Text(
                    'Borç: ${apartment['borçlar']} TL',
                    style: const TextStyle(fontSize: 16, color: Colors.red),
                  ),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          FloatingActionButton(
            heroTag: 'addNumber',
            onPressed: () {
              showAddApartmentDialog(context);
            },
            backgroundColor: Color(0xFFFF8805),
            child: const Icon(Icons.add_home, color: Colors.white),
          ),
          const SizedBox(height: 10),
          FloatingActionButton(
            heroTag: 'addSpecial',
            onPressed: () {
              showAddSpecialApartmentDialog(context);
            },
            backgroundColor: Colors.amber,
            child: const Icon(Icons.add_business, color: Colors.white),
          ),
        ],
      ),
    );
  }
}
