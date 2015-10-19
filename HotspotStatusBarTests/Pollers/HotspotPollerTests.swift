import XCTest

@testable import HotspotStatusBar

class HotspotPollerTests: XCTestCase {
  
  var status: HotspotStatus!
  
  override func setUp() {
    super.setUp()
    status = HotspotStatus()
  }
  
  override func tearDown() {
    super.tearDown()
  }
 
  func testConnectedString() {
    status.connected = true
    XCTAssertEqual("Connected", status.connectedString)

    status.connected = false
    XCTAssertEqual("Disconnected", status.connectedString)
  }
  
  func testChargingString() {
    status.charging = true
    XCTAssertEqual("Charging", status.chargingString)
    
    status.charging = false
    XCTAssertEqual("Normal", status.chargingString)
  }
  
  func testConnectedFalseResetsAllFields() {
    status.connected = true
    status.networkType = .FourG
    status.signal = .Full
    status.charging = true
    status.batteryLevel = .Full
    status.uptime = "uptime"
    status.ipAddress = "ipAddress"
    status.signalString = "signalString"

    // setting connected to false should clear the rest of the status fields
    status.connected = false
    XCTAssertFalse(status.connected)
    XCTAssertEqual(status.networkType, HotspotStatus.NetworkType.None)
    XCTAssertEqual(status.signal, HotspotStatus.SignalType.None)
    XCTAssertFalse(status.charging)
    XCTAssertEqual(status.batteryLevel, HotspotStatus.BatteryLevel.Unknown)
    XCTAssertEqual(status.uptime, "")
    XCTAssertEqual(status.ipAddress, "")
    XCTAssertEqual(status.signalString, "")
  }
  
  func testDescription() {
    status.connected = true
    status.networkType = .FourG
    status.signal = .Full
    status.charging = true
    status.batteryLevel = .Full
    status.uptime = "uptime"
    status.ipAddress = "ipAddress"
    status.signalString = "signalString"
    
    XCTAssertTrue(status.description.containsString(HotspotStatus.NetworkType.FourG.rawValue))
    XCTAssertTrue(status.description.containsString(HotspotStatus.SignalType.Full.rawValue))
    XCTAssertTrue(status.description.containsString(HotspotStatus.BatteryLevel.Full.rawValue))

  }
}
