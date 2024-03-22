import 'package:flutter/material.dart';
import 'package:sqflite/sqflite.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _SettingsScreenState createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  late Database _database;
  bool _isMetric = true;

  @override
  void initState() {
    super.initState();
    _initDatabase();
  }

  Future<void> _initDatabase() async {
    _database = await openDatabase(
      'health_tracker.db',
      version: 1,
      onCreate: (Database db, int version) async {
        await db.execute(
          'CREATE TABLE settings (id INTEGER PRIMARY KEY, isMetric INTEGER)',
        );
        await db.execute(
          'INSERT INTO settings (isMetric) VALUES (1)',
        );
      },
    );
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final List<Map<String, dynamic>> settings =
        await _database.rawQuery('SELECT * FROM settings');
    setState(() {
      _isMetric = settings[0]['isMetric'] == 1;
    });
  }

  Future<void> _updateSettings(bool isMetric) async {
    await _database.rawUpdate(
      'UPDATE settings SET isMetric = ? WHERE id = 1',
      [isMetric ? 1 : 0],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const Text(
              'Unit Settings',
              style: TextStyle(fontSize: 20),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                const Text('Metric'),
                Switch(
                  value: _isMetric,
                  onChanged: (value) {
                    setState(() {
                      _isMetric = value;
                    });
                    _updateSettings(value);
                  },
                ),
                const Text('Imperial'),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
