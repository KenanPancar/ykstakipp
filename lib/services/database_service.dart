import 'dart:convert';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/deneme.dart';


class DatabaseService {
  static final DatabaseService instance = DatabaseService._();
  DatabaseService._();
  Database? _db;

  Future<Database> get database async {
    if (_db != null) return _db!;
    _db = await _init();
    return _db!;
  }

  Future<Database> _init() async {
    final path = join(await getDatabasesPath(), 'yks_takip.db');
    return openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE denemeler (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            tarih TEXT,
            turkce REAL, sosyal REAL, tyt_mat REAL, fen REAL,
            ayt_mat REAL, fizik REAL, kimya REAL, biyoloji REAL,
            edeb REAL, tarih1 REAL, cog1 REAL
          )
        ''');
        await db.execute('''
          CREATE TABLE calisma (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            tarih TEXT NOT NULL,
            saat REAL NOT NULL,
            not_text TEXT
          )
        ''');
        await db.execute('''
          CREATE TABLE ayarlar (
            key TEXT PRIMARY KEY,
            value TEXT
          )
        ''');
      },
    );
  }

  // --- Deneme ---
  Future<int> insertDeneme(Deneme d) async {
    final db = await database;
    return db.insert('denemeler', d.toMap()..remove('id'));
  }

  Future<int> updateDeneme(Deneme d) async {
    final db = await database;
    return db.update('denemeler', d.toMap(), where: 'id = ?', whereArgs: [d.id]);
  }

  Future<int> deleteDeneme(int id) async {
    final db = await database;
    return db.delete('denemeler', where: 'id = ?', whereArgs: [id]);
  }

  Future<List<Deneme>> getAllDenemeler() async {
    final db = await database;
    final rows = await db.query('denemeler', orderBy: 'id ASC');
    return rows.map((e) => Deneme.fromMap(e)).toList();
  }

  // --- Çalışma ---
  Future<int> insertCalisma(GunlukCalisma c) async {
    final db = await database;
    return db.insert('calisma', c.toMap()..remove('id'));
  }

  Future<List<GunlukCalisma>> getAllCalisma() async {
    final db = await database;
    final rows = await db.query('calisma', orderBy: 'id ASC');
    return rows.map((e) => GunlukCalisma.fromMap(e)).toList();
  }

  Future<double> toplamSaat() async {
    final db = await database;
    final r = await db.rawQuery('SELECT SUM(saat) as t FROM calisma');
    return (r.first['t'] as num?)?.toDouble() ?? 0;
  }

  // --- Ayarlar ---
  Future<void> setSetting(String key, String value) async {
    final db = await database;
    await db.insert(
      'ayarlar',
      {'key': key, 'value': value},
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<String?> getSetting(String key) async {
    final db = await database;
    final r = await db.query('ayarlar', where: 'key = ?', whereArgs: [key]);
    if (r.isEmpty) return null;
    return r.first['value'] as String?;
  }

  Future<double> getObp() async {
    final v = await getSetting('obp');
    return double.tryParse(v ?? '400') ?? 400;
  }

  Future<void> setObp(double v) => setSetting('obp', v.toString());

  Future<int> getHedefSay() async {
    final v = await getSetting('hedef_say');
    return int.tryParse(v ?? '15000') ?? 15000;
  }

  Future<void> setHedefSay(int v) => setSetting('hedef_say', v.toString());

  Future<int> getHedefEa() async {
    final v = await getSetting('hedef_ea');
    return int.tryParse(v ?? '20000') ?? 20000;
  }

  Future<void> setHedefEa(int v) => setSetting('hedef_ea', v.toString());

  Future<double> getHedefSaat() async {
    final v = await getSetting('hedef_saat');
    return double.tryParse(v ?? '3000') ?? 3000;
  }

  Future<void> setHedefSaat(double v) => setSetting('hedef_saat', v.toString());

  Future<DateTime?> ilkCalismaTarihi() async {
    final db = await database;
    final r = await db.query('calisma', orderBy: 'id ASC', limit: 1);
    if (r.isEmpty) return null;
    final t = r.first['tarih'] as String?;
    if (t == null) return null;
    final p = t.split('.');
    if (p.length != 3) return null;
    return DateTime(int.parse(p[2]), int.parse(p[1]), int.parse(p[0]));
  }

  /// Tüm veriyi JSON string olarak dışa aktar
  Future<String> exportBackupJson() async {
    final db = await database;
    final denemeler = await db.query('denemeler', orderBy: 'id ASC');
    final calisma = await db.query('calisma', orderBy: 'id ASC');
    final ayarlar = await db.query('ayarlar');
    final map = {
      'version': 1,
      'exported_at': DateTime.now().toIso8601String(),
      'denemeler': denemeler,
      'calisma': calisma,
      'ayarlar': ayarlar,
    };
    return const JsonEncoder.withIndent('  ').convert(map);
  }

  /// JSON yedekten geri yükle (mevcut verinin üzerine yazar)
  Future<void> importBackupJson(String jsonStr) async {
    final map = jsonDecode(jsonStr) as Map<String, dynamic>;
    final db = await database;
    await db.transaction((txn) async {
      await txn.delete('denemeler');
      await txn.delete('calisma');
      await txn.delete('ayarlar');

      final denemeler = (map['denemeler'] as List?) ?? [];
      for (final row in denemeler) {
        final m = Map<String, dynamic>.from(row as Map);
        m.remove('id');
        await txn.insert('denemeler', m);
      }

      final calisma = (map['calisma'] as List?) ?? [];
      for (final row in calisma) {
        final m = Map<String, dynamic>.from(row as Map);
        m.remove('id');
        await txn.insert('calisma', m);
      }

      final ayarlar = (map['ayarlar'] as List?) ?? [];
      for (final row in ayarlar) {
        final m = Map<String, dynamic>.from(row as Map);
        await txn.insert('ayarlar', m);
      }
    });
  }
}


