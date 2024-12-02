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
      // another way to approach this: https://github.com/googlemaps/flutter-navigation-sdk/blob/main/example/ios/Runner/AppDelegate.swift
      if let mapsApiKey = Bundle.main.object(forInfoDictionaryKey: "MapsApiKey") as? String {
        GMSServices.provideAPIKey(mapsApiKey)
      }
      
    GeneratedPluginRegistrant.register(with: self)
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }
}
