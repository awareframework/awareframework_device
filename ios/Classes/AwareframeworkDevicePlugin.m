#import "AwareframeworkDevicePlugin.h"
#import <awareframework_device/awareframework_device-Swift.h>

@implementation AwareframeworkDevicePlugin
+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar>*)registrar {
  [SwiftAwareframeworkDevicePlugin registerWithRegistrar:registrar];
}
@end
