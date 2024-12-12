import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';  // FirebaseAuth'ı ekliyoruz
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class ExpensesScreen extends StatefulWidget {
  final int id;
  final String siteId;

  ExpensesScreen({required this.id, required this.siteId});

  @override
  _ExpensesScreenState createState() => _ExpensesScreenState();
}

class _ExpensesScreenState extends State<ExpensesScreen> {
  String? selectedApartment;
  bool canViewExpenses = false;

  @override
  void initState() {
    super.initState();
    checkPermissions();
  }

  // Kullanıcı izinlerini kontrol eden fonksiyon
  void checkPermissions() async {
    // Firebase Authentication ile currentUser'ı alıyoruz
    User? currentUser = FirebaseAuth.instance.currentUser;

    if (currentUser != null) {
      DocumentSnapshot userPermissionsSnapshot = await FirebaseFirestore.instance
          .collection('users')
          .doc(currentUser.uid) // Kullanıcının UID'sini kullanıyoruz
          .collection('izinler')
          .doc(widget.siteId)
          .get();

      if (userPermissionsSnapshot.exists) {
        var permissions = userPermissionsSnapshot.data() as Map<String, dynamic>;
        setState(() {
          canViewExpenses = permissions['harcamaSecili'] ?? false;
        });
      } else {
        setState(() {
          canViewExpenses = false;
        });
      }
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
                showAddExpenseDialog(context);
              },
              color: Colors.greenAccent,
            ),
        ],
        backgroundColor: Color(0xFFFF8805),
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('expenses')
                  .where('siteId', isEqualTo: widget.siteId)
                  .snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  if (canViewExpenses == false) {
                    return Center(
                      child: Icon(
                        Icons.lock,
                        color: Colors.grey,
                        size: 100,
                      ),
                    );
                  }
                  else {
                    return Center(
                      child: Text(
                        'Hiç gider bulunamadı.',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black),
                      ),
                    );
                  }
                }

                var expenses = snapshot.data!.docs;

                return ListView.builder(
                  itemCount: expenses.length,
                  itemBuilder: (context, index) {
                    var expense = expenses[index];
                    bool isLocked = !canViewExpenses;

                    if (isLocked) {
                      return Center(
                        child: Icon(
                          Icons.lock,
                          color: Colors.grey,
                          size: 100,
                        ),
                      );
                    } else {
                      return Card(
                        margin: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 4,
                        child: ListTile(
                          contentPadding: EdgeInsets.all(16),
                          title: Text(
                            expense['title'],
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 18,
                              color: Colors.black,
                            ),
                          ),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              SizedBox(height: 4),
                              Text(
                                '${expense['amount']} TL',
                                style: TextStyle(
                                  color: isLocked ? Colors.grey : Color(0xFFFF0000),
                                  fontSize: 16,
                                ),
                              ),
                              SizedBox(height: 4),
                              Text(
                                'Tarih: ${expense['date']}',
                                style: TextStyle(
                                  color: Color(0xFF707070),
                                  fontSize: 14,
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    }
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  void showAddExpenseDialog(BuildContext context) {
    final TextEditingController titleController = TextEditingController();
    final TextEditingController amountController = TextEditingController();
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
                  'Yeni Harcama Ekle',
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
                    setState(() {
                      selectedApartment = value;
                    });
                  },
                  decoration: InputDecoration(labelText: 'Apartman Seç'),
                ),
                SizedBox(height: 20),
                TextField(
                  controller: titleController,
                  decoration: InputDecoration(labelText: 'Harcama Başlığı'),
                ),
                SizedBox(height: 20),
                TextField(
                  controller: amountController,
                  decoration: InputDecoration(labelText: 'Harcama Miktarı (TL)'),
                  keyboardType: TextInputType.number,
                ),
                SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    TextButton(
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      child: Text('İptal', style: TextStyle(color: Colors.red)),
                    ),
                    ElevatedButton(
                      onPressed: () async {
                        String title = titleController.text.trim();
                        double amount = double.tryParse(amountController.text.trim()) ?? 0;

                        if (title.isEmpty || amount <= 0 || selectedApartment == null) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('Lütfen tüm alanları doldurun!')),
                          );
                          return;
                        }

                        DateTime now = DateTime.now();
                        String date = '${now.day}-${now.month}-${now.year}';

                        // Firebase Authentication ile currentUser'ı alıyoruz
                        User? currentUser = FirebaseAuth.instance.currentUser;

                        if (currentUser != null) {
                          // Veriyi Firestore'a kaydetmek
                          await FirebaseFirestore.instance.collection('expenses').add({
                            'title': title,
                            'date': date,
                            'amount': amount,
                            'siteId': widget.siteId,
                            'apartment': selectedApartment,
                            'userId': currentUser.uid, // Kullanıcı UID'sini kaydediyoruz
                          });

                          Navigator.pop(context);
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('Harcama başarıyla eklendi.')),
                          );
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        foregroundColor: Colors.white,
                        backgroundColor: Color(0xFFFF8805),
                      ),
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
}
