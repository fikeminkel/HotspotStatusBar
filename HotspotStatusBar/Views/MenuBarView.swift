import Cocoa
import AppKit

class MenuBarView: NSView {
  
  var prefsManager = PreferencesManager()
  
  let frameWithBattery = NSMakeRect(0, 0, 36, 20);
  let frameWithoutBattery = NSMakeRect(0, 0, 22, 20);

  var connectionImage: NSImage?
  var batteryImage: NSImage?
  var highlighted = false
  
  var menuBarItem: NSStatusItem?
  
  var status: HotspotStatus? {
    didSet(newValue) {
      updateConnectionImage()
      if prefsManager.showBatteryUsage {
        updateBatteryImage()
      }
      updateToolTip()
      needsDisplay = true
    }
  }
  
  init() {
    super.init(frame: frameWithoutBattery)
    prefsManager.batteryUsageChangedHandler = { _ in
      self.updateFrameForBatteryUsage()
    }
    updateFrameForBatteryUsage()
  }

  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  override func draw(_ dirtyRect: NSRect) {
    // highlight view in menu bar if the prefs panel is open
    if let menuBarItem = menuBarItem {
      menuBarItem.drawStatusBarBackground(in: bounds, withHighlight: highlighted)
    }
    
    connectionImage?.draw(at: NSMakePoint(2, 2), from: NSZeroRect, operation: NSCompositingOperation.sourceOver, fraction: 1.0)

    if let networkType = status?.networkType.rawValue {
      var textFontAttributes: [NSAttributedStringKey: AnyObject] = [:]
      textFontAttributes[NSAttributedStringKey.font] = NSFont(name: "Helvetica-Bold", size:9)
      textFontAttributes[NSAttributedStringKey.foregroundColor] = NSColor.darkGray
      let drawText = NSAttributedString(string: networkType, attributes: textFontAttributes)
      drawText.draw(at: NSMakePoint(0, 9))
    }
    
    if prefsManager.showBatteryUsage {
      batteryImage?.draw(at: NSMakePoint(20, 2), from: NSZeroRect, operation: NSCompositingOperation.sourceOver, fraction: 1.0)
    }
  }
  
  func updateConnectionImage() {
    guard let status = status, status.connected else {
      connectionImage = NSImage(named: .networkDisconnected)
      return
    }
    connectionImage = NSImage(named: .networkName(forSignalType: status.signal))
  }
  
  func updateBatteryImage() {
    guard let status = status else {
      batteryImage = NSImage(named: .batteryUnknownNormal)
      return
    }

    batteryImage = NSImage(named: .batteryName(forStatus: status))
  }
  
  func updateToolTip() {
    guard let status = status, status.connected else {
      toolTip = "Status: Disconnected"
      return
    }
    toolTip = "Status: \(status.connectedString) \nNetwork: \(status.networkType.rawValue) \nSignal: \(status.signalString) \nUptime: \(status.uptime) \nIP Address: \(status.ipAddress)"
  }
  
  func updateFrameForBatteryUsage() {
    frame = prefsManager.showBatteryUsage ? frameWithBattery : frameWithoutBattery
    needsDisplay = true
  }
  
  func populateSSIDs() {
    guard let menu = menu else {
      return
    }
    // first let's clear out the old ssid list
    let firstSeparator = menu.item(withTag: 1)!
    let secondSeparator = menu.item(withTag: 2)!
    var insertIndex = menu.index(of: firstSeparator) + 1
    var removalIndex = menu.index(of: secondSeparator) - 1
    while removalIndex >= insertIndex {
      menu.removeItem(at: removalIndex)
      removalIndex -= 1
    }

    // now we can add the known ssids into the menu
    for ssid in WIFIClient().knownSSIDs {
      let ssidMenuItem = NSMenuItem(title: ssid, action: #selector(self.updateSSID), keyEquivalent: "")
      ssidMenuItem.target = self
      ssidMenuItem.state = (ssid == prefsManager.observedSSID) ? .on : .off
      menu.insertItem(ssidMenuItem, at: insertIndex)
      insertIndex += 1
    }
  }
  
  @objc func updateSSID(sender: AnyObject?) {
    guard let selectedMenuItem = sender as? NSMenuItem else {
      return
    }
    prefsManager.observedSSID = selectedMenuItem.title
  }
}

// MARK: NSView mouse events
extension MenuBarView {
  override func mouseDown(with event: NSEvent) {
    if let menu = menu {
      menu.delegate = self
      self.populateSSIDs()
      menuBarItem?.popUpMenu(menu)
    }
  }
  
  override func rightMouseDown(with event: NSEvent) {
    mouseDown(with: event)
  }
}

// MARK: NSMenuDelegate
extension MenuBarView: NSMenuDelegate {
  func menuWillOpen(_ menu: NSMenu) {
    highlighted = true
    needsDisplay = true
  }
  
  func menuDidClose(_ menu: NSMenu) {
    highlighted = false
    menu.delegate = nil
    needsDisplay = true
  }
}

extension NSImage.Name {
    static let networkDisconnected = NSImage.Name("Network Disconnected")
    static let networkNone = NSImage.Name("Network None")
    static let networkLow = NSImage.Name("Network Low")
    static let networkMedium = NSImage.Name("Network Medium")
    static let networkHigh = NSImage.Name("Network High")
    static let networkFull = NSImage.Name("Network Full")
        
    static func networkName(forSignalType signalType: HotspotStatus.SignalType) -> NSImage.Name {
        return NSImage.Name(rawValue: "Network \(signalType)")
    }

    static let batteryUnknownNormal = NSImage.Name("Battery Unknown Normal")

    static func batteryName(forStatus status: HotspotStatus) -> NSImage.Name {
        return NSImage.Name(rawValue: "Battery \(status.batteryLevel) \(status.chargingString)")
    }
}
