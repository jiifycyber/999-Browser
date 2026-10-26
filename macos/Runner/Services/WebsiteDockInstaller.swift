import Cocoa
final class WebsiteDockInstaller {
  static func install(_ url: URL) throws {
    let fm = FileManager.default
    let directory = fm.homeDirectoryForCurrentUser.appendingPathComponent("Applications/999 Browser Shortcuts", isDirectory: true)
    try fm.createDirectory(at: directory, withIntermediateDirectories: true)
    let host = url.host ?? "Website"
    let name = String(host.map { ($0.isLetter || $0.isNumber || $0 == "-" || $0 == ".") ? $0 : "-" })
    let app = directory.appendingPathComponent(name + ".app")
    let browser = Bundle.main.bundleURL.path
    let quote = String(UnicodeScalar(34)!)
    let newline = String(UnicodeScalar(10)!)
    let browserLiteral = quote + browser.replacingOccurrences(of: quote, with: quote + quote) + quote
    let urlLiteral = quote + url.absoluteString.replacingOccurrences(of: quote, with: quote + quote) + quote
    let script = "on run" + newline + "do shell script " + quote + "/usr/bin/open -a " + quote + " & quoted form of " + browserLiteral + " & " + quote + " " + quote + " & quoted form of " + urlLiteral + newline + "end run"
    let compiler = Process()
    compiler.executableURL = URL(fileURLWithPath: "/usr/bin/osacompile")
    compiler.arguments = ["-o", app.path, "-e", script]
    try compiler.run()
    compiler.waitUntilExit()
    guard compiler.terminationStatus == 0 else { throw NSError(domain: "999Dock", code: 1) }
    let dock = Process()
    dock.executableURL = URL(fileURLWithPath: "/opt/homebrew/Cellar/dockutil/3.1.3/bin/dockutil")
    dock.arguments = ["--add", app.path]
    try dock.run()
    dock.waitUntilExit()
    guard dock.terminationStatus == 0 else { throw NSError(domain: "999Dock", code: 2) }
  }
}
