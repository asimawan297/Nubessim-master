import UIKit
import Flutter
import Firebase

@main
@objc class AppDelegate: FlutterAppDelegate {

  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {

    FirebaseApp.configure()   // ✅ Firebase init

    let controller: FlutterViewController = window?.rootViewController as! FlutterViewController

    let esimChannel = FlutterMethodChannel(
      name: "samples.flutter.dev/esim",
      binaryMessenger: controller.binaryMessenger
    )

    esimChannel.setMethodCallHandler { [weak self] (call: FlutterMethodCall, result: @escaping FlutterResult) in
      if call.method == "launchESimSetup" {
        if let activationCode = call.arguments as? String {
          self?.launchESimSetup(activationCode: activationCode, flutterResult: result)
        } else {
          result(FlutterError(code: "INVALID_ARGS", message: "Activation code missing", details: nil))
        }
      } else {
        result(FlutterMethodNotImplemented)
      }
    }

    GeneratedPluginRegistrant.register(with: self)
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }

  // ✅ MUST be inside the class
  private func launchESimSetup(activationCode: String, flutterResult: @escaping FlutterResult) {

    let encodedCode = activationCode.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? activationCode
    let urlString = "https://esimsetup.apple.com/esim_qrcode_provisioning?carddata=\(encodedCode)"

    guard let url = URL(string: urlString) else {
      flutterResult(FlutterError(code: "INVALID_URL", message: "Invalid eSIM setup URL", details: nil))
      return
    }

    if UIApplication.shared.canOpenURL(url) {
      UIApplication.shared.open(url, options: [:]) { success in
        if success {
          flutterResult("Successfully opened eSIM setup.")
        } else {
          flutterResult(FlutterError(code: "FAILED_TO_OPEN", message: "Failed to open eSIM setup.", details: nil))
        }
      }
    } else {
      flutterResult(FlutterError(code: "CANNOT_OPEN_URL", message: "Cannot open eSIM setup URL.", details: nil))
    }
  }
}
