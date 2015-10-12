import Cocoa
import CoreWLAN

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {

  var prefsManager = PreferencesManager()
  
  let statusItem = NSStatusBar.systemStatusBar().statusItemWithLength(NSVariableStatusItemLength)
  let menuBarView = MenuBarView()
  @IBOutlet var window: NSWindow?
  @IBOutlet var menuBarMenu: NSMenu?

  // network polling
  let reachability = Reachability.reachabilityForLocalWiFi()!
  let pollInterval = 2.0
  let hotspotPoller = VerizonHotspotPoller()
  
  var ssid: String? {
    return CWWiFiClient.sharedWiFiClient().interface()?.ssid()
  }

  func applicationDidFinishLaunching(aNotification: NSNotification) {
    setupMenuBar()
    setupPreferences()
    updateMenuBarStatus(nil)
    startReachability()
  }

  func applicationWillTerminate(aNotification: NSNotification) {
    stopHotspotPoller()
    reachability.stopNotifier()
  }
  
  @IBAction func quitApplication(sender: AnyObject?) {
    NSApplication.sharedApplication().terminate(sender)
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
      dispatch_async(dispatch_get_main_queue()) {
        // TODO: check the SSID against the prefs
        print("Network is now reachable.")
        self.observedSSIDChanged()
      }
    }
    reachability.whenUnreachable = { reachability in
      dispatch_async(dispatch_get_main_queue()) {
        print("Network unreachable!")
        self.stopHotspotPoller()
      }
    }
    if reachability.isReachable() {
      observedSSIDChanged()
    }
    reachability.startNotifier()
  }

  func observedSSIDChanged() {
    if ssid == prefsManager.observedSSID {
      startHotspotPoller()
    } else {
      stopHotspotPoller()
    }
  }
  
  func startHotspotPoller() {
    updateMenuBarStatus(nil)
    hotspotPoller.updateHandler = { status in
      self.updateMenuBarStatus(status)
    }
    hotspotPoller.pollFor(pollInterval)
  }
  
  func stopHotspotPoller() {
    hotspotPoller.updateHandler = nil
    hotspotPoller.stopPolling()
    updateMenuBarStatus(nil)
  }
  
  func updateMenuBarStatus(status: HotspotStatus?) {
    if !reachability.isReachable() {
      var status = HotspotStatus()
      status.connected = false
      menuBarView.status = status
    } else {
      menuBarView.status = status
    }
  }
  
}

