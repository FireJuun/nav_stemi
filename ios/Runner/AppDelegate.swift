import UIKit
import Flutter
import GoogleMaps

@main
@objc class AppDelegate: FlutterAppDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
      // spec: https://www.monterail.com/blog/configuring-flutter-apps-using-dart-define-from-file
      if let iosMapsApiKey = Bundle.main.object(forInfoDictionaryKey: "IosMapsApi") as? String {
        GMSServices.provideAPIKey(iosMapsApiKey)
      }
      
    GeneratedPluginRegistrant.register(with: self)
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }
}
