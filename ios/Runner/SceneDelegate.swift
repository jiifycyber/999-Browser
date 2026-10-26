import Flutter
import UIKit

class SceneDelegate: FlutterSceneDelegate {
  private var externalLinksChannel: FlutterMethodChannel?
  private var pendingURL: URL?
  private var flutterReady = false

  override func scene(
    _ scene: UIScene,
    willConnectTo session: UISceneSession,
    options connectionOptions: UIScene.ConnectionOptions
  ) {
    pendingURL = connectionOptions.urlContexts.first?.url
    super.scene(scene, willConnectTo: session, options: connectionOptions)
    DispatchQueue.main.async { [weak self] in
      self?.configureExternalLinksChannel()
    }
  }

  override func scene(
    _ scene: UIScene,
    openURLContexts URLContexts: Set<UIOpenURLContext>
  ) {
    super.scene(scene, openURLContexts: URLContexts)
    guard let url = URLContexts.first?.url,
          let scheme = url.scheme?.lowercased(),
          ["http", "https"].contains(scheme),
          url.host != nil else { return }
    pendingURL = url
    deliverPendingURL()
  }

  private func configureExternalLinksChannel() {
    guard externalLinksChannel == nil,
          let controller = window?.rootViewController as? FlutterViewController else {
      return
    }

    let channel = FlutterMethodChannel(
      name: "com.999browser/external_links",
      binaryMessenger: controller.binaryMessenger
    )

    channel.setMethodCallHandler { [weak self] call, result in
      guard call.method == "ready" else {
        result(FlutterMethodNotImplemented)
        return
      }
      self?.flutterReady = true
      result(nil)
      self?.deliverPendingURL()
    }

    externalLinksChannel = channel
  }

  private func deliverPendingURL() {
    guard flutterReady,
          let url = pendingURL,
          let channel = externalLinksChannel else { return }
    pendingURL = nil
    channel.invokeMethod("openUrl", arguments: url.absoluteString)
  }
}
