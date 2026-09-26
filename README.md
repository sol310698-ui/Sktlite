# SKT Takip Lite — Kurulum (Termux)

Bu paket sadece `lib/` kaynak kodlarını ve bağımlılık listesini içerir.
Android/iOS proje iskeleti (android/, ios/ klasörleri) burada YOK — onu
`flutter create` ile sen oluşturacaksın, ben sadece Dart kodunu veriyorum.

## 1) Yeni proje iskeletini oluştur

```bash
cd ~
flutter create skt_takip_lite
cd skt_takip_lite
```

## 2) Bu zip'i indir ve lib/ + pubspec bağımlılıklarını kopyala

```bash
cd /sdcard/Download
unzip -o skt_takip_lite.zip -d skt_takip_lite_src

# Oluşturulan projenin lib/ klasörünün üzerine yaz
rm -rf ~/skt_takip_lite/lib
cp -r skt_takip_lite_src/skt_takip_lite/lib ~/skt_takip_lite/lib
```

## 3) pubspec.yaml'a bağımlılıkları ekle

`~/skt_takip_lite/pubspec.yaml` dosyasını aç, `dependencies:` bloğunun
içine `skt_takip_lite_src/skt_takip_lite/pubspec_dependencies.yaml`
dosyasındaki 4 paketi ekle (flutter_riverpod, sqflite, path, mobile_scanner,
intl).

## 4) Kamera izni (barkod tarama için)

`android/app/src/main/AndroidManifest.xml` içine, `<application` etiketinden
ÖNCE ekle:

```xml
<uses-permission android:name="android.permission.CAMERA" />
```

## 5) minSdkVersion kontrolü

`mobile_scanner` en az minSdk 21 ister. `android/app/build.gradle` içinde
`minSdkVersion`'ın 21 veya üstü olduğundan emin ol (Flutter varsayılanı
zaten genelde yeterlidir).

## 6) Paketleri çek ve derle

```bash
cd ~/skt_takip_lite
flutter pub get
flutter build apk --release
```

## 7) Git'e gönder (mevcut skt_takip deponla karıştırma — bu AYRI bir proje)

```bash
cd ~/skt_takip_lite
git init
git add -A
git commit -m "SKT Takip Lite ilk sürüm"
# git remote add origin <yeni repo URL'in>
# git push -u origin main
```

CI ile otomatik derleme istersen `.github/workflows/build.yml` örneğini de
bu zip'te bulacaksın — kendi keystore sırlarınla eşleştirmen gerekir.

---

## Neden hafif?

- **Tek tablo, tek DB sürümü** (eski uygulamada 31 sürümlük migration
  zinciri, 10+ tablo vardı)
- **4 bağımlılık** (eski uygulamada Gemini AI, PDF üretimi, erişilebilirlik
  servisi, overlay pencere, Termux köprüsü, 3D çizim gibi çok sayıda ağır
  paket/servis vardı)
- **Arka plan servisi yok, overlay yok, AI agent yok** — sadece açtığında
  çalışan sade bir liste + ekleme ekranı
- **Riverpod tek bir AsyncNotifier** — eski uygulamadaki gibi onlarca
  provider/servis katmanı yok
