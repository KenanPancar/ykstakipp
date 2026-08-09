import 'package:flutter/material.dart';
import '../models/deneme.dart';
import '../services/database_service.dart';
import '../services/hedef_hesap.dart';
import '../data/ranking_2026.dart';
import 'deneme_form_screen.dart';
import 'deneme_list_screen.dart';
import 'calisma_screen.dart';
import 'grafik_screen.dart';
import 'ayarlar_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final db = DatabaseService.instance;
  List<Deneme> denemeler = [];
  double obp = 400;
  int hedefSay = 15000;
  int hedefEa = 20000;
  double toplamSaat = 0;
  double hedefSaat = 3000;
  DateTime? ilkCalisma;
  bool loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => loading = true);
    denemeler = await db.getAllDenemeler();
    obp = await db.getObp();
    hedefSay = await db.getHedefSay();
    hedefEa = await db.getHedefEa();
    toplamSaat = await db.toplamSaat();
    hedefSaat = await db.getHedefSaat();
    ilkCalisma = await db.ilkCalismaTarihi();
    setState(() => loading = false);
  }


  Deneme? get son => denemeler.isEmpty ? null : denemeler.last;

  @override
  Widget build(BuildContext context) {
    final sayP = son?.sayPuan(obp);
    final eaP = son?.eaPuan(obp);
    final sayS = sayP != null ? Ranking2026.saySira(sayP) : null;
    final eaS = eaP != null ? Ranking2026.eaSira(eaP) : null;

    final siralar = denemeler
        .map((d) => d.sayPuan(obp))
        .whereType<double>()
        .map(Ranking2026.saySira)
        .toList();
    final enIyi = siralar.isEmpty ? null : siralar.reduce((a, b) => a < b ? a : b);

    return Scaffold(
      appBar: AppBar(
        title: const Text('YKS 2026 Takip'),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () async {
              await Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const AyarlarScreen()),
              );
              _load();
            },
          ),
        ],
      ),
      body: loading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _load,
              child: ListView(
                padding: const EdgeInsets.all(12),
                children: [
                  _summaryCards(sayP, sayS, enIyi),
                  const SizedBox(height: 12),
                  _saatHedefCard(),
                  const SizedBox(height: 12),
                  _hedefCard('SAY HEDEF', hedefSay, sayS, sayP, Colors.blue),
                  const SizedBox(height: 8),
                  _hedefCard('EA HEDEF', hedefEa, eaS, eaP, Colors.green),
                  const SizedBox(height: 12),
                  _quickStats(),
                  const SizedBox(height: 12),
                  _menuGrid(),
                ],
              ),

            ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          await Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const DenemeFormScreen()),
          );
          _load();
        },
        icon: const Icon(Icons.add),
        label: const Text('Deneme Ekle'),
      ),
    );
  }

  Widget _summaryCards(double? sayP, int? sayS, int? enIyi) {
    return Row(
      children: [
        Expanded(child: _miniCard('SAY Puan', sayP?.toStringAsFixed(0) ?? '-', Colors.blue.shade700)),
        const SizedBox(width: 8),
        Expanded(child: _miniCard('SAY Sıra', sayS?.toString() ?? '-', Colors.indigo)),
        const SizedBox(width: 8),
        Expanded(child: _miniCard('En İyi', enIyi?.toString() ?? '-', Colors.teal)),
      ],
    );
  }

  Widget _miniCard(String title, String value, Color color) {
    return Card(
      color: color,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 8),
        child: Column(
          children: [
            Text(title, style: const TextStyle(color: Colors.white70, fontSize: 11)),
            const SizedBox(height: 4),
            Text(value,
                style: const TextStyle(
                    color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }

  Widget _saatHedefCard() {
    final ort = HedefHesap.ortalamaGunluk(toplamSaat, ilkCalisma);
    final gereken = HedefHesap.gerekenGunluk(toplamSaat, hedefSaat);
    final p = HedefHesap.ihtimal(
      toplamSaat: toplamSaat,
      hedefSaat: hedefSaat,
      ortalamaGunluk: ort,
      baslangic: ilkCalisma,
    );
    final yorum = HedefHesap.ihtimalYorum(p);
    final renk = p >= 65
        ? Colors.green.shade700
        : (p >= 40 ? Colors.orange.shade800 : Colors.red.shade800);
    final pct = (toplamSaat / hedefSaat * 100).clamp(0, 100);

    return Card(
      elevation: 3,
      color: renk.withOpacity(0.08),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: renk, width: 1.5),
      ),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.timer, color: renk),
                const SizedBox(width: 8),
                Text('3000 SAAT HEDEFİ',
                    style: TextStyle(
                        color: renk, fontWeight: FontWeight.bold, fontSize: 15)),
              ],
            ),
            const SizedBox(height: 10),
            Text(
              '${toplamSaat.toStringAsFixed(1)} / ${hedefSaat.toStringAsFixed(0)} saat  ·  %${pct.toStringAsFixed(1)}',
              style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
            ),
            const SizedBox(height: 6),
            ClipRRect(
              borderRadius: BorderRadius.circular(6),
              child: LinearProgressIndicator(
                value: pct / 100,
                minHeight: 10,
                backgroundColor: Colors.grey.shade300,
                color: renk,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'Ulaşma ihtimali: %${p.toStringAsFixed(0)}',
              style: TextStyle(
                  color: renk, fontWeight: FontWeight.bold, fontSize: 20),
            ),
            const SizedBox(height: 4),
            Text(yorum, style: TextStyle(color: renk.withOpacity(0.9), fontSize: 13)),
            const SizedBox(height: 8),
            Text(
              'Ort. tempo: ${ort.toStringAsFixed(1)} sa/gün  ·  '
              'Gereken: ${gereken.toStringAsFixed(1)} sa/gün  ·  '
              'Kalan: ${HedefHesap.kalanGun()} gün',
              style: const TextStyle(fontSize: 11, color: Colors.black54),
            ),
          ],
        ),
      ),
    );
  }

  Widget _hedefCard(String title, int hedef, int? guncel, double? puan, Color color) {

    String durum = '-';
    double? ilerleme;
    if (guncel != null && hedef > 0) {
      if (guncel <= hedef) {
        durum = '🟢 Yakın';
        ilerleme = 100;
      } else {
        final maxS = denemeler
            .map((d) => title.startsWith('SAY')
                ? Ranking2026.saySira(d.sayPuan(obp) ?? 999999)
                : Ranking2026.eaSira(d.eaPuan(obp) ?? 999999))
            .fold<int>(0, (a, b) => a > b ? a : b);
        if (maxS > hedef) {
          ilerleme = ((maxS - guncel) / (maxS - hedef) * 100).clamp(0, 100);
        }
        if ((ilerleme ?? 0) >= 80) {
          durum = '🟢 Yakın';
        } else if ((ilerleme ?? 0) >= 40) {
          durum = '🟡 Orta';
        } else {
          durum = '🔴 Uzak';
        }
      }
    }

    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title,
                style: TextStyle(
                    color: color, fontWeight: FontWeight.bold, fontSize: 15)),
            const Divider(),
            _row('Hedef Sıra', hedef.toString()),
            _row('Güncel Puan', puan?.toStringAsFixed(0) ?? '-'),
            _row('Güncel Sıra', guncel?.toString() ?? '-'),
            _row('İlerleme %', ilerleme != null ? ilerleme.toStringAsFixed(0) : '-'),
            _row('Durum', durum),
          ],
        ),
      ),
    );
  }

  Widget _row(String k, String v) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(k, style: const TextStyle(color: Colors.black54)),
          Text(v, style: const TextStyle(fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }

  Widget _quickStats() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _stat('Deneme', '${denemeler.length}'),
            _stat('OBP', obp.toStringAsFixed(0)),
            _stat('Toplam Saat', '${toplamSaat.toStringAsFixed(1)} sa'),
          ],
        ),
      ),
    );
  }

  Widget _stat(String t, String v) {
    return Column(
      children: [
        Text(t, style: const TextStyle(fontSize: 11, color: Colors.black54)),
        Text(v, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
      ],
    );
  }

  Widget _menuGrid() {
    final items = [
      ('Denemeler', Icons.list_alt, Colors.blue, () async {
        await Navigator.push(context, MaterialPageRoute(builder: (_) => const DenemeListScreen()));
        _load();
      }),
      ('Çalışma', Icons.timer, Colors.purple, () async {
        await Navigator.push(context, MaterialPageRoute(builder: (_) => const CalismaScreen()));
        _load();
      }),
      ('Grafikler', Icons.show_chart, Colors.orange, () {
        Navigator.push(context, MaterialPageRoute(builder: (_) => const GrafikScreen()));
      }),
      ('Ayarlar', Icons.tune, Colors.grey, () async {
        await Navigator.push(context, MaterialPageRoute(builder: (_) => const AyarlarScreen()));
        _load();
      }),
    ];

    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      mainAxisSpacing: 8,
      crossAxisSpacing: 8,
      childAspectRatio: 1.6,
      children: items.map((e) {
        return Card(
          color: e.$3,
          child: InkWell(
            onTap: e.$4,
            borderRadius: BorderRadius.circular(12),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(e.$2, color: Colors.white, size: 32),
                const SizedBox(height: 6),
                Text(e.$1, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }
}
