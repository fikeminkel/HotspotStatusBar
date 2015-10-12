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
  
  override func drawRect(dirtyRect: NSRect) {
    // highlight view in menu bar if the prefs panel is open
    if let menuBarItem = menuBarItem {
      menuBarItem.drawStatusBarBackgroundInRect(bounds, withHighlight: highlighted)
    }
    
    connectionImage?.drawAtPoint(NSMakePoint(2, 2), fromRect: NSZeroRect, operation: NSCompositingOperation.CompositeSourceOver, fraction: 1.0)

    if let networkType = status?.networkType.rawValue {
      let textColor = NSColor.darkGrayColor()
      let textFont = NSFont(name: "Helvetica-Bold", size:9)
      
      var textFontAttributes: [String: AnyObject] = [:]
      textFontAttributes[NSFontAttributeName] = textFont
      textFontAttributes[NSForegroundColorAttributeName] = textColor
      let drawText = NSAttributedString(string: networkType, attributes: textFontAttributes)
      drawText.drawAtPoint(NSMakePoint(0, 9))
    }
    
    if prefsManager.showBatteryUsage {
      batteryImage?.drawAtPoint(NSMakePoint(20, 2), fromRect: NSZeroRect, operation: NSCompositingOperation.CompositeSourceOver, fraction: 1.0)
    }
  }
  
  func updateConnectionImage() {
    guard let status = status where status.connected else {
      connectionImage = NSImage(named: "Network Disconnected")
      return
    }
    connectionImage = NSImage(named: "Network \(status.signal)")
  }
  
  func updateBatteryImage() {
    guard let status = status else {
      batteryImage = NSImage(named: "Battery Unknown Normal")
      return
    }
    batteryImage = NSImage(named: "Battery \(status.batteryLevel) \(status.chargingString)")
  }
  
  func updateToolTip() {
    guard let status = status where status.connected else {
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
    let firstSeparator = menu.itemWithTag(1)!
    let secondSeparator = menu.itemWithTag(2)!
    var insertIndex = menu.indexOfItem(firstSeparator) + 1
    var removalIndex = menu.indexOfItem(secondSeparator) - 1
    while removalIndex >= insertIndex {
      menu.removeItemAtIndex(removalIndex)
      removalIndex--
    }

    // now we can add the known ssids into the menu
    for ssid in WIFIClient().knownSSIDs {
      let ssidMenuItem = NSMenuItem(title: ssid, action: Selector("updateSSID:"), keyEquivalent: "")
      ssidMenuItem.target = self
      ssidMenuItem.state = (ssid == prefsManager.observedSSID) ? NSOnState : NSOffState
      menu.insertItem(ssidMenuItem, atIndex: insertIndex)
      insertIndex++
    }
  }
  
  func updateSSID(sender: AnyObject?) {
    guard let selectedMenuItem = sender as? NSMenuItem else {
      return
    }
    prefsManager.observedSSID = selectedMenuItem.title
  }
}

// MARK: NSView mouse events
extension MenuBarView {
  override func mouseDown(theEvent: NSEvent) {
    if let menu = menu {
      menu.delegate = self
      self.populateSSIDs()
      menuBarItem?.popUpStatusItemMenu(menu)
    }
  }
  
  override func rightMouseDown(theEvent: NSEvent) {
    mouseDown(theEvent)
  }
}

// MARK: NSMenuDelegate
extension MenuBarView: NSMenuDelegate {
  func menuWillOpen(menu: NSMenu) {
    highlighted = true
    needsDisplay = true
  }
  
  func menuDidClose(menu: NSMenu) {
    highlighted = false
    menu.delegate = nil
    needsDisplay = true
  }
}
