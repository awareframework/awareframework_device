import 'dart:async';

import 'package:flutter/services.dart';
import 'package:awareframework_core/awareframework_core.dart';
import 'package:flutter/material.dart';


/// The Device measures the acceleration applied to the sensor
/// built-in into the device, including the force of gravity.
///
/// Your can initialize this class by the following code.
/// ```dart
/// var sensor = DeviceSensor();
/// ```
///
/// If you need to initialize the sensor with configurations,
/// you can use the following code instead of the above code.
/// ```dart
/// var config =  DeviceSensorConfig();
/// config
///   ..debug = true
///   ..frequency = 100;
///
/// var sensor = DeviceSensor.init(config);
/// ```
///
/// Each sub class of AwareSensor provides the following method for controlling
/// the sensor:
/// - `start()`
/// - `stop()`
/// - `enable()`
/// - `disable()`
/// - `sync()`
/// - `setLabel(String label)`
///
/// `Stream<DeviceData>` allow us to monitor the sensor update
/// events as follows:
///
/// ```dart
/// sensor.onDataChanged.listen((data) {
///   print(data)
/// }
/// ```
///
/// In addition, this package support data visualization function on Cart Widget.
/// You can generate the Cart Widget by following code.
/// ```dart
/// var card = DeviceCard(sensor: sensor);
/// ```
class DeviceSensor extends AwareSensor {
  static const MethodChannel _deviceMethod = const MethodChannel('awareframework_device/method');
  // static const EventChannel  _deviceStream  = const EventChannel('awareframework_device/event');

  static const EventChannel  _onDataChangedStream  = const EventChannel('awareframework_device/event_on_data_changed');

  static StreamController<DeviceData> onDataChangedStreamController = StreamController<DeviceData>();

  DeviceData deviceData = DeviceData();

  /// Init Device Sensor without a configuration file
  ///
  /// ```dart
  /// var sensor = DeviceSensor.init(null);
  /// ```
  DeviceSensor():this.init(null);

  /// Init Device Sensor with DeviceSensorConfig
  ///
  /// ```dart
  /// var config =  DeviceSensorConfig();
  /// config
  ///   ..debug = true
  ///   ..frequency = 100;
  ///
  /// var sensor = DeviceSensor.init(config);
  /// ```
  DeviceSensor.init(DeviceSensorConfig config) : super(config){
    super.setMethodChannel(_deviceMethod);
  }

  /// An event channel for monitoring sensor events.
  ///
  /// `Stream<DeviceData>` allow us to monitor the sensor update
  /// events as follows:
  ///
  /// ```dart
  /// sensor.onDataChanged.listen((data) {
  ///   print(data)
  /// }
  ///
  /// [Creating Streams](https://www.dartlang.org/articles/libraries/creating-streams)

  Stream<DeviceData> get onDataChanged {
    onDataChangedStreamController.close();
    onDataChangedStreamController = StreamController<DeviceData>();
    return onDataChangedStreamController.stream;
  }

  @override
  Future<Null> start() {
    super.getBroadcastStream(
        _onDataChangedStream, "on_data_changed"
    ).map((dynamic event) => DeviceData.from(Map<String,dynamic>.from(event))).listen((event){
      if (!onDataChangedStreamController.isClosed) {
        onDataChangedStreamController.add(event);
    }
    });
    return super.start();
  }

  @override
  Future<Null> stop() {
    super.cancelBroadcastStream("on_data_changed");
    return super.stop();
  }

}

/// A configuration class of DeviceSensor
///
/// You can initialize the class by following code.
///
/// ```dart
/// var config =  DeviceSensorConfig();
/// config
///   ..debug = true
///   ..frequency = 100;
/// ```
class DeviceSensorConfig extends AwareSensorConfig{
  DeviceSensorConfig();

  @override
  Map<String, dynamic> toMap() {
    var map = super.toMap();
    return map;
  }
}

/// A data model of DeviceSensor
///
/// This class converts sensor data that is Map<String,dynamic> format, to a
/// sensor data object.
///
class DeviceData extends AwareData {

  Map<String,dynamic> source;

  String systemName = "";
  String systemVersion = "";
  String model = "";
  String localizedModel = "";
  String product = "";
  int userInterfaceIdiom = -1;
  String identifierForVendor = "";
  String modelCode = "";
  String osVersion = "";
  String manufacturer = "";

  DeviceData():this.from(null);
  DeviceData.from(Map<String,dynamic> data):super.from(data){
    if (data != null) {
      systemName = data["systemName"] ?? "";
      systemVersion = data["systemVersion"] ?? "";
      model = data["model"] ?? "";
      localizedModel = data["localizedModel"] ?? "";
      product = data["product"] ?? "";
      userInterfaceIdiom = data["userInterfaceIdiom"] ?? -1;
      identifierForVendor = data["identifierForVendor"] ?? "";
      modelCode = data["modelCode"] ?? "";
      osVersion = data["osVersion"] ?? "";
      manufacturer = data["manufacturer"] ?? "";
      source = data;
    }
  }

  @override
  String toString() {
    if(source != null){
      return source.toString();
    }
    return super.toString();
  }
}


///
/// A Card Widget of Device Sensor
///
/// You can generate a Cart Widget by following code.
/// ```dart
/// var card = DeviceCard(sensor: sensor);
/// ```
class DeviceCard extends StatefulWidget { DeviceCard({Key key, @required this.sensor}) : super(key: key);

  final DeviceSensor sensor;

  @override
  DeviceCardState createState() => new DeviceCardState();
}

///
/// A Card State of Device Sensor
///
class DeviceCardState extends State<DeviceCard> {

  String deviceInfo = "";

  @override
  void initState() {

    if(mounted){
      setState((){
        updateContent(widget.sensor.deviceData);
      });
    }

    super.initState();
    // set observer
    widget.sensor.onDataChanged.listen((event) {
      if(event!=null){
        if(mounted){
          setState((){
            updateContent(event);
          });
        }else{
          updateContent(event);
        }
      }
    }, onError: (dynamic error) {
        print('Received error: ${error.message}');
    });
    print(widget.sensor);
    widget.sensor.start();
  }

  void updateContent(DeviceData data){
    DateTime.fromMicrosecondsSinceEpoch(data.timestamp);
    deviceInfo = data.toString();
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
}
