import XCTest
import CoreWLAN

@testable import HotspotStatusBar

class WIFIClientTests: XCTestCase {

  let testData = ["ssid1", "ssid2", "ssid3"]
  var stubConfiguration: StubCWConfiguration!
  var wifiClient: WIFIClient!
  
  
  override func setUp() {
    super.setUp()
    wifiClient = WIFIClient()
    stubConfiguration = StubCWConfiguration(ssids: testData)
    wifiClient.interfaceConfiguration = stubConfiguration
  }
  
  override func tearDown() {
    super.tearDown()
  }
  
  func testKnownSSIDs() {
    XCTAssertEqual(wifiClient.knownSSIDs.count, testData.count)
    wifiClient.interfaceConfiguration = nil
    XCTAssertEqual(wifiClient.knownSSIDs.count, 0)
  }
}

class StubCWConfiguration: CWConfiguration {
  var profiles: [StubCWNetworkProfile] = []
  
  init(ssids: [String]) {
    super.init()
    for ssid in ssids {
      profiles.append(StubCWNetworkProfile(ssid: ssid))
    }
  }

  required init?(coder: NSCoder) {
    super.init(coder: coder)
  }
  
  override var networkProfiles: NSOrderedSet {
    let set = NSMutableOrderedSet(capacity: profiles.count)
    for profile in profiles {
      set.add(profile)
    }
    return set
  }
}

class StubCWNetworkProfile: CWNetworkProfile {
  var stubSSID = ""
  
  init(ssid: String) {
    super.init()
    stubSSID = ssid
  }
  
  required init?(coder: NSCoder) {
    super.init(coder: coder)
  }
  override var ssid: String {
    return stubSSID
  }
  override func isEqual(to networkProfile: CWNetworkProfile) -> Bool {
    guard let stubNetworkProfile = networkProfile as? StubCWNetworkProfile else {
      return false
    }
    return stubSSID == stubNetworkProfile.stubSSID
  }

}
