import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../models/deneme.dart';
import '../services/database_service.dart';
import '../data/ranking_2026.dart';

class GrafikScreen extends StatefulWidget {
  const GrafikScreen({super.key});

  @override
  State<GrafikScreen> createState() => _GrafikScreenState();
}

class _GrafikScreenState extends State<GrafikScreen> {
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
      appBar: AppBar(title: const Text('Grafikler')),
      body: list.isEmpty
          ? const Center(child: Text('Grafik için deneme ekle'))
          : ListView(
              padding: const EdgeInsets.all(12),
              children: [
                _chartCard(
                  'SAY Sıra Gelişimi',
                  _siraSpots(),
                  Colors.blue,
                  invertY: true,
                ),
                _chartCard(
                  'TYT Toplam Net',
                  _spots((d) => d.tytTop),
                  Colors.indigo,
                ),
                _chartCard(
                  'AYT SAY Net',
                  _spots((d) => d.aytSay),
                  Colors.green,
                ),
                _chartCard(
                  'AYT Mat Net',
                  _spots((d) => d.aytMat),
                  Colors.orange,
                ),
              ],
            ),
    );
  }

  List<FlSpot> _spots(double? Function(Deneme) getter) {
    final spots = <FlSpot>[];
    for (int i = 0; i < list.length; i++) {
      final v = getter(list[i]);
      if (v != null) spots.add(FlSpot(i.toDouble() + 1, v));
    }
    return spots;
  }

  List<FlSpot> _siraSpots() {
    final spots = <FlSpot>[];
    for (int i = 0; i < list.length; i++) {
      final p = list[i].sayPuan(obp);
      if (p != null) {
        spots.add(FlSpot(i.toDouble() + 1, Ranking2026.saySira(p).toDouble()));
      }
    }
    return spots;
  }

  Widget _chartCard(String title, List<FlSpot> spots, Color color,
      {bool invertY = false}) {
    if (spots.isEmpty) {
      return Card(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Text('$title — veri yok'),
        ),
      );
    }
    final ys = spots.map((s) => s.y);
    final minY = ys.reduce((a, b) => a < b ? a : b);
    final maxY = ys.reduce((a, b) => a > b ? a : b);
    final pad = (maxY - minY) * 0.1 + 1;

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            SizedBox(
              height: 200,
              child: LineChart(
                LineChartData(
                  minY: invertY ? minY - pad : (minY - pad).clamp(0, double.infinity),
                  maxY: maxY + pad,
                  gridData: const FlGridData(show: true),
                  borderData: FlBorderData(show: true),
                  titlesData: FlTitlesData(
                    topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 22,
                        getTitlesWidget: (v, _) => Text(
                          v.toInt().toString(),
                          style: const TextStyle(fontSize: 10),
                        ),
                      ),
                    ),
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 40,
                        getTitlesWidget: (v, _) => Text(
                          v >= 1000 ? '${(v / 1000).toStringAsFixed(0)}k' : v.toInt().toString(),
                          style: const TextStyle(fontSize: 10),
                        ),
                      ),
                    ),
                  ),
                  lineBarsData: [
                    LineChartBarData(
                      spots: spots,
                      isCurved: false,
                      color: color,
                      barWidth: 0,
                      dotData: FlDotData(
                        show: true,
                        getDotPainter: (_, __, ___, ____) => FlDotCirclePainter(
                          radius: 5,
                          color: color,
                          strokeWidth: 0,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
