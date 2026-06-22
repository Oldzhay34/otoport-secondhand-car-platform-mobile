# FIRSAT - Mobil İstemci (iOS & Android) 📱🚗

![Flutter](https://img.shields.io/badge/Flutter-3.x-blue) ![Dart](https://img.shields.io/badge/Dart-Language-0175C2) ![Architecture](https://img.shields.io/badge/Architecture-RESTful%20JSON-orange) ![Accessibility](https://img.shields.io/badge/Accessibility-WCAG%202.1%20AA-brightgreen)

FIRSAT Mobil İstemcisi, araç alıcılarını (Client) ve galeri mağazalarını (Store) bir araya getiren yüksek performanslı, çapraz platform bir uygulamadır. Tek bir Dart kod tabanıyla hem iOS (14.0+) hem de Android (8.0+) için derlenmektedir.

## 🌟 Rol Bazlı Özellik Seti

Platform, giriş yapan kullanıcının JWT rolüne (`ROLE_GUEST`, `ROLE_CLIENT`, `ROLE_STORE`, `ROLE_ADMIN`) göre arayüzü dinamik olarak yapılandırır.

### 👤 Müşteriler (Client) İçin:
*   **Milisaniyelik Araç Arama:** Elasticsearch altyapısına bağlı anlık filtreleme (Marka, model, donanım, km, fiyat).
*   **Yapay Zeka Destekli Öneriler:** `SentenceTransformer` modeli üzerinden, kullanıcı yolculuğuna (collaborative filtering) özel araç önerileri.
*   **Favori & Fiyat Takibi:** İlanları favoriye alma ve fiyat düşüşlerinde RabbitMQ destekli anlık bildirim alma.
*   **Güvenli İletişim:** Satıcı galerilerle AES-256 standartlarında şifrelenmiş uygulama içi mesajlaşma. Modere edilmiş temiz içerik alanı.

### 🏢 Galeri Mağazaları (Store) İçin:
*   **İlan Yönetimi:** Cepten hızlı araç ilanı oluşturma, yayına alma ve pasifleştirme.
*   **Yapay Zeka Açıklama Üretici:** Araç özelliklerini seçerek saniyeler içinde NLP modelinden profesyonel Türkçe ilan açıklaması alma.
*   **Finans & Analitik Dashboard:** Araç bazlı kâr/zarar hesaplama modülü; ilanların gösterim ve favoriye eklenme istatistikleri.
*   **Abonelik Yönetimi:** Sistem içi sıralamayı (Ranking Queue) etkileyen paketlerin (PRO, PLUS vb.) takibi ve yönetimi.

## 🎨 UI/UX Tasarım ve Performans Mimarisi

Uygulama, Nielsen'ın yanıt süresi eşiklerine göre dizayn edilmiştir:
*   **Anlık Tepkime (<100ms):** Favori ekleme ve beğeniler gibi işlemlerde kullanıcıya bekleme hissi vermemek adına **Optimistic UI** (Anında arayüz güncellemesi, arka planda API çağrısı) uygulanır.
*   **İskelet Ekranlar (Skeleton Screens):** İlan listesi ve profil yüklemeleri sırasında (1-5 sn aralığı) düzen kaymalarını (CLS) engelleyen dinamik iskelet ekranlar gösterilir.
*   **Hata Yönetimi ve Kurtarma:** Token Bucket limitleri aşıldığında veya ağ bağlantısı koptuğunda "Offline Banner", "Otomatik Yeniden Deneme (Exponential Backoff)" ve detaylı hata kurtarma mesajları sunulur.
*   **Erişilebilirlik:** WCAG 2.1 AA standartlarına uygun renk kontrastları ve `aria-label` destekli komut etiketleme stratejisi.

## 🔒 Güvenlik

*   **Stateless İletişim:** Tüm istekler HTTPS (TLS 1.2+) üzerinden, JSON gövdesine gömülmüş (veya header'da iletilen) Access (15 dk) ve Refresh Token (7 gün) ikilisi ile atılır.
*   **Güvenli Depolama (Secure Storage):** Hassas oturum verileri iOS'ta Keychain, Android'de EncryptedSharedPreferences ile saklanır.
*   **Mobil Özgü Koruma:** Mobil uygulama durumsuz (stateless) olduğu için CSRF token zorunluluğu barındırmaz.

## 🛠 Kurulum ve Build Talimatları

1.  Flutter SDK ortamını hazırlayın.
2.  Depoyu klonlayıp bağımlılıkları yükleyin:
```bash
    flutter pub get
    ```
3.  Çevre değişkenleri dosyası oluşturun (`.env`):
```env
    API_BASE_URL=[https://api.autofirsat.com/api](https://api.autofirsat.com/api)
    ML_SERVICE_TIMEOUT=10000
    ```
4.  Derleme:
    *   **Android APK:** `flutter build apk --release`
    *   **iOS IPA:** `flutter build ios --release` (macOS ve Xcode gerektirir)
