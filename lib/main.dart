import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:onesignal_flutter/onesignal_flutter.dart';
import 'firebase_options.dart';
import 'adminpanel.dart';
import 'userpanel.dart';
import 'package:firebase_remote_config/firebase_remote_config.dart';
import 'package:package_info_plus/package_info_plus.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(); // Firebase'i başlat
  await initRemoteConfig();  // Remote Config başlatma
  runApp(MaterialApp(
    home: MyApp(),
  ));
}

Future<void> initRemoteConfig() async {
  final FirebaseRemoteConfig remoteConfig = await FirebaseRemoteConfig.instance;
  await remoteConfig.fetchAndActivate();  // Remote config verilerini al ve etkinleştir
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  late String currentVersion;

  @override
  void initState() {
    super.initState();
    _checkAppVersion();
  }

  Future<void> _checkAppVersion() async {
    final PackageInfo packageInfo = await PackageInfo.fromPlatform();
    final String appVersion = packageInfo.version; // Uygulamanın mevcut sürümünü al

    final FirebaseRemoteConfig remoteConfig = FirebaseRemoteConfig.instance;
    await remoteConfig.fetchAndActivate();
    final String remoteVersion = remoteConfig.getString('current_version');

    setState(() {
      currentVersion = remoteVersion;
    });

    if (appVersion != currentVersion) {
      _showUpdateDialog();
    }
  }

  void _showUpdateDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Yeni Güncelleme Mevcut'),
          content: Text('Yeni sürümü yüklemek için uygulamanızı güncelleyin.'),
          actions: <Widget>[
            TextButton(
              child: Text('Tamam'),
              onPressed: () {
                Navigator.of(context).pop();
                // Güncelleme sayfasına yönlendirme yapabilirsiniz
              },
            ),
          ],
        );
      },
    );
  }


  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: FirebaseAuth.instance.currentUser == null
          ? LoginScreen() // Eğer kullanıcı yoksa login ekranına yönlendir
          : FutureBuilder<String?>(
        future: _getUserRole(), // Kullanıcı rolünü almak için asenkron işlem
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Scaffold(
              backgroundColor: Colors.blueAccent, // Yükleme sırasında arka plan rengi
              body: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Image.asset(
                      'assets/images/vizyon2.png', // Buraya görsel yolunu yazın
                      width: 150, // İsteğe bağlı boyutlandırma
                      height: 150,
                    ),
                    SizedBox(height: 20),
                    Text(
                      'Veriler Yükleniyor...',
                      style: TextStyle(color: Colors.white, fontSize: 16),
                    ),
                  ],
                ),
              ),
            );
          }

          if (snapshot.hasData) {
            final role = snapshot.data;
            if (role == 'admin') {
              return AdminPanel(); // Admin ise admin paneline yönlendir
            } else if (role == 'user') {
              return UserPanel(); // User ise user paneline yönlendir
            }
          }

          // Eğer rol alınamazsa login ekranına yönlendir
          return LoginScreen();
        },
      ),
    );
  }

  // Kullanıcı rolünü Firestore'dan alacak fonksiyon
  Future<String?> _getUserRole() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      try {
        final userDoc = await FirebaseFirestore.instance.collection('users').doc(user.uid).get();
        return userDoc.data()?['role']; // Kullanıcı rolünü döndürüyoruz
      } catch (e) {
        print("Rol alınırken hata oluştu: $e");
        return null; // Rol alınamadığında null döndür
      }
    }
    return null; // Kullanıcı yoksa null döndür
  }
}

class LoginScreen extends StatelessWidget {
  final TextEditingController usernameController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  // Kullanıcı girişi yapma fonksiyonu
  Future<void> loginUser(String username, String password, BuildContext context) async {
    try {
      final email = '$username@example.com';

      // Firebase ile giriş yapma işlemi
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Kullanıcı başarılı şekilde giriş yaptıysa
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        // Firestore'dan kullanıcı rolünü alıyoruz
        final userDoc = await FirebaseFirestore.instance.collection('users').doc(user.uid).get();
        final role = userDoc.data()?['role'];
        final userId = user.uid;

        // Rol kontrolü yapıyoruz
        if (role == 'admin') {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => AdminPanel()),
          );
        } else if (role == 'user') {
          try {
            final token = await FirebaseMessaging.instance.getToken();
            await FirebaseFirestore.instance.collection('users').doc(userId).update({
              'deviceToken': token,
            });
            saveUserToOneSignal(userId, token!);
          }
          catch (e){
            print("HATA $e");
          }

          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => UserPanel()),
          );
        }
      }
    } on FirebaseAuthException catch (e) {
      // FirebaseAuthException hatalarında kullanıcıya basit bir mesaj gösteriyoruz
      _showSnackBar(context, "Bilgiler Yanlış. Tekrar Deneyiniz.");
    } catch (e) {
      // Diğer hatalar için genel bir mesaj
      _showSnackBar(context, 'Beklenmeyen bir hata oluştu. Lütfen tekrar deneyiniz.');
    }
  }

  Future<void> saveUserToOneSignal(String userId, String token) async {
    const String appId = "402eedf4-e7b6-48df-9941-fbfcdc9362dc"; // OneSignal App ID
    const String apiKey = "os_v2_app_iaxo35hhwzen7gkb7p6nze3c3q7vf7oswp2edhnry3mf7r2whe753txc3ai63wqhamegsneit5to6lnhzebkqtp4befnsv3z2zb3x2i";

    final headers = {
      "Content-Type": "application/json; charset=utf-8",
      "Authorization": "Basic $apiKey",
    };

    final body = jsonEncode({
      "subscriptions": [
        {
          "type": "AndroidPush",
          "token": token,
          "enabled": true,
          "notification_types": 1,
        }
      ],
      "identity": {
        "external_id": userId,
      }
    });

    final response = await http.post(
      Uri.parse('https://api.onesignal.com/apps/$appId/users'),
      headers: headers,
      body: body,
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      print("OneSignal kullanıcısı başarıyla oluşturuldu.");
    } else {
      print("Hata oluştu: ${response.body}");
    }
  }

  // SnackBar göstermek için kullanılan fonksiyon
  void _showSnackBar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFEAE8E8), // Hafif gri arka plan
      body: Center(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Image.asset(
                  'assets/images/vizyon.png',
                  height: 250, // Logonun yüksekliği
                ),
                SizedBox(height: 10), // Logo ile başlık arasındaki boşluk

                // Başlık
                Text(
                  'Hoş Geldiniz',
                  style: TextStyle(
                      fontSize: 30,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFFFF8805),
                      fontStyle: FontStyle.italic
                  ),
                ),
                SizedBox(height: 100), // Başlık ile giriş formu arasındaki boşluk

                // Kullanıcı adı girişi
                TextField(
                  controller: usernameController,
                  decoration: InputDecoration(
                    labelText: 'Kullanıcı Adı',
                    border: OutlineInputBorder(),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Color(0xFF08FFFF), width: 2),
                    ),
                    prefixIcon: Icon(Icons.person, color: Color(0xFF08FFFF)),
                  ),
                ),
                SizedBox(height: 25),

                // Şifre girişi
                TextField(
                  controller: passwordController,
                  decoration: InputDecoration(
                    labelText: 'Şifre',
                    border: OutlineInputBorder(),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Color(0xFF08FFFF), width: 2),
                    ),
                    prefixIcon: Icon(Icons.lock, color: Color(0xFF08FFFF)),
                  ),
                  obscureText: true,
                ),
                SizedBox(height: 32),

                // Giriş butonu
                ElevatedButton(
                  onPressed: () =>
                      loginUser(usernameController.text, passwordController.text, context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color(0xFFFF8805), // Buton rengi
                    padding: EdgeInsets.symmetric(horizontal: 50, vertical: 15),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                  ),
                  child: Text('Giriş Yap', style: TextStyle(fontSize: 18, color: Colors.white)),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
