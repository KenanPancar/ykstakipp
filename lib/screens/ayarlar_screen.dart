import 'dart:io';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:file_picker/file_picker.dart';
import '../services/database_service.dart';

class AyarlarScreen extends StatefulWidget {
  const AyarlarScreen({super.key});

  @override
  State<AyarlarScreen> createState() => _AyarlarScreenState();
}

class _AyarlarScreenState extends State<AyarlarScreen> {
  final obpCtrl = TextEditingController();
  final sayCtrl = TextEditingController();
  final eaCtrl = TextEditingController();
  final saatCtrl = TextEditingController();
  bool busy = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final db = DatabaseService.instance;
    obpCtrl.text = (await db.getObp()).toStringAsFixed(0);
    sayCtrl.text = (await db.getHedefSay()).toString();
    eaCtrl.text = (await db.getHedefEa()).toString();
    saatCtrl.text = (await db.getHedefSaat()).toStringAsFixed(0);
  }

  Future<void> _save() async {
    final db = DatabaseService.instance;
    final obp = double.tryParse(obpCtrl.text);
    final say = int.tryParse(sayCtrl.text);
    final ea = int.tryParse(eaCtrl.text);
    final saat = double.tryParse(saatCtrl.text);
    if (obp != null) await db.setObp(obp.clamp(250, 500));
    if (say != null) await db.setHedefSay(say);
    if (ea != null) await db.setHedefEa(ea);
    if (saat != null) await db.setHedefSaat(saat.clamp(100, 10000));
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Kaydedildi')),
      );
      Navigator.pop(context);
    }
  }

  Future<void> _yedekAl() async {
    setState(() => busy = true);
    try {
      final json = await DatabaseService.instance.exportBackupJson();
      final dir = await getTemporaryDirectory();
      final name =
          'yks_yedek_${DateTime.now().toIso8601String().substring(0, 10)}.json';
      final file = File('${dir.path}/$name');
      await file.writeAsString(json);
      await Share.shareXFiles(
        [XFile(file.path)],
        text: 'YKS Takip yedegi',
      );
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text(
                  'Yedek paylasim menusune gitti — Drive/Dosyalara kaydet')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Yedek hatasi: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => busy = false);
    }
  }

  Future<void> _yedektenYukle() async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Yedekten yukle'),
        content: const Text(
          'Mevcut tum deneme ve calisma kayitlarinin uzerine yazilacak. Emin misin?',
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('Iptal')),
          FilledButton(
              onPressed: () => Navigator.pop(ctx, true),
              child: const Text('Yukle')),
        ],
      ),
    );
    if (ok != true) return;

    setState(() => busy = true);
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['json'],
        withData: true,
      );
      if (result == null || result.files.isEmpty) {
        setState(() => busy = false);
        return;
      }
      final file = result.files.first;
      String? text =
          file.bytes != null ? String.fromCharCodes(file.bytes!) : null;
      if (text == null && file.path != null) {
        text = await File(file.path!).readAsString();
      }
      if (text == null || text.isEmpty) {
        throw Exception('Dosya okunamadi');
      }
      await DatabaseService.instance.importBackupJson(text);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Yedek yuklendi')),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Yukleme hatasi: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Ayarlar')),
      body: busy
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.all(16),
              children: [
                TextField(
                  controller: obpCtrl,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: 'OBP (250-500)',
                    border: OutlineInputBorder(),
                    helperText: 'Diploma notu x 5',
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: sayCtrl,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: 'SAY Hedef Sira',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: eaCtrl,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: 'EA Hedef Sira',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: saatCtrl,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: 'Calisma Saat Hedefi',
                    border: OutlineInputBorder(),
                    helperText: 'Varsayilan 3000 saat',
                  ),
                ),
                const SizedBox(height: 24),
                FilledButton.icon(
                  onPressed: _save,
                  icon: const Icon(Icons.save),
                  label: const Text('Kaydet'),
                  style: FilledButton.styleFrom(
                      minimumSize: const Size.fromHeight(48)),
                ),
                const SizedBox(height: 32),
                const Text('Yedekleme',
                    style:
                        TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                const SizedBox(height: 8),
                const Text(
                  'Veriler telefonda tutulur. Telefonu sifirlamadan once yedek al.',
                  style: TextStyle(color: Colors.black54, fontSize: 13),
                ),
                const SizedBox(height: 12),
                OutlinedButton.icon(
                  onPressed: _yedekAl,
                  icon: const Icon(Icons.backup),
                  label: const Text('Yedek al (JSON paylas)'),
                  style: OutlinedButton.styleFrom(
                      minimumSize: const Size.fromHeight(48)),
                ),
                const SizedBox(height: 8),
                OutlinedButton.icon(
                  onPressed: _yedektenYukle,
                  icon: const Icon(Icons.restore),
                  label: const Text('Yedekten geri yukle'),
                  style: OutlinedButton.styleFrom(
                      minimumSize: const Size.fromHeight(48)),
                ),
                const SizedBox(height: 24),
                const Text(
                  'Yedek dosyasini Google Drive / Dosyalar uygulamasina kaydet.\n'
                  'Internet baglantisini uygulama kendisi acmaz; paylasimi sen secersin.',
                  style: TextStyle(color: Colors.black54, fontSize: 12),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
    );
  }
}
