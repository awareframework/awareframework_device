import 'package:test/test.dart';

import 'package:awareframework_device/awareframework_device.dart';

void main(){
  test("test sensor config", (){
    var config = DeviceSensorConfig();
    expect(config.debug, false);
  });
}