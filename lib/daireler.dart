import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class DairelerScreen extends StatelessWidget {
  final String blockId; // Önceki widgettan gelen blockId
  final String blockName;
  const DairelerScreen({Key? key, required this.blockId, required this.blockName}) : super(key: key);

  // Daire ekleme popup'ı
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
                // Text alanının boş olmadığını ve yalnızca rakam içerdiğini kontrol edin
                final String inputText = apartmentNumberController.text.trim();
                if (inputText.isEmpty || int.tryParse(inputText) == null) {
                  // Kullanıcıya hatalı giriş için bir uyarı gösterin
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Lütfen geçerli bir daire numarası girin.')),
                  );
                  return;
                }

                // Giriş geçerli, tam sayıya dönüştürün
                final int apartmentNumber = int.parse(inputText);

                try {
                  // Firebase'e yeni daire ekleme
                  await FirebaseFirestore.instance
                      .collection('blocks')
                      .doc(blockId)
                      .collection('apartments')
                      .add({
                    'blockId': blockId,
                    'number': apartmentNumber,
                    'borçlar': 0, // Varsayılan borç miktarı
                  });

                  // İşlem başarılıysa, popup'ı kapatın
                  Navigator.pop(context);
                } catch (e) {
                  // Hata durumunda kullanıcıyı bilgilendirin
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

  // Daire silme popup'ı
  void showDeleteConfirmationDialog(BuildContext context, String apartmentId) {
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
                // Firebase'den daire silme
                await FirebaseFirestore.instance
                    .collection('blocks')
                    .doc(blockId)
                    .collection('apartments')
                    .doc(apartmentId)
                    .delete();
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
          'Daireler',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Color(0xFFFF8805), // Öne çıkan renk
        elevation: 0,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('blocks')
            .doc(blockId)
            .collection('apartments')
            .orderBy('number', descending: false) // Sıralama eklendi
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
              return GestureDetector(
                onLongPress: () {
                  showDeleteConfirmationDialog(context, apartment.id);
                },
                child: Card(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15), // Daha yuvarlak köşeler
                  ),
                  elevation: 10, // Daha belirgin gölge
                  margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                  color: Color(0xFFFF8805).withOpacity(0.2), // Öne çıkan renk
                  child: ListTile(
                    contentPadding: const EdgeInsets.all(16),
                    title: Text(
                      'Daire No: ${apartment['number']}',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                    subtitle: Text(
                      'Borç: ${apartment['borçlar']} TL',
                      style: const TextStyle(
                        fontSize: 16,
                        color: Colors.redAccent,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          showAddApartmentDialog(context);
        },
        backgroundColor: Color(0xFFFF8805), // Öne çıkan renk
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}
