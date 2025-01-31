import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class BlokSayfasi extends StatefulWidget {
  final String blockId;
  final String blockName;
  final String userId;

  BlokSayfasi({required this.blockId, required this.blockName, required this.userId});

  @override
  _BlokSayfasiState createState() => _BlokSayfasiState();
}

class _BlokSayfasiState extends State<BlokSayfasi> {
  List<Map<String, dynamic>> daireler = [];
  Map<String, bool> izinDurumlari = {};
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    getDaireler();
  }

  void getDaireler() async {
    try {
      // Bloktaki daireleri al
      QuerySnapshot snapshot = await FirebaseFirestore.instance
          .collection('blocks')
          .doc(widget.blockId)
          .collection('apartments')
          .orderBy('number')
          .get();

      // Kullanıcının ilgili block için izinlerini al veya oluştur
      DocumentReference izinlerRef = FirebaseFirestore.instance
          .collection('users')
          .doc(widget.userId)
          .collection('izinler')
          .doc(widget.blockId);

      DocumentSnapshot izinlerSnapshot = await izinlerRef.get();

      Map<String, dynamic> izinler = {};

      // Eğer izinler dokümanı yoksa varsayılan izinler oluştur
      if (!izinlerSnapshot.exists) {
        for (var doc in snapshot.docs) {
          String daireNo = doc['number'].toString();
          if (doc['number'] == 0) {
            // 'number' 0 ise 'name' değerini izinlere kaydet
            izinler[doc['name']] = false;
          } else {
            izinler[daireNo] = false; // Varsayılan olarak false
          }
        }
        await izinlerRef.set(izinler);
      } else {
        izinler = Map<String, dynamic>.from(izinlerSnapshot.data() as Map);
        // Eksik daire izinlerini doldur
        for (var doc in snapshot.docs) {
          String daireNo = doc['number'].toString();
          if (doc['number'] == 0) {
            String daireAdi = doc['name'];
            if (!izinler.containsKey(daireAdi)) {
              izinler[daireAdi] = false; // Varsayılan olarak false
            }
          } else if (!izinler.containsKey(daireNo)) {
            izinler[daireNo] = false; // Varsayılan olarak false
          }
        }
        await izinlerRef.set(izinler);
      }

      setState(() {
        daireler = snapshot.docs.map((doc) {
          return {
            'number': doc['number'],
            'name': doc['name'] ?? " ",
          };
        }).toList();
        izinDurumlari = Map<String, bool>.from(izinler);
        isLoading = false;
      });
    } catch (e) {
      print("Veri alınırken hata oluştu: $e");
      setState(() {
        isLoading = false;
      });
    }
  }

  void updateIzin(String key, bool izin) async {
    DocumentReference izinlerRef = FirebaseFirestore.instance
        .collection('users')
        .doc(widget.userId)
        .collection('izinler')
        .doc(widget.blockId);

    await izinlerRef.update({key: izin});

    setState(() {
      izinDurumlari[key] = izin;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "${widget.blockName}",
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        backgroundColor: Color(0xFFFF8805),  // AppBar rengi
        elevation: 8,  // Gölge efekti ekledik
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
        itemCount: daireler.length,
        itemBuilder: (context, index) {
          var daire = daireler[index];
          String daireNo = daire['number'].toString();
          return Card(
            margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12), // Yuvarlatılmış köşeler
            ),
            elevation: 5, // Kart gölgesi
            child: CheckboxListTile(
              contentPadding: const EdgeInsets.symmetric(horizontal: 16),
              title: Text(
                daire['number'] == 0
                    ? daire['name'] // Eğer 'number' 0 ise 'name' göster
                    : 'Daire ${daire['number']}', // Aksi halde 'number' göster
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFFFF8805), // Başlık rengi
                ),
              ),
              value: izinDurumlari[daire['number'] == 0 ? daire['name'] : daireNo],
              onChanged: (value) {
                updateIzin(daire['number'] == 0 ? daire['name'] : daireNo, value!);
              },
              activeColor: Color(0xFF08FFFF).withOpacity(0.5), // Onaylandığında renk
              checkColor: Colors.white, // Onay işareti rengi
              controlAffinity: ListTileControlAffinity.leading, // Checkbox solda
            ),
          );
        },
      ),
    );
  }
}
