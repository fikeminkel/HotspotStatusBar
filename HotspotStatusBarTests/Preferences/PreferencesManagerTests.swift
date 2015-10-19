import XCTest

@testable import HotspotStatusBar

class PreferencesManagerTests: XCTestCase {

  // not great but we don't want to change the acccess modifier on 
  // the actual properties in PreferencesManager
  let showBatteryUsageKey = "showBatteryUsage"
  let observedSSIDKey = "observedSSID"

  
  var prefsManager: PreferencesManager!
  var stubUserDefaults: StubNSUserDefaultsDelegator!
  
  override func setUp() {
    super.setUp()
    prefsManager = PreferencesManager()
    stubUserDefaults = StubNSUserDefaultsDelegator()
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
    let expectation = expectationWithDescription("expect this to be called")
    stubUserDefaults.dictionary[showBatteryUsageKey] = true
    prefsManager.batteryUsageChangedHandler = { newValue in
      XCTAssertTrue(newValue)
      expectation.fulfill()
    }
    prefsManager.observeValueForKeyPath(showBatteryUsageKey, ofObject: nil, change: nil, context: nil)
    waitForExpectationsWithTimeout(1, handler: nil)
  }

  func testObservedSSIDChangedHandler() {
    let expectation = expectationWithDescription("expect this to be called")
    stubUserDefaults.dictionary[observedSSIDKey] = "somessidstring"
    prefsManager.observedSSIDChangedHandler = { newValue in
      XCTAssertEqual(newValue, "somessidstring")
      expectation.fulfill()
    }
    prefsManager.observeValueForKeyPath(observedSSIDKey, ofObject: nil, change: nil, context: nil)
    waitForExpectationsWithTimeout(1, handler: nil)
  }
  
  func testNothingBadHappensIfOtherPrefsAreUpdated() {
    prefsManager.observeValueForKeyPath("someotherkey", ofObject: nil, change: nil, context: nil)
    prefsManager.observeValueForKeyPath(nil, ofObject: nil, change: nil, context: nil)
  }
}



class StubNSUserDefaultsDelegator: NSUserDefaultsDelegator {
  var dictionary: [String: AnyObject?] = [:]

  override func boolForKey(defaultName: String) -> Bool {
    return dictionary[defaultName] as! Bool
  }
  override func setBool(value: Bool, forKey: String) {
    dictionary[forKey] = value
  }
  override func stringForKey(defaultName: String) -> String? {
    return dictionary[defaultName] as? String
  }
  override func setObject(value: AnyObject?, forKey: String) {
    dictionary[forKey] = value
  }
}