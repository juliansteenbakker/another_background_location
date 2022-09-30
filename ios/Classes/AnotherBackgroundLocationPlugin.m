#import "AnotherBackgroundLocationPlugin.h"
#import <another_background_location/another_background_location-Swift.h>

@implementation AnotherBackgroundLocationPlugin
+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar>*)registrar {
  [SwiftBackgroundLocationPlugin registerWithRegistrar:registrar];
}
@end
