import Cocoa
import FlutterMacOS

@main
class AppDelegate: FlutterAppDelegate {
  private var pendingURLs: [String] = []
  private var linkChannel: FlutterMethodChannel?
  private var flutterReady = false
  func attachLinkChannel(_ messenger: FlutterBinaryMessenger) {
    linkChannel = FlutterMethodChannel(name: "com.999browser/external_links", binaryMessenger: messenger)
    linkChannel?.setMethodCallHandler { [weak self] call, result in
      if call.method == "ready" {
        self?.flutterReady = true
        self?.deliverPendingURLs()
        result(nil)
      } else { result(FlutterMethodNotImplemented) }
    }
  }
  override func application(_ application: NSApplication, open urls: [URL]) {
    for url in urls where url.scheme == "http" || url.scheme == "https" {
      pendingURLs.append(url.absoluteString)
    }
    deliverPendingURLs()
  }
  private func deliverPendingURLs() {
    guard flutterReady, let channel = linkChannel else { return }
    for url in pendingURLs { channel.invokeMethod("openUrl", arguments: url) }
    pendingURLs.removeAll()
  }
  override func applicationShouldTerminateAfterLastWindowClosed(_ sender: NSApplication) -> Bool {
    return true
  }

  override func applicationSupportsSecureRestorableState(_ app: NSApplication) -> Bool {
    return true
  }
}
