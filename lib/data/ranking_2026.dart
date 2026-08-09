/// 2026 ÖSYM yerleştirme puanı yığınsal dağılımı (enterpolasyonlu)
class Ranking2026 {
  // puan -> sıra (kümülatif)
  static const List<(int, int)> say = [
    (100, 1135800), (150, 1135198), (170, 1117304), (190, 1019046),
    (210, 858167), (230, 681176), (250, 533920), (270, 425443),
    (290, 344726), (310, 282213), (330, 232317), (350, 191247),
    (370, 157778), (390, 129485), (410, 105112), (430, 83511),
    (450, 63669), (470, 44919), (490, 27402), (510, 12887),
    (530, 3500), (550, 154), (570, 40), (590, 10),
  ];

  static const List<(int, int)> ea = [
    (100, 1421400), (150, 1421093), (170, 1412649), (190, 1347025),
    (210, 1196809), (230, 990764), (250, 775922), (270, 585271),
    (290, 429479), (310, 307918), (330, 215631), (350, 148570),
    (370, 97839), (390, 58772), (410, 29700), (430, 12363),
    (450, 5299), (470, 2482), (490, 1118), (510, 394),
    (530, 98), (550, 12), (570, 5), (590, 2),
  ];

  static int lookup(double puan, List<(int, int)> table) {
    if (puan < 100) return table.first.$2;
    if (puan > 590) return table.last.$2;
    for (int i = 0; i < table.length - 1; i++) {
      final (p0, r0) = table[i];
      final (p1, r1) = table[i + 1];
      if (puan >= p0 && puan <= p1) {
        final t = (puan - p0) / (p1 - p0);
        return (r0 + t * (r1 - r0)).round();
      }
    }
    return table.last.$2;
  }

  static int saySira(double puan) => lookup(puan, say);
  static int eaSira(double puan) => lookup(puan, ea);
}
