import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:health_tracker/view/SettingsScreen.dart';
import 'package:pedometer/pedometer.dart';
import 'package:sqflite/sqflite.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _DashboardScreenState createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  int _stepsCount = 0;
  int _waterIntake = 0;
  final int _calorieIntake = 0;
  late Database _database;
  bool _isDatabaseInitialized = false;
  @override
  void initState() {
    super.initState();
    _initStepCount();
    _initDatabase();
    _initializeApp();
    _loadWaterIntake();
  }

  Future<void> _initializeApp() async {
    await _initDatabase();
    setState(() {
      _isDatabaseInitialized = true;
    });
    if (_isDatabaseInitialized) {
      await _loadWaterIntake();
    }
  }

  Future<void> _addWaterIntake(int amount) async {
    if (!_isDatabaseInitialized) {
      return;
    }

    final DateTime now = DateTime.now();
    try {
      await _database.transaction((txn) async {
        await txn.rawInsert(
          'INSERT INTO water_intake (amount, date) VALUES (?, ?)',
          [amount, now.toIso8601String()],
        );
      });

      await _loadWaterIntake();
    } catch (e) {
      ("Error adding water intake: $e");
    }
  }

  Future<void> _initDatabase() async {
    try {
      _database = await openDatabase(
        'health_tracker.db',
        version: 1,
        onCreate: (Database db, int version) async {
          await db.execute(
            'CREATE TABLE settings (id INTEGER PRIMARY KEY, isMetric INTEGER)',
          );
          await db.execute(
            'CREATE TABLE water_intake (id INTEGER PRIMARY KEY, amount INTEGER, date TEXT)',
          );
          await db.execute(
            'INSERT INTO settings (isMetric) VALUES (1)',
          );
        },
      );

      await _addWaterIntake(0);
      await _loadWaterIntake();
    } catch (e) {
      print("Error initializing database: $e");
    }
  }

  void _initStepCount() {
    Pedometer.stepCountStream.listen((stepCount) {
      setState(() {
        _stepsCount = stepCount.steps;
      });
    });
  }

  Future<void> _loadWaterIntake() async {
    final List<Map<String, dynamic>> intake = await _database
        .rawQuery('SELECT SUM(amount) AS total FROM water_intake');
    setState(() {
      _waterIntake = intake[0]['total'] ?? 0;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 230, 227, 227),
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 230, 227, 227),
        centerTitle: true,
        title: const Text(
          'Health Tracker',
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => const SettingsScreen()),
                );
              },
              icon: const Icon(Icons.settings))
        ],
      ),
      body: Center(
        child: Column(
          children: <Widget>[
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Column(
                  children: [
                    CircleAvatar(
                      radius: 65,
                      child: Text(
                        '$_stepsCount',
                        style: const TextStyle(fontSize: 24),
                      ),
                    ),
                    const Text(
                      'Steps Count',
                      style: TextStyle(fontSize: 18),
                    ),
                  ],
                ),
                InkWell(
                  onTap: () {
                    _addWaterIntake(250);
                  },
                  child: Column(
                    children: [
                      CircleAvatar(
                        radius: 65,
                        child: Text(
                          '$_waterIntake ml',
                          style: const TextStyle(fontSize: 24),
                        ),
                      ),
                      const Text(
                        'Water Intake',
                        style: TextStyle(fontSize: 18),
                      ),
                    ],
                  ),
                ),
                Column(
                  children: [
                    CircleAvatar(
                      radius: 65,
                      child: Text(
                        '$_calorieIntake kcal',
                        style: const TextStyle(fontSize: 24),
                      ),
                    ),
                    const Text(
                      'Calorie Intake',
                      style: TextStyle(fontSize: 18),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(
              height: 30,
            ),
            SizedBox(
              width: 300,
              height: 200,
              child: LineChart(
                LineChartData(
                  titlesData: const FlTitlesData(
                    bottomTitles: AxisTitles(sideTitles: SideTitles()),
                    leftTitles: AxisTitles(),
                  ),
                  borderData: FlBorderData(show: false),
                  lineBarsData: [
                    LineChartBarData(
                      spots: [
                        const FlSpot(0, 0),
                        const FlSpot(1, 50),
                        const FlSpot(2, 150),
                        const FlSpot(3, 100),
                        const FlSpot(4, 200),
                        const FlSpot(5, 250),
                        const FlSpot(6, 300),
                      ],
                      isCurved: true,
                      color: Colors.blue,
                      barWidth: 4,
                      isStrokeCapRound: true,
                      belowBarData: BarAreaData(show: false),
                    ),
                  ],
                ),
                duration: const Duration(milliseconds: 150),
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}
