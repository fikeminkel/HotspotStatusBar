import Cocoa

class PreferencesManager: NSObject {
  private let showBatteryUsageKey = "showBatteryUsage"
  private let observedSSIDKey = "observedSSID"

  var userDefaults = UserDefaultsDelegator()
  var batteryUsageChangedHandler: ((Bool) -> ())?
  var observedSSIDChangedHandler: ((String?) -> ())?
  
  override init() {
    super.init()
    userDefaults.addObserver(observer: self, forKeyPath: showBatteryUsageKey, options: NSKeyValueObservingOptions.new, context: nil)
    userDefaults.addObserver(observer: self, forKeyPath: observedSSIDKey, options: NSKeyValueObservingOptions.new, context: nil)
  }
  
  var showBatteryUsage: Bool {
    get {
        return userDefaults.bool(forKey: showBatteryUsageKey)
    }
    set(newValue) {
      userDefaults.set(newValue, forKey: showBatteryUsageKey)
    }
  }
  
  var observedSSID: String? {
    get {
      return userDefaults.string(forKey: observedSSIDKey)
    }
    set(newValue) {
      userDefaults.set(newValue, forKey: observedSSIDKey)
    }
  }
}

// MARK: NSUserDefaults property observer
extension PreferencesManager {
  override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
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

class UserDefaultsDelegator {
  func bool(forKey key: String) -> Bool {
    return UserDefaults.standard.bool(forKey: key)
  }
  func set(_ value: Bool, forKey: String) {
    UserDefaults.standard.set(value, forKey: forKey)
  }
  func string(forKey key: String) -> String? {
    return UserDefaults.standard.string(forKey: key)
  }
  func set(_ value: Any?, forKey key: String) {
    UserDefaults.standard.set(value, forKey: key)
  }
  func addObserver(observer: NSObject, forKeyPath: String, options: NSKeyValueObservingOptions, context: UnsafeMutableRawPointer?) {
    UserDefaults.standard.addObserver(observer, forKeyPath: forKeyPath, options: options, context: context)
  }
}

