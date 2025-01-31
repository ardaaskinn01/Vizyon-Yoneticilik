import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class DuyuruScreen extends StatefulWidget {
  final int id;
  final String siteId; // Site ID parametresi

  DuyuruScreen({required this.id, required this.siteId});

  @override
  _DuyuruScreenState createState() => _DuyuruScreenState();
}

class _DuyuruScreenState extends State<DuyuruScreen> {
  bool isLocked = false;

  // Kullanıcı izinlerini kontrol etme
  void checkPermissions() async {
    if (widget.id != 1) {
      setState(() {
        isLocked = false;
      });
      return;
    }

    User? currentUser = FirebaseAuth.instance.currentUser;

    if (currentUser != null) {
      DocumentSnapshot userPermissionsSnapshot = await FirebaseFirestore.instance
          .collection('users')
          .doc(currentUser.uid)
          .collection('izinler')
          .doc(widget.siteId)
          .get();

      if (userPermissionsSnapshot.exists) {
        var permissions = userPermissionsSnapshot.data() as Map<String, dynamic>;
        setState(() {
          isLocked = !permissions['duyuruSecili'];
        });
      } else {
        setState(() {
          isLocked = true;
        });
      }
    }
  }

  @override
  void initState() {
    super.initState();
    checkPermissions(); // İzinleri kontrol etmek için çağırıyoruz
  }

  // Duyuru Silme İşlemi
  void deleteAnnouncement(String announcementId) async {
    try {
      await FirebaseFirestore.instance
          .collection('announcements')
          .doc(announcementId)
          .delete();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Duyuru başarıyla silindi')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Duyuru silinirken bir hata oluştu')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        actions: [
          if (widget.id != 1)
            IconButton(
              icon: Icon(Icons.add),
              onPressed: () {
                showAnnouncementDialog(context);
              },
              color: Color(0xFFFF8805),
            ),
        ],
        backgroundColor: Colors.white,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('announcements')
            .where('siteId', isEqualTo: widget.siteId)
            .orderBy('date', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Center(
              child: isLocked
                  ? Icon(
                Icons.lock,
                color: Colors.grey,
                size: 100,
              )
                  : Text(
                'Hiç duyuru bulunamadı.',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black),
              ),
            );
          }

          var announcements = snapshot.data!.docs
              .where((announcement) => announcement['siteId'] == widget.siteId)
              .toList();

          return ListView.builder(
            padding: EdgeInsets.all(16),
            itemCount: announcements.length,
            itemBuilder: (context, index) {
              var announcement = announcements[index];
              Timestamp timestamp = announcement['date'];
              DateTime dateTime = timestamp.toDate();

              String formattedDate = '${dateTime.day.toString().padLeft(2, '0')}-${dateTime.month.toString().padLeft(2, '0')}-${dateTime.year}';
              if (isLocked && widget.id == 1) {
                return Center(
                  child: Icon(
                    Icons.lock,
                    color: Colors.grey,
                    size: 100,
                  ),
                );
              } else {
                var announcement = announcements[index];
                String announcementText = announcement['metin'];
                bool isLongText = announcementText.length > 100;
                String shortText = isLongText
                    ? announcementText.substring(0, 100) + '...'
                    : announcementText;

                String addedBy = announcement['ekleyen'] ?? 'Bilinmiyor';
                String announcementId = announcement.id; // Duyuru ID'sini alıyoruz

                return Card(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 8,
                  color: Color(0xFFFF8805).withOpacity(0.7),
                  margin: EdgeInsets.symmetric(vertical: 8),
                  child: ListTile(
                    contentPadding: EdgeInsets.all(16),
                    title: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded( // Announcement title Text wrapped with Expanded
                              child: Text(
                                announcement['başlık'],
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 20,
                                  color: Colors.black,
                                ),
                              ),
                            ),
                            Align( // Align widget used to align "addedBy" text to the right
                              alignment: Alignment.topRight,
                              child: Text(
                                addedBy,
                                style: TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black54,
                                ),
                              ),
                            ),
                          ],
                        ),
                        Text(
                          formattedDate,
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.black54,
                          ),
                        ),
                      ],
                    ),
                    subtitle: Text(
                      shortText,
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.white70,
                      ),
                    ),
                    trailing: isLongText
                        ? IconButton(
                      icon: Icon(
                        Icons.arrow_forward,
                        color: Colors.white,
                      ),
                      onPressed: () {
                        showDialog(
                          context: context,
                          builder: (context) {
                            return AlertDialog(
                              title: Text(
                                'Duyuru Metni',
                                style: TextStyle(color: Color(0xFF08FFFF)),
                              ),
                              content: Text(announcement['metin']),
                              actions: [
                                TextButton(
                                  onPressed: () {
                                    Navigator.pop(context);
                                  },
                                  child: Text(
                                    'Kapat',
                                    style: TextStyle(color: Color(0xFFFF8805)),
                                  ),
                                ),
                              ],
                            );
                          },
                        );
                      },
                    )
                        : null,
                    onLongPress: widget.id == 0
                        ? () {
                      showDialog(
                        context: context,
                        builder: (BuildContext context) {
                          return AlertDialog(
                            title: Text('Duyuru Sil'),
                            content: Text('Bu duyuruyu silmek istediğinizden emin misiniz?'),
                            actions: [
                              TextButton(
                                onPressed: () {
                                  Navigator.pop(context);
                                },
                                child: Text('Vazgeç'),
                              ),
                              TextButton(
                                onPressed: () {
                                  deleteAnnouncement(announcementId);
                                  Navigator.pop(context);
                                },
                                child: Text('Sil', style: TextStyle(color: Colors.red)),
                              ),
                            ],
                          );
                        },
                      );
                    }
                        : null,
                  ),
                );
              }
            },
          );
        },
      ),
    );
  }


  void showAnnouncementDialog(BuildContext context) {
    final TextEditingController announcementController = TextEditingController();
    final TextEditingController announcementController2 = TextEditingController();
    final user = FirebaseAuth.instance.currentUser;
    String? selectedApartment;
    List<String> apartmentList = [];

    FirebaseFirestore.instance.collection('site').get().then((querySnapshot) {
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
                            .collection('site')
                            .where('name', isEqualTo: selectedApartment)
                            .get();

                        if (apartmentSnapshot.docs.isNotEmpty) {
                          String apartmentId = apartmentSnapshot.docs.first.id;
                          final querySnapshot = await FirebaseFirestore.instance
                              .collection('users')
                              .where('apartmentId', isEqualTo: apartmentId)
                              .get();

                          for (var doc in querySnapshot.docs) {
                            final token = doc.id;
                            userTokens.add(token);
                          }
                        }

                        Timestamp timestamp = Timestamp.now();
                        await FirebaseFirestore.instance.collection('announcements').add({
                          'başlık': announcementController2.text.trim(),
                          'metin': announcementController.text.trim(),
                          'date': timestamp,
                          'ekleyen': user?.displayName ?? 'Bilinmiyor',
                          'apartman': selectedApartment,
                          'siteId': widget.siteId,
                        });

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
    const String appId = "your_app_id";
    const String restApiKey = "your_rest_api_key";

    for (String token in tokens) {
      final response = await http.post(
        Uri.parse(oneSignalApiUrl),
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Basic $restApiKey",
        },
        body: json.encode({
          "app_id": appId,
          "include_player_ids": [token],
          "headings": {"en": title},
          "contents": {"en": message},
        }),
      );

      if (response.statusCode == 200) {
        print('Bildirim başarıyla gönderildi');
      } else {
        print('Bildirim gönderilirken hata oluştu: ${response.body}');
      }
    }
  }
}
