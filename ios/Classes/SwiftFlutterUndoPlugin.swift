import Flutter
import UIKit

public class SwiftFlutterUndoPlugin: NSObject, FlutterPlugin {
  var channel: FlutterMethodChannel

  public init(channel: FlutterMethodChannel) {
    self.channel = channel
  }

  public static func register(with registrar: FlutterPluginRegistrar) {
    let channel = FlutterMethodChannel(name: "flutter_undo", binaryMessenger: registrar.messenger())
    let instance = SwiftFlutterUndoPlugin(channel: channel)
    registrar.addMethodCallDelegate(instance, channel: channel)
  }

  public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
    if call.method == "UndoManagerPlugin.register" {
      registerUndo(call.arguments as! String, type: "undo")
      result(nil)
    } else if call.method == "UndoManagerPlugin.reset" {
      if let controller = UIApplication.shared.keyWindow?.rootViewController as? FlutterViewController {
        controller.undoManager?.removeAllActions()
      }
      result(nil)
    } else {
      result(FlutterMethodNotImplemented)
    }
  }

  private func registerUndo(_ identifier: String, type: String) {
    NSLog("[Undo] registerUndo \(identifier), type: \(type)")
    if let controller = UIApplication.shared.keyWindow?.rootViewController as? FlutterViewController {
      controller.undoManager?.groupsByEvent = false
      controller.undoManager?.beginUndoGrouping()
      controller.undoManager?.registerUndo(withTarget: self, handler: { selfTarget in
        NSLog("[Undo] handler for \(identifier), type: \(type)")
        selfTarget.registerUndo(identifier, type: type == "undo" ? "redo" : "undo")
        selfTarget.channel.invokeMethod("UndoManager.\(type)", arguments: identifier)
      })
      controller.undoManager?.endUndoGrouping()
      controller.undoManager?.groupsByEvent = true
    }
  }
}
