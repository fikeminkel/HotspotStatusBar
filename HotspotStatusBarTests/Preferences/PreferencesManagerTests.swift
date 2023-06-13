import XCTest

@testable import HotspotStatusBar

class PreferencesManagerTests: XCTestCase {

  // not great but we don't want to change the acccess modifier on 
  // the actual properties in PreferencesManager
  let showBatteryUsageKey = "showBatteryUsage"
  let observedSSIDKey = "observedSSID"

  
  var prefsManager: PreferencesManager!
  var stubUserDefaults: StubUserDefaultsDelegator!
  
  override func setUp() {
    super.setUp()
    prefsManager = PreferencesManager()
    stubUserDefaults = StubUserDefaultsDelegator()
    prefsManager.userDefaults = stubUserDefaults
  }
  
  override func tearDown() {
    super.tearDown()
  }

  func testShowBatteryUsage() {
    stubUserDefaults.dictionary[showBatteryUsageKey] = true
    XCTAssertTrue(prefsManager.showBatteryUsage)
    
    prefsManager.showBatteryUsage = false
    XCTAssertFalse(stubUserDefaults.dictionary[showBatteryUsageKey] as! Bool)
  }
  
  func testObservedSSID() {
    stubUserDefaults.dictionary[observedSSIDKey] = "somestring"
    XCTAssertEqual(prefsManager.observedSSID, "somestring")
    
    prefsManager.observedSSID = "someotherstring"
    XCTAssertEqual(stubUserDefaults.dictionary[observedSSIDKey] as? String, "someotherstring")
  }
  
  func testBatteryUsageChangedHandler() {
    let expectation = expectation(description: "expect this to be called")
    stubUserDefaults.dictionary[showBatteryUsageKey] = true
    prefsManager.batteryUsageChangedHandler = { newValue in
      XCTAssertTrue(newValue)
      expectation.fulfill()
    }
    prefsManager.observeValue(forKeyPath: showBatteryUsageKey, of: nil, change: nil, context: nil)
    waitForExpectations(timeout: 1, handler: nil)
  }

  func testObservedSSIDChangedHandler() {
    let expectation = expectation(description: "expect this to be called")
    stubUserDefaults.dictionary[observedSSIDKey] = "somessidstring"
    prefsManager.observedSSIDChangedHandler = { newValue in
      XCTAssertEqual(newValue, "somessidstring")
      expectation.fulfill()
    }
    prefsManager.observeValue(forKeyPath: observedSSIDKey, of: nil, change: nil, context: nil)
    waitForExpectations(timeout: 1, handler: nil)
  }
  
  func testNothingBadHappensIfOtherPrefsAreUpdated() {
    prefsManager.observeValue(forKeyPath: "someotherkey", of: nil, change: nil, context: nil)
    prefsManager.observeValue(forKeyPath: nil, of: nil, change: nil, context: nil)
  }
}

class StubUserDefaultsDelegator: UserDefaultsDelegator {
  var dictionary: [String: Any?] = [:]

  override func bool(forKey key: String) -> Bool {
    return dictionary[key] as! Bool
  }
  override func set(_ value: Bool, forKey key: String) {
    dictionary[key] = value
  }
  override func string(forKey key: String) -> String? {
    return dictionary[key] as? String
  }
  override func set(_ value: Any?, forKey key: String) {
    dictionary[key] = value
  }
}
