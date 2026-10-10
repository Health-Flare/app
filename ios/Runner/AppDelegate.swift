import Flutter
import UIKit

@main
@objc class AppDelegate: FlutterAppDelegate, FlutterImplicitEngineDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }

  func didInitializeImplicitFlutterEngine(_ engineBridge: FlutterImplicitEngineBridge) {
    GeneratedPluginRegistrant.register(with: engineBridge.pluginRegistry)

    // Lets Dart mark the pre-upgrade safety copies (snapshots/) as excluded
    // from iCloud backup. The database itself stays in backups on purpose.
    // See lib/core/security/backup_exclusion.dart.
    // Hide in app switcher (#101). See lib/core/security/secure_window.dart.
    let secureWindowChannel = FlutterMethodChannel(
      name: "org.healthflare.app/secure_window",
      binaryMessenger: engineBridge.applicationRegistrar.messenger()
    )
    secureWindowChannel.setMethodCallHandler { call, result in
      guard call.method == "setHidden",
        let args = call.arguments as? [String: Any],
        let hidden = args["hidden"] as? Bool
      else {
        result(FlutterMethodNotImplemented)
        return
      }
      AppSwitcherCover.shared.enabled = hidden
      result(nil)
    }
    AppSwitcherCover.shared.observeScenes()

    let backupChannel = FlutterMethodChannel(
      name: "org.healthflare.app/backup_exclusion",
      binaryMessenger: engineBridge.applicationRegistrar.messenger()
    )
    backupChannel.setMethodCallHandler { call, result in
      guard call.method == "excludeFromBackup",
        let args = call.arguments as? [String: Any],
        let path = args["path"] as? String
      else {
        result(FlutterMethodNotImplemented)
        return
      }
      var url = URL(fileURLWithPath: path)
      var values = URLResourceValues()
      values.isExcludedFromBackup = true
      do {
        try url.setResourceValues(values)
        result(true)
      } catch {
        result(
          FlutterError(
            code: "EXCLUDE_FROM_BACKUP_FAILED",
            message: error.localizedDescription,
            details: nil
          )
        )
      }
    }
  }
}

/// Covers the window while the app isn't active, so the app switcher
/// snapshot shows a plain screen instead of the last health screen (#101).
/// iOS takes that snapshot after the scene resigns active. Screenshots are
/// not blocked: iOS has no equivalent of Android's FLAG_SECURE.
final class AppSwitcherCover {
  static let shared = AppSwitcherCover()

  var enabled = false
  private var observing = false
  private var covers: [ObjectIdentifier: UIView] = [:]

  func observeScenes() {
    guard !observing else { return }
    observing = true
    let center = NotificationCenter.default
    center.addObserver(
      forName: UIScene.willDeactivateNotification, object: nil, queue: .main
    ) { [weak self] note in
      self?.cover(note.object as? UIWindowScene)
    }
    center.addObserver(
      forName: UIScene.didActivateNotification, object: nil, queue: .main
    ) { [weak self] note in
      self?.uncover(note.object as? UIWindowScene)
    }
  }

  private func cover(_ scene: UIWindowScene?) {
    guard enabled, let scene = scene,
      let window = scene.windows.first(where: { $0.isKeyWindow }) ?? scene.windows.first
    else { return }
    let key = ObjectIdentifier(scene)
    guard covers[key] == nil else { return }
    let view = UIView(frame: window.bounds)
    view.autoresizingMask = [.flexibleWidth, .flexibleHeight]
    view.backgroundColor = .systemBackground
    let logo = UIImageView(image: UIImage(named: "LaunchImage"))
    logo.contentMode = .center
    logo.frame = view.bounds
    logo.autoresizingMask = [.flexibleWidth, .flexibleHeight]
    view.addSubview(logo)
    window.addSubview(view)
    covers[key] = view
  }

  private func uncover(_ scene: UIWindowScene?) {
    guard let scene = scene else { return }
    covers.removeValue(forKey: ObjectIdentifier(scene))?.removeFromSuperview()
  }
}
