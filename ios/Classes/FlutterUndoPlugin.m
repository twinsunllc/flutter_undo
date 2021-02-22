#import "FlutterUndoPlugin.h"
#if __has_include(<flutter_undo/flutter_undo-Swift.h>)
#import <flutter_undo/flutter_undo-Swift.h>
#else
// Support project import fallback if the generated compatibility header
// is not copied when this plugin is created as a library.
// https://forums.swift.org/t/swift-static-libraries-dont-copy-generated-objective-c-header/19816
#import "flutter_undo-Swift.h"
#endif

@implementation FlutterUndoPlugin
+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar>*)registrar {
  [SwiftFlutterUndoPlugin registerWithRegistrar:registrar];
}
@end
