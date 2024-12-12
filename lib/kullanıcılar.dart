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
        title: Text("Kullanıcılar"),
        centerTitle: true,
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
                  elevation: 5,
                  margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  child: ListTile(
                    title: Text("İsim: ${user['name']}"),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text("ID: ${user['email']}"),
                        Text("Şifre: ${user['password']}"),
                      ],
                    ),
                    trailing: IconButton(
                      icon: Icon(Icons.add_moderator, color: Colors.orange),
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
        child: Icon(Icons.person_add),
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
