# YKS 2026 Deneme Takip — Flutter APK

Excel panelinin mobil sürümü. Veriler telefonda **SQLite** ile kalıcı saklanır.

## Özellikler

- Deneme net girişi (TYT + AYT SAY + EA)
- 2026 ÖSYM sıralama tablosu (SAY / EA ayrı)
- SAY & EA hedef takip
- Günlük çalışma saati
- Net / sıra grafikleri (nokta nokta)
- OBP ve hedef ayarları

## Android Studio **kurmadan** APK alma

### 1. GitHub’a yükle

1. [github.com](https://github.com) → **New repository** → isim: `yks-takip-app` (Public)
2. Bilgisayarında (veya GitHub web “Upload files”):

```bash
cd yks_takip_app
git init
git add .
git commit -m "YKS 2026 Takip uygulaması"
git branch -M main
git remote add origin https://github.com/KULLANICI_ADIN/yks-takip-app.git
git push -u origin main
```

> Git yoksa: GitHub’da repo oluştur → **uploading an existing file** ile tüm klasörü sürükle.

### 2. APK’yı indir

1. Repo sayfasında **Actions** sekmesi
2. **Build APK** workflow’unun yeşil tikini bekle (~5–8 dk)
3. Alttaki **Artifacts** → **yks-takip-apk** indir
4. Zip’ten `app-release.apk` çıkarıp telefona at
5. Telefonda “Bilinmeyen kaynaklardan yükleme”ne izin ver → kur

### 3. Manuel tetikleme

Actions → Build APK → **Run workflow**

---

## Geliştirici notu

- `lib/data/ranking_2026.dart` — ÖSYM 2026 yığılma
- `lib/services/database_service.dart` — SQLite
- `.github/workflows/build-apk.yml` — otomatik derleme

Flutter / Android Studio **gerekmez**; sadece GitHub hesabı yeter.
