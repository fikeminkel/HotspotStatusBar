import Cocoa

class PreferencesManager: NSObject {
  private let showBatteryUsageKey = "showBatteryUsage"
  private let observedSSIDKey = "observedSSID"

  var batteryUsageChangedHandler: (Bool -> ())?
  var observedSSIDChangedHandler: (String? -> ())?
  
  override init() {
    super.init()
    NSUserDefaults.standardUserDefaults().addObserver(self, forKeyPath: showBatteryUsageKey, options: NSKeyValueObservingOptions.New, context: nil)
    NSUserDefaults.standardUserDefaults().addObserver(self, forKeyPath: observedSSIDKey, options: NSKeyValueObservingOptions.New, context: nil)
  }
  
  var showBatteryUsage: Bool {
    get {
      return NSUserDefaults.standardUserDefaults().boolForKey(showBatteryUsageKey)
    }
    set(newValue) {
      NSUserDefaults.standardUserDefaults().setBool(newValue, forKey: showBatteryUsageKey)
    }
  }
  
  var observedSSID: String? {
    get {
      return NSUserDefaults.standardUserDefaults().stringForKey(observedSSIDKey)
    }
    set(newValue) {
      NSUserDefaults.standardUserDefaults().setObject(newValue, forKey: observedSSIDKey)
    }
  }
}

// MARK: NSUserDefaults property observer
extension PreferencesManager {
  override func observeValueForKeyPath(keyPath: String?, ofObject object: AnyObject?, change: [String : AnyObject]?, context: UnsafeMutablePointer<Void>) {
    guard let prefName = keyPath else {
      return
    }
    switch prefName {
    case showBatteryUsageKey:
      batteryUsageChangedHandler?(showBatteryUsage)
    case observedSSIDKey:
      observedSSIDChangedHandler?(observedSSID)
    default:
      break
    }
  }
}

