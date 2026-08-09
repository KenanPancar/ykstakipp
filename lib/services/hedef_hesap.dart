/// 3000 saat hedefi ve "gaddar" ulaşma ihtimali
class HedefHesap {
  /// YKS tarihi (varsayılan: 2027 Haziran ortası)
  static DateTime yksTarihi = DateTime(2027, 6, 14);

  static int kalanGun([DateTime? now]) {
    final n = now ?? DateTime.now();
    final d = yksTarihi.difference(DateTime(n.year, n.month, n.day)).inDays;
    return d < 0 ? 0 : d;
  }

  /// Beklenen günlük tempo: kalan_saat / kalan_gün
  static double gerekenGunluk(double yapilanSaat, double hedefSaat) {
    final kalanSaat = (hedefSaat - yapilanSaat).clamp(0, hedefSaat);
    final gun = kalanGun();
    if (gun <= 0) return kalanSaat > 0 ? 999 : 0;
    return kalanSaat / gun;
  }

  /// Geçmişe göre ortalama günlük (ilk kayıttan bugüne)
  static double ortalamaGunluk(
    double toplamSaat,
    DateTime? ilkTarih, [
    DateTime? now,
  ]) {
    final n = now ?? DateTime.now();
    if (ilkTarih == null || toplamSaat <= 0) return 0;
    final gun = n.difference(DateTime(ilkTarih.year, ilkTarih.month, ilkTarih.day)).inDays + 1;
    if (gun <= 0) return toplamSaat;
    return toplamSaat / gun;
  }

  /// Şimdiye kadar olması gereken saat (eşit tempo varsayımı)
  static double beklenenSaatSimdi(double hedefSaat, DateTime baslangic, [DateTime? now]) {
    final n = now ?? DateTime.now();
    final toplamGun = yksTarihi.difference(DateTime(baslangic.year, baslangic.month, baslangic.day)).inDays;
    if (toplamGun <= 0) return hedefSaat;
    final gecen = n.difference(DateTime(baslangic.year, baslangic.month, baslangic.day)).inDays.clamp(0, toplamGun);
    return hedefSaat * (gecen / toplamGun);
  }

  /// Ulaşma ihtimali %0–99 — gerideyse gaddar (sert) düşer
  ///
  /// tempoOrani = ortalamaGunluk / gerekenGunluk
  /// - tempo >= 1.1 → yüksek
  /// - tempo 1.0 → ~70–80
  /// - tempo < 1 → üssel ceza (gaddar)
  static double ihtimal({
    required double toplamSaat,
    required double hedefSaat,
    required double ortalamaGunluk,
    DateTime? baslangic,
  }) {
    if (hedefSaat <= 0) return 0;
    if (toplamSaat >= hedefSaat) return 99;
    final kalan = hedefSaat - toplamSaat;
    final gun = kalanGun();
    if (gun <= 0) return toplamSaat >= hedefSaat ? 99 : 1;

    final gereken = kalan / gun;
    if (gereken <= 0) return 99;

    // Tempo: mevcut ortalama / gereken
    final tempo = ortalamaGunluk <= 0 ? 0.0 : (ortalamaGunluk / gereken);

    // İlerleme: şimdiye kadar beklenen vs yapılan (daha gaddar ceza)
    double ilerlemeCarpani = 1.0;
    if (baslangic != null) {
      final beklenen = beklenenSaatSimdi(hedefSaat, baslangic);
      if (beklenen > 1) {
        final oran = (toplamSaat / beklenen).clamp(0.0, 2.0);
        if (oran < 1) {
          // Geride: kare ile cezalandır (gaddar)
          ilerlemeCarpani = oran * oran;
        } else {
          ilerlemeCarpani = 0.85 + 0.15 * (oran > 1.2 ? 1.2 : oran);
        }
      }
    }

    double p;
    if (tempo >= 1.25) {
      p = 92 + (tempo - 1.25).clamp(0, 1) * 6;
    } else if (tempo >= 1.0) {
      p = 72 + (tempo - 1.0) * 80; // 1.0→72, 1.25→92
    } else if (tempo >= 0.7) {
      // Hafif geride — orta sert
      p = 35 + (tempo - 0.7) / 0.3 * 37; // 0.7→35, 1.0→72
    } else if (tempo >= 0.4) {
      // Ciddi geride — gaddar
      p = 8 + (tempo - 0.4) / 0.3 * 27; // 0.4→8, 0.7→35
    } else if (tempo > 0) {
      // Çok kötü — çok gaddar (kübik)
      p = 8 * (tempo / 0.4) * (tempo / 0.4) * (tempo / 0.4);
    } else {
      p = 2; // hiç çalışmamış
    }

    p = p * ilerlemeCarpani;

    // Günlük gereken 10+ saat gibi imkânsızsa ekstra ceza
    if (gereken > 10) {
      p *= 0.35;
    } else if (gereken > 7) {
      p *= 0.55;
    } else if (gereken > 5) {
      p *= 0.75;
    }

    return p.clamp(1, 99);
  }

  static String ihtimalYorum(double p) {
    if (p >= 85) return 'Güçlü tempo — hedef gerçekçi';
    if (p >= 65) return 'İyi gidiyorsun, tempo korunmalı';
    if (p >= 40) return 'Sınırda — tempo artmazsa risk büyür';
    if (p >= 20) return 'Geridesin — sert tempo şart';
    if (p >= 8) return 'Kritik açık — günlük saat ciddi artmalı';
    return 'Mevcut tempo ile hedef uzak görünüyor';
  }

  static String ihtimalRenk(double p) {
    if (p >= 65) return 'green';
    if (p >= 40) return 'orange';
    return 'red';
  }
}
