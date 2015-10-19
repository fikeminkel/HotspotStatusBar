import Cocoa

class PreferencesManager: NSObject {
  private let showBatteryUsageKey = "showBatteryUsage"
  private let observedSSIDKey = "observedSSID"

  var userDefaults = NSUserDefaultsDelegator()
  var batteryUsageChangedHandler: (Bool -> ())?
  var observedSSIDChangedHandler: (String? -> ())?
  
  override init() {
    super.init()
    userDefaults.addObserver(self, forKeyPath: showBatteryUsageKey, options: NSKeyValueObservingOptions.New, context: nil)
    userDefaults.addObserver(self, forKeyPath: observedSSIDKey, options: NSKeyValueObservingOptions.New, context: nil)
  }
  
  var showBatteryUsage: Bool {
    get {
      return userDefaults.boolForKey(showBatteryUsageKey)
    }
    set(newValue) {
      userDefaults.setBool(newValue, forKey: showBatteryUsageKey)
    }
  }
  
  var observedSSID: String? {
    get {
      return userDefaults.stringForKey(observedSSIDKey)
    }
    set(newValue) {
      userDefaults.setObject(newValue, forKey: observedSSIDKey)
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

class NSUserDefaultsDelegator {
  func boolForKey(defaultName: String) -> Bool {
    return NSUserDefaults.standardUserDefaults().boolForKey(defaultName)
  }
  func setBool(value: Bool, forKey: String) {
    NSUserDefaults.standardUserDefaults().setBool(value, forKey: forKey)
  }
  func stringForKey(defaultName: String) -> String? {
    return NSUserDefaults.standardUserDefaults().stringForKey(defaultName)
  }
  func setObject(value: AnyObject?, forKey: String) {
    NSUserDefaults.standardUserDefaults().setObject(value, forKey: forKey)
  }
  func addObserver(observer: NSObject, forKeyPath: String, options: NSKeyValueObservingOptions, context: UnsafeMutablePointer<Void>) {
    NSUserDefaults.standardUserDefaults().addObserver(observer, forKeyPath: forKeyPath, options: options, context: context)
  }
}

