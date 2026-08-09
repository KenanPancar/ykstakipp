import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/deneme.dart';
import '../services/database_service.dart';
import '../data/ranking_2026.dart';

class DenemeFormScreen extends StatefulWidget {
  final Deneme? deneme;
  const DenemeFormScreen({super.key, this.deneme});

  @override
  State<DenemeFormScreen> createState() => _DenemeFormScreenState();
}

class _DenemeFormScreenState extends State<DenemeFormScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController tarih;
  late TextEditingController turkce, sosyal, tytMat, fen;
  late TextEditingController aytMat, fizik, kimya, biyoloji;
  late TextEditingController edeb, tarih1, cog1;
  double? previewSay, previewEa;
  int? previewSaySira, previewEaSira;

  @override
  void initState() {
    super.initState();
    final d = widget.deneme;
    tarih = TextEditingController(
        text: d?.tarih ?? DateFormat('dd.MM.yyyy').format(DateTime.now()));
    turkce = TextEditingController(text: d?.turkce?.toString() ?? '');
    sosyal = TextEditingController(text: d?.sosyal?.toString() ?? '');
    tytMat = TextEditingController(text: d?.tytMat?.toString() ?? '');
    fen = TextEditingController(text: d?.fen?.toString() ?? '');
    aytMat = TextEditingController(text: d?.aytMat?.toString() ?? '');
    fizik = TextEditingController(text: d?.fizik?.toString() ?? '');
    kimya = TextEditingController(text: d?.kimya?.toString() ?? '');
    biyoloji = TextEditingController(text: d?.biyoloji?.toString() ?? '');
    edeb = TextEditingController(text: d?.edeb?.toString() ?? '');
    tarih1 = TextEditingController(text: d?.tarih1?.toString() ?? '');
    cog1 = TextEditingController(text: d?.cog1?.toString() ?? '');
    _preview();
  }

  double? _p(TextEditingController c) => double.tryParse(c.text.replaceAll(',', '.'));

  Future<void> _preview() async {
    final obp = await DatabaseService.instance.getObp();
    final d = _build();
    setState(() {
      previewSay = d.sayPuan(obp);
      previewEa = d.eaPuan(obp);
      previewSaySira = previewSay != null ? Ranking2026.saySira(previewSay!) : null;
      previewEaSira = previewEa != null ? Ranking2026.eaSira(previewEa!) : null;
    });
  }

  Deneme _build() => Deneme(
        id: widget.deneme?.id,
        tarih: tarih.text,
        turkce: _p(turkce),
        sosyal: _p(sosyal),
        tytMat: _p(tytMat),
        fen: _p(fen),
        aytMat: _p(aytMat),
        fizik: _p(fizik),
        kimya: _p(kimya),
        biyoloji: _p(biyoloji),
        edeb: _p(edeb),
        tarih1: _p(tarih1),
        cog1: _p(cog1),
      );

  Future<void> _save() async {
    final d = _build();
    if (widget.deneme == null) {
      await DatabaseService.instance.insertDeneme(d);
    } else {
      await DatabaseService.instance.updateDeneme(d);
    }
    if (mounted) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.deneme == null ? 'Yeni Deneme' : 'Deneme Düzenle'),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            TextFormField(
              controller: tarih,
              decoration: const InputDecoration(
                labelText: 'Tarih',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.calendar_today),
              ),
            ),
            const SizedBox(height: 16),
            const Text('TYT', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            const SizedBox(height: 8),
            _netRow([
              ('Türkçe', turkce),
              ('Sosyal', sosyal),
              ('Mat', tytMat),
              ('Fen', fen),
            ]),
            const SizedBox(height: 16),
            const Text('AYT Sayısal', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            const SizedBox(height: 8),
            _netRow([
              ('Mat', aytMat),
              ('Fizik', fizik),
              ('Kimya', kimya),
              ('Biyo', biyoloji),
            ]),
            const SizedBox(height: 16),
            const Text('AYT EA (opsiyonel)', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            const SizedBox(height: 8),
            _netRow([
              ('Edeb', edeb),
              ('Tarih1', tarih1),
              ('Coğ1', cog1),
            ]),
            const SizedBox(height: 20),
            Card(
              color: Colors.blue.shade50,
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  children: [
                    Text(
                      'SAY: ${previewSay?.toStringAsFixed(0) ?? "-"} puan  ·  ${previewSaySira ?? "-"} sıra',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'EA: ${previewEa?.toStringAsFixed(0) ?? "-"} puan  ·  ${previewEaSira ?? "-"} sıra',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),
            FilledButton.icon(
              onPressed: _save,
              icon: const Icon(Icons.save),
              label: const Text('Kaydet'),
              style: FilledButton.styleFrom(
                minimumSize: const Size.fromHeight(48),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _netRow(List<(String, TextEditingController)> fields) {
    return Row(
      children: fields.map((f) {
        return Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: TextFormField(
              controller: f.$2,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              decoration: InputDecoration(
                labelText: f.$1,
                border: const OutlineInputBorder(),
                isDense: true,
              ),
              onChanged: (_) => _preview(),
            ),
          ),
        );
      }).toList(),
    );
  }
}
