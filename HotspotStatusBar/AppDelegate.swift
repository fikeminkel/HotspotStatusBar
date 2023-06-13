import Cocoa
import CoreWLAN
import Reachability

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {

  var prefsManager = PreferencesManager()

    
  let statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
  let menuBarView = MenuBarView()
  @IBOutlet var window: NSWindow?
  @IBOutlet var menuBarMenu: NSMenu?

  // network polling
  let reachability = try! Reachability()
  let pollInterval = 2.0
  let hotspotPoller = VerizonHotspotPoller()
  
  var ssid: String? {
    return CWWiFiClient.shared().interface()?.ssid()
  }

  func applicationDidFinishLaunching(aNotification: NSNotification) {
    setupMenuBar()
    setupPreferences()
    updateMenuBar(status: nil)
    startReachability()
  }

  func applicationWillTerminate(aNotification: NSNotification) {
    stopHotspotPoller()
    reachability.stopNotifier()
  }
  
  @IBAction func quitApplication(sender: AnyObject?) {
    NSApplication.shared.terminate(sender)
  }
  
  func setupPreferences() {
    prefsManager.observedSSIDChangedHandler = { _ in
      self.observedSSIDChanged()
    }
  }
  
  func setupMenuBar() {
    statusItem.view = menuBarView
    menuBarView.menuBarItem = statusItem
    menuBarView.menu = menuBarMenu
  }
  
  func startReachability() {
    reachability.whenReachable = { reachability in
      DispatchQueue.main.async {
        // TODO: check the SSID against the prefs
        print("Network is now reachable.")
        self.observedSSIDChanged()
      }
    }
    reachability.whenUnreachable = { reachability in
      DispatchQueue.main.async {
        print("Network unreachable!")
        self.stopHotspotPoller()
      }
    }
    if reachability.connection != .unavailable {
      observedSSIDChanged()
    }
    do {
      try reachability.startNotifier()
    } catch {
      print("Failed to start reachability notifier")
    }
  }

  func observedSSIDChanged() {
    if ssid == prefsManager.observedSSID {
      startHotspotPoller()
    } else {
      stopHotspotPoller()
    }
  }
  
  func startHotspotPoller() {
    updateMenuBar(status: nil)
    hotspotPoller.updateHandler = { status in
      self.updateMenuBar(status: status)
    }
    hotspotPoller.pollFor(interval: pollInterval)
  }
  
  func stopHotspotPoller() {
    hotspotPoller.updateHandler = nil
    hotspotPoller.stopPolling()
    updateMenuBar(status: nil)
  }
  
  func updateMenuBar(status: HotspotStatus?) {
    if reachability.connection == .unavailable {
      var status = HotspotStatus()
      status.connected = false
      menuBarView.status = status
    } else {
      menuBarView.status = status
    }
  }
  
}

