import 'package:flutter/material.dart';

import 'package:awareframework_device/awareframework_device.dart';

void main() => runApp(new MyApp());

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => new _MyAppState();
}

class _MyAppState extends State<MyApp> {

  DeviceSensor sensor;
  DeviceSensorConfig config;

  @override
  void initState() {
    super.initState();

    config = DeviceSensorConfig()
      ..debug = true;

    sensor = new DeviceSensor.init(config);

    sensor.start();
  }

  @override
  Widget build(BuildContext context) {
    return new MaterialApp(
      home: new Scaffold(
          appBar: new AppBar(
            title: const Text('Plugin Example App'),
          ),
          body: new DeviceCard(sensor: sensor,)
      ),
    );
  }
}
