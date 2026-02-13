import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../services/firebase_service.dart';

class AnalyticsScreen extends StatefulWidget {
  static const routeName = '/analytics';

  const AnalyticsScreen({super.key});

  @override
  State<AnalyticsScreen> createState() => _AnalyticsScreenState();
}

class _AnalyticsScreenState extends State<AnalyticsScreen> {
  int _filterIndex = 0;

  DateTime get _from {
    final now = DateTime.now();
    switch (_filterIndex) {
      case 0:
        return DateTime(now.year, now.month, now.day);
      case 1:
        return now.subtract(const Duration(days: 7));
      default:
        return now.subtract(const Duration(days: 30));
    }
  }

  @override
  Widget build(BuildContext context) {
    final firebase = Provider.of<FirebaseService>(context, listen: false);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Analytics'),
      ),
      body: Column(
        children: [
          const SizedBox(height: 8),
          ToggleButtons(
            isSelected: [
              _filterIndex == 0,
              _filterIndex == 1,
              _filterIndex == 2,
            ],
            onPressed: (i) => setState(() => _filterIndex = i),
            children: const [
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 12),
                child: Text('Today'),
              ),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 12),
                child: Text('7 Days'),
              ),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 12),
                child: Text('30 Days'),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Expanded(
            child: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
              stream: firebase.pressureLogsStream(_from),
              builder: (context, snapshot) {
                final docs = snapshot.data?.docs ?? [];
                final spotsLeft = <FlSpot>[];
                final spotsRight = <FlSpot>[];

                for (var i = 0; i < docs.length; i++) {
                  final d = docs[i].data();
                  spotsLeft.add(
                    FlSpot(
                      i.toDouble(),
                      (d['left_front_pressure'] ?? 0).toDouble(),
                    ),
                  );
                  spotsRight.add(
                    FlSpot(
                      i.toDouble(),
                      (d['right_front_pressure'] ?? 0).toDouble(),
                    ),
                  );
                }

                return ListView(
                  padding: const EdgeInsets.all(16),
                  children: [
                    const Text(
                      'Pressure vs Time',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 8),
                    SizedBox(
                      height: 200,
                      child: LineChart(
                        LineChartData(
                          lineBarsData: [
                            LineChartBarData(
                              spots: spotsLeft,
                              isCurved: true,
                              color: Colors.blue,
                            ),
                            LineChartBarData(
                              spots: spotsRight,
                              isCurved: true,
                              color: Colors.green,
                            ),
                          ],
                          titlesData: FlTitlesData(show: false),
                          borderData: FlBorderData(show: false),
                          gridData: FlGridData(show: false),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
                      stream: firebase.batteryLogsStream(_from),
                      builder: (context, snap) {
                        final bdocs = snap.data?.docs ?? [];
                        final leftBat = <FlSpot>[];
                        final rightBat = <FlSpot>[];
                        for (var i = 0; i < bdocs.length; i++) {
                          final d = bdocs[i].data();
                          leftBat.add(
                            FlSpot(
                              i.toDouble(),
                              (d['left_battery'] ?? 0).toDouble(),
                            ),
                          );
                          rightBat.add(
                            FlSpot(
                              i.toDouble(),
                              (d['right_battery'] ?? 0).toDouble(),
                            ),
                          );
                        }
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Battery vs Time',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: 8),
                            SizedBox(
                              height: 200,
                              child: LineChart(
                                LineChartData(
                                  lineBarsData: [
                                    LineChartBarData(
                                      spots: leftBat,
                                      isCurved: true,
                                      color: Colors.orange,
                                    ),
                                    LineChartBarData(
                                      spots: rightBat,
                                      isCurved: true,
                                      color: Colors.red,
                                    ),
                                  ],
                                  titlesData: FlTitlesData(show: false),
                                  borderData: FlBorderData(show: false),
                                  gridData: FlGridData(show: false),
                                ),
                              ),
                            ),
                          ],
                        );
                      },
                    ),
                    const SizedBox(height: 16),
                    StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
                      stream: firebase.alertsStream(_from),
                      builder: (context, snap) {
                        final adocs = snap.data?.docs ?? [];
                        final freezingCount = adocs
                            .where(
                              (d) => d.data()['type'] == 'Freezing',
                            )
                            .length;
                        final imbalanceCount = adocs
                            .where(
                              (d) => d.data()['type'] == 'Imbalance',
                            )
                            .length;

                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Freezing Events',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Row(
                              mainAxisAlignment:
                                  MainAxisAlignment.spaceAround,
                              children: [
                                _analyticsChip(
                                  'Freezing',
                                  freezingCount,
                                  Colors.red,
                                ),
                                _analyticsChip(
                                  'Imbalance',
                                  imbalanceCount,
                                  Colors.orange,
                                ),
                              ],
                            ),
                          ],
                        );
                      },
                    ),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _analyticsChip(String label, int value, Color color) {
    return Chip(
      avatar: CircleAvatar(
        backgroundColor: color,
        child: Text(
          '$value',
          style: const TextStyle(color: Colors.white),
        ),
      ),
      label: Text(label),
    );
  }
}


