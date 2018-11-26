import 'dart:async';

import 'package:flutter/services.dart';
import 'package:awareframework_core/awareframework_core.dart';
import 'package:flutter/material.dart';
import 'package:charts_flutter/flutter.dart' as charts;

/// init sensor
class DeviceSensor extends AwareSensorCore {
  static const MethodChannel _deviceMethod = const MethodChannel('awareframework_device/method');
  static const EventChannel  _deviceStream  = const EventChannel('awareframework_device/event');

  /// Init Device Sensor with DeviceSensorConfig
  DeviceSensor(DeviceSensorConfig config):this.convenience(config);
  DeviceSensor.convenience(config) : super(config){
    /// Set sensor method & event channels
    super.setMethodChannel(_deviceMethod);
  }

  /// A sensor observer instance
  Stream<Map<String,dynamic>> onDataChanged(String id) {
    return super.getBroadcastStream(_deviceStream, "on_data_changed", id).map((dynamic event) => Map<String,dynamic>.from(event));
  }
}

class DeviceSensorConfig extends AwareSensorConfig{
  DeviceSensorConfig();

  @override
  Map<String, dynamic> toMap() {
    var map = super.toMap();
    return map;
  }
}

/// Make an AwareWidget
class DeviceCard extends StatefulWidget {
  DeviceCard({Key key, @required this.sensor, this.cardId = "device_card"}) : super(key: key);

  DeviceSensor sensor;
  String cardId;

  @override
  DeviceCardState createState() => new DeviceCardState();
}


class DeviceCardState extends State<DeviceCard> {

  String deviceInfo = "";

  @override
  void initState() {

    super.initState();
    // set observer
    widget.sensor.onDataChanged(widget.cardId).listen((event) {
      setState((){
        if(event!=null){
          DateTime.fromMicrosecondsSinceEpoch(event['timestamp']);
          deviceInfo = event.toString();
        }
      });
    }, onError: (dynamic error) {
        print('Received error: ${error.message}');
    });
    print(widget.sensor);
    widget.sensor.start();
  }


  @override
  Widget build(BuildContext context) {
    return new AwareCard(
      contentWidget: SizedBox(
          width: MediaQuery.of(context).size.width*0.8,
          child: new Text(deviceInfo),
        ),
      title: "Device",
      sensor: widget.sensor
    );
  }

  @override
  void dispose() {
    // TODO: implement dispose
    widget.sensor.cancelBroadcastStream(widget.cardId);
    super.dispose();
  }

}
