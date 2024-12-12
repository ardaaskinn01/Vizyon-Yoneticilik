import 'package:flutter/material.dart';

class AboutPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Hakkımızda'),
        backgroundColor: Color(0xFF08FFFF),
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Card(
                color: Colors.teal.shade50,
                elevation: 5,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Text(
                    "Profesyonel apartman yönetimi hizmeti veren firmamız, konusunda uzman profesyonel yöneticilerle, sitenize, apartmanınıza uygun profesyonel yönetimi sunmaktadır.",
                    style: TextStyle(fontSize: 16, color: Colors.black87),
                  ),
                ),
              ),
              SizedBox(height: 20),
              Text(
                'Profesyonel Site Yönetimi',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Colors.teal,
                ),
              ),
              SizedBox(height: 10),
              Text(
                "Kurulan her sistemin temelinde bir takım sorunlar, düzensizlikler ve anlaşmazlıklar ortaya çıkar. Bunların nasıl çözümlenebileceği noktasında arayışlar başlar. Profesyonel Site yönetimi kavramı da, bu sorunları ortadan kaldırmaya yönelik amaç güdülerek ortaya çıkmıştır.Günümüz koşullarında insanlar, artan ihtiyaçlar sebebiyle kurulan fabrika ve iş yerleri sonucu çoğalan işçi ihtiyaçlarını karşılamak üzere büyük şehirlere akın ettiler. Konut ihtiyaçlarının artması sonucu devrim niteliğinde betonarme yapılar yapıldı. Maliyet düşürülmesi adına kat sayıları artınca site kültürü oturmaya başladı ve insanlar hiç olmadığı kadar iç içe yaşamaya başladılar.İnsanlar birlikte yaşamanın sağladığı avantajların yanında, bir arada yaşamanın verdiği dezavantajlarla da yüzleştiler. Bu konu ile alakalı mevzuatlar, kanunlar, yönetmelikler ve kurallar ortaya çıkarıldı. İnsanlar apartman veya sitelerinde kat malikleri arasından yöneticiler seçerek, sorunların üstesinden gelmeye çalıştılar. Ancak birçok konuda anlaşmazlıklara çözüm bulunamadığı için profesyonel site yönetimi kavramı ortaya çıktı.Profesyonel site yönetimi; apartman, site ve plaza gibi kat mülkiyeti esasına dayalı olarak bir arada yaşayan insanların binalarının mali, idari hukuki ve yönetim işlemlerinin profesyonel tek bir şirket tarafından tek elden yönetilmesi olgusudur.",
                style: TextStyle(fontSize: 14), // Yazı boyutunu küçülttük
              ),
              SizedBox(height: 20),
              Text(
                "Firmamızın Sizlere Sağlayacağı Avantajlar",
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Colors.teal,
                ),
              ),
              SizedBox(height: 5),
              Text(
                "Hukuki altyapımızı etkin şekilde kullanarak aidat tahsilatları konusunda başarılı bir grafik sergilenmesi.Sistemimizde kat malikleri (mal sahibi) arasında yaşanacak anlaşmazlıklarda tecrübemiz ve deneyimlerimizle Kat Mülkiyeti Kanunu uyarınca çözüm başarısı.Yapılacak her türlü işlem ile ilgili anlaşmalı olduğumuz, asansör, elektrik, su, kilit merkezi sistem yerden ısıtma uydu, bahçe, havuz, yangın önleme, tadilat, tamirat, kamera sistemleri, peyzaj, boyama, temizlik vs. firmalar ile profesyonel düşük maliyette çalışma.Sitedeki kapıcı, güvenlik, temizlikçi vs. görevlilerin sigorta primleri ve iş takibinin profesyonel ekibimiz tarafından yapılması.",
                style: TextStyle(fontSize: 14), // Yazı boyutunu küçülttük
              ),
              SizedBox(height: 20),
              Text(
                "Çalışma Sistemimiz",
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Colors.teal,
                ),
              ),
              SizedBox(height: 10),
              Text(
                "Site veya apartmanınızı firmamıza devretmek istediğinizde;\n1- Öncelikle kat malikleri kurulu toplantısı yapılır. Mevcut kanun hükmü gereği toplantıdan az 15 gün önce duyuru yapılır. Toplantıya kat maliklerinin (ev sahiplerinin) en az yarısının katılımı olmalıdır. Birinci toplantıda katılım yeterli değil ise, ikinci toplantı 15 gün sonra yapılır ve kat maliklerinin yarısının katılması kuralı aranmaz.\n2- Yönetimin şirketimize devri hususunda karar alınarak yetki verilir. Karar defterine imza atılarak yetki verilir.\n3- Devir işleminde ilk olarak mevcut yönetimin alacak, borç, tamamlanmış ya da devam eden projeler ve mali durumu belirten raporu yeni yönetime vermesi gerekir. Bu işlemin de yine kat malikleri tarafından imza altına alınması gerekir.\n4- Toplantıda en az 2 kişiden oluşacak şekilde kat malikleri arasından denetim kurulu seçilir. Yılda 2 defa olağan yönetim ve denetim kurulu toplantısı yapılarak aidat ve gelir giderler hakkında denetim yapılır. Aidat ücretlerine karar verilir.\n5- Varsa WhatsApp grubu yönetime devredilir. Yoksa bina sakinlerinin bulunduğu bir WhatsApp grubu kurulur.\n6- Yeni yönetim bankacılık işlemlerini karar defteri ile birlikte noterden yetki alarak üzerine alır.\n7- Tüm bu işlemlerin ardından duyuru yapılarak apartman/site sakinleriyle tanışma toplantısı gerçekleştirilir.Bu toplantıda istek ve talepler dinlenir, gerek kanun maddeleri ve işleyiş hakkında apartman/site sakinlerine bilgi verilir.\n8- Tüm bunların ardından mali, idari ve hukuki işlemler yeni yönetimin sorumluluğundadır.",
                style: TextStyle(fontSize: 14), // Yazı boyutunu küçülttük
              ),
              SizedBox(height: 20),
              Text(
                "Önceliklerimiz ve Prensiplerimiz",
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Colors.teal,
                ),
              ),
              SizedBox(height: 10),
              Text(
                "1- En başta önem verdiğimiz husus; huzur ve güvenlik olup, ilk çalışmamız binanın varsa kamera sisteminin güncellenmesi, yoksa kamera sisteminin kurulmasıdır. Yine kapı, kepenk ve kilit sistemlerinin hali hazırda çalışır ve güvenli olması yine ilk önceliğimizdir. IP kamera sistemi ile 7/24 bina ve çevresi izlenir.\n2- Kamera odası, asansör dairesi havuz kazan dairesi, merkezi sistem kazan dairesi, yönetim odası, vb. yerlerin kötü niyetli insanların amaçlarını önlemek adına hemen kilitlerinin değişimi yapılması yine önceliğimizdir.\n3- Görsellik ve düzen konusunda ise, herkesin misafiri gelebileceğinden, bina ve çevre temizliğinin denetlenmesi, ortak alanlara eşya bırakılmaması, bina dışına ve balkonlara kötü görüntü oluşturacak cisimlerin asılmaması için firmamız tarafından haftada en az 2 defa olmak koşuluyla bina denetimi yapılır.\n4- Varsa temizlikçi, güvenlik, kapıcı vs. çalışanlar ile 7/24 irtibatta kalınarak denetimi sağlanır.\n5- Asansörlerin güvenliği ve bakım her zaman denetlenir. Yılda 1 defa yapılan belediye kontrollerinden tam not alarak asansörlerin kullanıma uygun etiketini almak en önemli prensiplerimizdendir.\n6- Aidat ödenmemesi, ortak alanların işgal edilmesi, komşuluk hukukuna uygun davranılmaması durumunda derhal zaman kaybetmeden şirketimiz avukatları tarafından hukuki süreç başlatılır.\n7- Acil durum ekipmanlarının, merkezi sistem varsa ısı pay ölçerlerinin denetimleri yine en önemli önceliklerimizdendir.\n8- Kurulmuş olan WhatsApp grubuna yalnızca yönetim duyuru yapar. Komşuların gece ve istirahat saatlerinde rahatsız olmaması adına gruba mesaj atma engellenir. Talep şikâyet ve istek olduğunda komşularımız belirtilmiş olan telefon ile acil durum ekibimizle bizzat iletişime geçerler.",
                style: TextStyle(fontSize: 14), // Yazı boyutunu küçülttük
              ),
              SizedBox(height: 20),
              Text(
                "Ödeme İşlemleri",
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Colors.teal,
                ),
              ),
              SizedBox(height: 10),
              Text(
                "Yapılacak olan kat malikleri kurulu olağan toplantılarda, mevcut enflasyon, yönetim şirketinin ücret tarifesi, kat maliklerinin belirlediği ücretler, mevcut yönetimden memnuniyet hususları, göz önüne alınarak, yönetim şirketi ve kat malikleri ile daire başı ücret belirlenecek şekilde pazarlık usulü ücret belirlenir.Yeni yönetimin hizmete başlangıç tarih örneğin mevcut ayın 5’i ise, bir sonraki ayın 5'inden itibaren her ay yönetim ücreti toplanan aidatlardan tahsil edilir ve firmamız tarafından faturalandırılır.",
                style: TextStyle(fontSize: 14), // Yazı boyutunu küçülttük
              ),
              SizedBox(height: 30),
              Center(
                child: Text(
                  "BİZİ TERCİH ETTİĞİNİZ İÇİN TEŞEKKÜR EDERİZ.",
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.teal,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
