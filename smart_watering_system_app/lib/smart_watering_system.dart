import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';

class SmartWateringSystem extends StatefulWidget {
  @override
  _SmartWateringSystemState createState() => _SmartWateringSystemState();
}

class _SmartWateringSystemState extends State<SmartWateringSystem> {
  final DatabaseReference _dbRef = FirebaseDatabase.instance.ref();
  bool _manualControl = false;
  bool _pumpStatus = false;
  int _soilMoisture = 0;

  @override
  void initState() {
    super.initState();

    // Listen to changes in Firebase Realtime Database
    _dbRef.child('manualControl').onValue.listen((event) {
      setState(() {
        _manualControl = (event.snapshot.value as bool?) ?? false;
      });
    });

    _dbRef.child('pumpStatus').onValue.listen((event) {
      setState(() {
        _pumpStatus = (event.snapshot.value as bool?) ?? false;
      });
    });

    _dbRef.child('soilMoisture').onValue.listen((event) {
      setState(() {
        _soilMoisture = (event.snapshot.value as int?) ?? 0;
      });
    });
  }

  // Toggle manual control
  void _toggleManualControl() {
    setState(() {
      _manualControl = !_manualControl;
    });
    _dbRef.child('manualControl').set(_manualControl);
  }

  // Toggle pump status in manual mode
  void _togglePumpStatus() {
    if (_manualControl) {
      setState(() {
        _pumpStatus = !_pumpStatus;
      });
      _dbRef.child('pumpStatus').set(_pumpStatus);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Smart Watering System'),
        centerTitle: true,
        backgroundColor: Colors.green,
      ),
      body: Container(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Soil Moisture Animation
            AnimatedContainer(
              duration: const Duration(seconds: 1),
              curve: Curves.easeInOut,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: _soilMoisture <= 30 ? Colors.brown : Colors.green,
              ),
              height: 150,
              width: 150,
              child: Icon(
                _soilMoisture <= 30 ? Icons.water_drop : Icons.grass,
                size: 100,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 20),
            Text(
              'Soil Moisture: $_soilMoisture%',
              style: const TextStyle(fontSize: 18),
            ),
            const SizedBox(height: 30),
            // Manual Control Switch
            SwitchListTile(
              title: const Text('Manual Control'),
              value: _manualControl,
              onChanged: (value) {
                _toggleManualControl();
              },
            ),
            const SizedBox(height: 20),
            // Pump Control Button
            ElevatedButton(
              onPressed: _manualControl ? _togglePumpStatus : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: _pumpStatus ? Colors.red : Colors.green,
                padding: const EdgeInsets.symmetric(
                    vertical: 15.0, horizontal: 30.0),
              ),
              child: Text(
                _pumpStatus ? 'Turn Pump OFF' : 'Turn Pump ON',
                style:
                    const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ),
            const SizedBox(height: 30),
            // Pump Status Indicator
            AnimatedContainer(
              duration: const Duration(milliseconds: 500),
              color: _pumpStatus ? Colors.blueAccent : Colors.grey,
              padding: const EdgeInsets.all(20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.electric_bolt,
                    color: _pumpStatus ? Colors.yellow : Colors.black45,
                    size: 40,
                  ),
                  const SizedBox(width: 10),
                  Text(
                    _pumpStatus ? 'Pump is ON' : 'Pump is OFF',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: _pumpStatus ? Colors.white : Colors.black54,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
