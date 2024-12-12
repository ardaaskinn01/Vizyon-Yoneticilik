/* void showAddApartmentDialog(BuildContext context) {
  final TextEditingController apartmentNameController = TextEditingController();
  final TextEditingController apartmentNumberController = TextEditingController();

  showDialog(
    context: context,
    builder: (context) {
      return Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        elevation: 16,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Yeni Apartman Ekle',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 20),
              TextField(
                controller: apartmentNameController,
                decoration: InputDecoration(labelText: 'Apartman İsmi'),
              ),
              TextField(
                controller: apartmentNumberController,
                decoration: InputDecoration(labelText: 'Apartman Numarası'),
                keyboardType: TextInputType.number,
              ),
              SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: Text('İptal'),
                  ),
                  ElevatedButton(
                    onPressed: () async {
                      // Firebase'e apartman bilgilerini ekleyin
                      await FirebaseFirestore.instance.collection('apartments').add({
                        'name': apartmentNameController.text.trim(),
                        'num': int.tryParse(apartmentNumberController.text) ?? 0, // text'i int'e dönüştür
                        'toplamBorç': 0,
                      });

                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Apartman başarıyla eklendi.')),
                      );
                    },
                    child: Text('Ekle'),
                  ),
                ],
              ),
            ],
          ),
        ),
      );
    },
  );
}

void showAddUserDialog(BuildContext context, String apartmentId, int apartmentNum) async {
  final TextEditingController usernameController = TextEditingController();
  final TextEditingController nameController = TextEditingController();
  final TextEditingController daireController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  showDialog(
    context: context,
    builder: (context) {
      return StatefulBuilder(
        builder: (context, setState) {
          return Dialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            elevation: 16,
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Yeni Kullanıcı Ekle',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 20),
                  TextField(
                    controller: nameController,
                    decoration: InputDecoration(labelText: 'İsim'),
                  ),
                  TextField(
                    controller: usernameController,
                    decoration: InputDecoration(labelText: 'Kullanıcı Adı'),
                  ),
                  TextField(
                    controller: passwordController,
                    decoration: InputDecoration(labelText: 'Şifre'),
                    obscureText: true,
                  ),
                  TextField(
                    controller: daireController,
                    decoration: InputDecoration(labelText: 'Daire No'),
                    keyboardType: TextInputType.number,
                  ),
                  SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: Text('İptal'),
                      ),
                      ElevatedButton(
                        onPressed: () {
                          addUserWithDebt(
                            nameController.text.trim(),
                            int.tryParse(daireController.text.trim()) ?? 0,
                            usernameController.text.trim(),
                            passwordController.text.trim(),
                            apartmentId,  // ApartmanId'yi burada kullanıyoruz
                            apartmentNum,  // Apartman numarasını da kullanıyoruz
                            context,
                          );
                          Navigator.pop(context);
                        },
                        child: Text('Ekle'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        },
      );
    },
  );
}

void showAnnouncementDialog(BuildContext context) {
  final TextEditingController announcementController = TextEditingController();
  final TextEditingController announcementController2 = TextEditingController();
  final user = FirebaseAuth.instance.currentUser;
  String? selectedApartment; // Seçilen apartman
  List<String> apartmentList = []; // Apartman listesi

  // Firestore'dan apartman isimlerini çek
  FirebaseFirestore.instance.collection('apartments').get().then((querySnapshot) {
    apartmentList = querySnapshot.docs.map((doc) => doc['name'] as String).toList();
  });

  showDialog(
    context: context,
    builder: (context) {
      return Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        elevation: 16,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Yeni Duyuru Paylaş',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 20),
              DropdownButtonFormField<String>(
                value: selectedApartment,
                items: apartmentList
                    .map((apartment) => DropdownMenuItem(
                  value: apartment,
                  child: Text(apartment),
                ))
                    .toList(),
                onChanged: (value) {
                  selectedApartment = value;
                },
                decoration: InputDecoration(labelText: 'Apartman Seç'),
              ),
              SizedBox(height: 25),
              TextField(
                controller: announcementController2,
                decoration: InputDecoration(labelText: 'Duyuru Başlığı'),
                maxLines: 1,
              ),
              SizedBox(height: 25),
              TextField(
                controller: announcementController,
                decoration: InputDecoration(labelText: 'Duyuru Metni'),
                maxLines: 8,
              ),
              SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  TextButton(
                    style: ElevatedButton.styleFrom(
                      foregroundColor: Colors.white,
                      backgroundColor: Color(0xFFFF8805),
                    ),
                    onPressed: () => Navigator.pop(context),
                    child: Text('İptal'),
                  ),
                  ElevatedButton(
                    onPressed: () async {
                      if (selectedApartment == null) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Lütfen bir apartman seçin.')),
                        );
                        return;
                      }

                      final List<String> userTokens = [];
                      final apartmentSnapshot = await FirebaseFirestore.instance
                          .collection('apartments')
                          .where('name', isEqualTo: selectedApartment) // apartman adı
                          .get();

                      if (apartmentSnapshot.docs.isNotEmpty) {
                        // Apartman bulundu, ID'yi alalım
                        String apartmentId = apartmentSnapshot.docs.first.id;
                        print(apartmentId);
                        // Ardından, bu apartmentId ile kullanıcıları sorgulayalım
                        final querySnapshot = await FirebaseFirestore.instance
                            .collection('users')
                            .where('apartmentId', isEqualTo: apartmentId) // apartmentId'yi kullanıyoruz
                            .get();

                        for (var doc in querySnapshot.docs) {
                          final token = doc.id;
                          userTokens.add(token);
                          print("userTokens: $userTokens");
                        }
                      } else {
                        print("Apartment not found.");
                      }
                      final now = DateTime.now();
                      await FirebaseFirestore.instance.collection('announcements').add({
                        'başlık': announcementController2.text.trim(),
                        'metin': announcementController.text.trim(),
                        'tarih': '${now.day}/${now.month}/${now.year}',
                        'ekleyen': user?.displayName ?? 'Bilinmiyor',
                        'apartman': selectedApartment,
                      });

                      // OneSignal API ile bildirim gönder
                      await sendNotificationToUsers(
                        userTokens,
                        announcementController2.text.trim(),
                        announcementController.text.trim(),
                      );

                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Duyuru başarıyla paylaşıldı.')),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      foregroundColor: Colors.white,
                      backgroundColor: Color(0xFFFF8805),
                    ),
                    child: Text('Paylaş'),
                  ),
                ],
              ),
            ],
          ),
        ),
      );
    },
  );
}

Future<void> sendNotificationToUsers(List<String> tokens, String title, String message) async {
  const String oneSignalApiUrl = "https://onesignal.com/api/v1/notifications";
  const String appId = "402eedf4-e7b6-48df-9941-fbfcdc9362dc"; // OneSignal App ID
  const String restApiKey = "os_v2_app_iaxo35hhwzen7gkb7p6nze3c3q7vf7oswp2edhnry3mf7r2whe753txc3ai63wqhamegsneit5to6lnhzebkqtp4befnsv3z2zb3x2i"; // OneSignal REST API Key
  List<String> validTokens = tokens.where((token) => token.isNotEmpty).toList();
  print("tokens: $validTokens");
  // Header tanımlaması
  final headers = {
    "Content-Type": "application/json; charset=utf-8",
    "Authorization": "Basic $restApiKey",
  };

  // Body oluşturma
  final body = jsonEncode({
    "app_id": appId,
    "target_channel": "push",
    "contents": {
      "en": message, // İngilizce mesaj
    },
    "headings": {
      "en": title, // Bildirim başlığı
    },
    "include_aliases": {
      "external_id": [
        "8fU0nICvweQt2X6x4dSwEuco4G23"
      ]
    }
  });

  try {
    // HTTP POST isteği
    final response = await http.post(
      Uri.parse(oneSignalApiUrl),
      headers: headers,
      body: body,
    );

    // Duruma göre çıktılar
    if (response.statusCode == 200) {
      print("Bildirim başarıyla gönderildi: ${response.body}");
    } else {
      print("Bildirim gönderilirken hata oluştu: ${response.body}");
    }
  } catch (e) {
    print("Bildirim gönderme sırasında bir hata oluştu: $e");
  }
}

void addUserWithDebt(
    String name,
    int daire,
    String username,
    String password,
    String apartmentId,
    int apartmentNum,
    BuildContext context) async {
  try {
    final email = '$username@example.com';

    // Firebase Authentication ile kullanıcı oluştur
    UserCredential userCredential =
    await FirebaseAuth.instance.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );

    final userId = userCredential.user!.uid;
    const appId = "402eedf4-e7b6-48df-9941-fbfcdc9362dc";
    const apiKey = "7vf7oswp2edhnry3mf7r2whe7";

    // Kullanıcı Firestore'a ekleniyor
    DocumentReference userRef =
    FirebaseFirestore.instance.collection('users').doc(userId);
    DocumentReference userRef2 =
    FirebaseFirestore.instance.collection('apartments').doc(apartmentId);

    await userRef.set({
      'name': name,
      'daireno': daire,
      'username': username,
      'email': email,
      'role': 'user',
      'apartmentId': apartmentId,
    });

    await userRef2.collection('daireler').doc(userId).set({
      'name': name,
      'daireno': daire,
      'toplamBorç': 0,
      'userId': userId,
    });

    // Apartmanın toplam borcunu güncelle
    DocumentReference apartmentRef =
    FirebaseFirestore.instance.collection('apartments').doc(apartmentId);
    DocumentSnapshot apartmentSnapshot = await apartmentRef.get();

    Map<String, dynamic> apartmentData =
    apartmentSnapshot.data() as Map<String, dynamic>;
    int currentDebt = (apartmentData['toplamBorç'] ?? 0).toInt();

    await apartmentRef.update({'toplamBorç': currentDebt + 0});
    await calculateTotalDebt(apartmentId);

    await userCredential.user!.updateDisplayName(name);

    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Kullanıcı başarıyla eklendi.')),
      );
    }
  } catch (e) {
    print('Hata: ${e.toString()}');

    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Kullanıcı eklenirken hata oluştu: ${e.toString()}')),
      );
    }
  }
}

Future<void> calculateTotalDebt(String apartmentId) async {
  QuerySnapshot userSnapshot = await FirebaseFirestore.instance
      .collection('users')
      .where('apartmentId', isEqualTo: apartmentId)
      .get();

  int totalDebt = 0;

  for (var userDoc in userSnapshot.docs) {
    QuerySnapshot debtSnapshot =
    await userDoc.reference.collection('borçlar').get();

    for (var debtDoc in debtSnapshot.docs) {
      // Veriyi Map<String, dynamic> türüne dönüştür
      var debtData = debtDoc.data() as Map<String, dynamic>;

      // Eğer borç miktarı varsa, toplam borca ekle
      totalDebt += (debtData['amount'] ?? 0) as int;
    }
  }

  // Apartmanın toplam borç miktarını güncelle
  await FirebaseFirestore.instance.collection('apartments').doc(apartmentId).update({
    'toplamBorç': totalDebt,
  });
} */