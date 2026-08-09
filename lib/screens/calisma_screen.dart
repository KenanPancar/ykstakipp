import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/deneme.dart';
import '../services/database_service.dart';

class CalismaScreen extends StatefulWidget {
  const CalismaScreen({super.key});

  @override
  State<CalismaScreen> createState() => _CalismaScreenState();
}

class _CalismaScreenState extends State<CalismaScreen> {
  List<GunlukCalisma> list = [];
  double toplam = 0;
  final saatCtrl = TextEditingController();
  final notCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    list = await DatabaseService.instance.getAllCalisma();
    toplam = await DatabaseService.instance.toplamSaat();
    setState(() {});
  }

  Future<void> _ekle() async {
    final s = double.tryParse(saatCtrl.text.replaceAll(',', '.'));
    if (s == null || s <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Geçerli bir saat gir')),
      );
      return;
    }
    await DatabaseService.instance.insertCalisma(GunlukCalisma(
      tarih: DateFormat('dd.MM.yyyy').format(DateTime.now()),
      saat: s,
      not: notCtrl.text.isEmpty ? null : notCtrl.text,
    ));
    saatCtrl.clear();
    notCtrl.clear();
    _load();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Günlük Çalışma')),
      body: Column(
        children: [
          Card(
            margin: const EdgeInsets.all(12),
            color: Colors.purple.shade700,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.timer, color: Colors.white),
                  const SizedBox(width: 8),
                  Text(
                    'Toplam: ${toplam.toStringAsFixed(1)} saat',
                    style: const TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Row(
              children: [
                Expanded(
                  flex: 2,
                  child: TextField(
                    controller: saatCtrl,
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    decoration: const InputDecoration(
                      labelText: 'Saat',
                      border: OutlineInputBorder(),
                      isDense: true,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  flex: 3,
                  child: TextField(
                    controller: notCtrl,
                    decoration: const InputDecoration(
                      labelText: 'Not (opsiyonel)',
                      border: OutlineInputBorder(),
                      isDense: true,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                FilledButton(onPressed: _ekle, child: const Text('Ekle')),
              ],
            ),
          ),
          const SizedBox(height: 8),
          Expanded(
            child: list.isEmpty
                ? const Center(child: Text('Henüz kayıt yok'))
                : ListView.builder(
                    itemCount: list.length,
                    itemBuilder: (_, i) {
                      final c = list[list.length - 1 - i];
                      return ListTile(
                        leading: const Icon(Icons.access_time, color: Colors.purple),
                        title: Text('${c.saat} saat'),
                        subtitle: Text('${c.tarih}${c.not != null ? " · ${c.not}" : ""}'),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
