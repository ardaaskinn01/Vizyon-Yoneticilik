import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ApartmentProfile extends StatefulWidget {
  final String apartmentId;
  final String apartmentName;
  final int id;

  ApartmentProfile(
      {required this.apartmentId,
      required this.apartmentName,
        required this.id
      });

  @override
  _ApartmentProfileState createState() => _ApartmentProfileState();
}

class _ApartmentProfileState extends State<ApartmentProfile> {
  List<String> selectedUserIds = [];

  void _showAddDebtDialogForSelectedUsers() {
    final _amountController = TextEditingController();
    final _descriptionController = TextEditingController();

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Seçilen Kullanıcılara Borç Ekle"),
          content: StatefulBuilder(
            builder: (context, setState) {
              return Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: _amountController,
                    decoration: InputDecoration(labelText: 'Miktar'),
                    keyboardType: TextInputType.number,
                  ),
                  SizedBox(height: 10),
                  TextField(
                    controller: _descriptionController,
                    decoration: InputDecoration(labelText: 'Açıklama'),
                    keyboardType: TextInputType.text,
                    maxLines: 3,
                  ),
                  SizedBox(height: 10),
                ],
              );
            },
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Vazgeç'),
            ),
            TextButton(
              onPressed: () async {
                final amount = double.tryParse(_amountController.text);
                final description = _descriptionController.text;

                if (amount != null && description.isNotEmpty) {
                  for (var userId in selectedUserIds) {
                    await _addDebtForSingleUser(
                        userId, description, amount);
                  }
                }
                Navigator.of(context).pop();
              },
              child: Text('Ekle'),
            ),
          ],
        );
      },
    );
  }


  void _showAddDebtDialog({
    required String userId,
    required bool isForAllUsers,
  }) {
    final _amountController = TextEditingController(); // Miktar için kontrolcü
    final _descriptionController =
        TextEditingController(); // Açıklama için kontrolcü

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title:
              Text(isForAllUsers ? "Tüm Kullanıcılara Borç Ekle" : "Borç Ekle"),
          content: StatefulBuilder(
            builder: (context, setState) {
              return Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: _amountController,
                    decoration: InputDecoration(labelText: 'Miktar'),
                    keyboardType: TextInputType.number,
                  ),
                  SizedBox(height: 10),
                  TextField(
                    controller: _descriptionController,
                    decoration: InputDecoration(labelText: 'Açıklama'),
                    keyboardType: TextInputType.text,
                    maxLines: 3,
                  ),
                  SizedBox(height: 10),
                ],
              );
            },
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Vazgeç'),
            ),
            TextButton(
              onPressed: () async {
                final amount = double.tryParse(_amountController.text);
                final description = _descriptionController.text;

                if (amount != null && description.isNotEmpty) {
                  if (isForAllUsers) {
                    // Tüm kullanıcılara borç ekleme
                    await _addDebtToAllUsers(
                        description, amount);
                  } else {
                    // Tek bir kullanıcıya borç ekleme
                    await _addDebtForSingleUser(userId, description, amount);
                  }

                  _amountController.clear();
                  _descriptionController.clear();
                  Navigator.of(context).pop();
                }
              },
              child: Text('Ekle'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _addDebtForSingleUser(String userId, String description,
      double amount) async {
    await FirebaseFirestore.instance
        .collection('blocks')
        .doc(widget.apartmentId)
        .collection('apartments')
        .doc(userId)
        .collection('borçlar')
        .add({
      'amount': amount,
      'description': description,
    });

    // Tek kullanıcı için toplam borcu güncelle
    await _updateTotalDebt();
    setState(() {});
  }


  Future<void> _addDebtToAllUsers(
      String description, double amount) async {
    final usersSnapshot = await FirebaseFirestore.instance
        .collection('blocks')
        .doc(widget.apartmentId)
        .collection('apartments')
        .where('blockId', isEqualTo: widget.apartmentId)
        .get();

    for (var userDoc in usersSnapshot.docs) {
      final userId = userDoc.id;

      await FirebaseFirestore.instance
          .collection('blocks')
          .doc(widget.apartmentId)
          .collection('apartments')
          .doc(userId)
          .collection('borçlar')
          .add({
        'amount': amount,
        'description': description,
      });
    }


    // Tüm kullanıcılar için toplam borcu güncelle
    await _updateTotalDebt();
    setState(() {});
  }

  void _deleteDebt(String userId, String debtId) async {
    await FirebaseFirestore.instance
        .collection('blocks')
        .doc(widget.apartmentId)
        .collection('apartments')
        .doc(userId)
        .collection('borçlar')
        .doc(debtId)
        .delete();

    // Borçların toplamını yeniden hesapla ve güncelle
    await _updateTotalDebt(); // Apartmanın toplam borcunu güncelle
    setState(() {}); // Listeyi güncellemek için setState
  }


  // Apartmanın toplam borcunu güncelleme
  Future<void> _updateTotalDebt() async {
    final usersSnapshot = await FirebaseFirestore.instance
        .collection('blocks')
        .doc(widget.apartmentId)
        .collection('apartments')
        .where('blockId', isEqualTo: widget.apartmentId)
        .get();

    double totalDebt = 0.0;

    for (var userDoc in usersSnapshot.docs) {
      final userId = userDoc.id;

      // Her kullanıcı için borçları al ve toplamı hesapla
      final debtSnapshot = await FirebaseFirestore.instance
          .collection('blocks')
          .doc(widget.apartmentId)
          .collection('apartments')
          .doc(userId)
          .collection('borçlar')
          .get();

      double userTotalDebt = 0.0;
      List<Map<String, dynamic>> debts = [];

      for (var doc in debtSnapshot.docs) {
        double amount = (doc['amount'] is int)
            ? (doc['amount'] as int).toDouble()
            : doc['amount'];
        debts.add({
          'id': doc.id, // Borcun ID'sini ekliyoruz
          'amount': amount,
        });
        userTotalDebt += amount; // Kullanıcının toplam borcunu hesapla
      }

      // Kullanıcının toplam borcunu apartments içindeki dökümanda güncelle
      await FirebaseFirestore.instance
          .collection('blocks')
          .doc(widget.apartmentId)
          .collection('apartments')
          .doc(userId)
          .update({'borçlar': userTotalDebt});

      totalDebt += userTotalDebt; // Genel toplam borcu hesapla
    }
  }

  Future<List<Map<String, dynamic>>> _getUserDebts(String userId) async {
    final debtSnapshot = await FirebaseFirestore.instance
        .collection('blocks')
        .doc(widget.apartmentId)
        .collection('apartments')
        .doc(userId)
        .collection('borçlar')
        .get();

    List<Map<String, dynamic>> debts = [];
    double totalDebt = 0.0;

    for (var doc in debtSnapshot.docs) {
      double amount = (doc['amount'] is int)
          ? (doc['amount']).toDouble()
          : doc['amount'];
      debts.add({
        'id': doc.id, // Borcun ID'sini ekliyoruz
        'amount': amount,
        'description': doc["description"],
      });
      totalDebt += amount; // Toplam borç miktarını ekle
    }
    return debts;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.apartmentName,
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Color(0xFF08FFFF), // Belirtilen renk
      ),
      body: Column(
        children: [
          // Kaydırılabilir içerik alanı
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('blocks')
                  .doc(widget.apartmentId)
                  .collection("apartments")
                  .where('blockId', isEqualTo: widget.apartmentId)
                  .snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return Center(
                    child: Text(
                      'Bu apartmanda kullanıcı yok.',
                      style: TextStyle(fontSize: 16, color: Colors.grey),
                    ),
                  );
                }

                final users = snapshot.data!.docs;

                users.sort((a, b) {
                  int daireNoA = (a['number']);
                  int daireNoB = (b['number']);
                  return daireNoA.compareTo(daireNoB);
                });

                return ListView.builder(
                  itemCount: users.length,
                  itemBuilder: (context, index) {
                    User? currentUser = FirebaseAuth.instance.currentUser;
                    final user = users[index];
                    final userId = currentUser!.uid;
                    final userId2 = user.id;
                    final daireNumber = user['number'].toString();

                    return FutureBuilder<DocumentSnapshot>(
                      future: FirebaseFirestore.instance
                          .collection('users')
                          .doc(userId)
                          .collection('izinler')
                          .doc(widget.apartmentId)
                          .get(),
                      builder: (context, permissionSnapshot) {
                        if (permissionSnapshot.hasError) {
                          return Card(
                            margin: EdgeInsets.symmetric(vertical: 10, horizontal: 15),
                            elevation: 8,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20),
                            ),
                            color: Color(0xFF08FFFF).withOpacity(0.2),
                            child: ListTile(
                              title: Text(
                                user['number'] == 0
                                    ? '${user['name']}' // Eğer 'number' 0 ise 'name' göster
                                    : 'Daire ${user['number']}',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                  color: Colors.black,
                                ),
                              ),
                              subtitle: Text('İzin durumu kontrol edilemedi.'),
                            ),
                          );
                        }

                        // Admin kontrolü
                        bool isAdmin = widget.id == 1;
                        final permissionData = permissionSnapshot.data?.data() as Map<String, dynamic>?;
                        final hasPermission = isAdmin || permissionData?[daireNumber] == true;

                        return Card(
                          margin: EdgeInsets.symmetric(vertical: 10, horizontal: 15),
                          elevation: 8,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                          color: Color(0xFF08FFFF).withOpacity(0.2),
                          child: GestureDetector(
                            onLongPress: () {
                              if (!isAdmin) { // Admin değilse seçim yapılmasın
                                setState(() {
                                  if (selectedUserIds.contains(userId)) {
                                    selectedUserIds.remove(userId);
                                  } else {
                                    selectedUserIds.add(userId);
                                  }
                                });
                              }
                            },
                            child: ExpansionTile(
                              backgroundColor: hasPermission
                                  ? Color(0xFF08FFFF).withOpacity(0.6)
                                  : Colors.grey.withOpacity(0.6),
                              title: Row(
                                children: [
                                  if (isAdmin) // Admin ise checkbox gizlensin
                                    Checkbox(
                                      value: selectedUserIds.contains(userId2),
                                      onChanged: (value) {
                                        setState(() {
                                          if (value == true) {
                                            selectedUserIds.add(userId2);
                                          } else {
                                            selectedUserIds.remove(userId2);
                                          }
                                        });
                                      },
                                    ),
                                  CircleAvatar(
                                    backgroundColor: hasPermission
                                        ? Color(0xFFFF8805)
                                        : Colors.grey,
                                    child: Text(
                                      user['number'].toString(),
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                  SizedBox(width: 15),
                                  Expanded(
                                    child: Text(
                                      user['number'] == 0
                                          ? '${user['name']}' // Eğer 'number' 0 ise 'name' göster
                                          : 'Daire ${user['number']}',
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16,
                                        color: Colors.black,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              children: hasPermission
                                  ? [
                                Container(
                                  color: Colors.grey[100],
                                  child: FutureBuilder<List<Map<String, dynamic>>>(
                                    future: _getUserDebts(userId2),
                                    builder: (context, debtSnapshot) {
                                      if (debtSnapshot.hasError) {
                                        return Text("Hata oluştu");
                                      }
                                      final debts = debtSnapshot.data!;
                                      return Column(
                                        children: debts.map((debt) {
                                          return ListTile(
                                            title: Text(
                                              '₺${debt['amount']}',
                                              style: TextStyle(fontWeight: FontWeight.bold),
                                            ),
                                            subtitle: Text(debt['description'] ?? 'Açıklama yok'),
                                            trailing: isAdmin // Admin ise silme ikonu gösterilsin
                                                ? IconButton(
                                              icon: Icon(Icons.delete, color: Colors.red),
                                              onPressed: () => _deleteDebt(userId2, debt['id']),
                                            )
                                                : null, // Admin değilse ikon gizlensin
                                          );
                                        }).toList(),
                                      );
                                    },
                                  ),
                                ),
                              ]
                                  : [
                                Padding(
                                  padding: EdgeInsets.all(10),
                                  child: Text(
                                    'Bu daire bilgilerini görüntülemek için izniniz yok.',
                                    style: TextStyle(
                                      color: Colors.red,
                                      fontSize: 14,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    );
                  },
                );
              },
            ),
          ),

          // Butonun olduğu alan
          widget.id == 0
              ? SizedBox.shrink() // Admin değilse buton gizlenir
              : selectedUserIds.isEmpty
              ? Align(
            alignment: Alignment.bottomCenter,
            child: Padding(
              padding: const EdgeInsets.only(bottom: 20.0),
              child: FloatingActionButton.extended(
                onPressed: () {
                  _showAddDebtDialog(userId: '', isForAllUsers: true);
                },
                label: Text(
                  "Hepsine Ekle",
                  style: TextStyle(fontSize: 12),
                ),
                icon: Icon(
                  Icons.add,
                  size: 15,
                ),
                backgroundColor: Color(0xFF08FFFF),
              ),
            ),
          )
              : Align(
            alignment: Alignment.bottomCenter,
            child: Padding(
              padding: const EdgeInsets.only(bottom: 20.0),
              child: FloatingActionButton.extended(
                onPressed: () {
                  _showAddDebtDialogForSelectedUsers();
                },
                label: Text(
                  "Seçililere Ekle",
                  style: TextStyle(fontSize: 11),
                ),
                icon: Icon(
                  Icons.add,
                  size: 15,
                ),
                backgroundColor: Color(0xFF08FFFF),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
