import 'package:flutter/material.dart';
import '../models/deneme.dart';
import '../services/database_service.dart';
import '../data/ranking_2026.dart';
import 'deneme_form_screen.dart';

class DenemeListScreen extends StatefulWidget {
  const DenemeListScreen({super.key});

  @override
  State<DenemeListScreen> createState() => _DenemeListScreenState();
}

class _DenemeListScreenState extends State<DenemeListScreen> {
  List<Deneme> list = [];
  double obp = 400;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    list = await DatabaseService.instance.getAllDenemeler();
    obp = await DatabaseService.instance.getObp();
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Denemeler (${list.length})')),
      body: list.isEmpty
          ? const Center(child: Text('Henüz deneme yok'))
          : ListView.builder(
              itemCount: list.length,
              itemBuilder: (ctx, i) {
                final d = list[list.length - 1 - i]; // newest first
                final sayP = d.sayPuan(obp);
                final sayS = sayP != null ? Ranking2026.saySira(sayP) : null;
                return Card(
                  margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: Colors.blue.shade700,
                      child: Text('${list.length - i}',
                          style: const TextStyle(color: Colors.white, fontSize: 12)),
                    ),
                    title: Text(d.tarih ?? 'Deneme #${d.id}'),
                    subtitle: Text(
                      'TYT: ${d.tytTop?.toStringAsFixed(0) ?? "-"}  ·  '
                      'AYT: ${d.aytSay?.toStringAsFixed(0) ?? "-"}\n'
                      'SAY: ${sayP?.toStringAsFixed(0) ?? "-"}p / ${sayS ?? "-"} sıra',
                    ),
                    isThreeLine: true,
                    trailing: PopupMenuButton(
                      itemBuilder: (_) => [
                        const PopupMenuItem(value: 'edit', child: Text('Düzenle')),
                        const PopupMenuItem(value: 'del', child: Text('Sil')),
                      ],
                      onSelected: (v) async {
                        if (v == 'edit') {
                          await Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (_) => DenemeFormScreen(deneme: d)),
                          );
                          _load();
                        } else if (v == 'del' && d.id != null) {
                          await DatabaseService.instance.deleteDeneme(d.id!);
                          _load();
                        }
                      },
                    ),
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          await Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const DenemeFormScreen()),
          );
          _load();
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
