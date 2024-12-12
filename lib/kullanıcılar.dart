import 'package:apartman/yetkiler.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class KullanicilarEkrani extends StatefulWidget {
  @override
  _KullanicilarEkraniState createState() => _KullanicilarEkraniState();
}

class _KullanicilarEkraniState extends State<KullanicilarEkrani> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Kullanıcılar",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        backgroundColor: Color(0xFFFF8805), // Öne çıkan renk
        elevation: 0,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: _firestore.collection('users').snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text("Hata: ${snapshot.error}"));
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Center(child: Text("Kullanıcı bulunamadı."));
          }

          List<DocumentSnapshot> users = snapshot.data!.docs;

          return ListView.builder(
            itemCount: users.where((user) => user["role"] == "user").length,
            itemBuilder: (context, index) {
              var filteredUsers = users.where((user) => user["role"] == "user").toList();
              var user = filteredUsers[index];

              return GestureDetector(
                onLongPress: () => _showDeleteDialog(user.id),
                child: Card(
                  elevation: 6,
                  margin: const EdgeInsets.symmetric(horizontal: 6, vertical: 8),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15), // Yuvarlak köşeler
                  ),
                  color: Color(0xFF08FFFF).withOpacity(0.2), // Yumuşak arka plan rengi
                  child: ListTile(
                    contentPadding: const EdgeInsets.all(7),
                    title: Text(
                      "İsim: ${user['name']}",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // E-posta adresinden @example.com kısmını kırpıyoruz
                        Text("ID: ${user['email'].split('@')[0]}", style: TextStyle(color: Colors.grey[700])),
                        Text("Şifre: ${user['password']}", style: TextStyle(color: Colors.grey[700])),
                      ],
                    ),
                    trailing: IconButton(
                      icon: Icon(Icons.add_moderator, color: Color(0xFFFF8805)),
                      onPressed: () {
                        // Yetki verme ekranına yönlendirme
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => YetkiVerme(userId: user.id),
                          ),
                        );
                      },
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddUserDialog,
        backgroundColor: Color(0xFFFF8805), // Floating button rengi
        child: Icon(Icons.person_add, color: Colors.white),
      ),
    );
  }


// Kullanıcı ekleme dialog
  void _showAddUserDialog() {
    final TextEditingController _nameController = TextEditingController();
    final TextEditingController _idController = TextEditingController();
    final TextEditingController _passwordController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text("Kullanıcı Ekle"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: _nameController,
                decoration: InputDecoration(labelText: "İsim"),
              ),
              TextField(
                controller: _idController,
                decoration: InputDecoration(labelText: "ID"),
              ),
              TextField(
                controller: _passwordController,
                decoration: InputDecoration(labelText: "Şifre"),
                obscureText: true,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text("İptal"),
            ),
            ElevatedButton(
              onPressed: () async {
                final name = _nameController.text;
                final id = _idController.text;
                final password = _passwordController.text;

                final email = '$id@example.com';

                UserCredential userCredential =
                await FirebaseAuth.instance.createUserWithEmailAndPassword(
                  email: email,
                  password: password,
                );

                final userId = userCredential.user!.uid;

                DocumentReference userRef =
                FirebaseFirestore.instance.collection('users').doc(userId);

                if (name.isNotEmpty && id.isNotEmpty && password.isNotEmpty) {
                  await userRef.set({
                    'name': name,
                    'email': email,
                    'password': password,
                    'role': "user",
                  });
                  Navigator.pop(context);
                }
              },
              child: Text("Ekle"),
            ),
          ],
        );
      },
    );
  }

// Kullanıcı silme dialog
  void _showDeleteDialog(String userId) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text("Kullanıcı Sil"),
          content: Text("Bu kullanıcıyı silmek istediğinizden emin misiniz?"),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text("İptal"),
            ),
            ElevatedButton(
              onPressed: () async {
                await _firestore.collection('users').doc(userId).delete();
                Navigator.pop(context);
              },
              child: Text("Sil"),
            ),
          ],
        );
      },
    );
  }
}
