import 'dart:async';

import 'package:flutter/services.dart';
import 'package:awareframework_core/awareframework_core.dart';
import 'package:flutter/material.dart';

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
  Stream<Map<String,dynamic>> get onDataChanged {
    return super.getBroadcastStream(
        _deviceStream, "on_data_changed"
    ).map((dynamic event) => Map<String,dynamic>.from(event));
  }

  @override
  void cancelAllEventChannels() {
    cancelBroadcastStream("on_data_changed");
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
class DeviceCard extends StatefulWidget { DeviceCard({Key key, @required this.sensor}) : super(key: key);

  final DeviceSensor sensor;
  String deviceInfo = "";

  @override
  DeviceCardState createState() => new DeviceCardState();
}


class DeviceCardState extends State<DeviceCard> {

  @override
  void initState() {

    super.initState();
    // set observer
    widget.sensor.onDataChanged.listen((event) {
      setState((){
        if(event!=null){
          DateTime.fromMicrosecondsSinceEpoch(event['timestamp']);
          widget.deviceInfo = event.toString();
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
          child: new Text(widget.deviceInfo),
        ),
      title: "Device",
      sensor: widget.sensor
    );
  }

  @override
  void dispose() {
    widget.sensor.cancelAllEventChannels();
    super.dispose();
  }

}
