import UIKit
import Flutter

@UIApplicationMain
@objc class AppDelegate: FlutterAppDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
      
    let controller = window?.rootViewController as! FlutterViewController
    let channel = FlutterMethodChannel(name: "battery", binaryMessenger: controller as! FlutterBinaryMessenger)
      channel.setMethodCallHandler ({
          [weak self] (call: FlutterMethodCall, result: FlutterResult) -> Void in
          guard call.method == "getBatteryLevel" else {
              result(FlutterMethodNotImplemented)
              return
          }
          self?.receiveBatteryLevel(result: result)
      })
      
    GeneratedPluginRegistrant.register(with: self)
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }
    
    private func receiveBatteryLevel(result: FlutterResult) {
        let device = UIDevice.current
        device.isBatteryMonitoringEnabled = true
        if device.batteryState == UIDevice.BatteryState.unknown {
            result(FlutterError(code: "Unavailable", message: "Buttery Info unvailable", details: nil))
        } else {
            result(Int(device.batteryLevel * 100))
        }
    }
}
