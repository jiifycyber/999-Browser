import Cocoa
import FlutterMacOS

class MainFlutterWindow: NSWindow {
  override func awakeFromNib() {
    let flutterViewController = FlutterViewController()
    let windowFrame = self.frame
    self.contentViewController = flutterViewController
    self.setFrame(windowFrame, display: true)

    RegisterGeneratedPlugins(registry: flutterViewController)
    if let delegate = NSApplication.shared.delegate as? AppDelegate {
      delegate.attachLinkChannel(flutterViewController.engine.binaryMessenger)
    }

    let dockChannel = FlutterMethodChannel(name: "com.999browser/dock", binaryMessenger: flutterViewController.engine.binaryMessenger)
    dockChannel.setMethodCallHandler { call, result in
      guard call.method == "installWebsite" else {
        result(FlutterMethodNotImplemented)
        return
      }
      guard let args = call.arguments as? [String: String], let raw = args["url"], let url = URL(string: raw), ["http", "https"].contains(url.scheme?.lowercased() ?? ""), url.host != nil else {
        result(FlutterError(code: "INVALID_URL", message: "Valid website URL required", details: nil))
        return
      }
      DispatchQueue.global(qos: .userInitiated).async {
        do {
          try WebsiteDockInstaller.install(url)
          DispatchQueue.main.async { result(nil) }
        } catch {
          DispatchQueue.main.async { result(FlutterError(code: "DOCK_INSTALL_FAILED", message: error.localizedDescription, details: nil)) }
        }
      }
    }
    super.awakeFromNib()
  }
}
