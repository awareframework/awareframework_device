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
    super.setSensorChannels(_deviceMethod, _deviceStream);
  }

  /// A sensor observer instance
  Stream<Map<String,dynamic>> get onDataChanged {
     return super.receiveBroadcastStream("on_data_changed").map((dynamic event) => Map<String,dynamic>.from(event));
  }
}

class DeviceSensorConfig extends AwareSensorConfig{
  DeviceSensorConfig();

  /// TODO

  @override
  Map<String, dynamic> toMap() {
    var map = super.toMap();
    return map;
  }
}

/// Make an AwareWidget
class DeviceCard extends StatefulWidget {
  DeviceCard({Key key, @required this.sensor}) : super(key: key);

  DeviceSensor sensor;

  @override
  DeviceCardState createState() => new DeviceCardState();
}


class DeviceCardState extends State<DeviceCard> {

  List<LineSeriesData> dataLine1 = List<LineSeriesData>();
  List<LineSeriesData> dataLine2 = List<LineSeriesData>();
  List<LineSeriesData> dataLine3 = List<LineSeriesData>();
  int bufferSize = 299;

  @override
  void initState() {

    super.initState();
    // set observer
    widget.sensor.onDataChanged.listen((event) {
      setState((){
        if(event!=null){
          DateTime.fromMicrosecondsSinceEpoch(event['timestamp']);
          StreamLineSeriesChart.add(data:event['x'], into:dataLine1, id:"x", buffer: bufferSize);
          StreamLineSeriesChart.add(data:event['y'], into:dataLine2, id:"y", buffer: bufferSize);
          StreamLineSeriesChart.add(data:event['z'], into:dataLine3, id:"z", buffer: bufferSize);
        }
      });
    }, onError: (dynamic error) {
        print('Received error: ${error.message}');
    });
    print(widget.sensor);
  }


  @override
  Widget build(BuildContext context) {
    return new AwareCard(
      contentWidget: SizedBox(
          height:250.0,
          width: MediaQuery.of(context).size.width*0.8,
          child: new StreamLineSeriesChart(StreamLineSeriesChart.createTimeSeriesData(dataLine1, dataLine2, dataLine3)),
        ),
      title: "Device",
      sensor: widget.sensor
    );
  }

}
