class Deneme {
  final int? id;
  final String? tarih;
  final double? turkce;
  final double? sosyal;
  final double? tytMat;
  final double? fen;
  final double? aytMat;
  final double? fizik;
  final double? kimya;
  final double? biyoloji;
  final double? edeb;
  final double? tarih1;
  final double? cog1;

  Deneme({
    this.id,
    this.tarih,
    this.turkce,
    this.sosyal,
    this.tytMat,
    this.fen,
    this.aytMat,
    this.fizik,
    this.kimya,
    this.biyoloji,
    this.edeb,
    this.tarih1,
    this.cog1,
  });

  double? get tytTop {
    final vals = [turkce, sosyal, tytMat, fen].whereType<double>();
    if (vals.isEmpty) return null;
    return vals.fold(0.0, (a, b) => a + b);
  }

  double? get aytSay {
    final vals = [aytMat, fizik, kimya, biyoloji].whereType<double>();
    if (vals.isEmpty) return null;
    return vals.fold(0.0, (a, b) => a + b);
  }

  double? get eaAyt {
    final vals = [aytMat, edeb, tarih1, cog1].whereType<double>();
    if (vals.isEmpty) return null;
    return vals.fold(0.0, (a, b) => a + b);
  }

  double? get toplam {
    final t = tytTop;
    final a = aytSay;
    if (t == null && a == null) return null;
    return (t ?? 0) + (a ?? 0);
  }

  /// 2025 katsayılarına yakın yaklaşık puan
  double? sayPuan(double obp) {
    if (toplam == null) return null;
    final p = 135 +
        (turkce ?? 0) * 1.20 +
        (sosyal ?? 0) * 1.27 +
        (tytMat ?? 0) * 1.39 +
        (fen ?? 0) * 1.07 +
        (aytMat ?? 0) * 2.89 +
        (fizik ?? 0) * 2.46 +
        (kimya ?? 0) * 2.53 +
        (biyoloji ?? 0) * 2.61 +
        obp * 0.12;
    return p.roundToDouble();
  }

  double? eaPuan(double obp) {
    if (tytTop == null || eaAyt == null) return null;
    final p = 131 +
        (turkce ?? 0) * 1.19 +
        (sosyal ?? 0) * 1.26 +
        (tytMat ?? 0) * 1.38 +
        (fen ?? 0) * 1.07 +
        (aytMat ?? 0) * 2.88 +
        (edeb ?? 0) * 2.94 +
        (tarih1 ?? 0) * 2.53 +
        (cog1 ?? 0) * 2.85 +
        obp * 0.12;
    return p.roundToDouble();
  }

  Map<String, dynamic> toMap() => {
        'id': id,
        'tarih': tarih,
        'turkce': turkce,
        'sosyal': sosyal,
        'tyt_mat': tytMat,
        'fen': fen,
        'ayt_mat': aytMat,
        'fizik': fizik,
        'kimya': kimya,
        'biyoloji': biyoloji,
        'edeb': edeb,
        'tarih1': tarih1,
        'cog1': cog1,
      };

  factory Deneme.fromMap(Map<String, dynamic> m) => Deneme(
        id: m['id'] as int?,
        tarih: m['tarih'] as String?,
        turkce: (m['turkce'] as num?)?.toDouble(),
        sosyal: (m['sosyal'] as num?)?.toDouble(),
        tytMat: (m['tyt_mat'] as num?)?.toDouble(),
        fen: (m['fen'] as num?)?.toDouble(),
        aytMat: (m['ayt_mat'] as num?)?.toDouble(),
        fizik: (m['fizik'] as num?)?.toDouble(),
        kimya: (m['kimya'] as num?)?.toDouble(),
        biyoloji: (m['biyoloji'] as num?)?.toDouble(),
        edeb: (m['edeb'] as num?)?.toDouble(),
        tarih1: (m['tarih1'] as num?)?.toDouble(),
        cog1: (m['cog1'] as num?)?.toDouble(),
      );
}

class GunlukCalisma {
  final int? id;
  final String tarih;
  final double saat;
  final String? not;

  GunlukCalisma({this.id, required this.tarih, required this.saat, this.not});

  Map<String, dynamic> toMap() => {
        'id': id,
        'tarih': tarih,
        'saat': saat,
        'not_text': not,
      };

  factory GunlukCalisma.fromMap(Map<String, dynamic> m) => GunlukCalisma(
        id: m['id'] as int?,
        tarih: m['tarih'] as String,
        saat: (m['saat'] as num).toDouble(),
        not: m['not_text'] as String?,
      );
}
