import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class ContactPage extends StatelessWidget {
  // Fonksiyon: URL açma
  Future<void> _launchURL(String url) async {
      await launch(url);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFEAE8E8),
      appBar: AppBar(
        title: Text('İletişim'),
        backgroundColor: Color(0xFF08FFFF),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Text(
                'Bize Ulaşın',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFFFF8805),
                ),
              ),
            ),
            SizedBox(height: 20),
            Card(
              elevation: 5,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              child: ListTile(
                leading: Icon(Icons.email, color: Color(0xFF08FFFF)),
                title: Text(
                  'E-posta',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                subtitle: Text(
                  'info@vizyonyoneticilik.com',
                  style: TextStyle(color: Colors.black54),
                ),
              ),
            ),
            SizedBox(height: 15),
            Card(
              elevation: 5,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              child: ListTile(
                leading: Icon(Icons.phone, color: Color(0xFF08FFFF)),
                title: Text(
                  'Telefon',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                subtitle: Text(
                  '0541 882 82 83',
                  style: TextStyle(color: Colors.black54),
                ),
              ),
            ),
            SizedBox(height: 15),
            Card(
              elevation: 5,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              child: ListTile(
                leading: Icon(Icons.location_on, color: Color(0xFF08FFFF)),
                title: Text(
                  'Adres',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                subtitle: Text(
                  'Millet Mahallesi, 11 Eylül Bulvarı, No:54\nYıldırım/Bursa',
                  style: TextStyle(color: Colors.black54),
                ),
              ),
            ),
            SizedBox(height: 100),
            Center(
              child: Text(
                'Bizi Takip Edin',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFFFF8805),
                ),
              ),
            ),
            SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                IconButton(
                  icon: Image.asset(
                    'assets/images/facebook.png',
                    width: 28, // Boyut ayarı
                    height: 28, // Boyut ayarı
                  ),
                  onPressed: () => _launchURL('https://www.facebook.com/'),
                ),
                SizedBox(width: 20),
                IconButton(
                  icon: Image.asset(
                    'assets/images/twitter.png',
                    width: 25, // Boyut ayarı
                    height: 25, // Boyut ayarı
                  ),
                  onPressed: () => _launchURL('https://twitter.com/'),
                ),
                SizedBox(width: 20),
                IconButton(
                  icon: Image.asset(
                    'assets/images/instagram.png',
                    width: 25, // Boyut ayarı
                    height: 25, // Boyut ayarı
                  ),
                  onPressed: () => _launchURL(
                    'https://www.instagram.com/vizyonyoneticilik?utm_source=qr&igsh=NjJlZTlsZG9mam1s',
                  ),
                ),
                SizedBox(width: 14),
                IconButton(
                  icon: Image.asset(
                    'assets/images/linked.png',
                    width: 50, // Boyut ayarı
                    height: 50, // Boyut ayarı
                  ),
                  onPressed: () => _launchURL('https://www.linkedin.com/'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
