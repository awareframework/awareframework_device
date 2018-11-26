import Flutter
import UIKit
import SwiftyJSON
import com_awareframework_ios_sensor_device
import com_awareframework_ios_sensor_core
import awareframework_core

public class SwiftAwareframeworkDevicePlugin: AwareFlutterPluginCore, FlutterPlugin, AwareFlutterPluginSensorInitializationHandler, DeviceOserver{

    public func initializeSensor(_ call: FlutterMethodCall, result: @escaping FlutterResult) -> AwareSensor? {
        if self.sensor == nil {
            if let config = call.arguments as? Dictionary<String,Any>{
                let json = JSON.init(config)
                self.deviceSensor = DeviceSensor.init(DeviceSensor.Config(json))
            }else{
                self.deviceSensor = DeviceSensor.init(DeviceSensor.Config())
            }
            self.deviceSensor?.CONFIG.sensorObserver = self
            return self.deviceSensor
        }else{
            return nil
        }
    }

    var deviceSensor:DeviceSensor?

    public override init() {
        super.init()
        super.initializationCallEventHandler = self
    }

    public static func register(with registrar: FlutterPluginRegistrar) {
        let instance = SwiftAwareframeworkDevicePlugin()
        super.setMethodChannel(with: registrar,
                               instance: instance,
                               channelName: "awareframework_device/method")
        self.setEventChannels(with: registrar,
                              instance: instance,
                              channelNames: ["awareframework_device/event"])
    }

    public func onDeviceChanged(data: DeviceData) {
        for handler in self.streamHandlers {
            if handler.eventName == "on_data_changed" {
                handler.eventSink(data.toDictionary())
            }
        }
    }
}
