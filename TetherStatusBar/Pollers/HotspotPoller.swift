import Cocoa

protocol HotspotPoller {
  typealias HotspotStatusUpdateHandler = (HotspotStatus) -> ()
  
  var updateHandler: HotspotStatusUpdateHandler? { get set }
  func pollFor(interval: NSTimeInterval)
  func stopPolling()
}

struct HotspotStatus {
  enum NetworkType: String {
    case None = ""
    case OneX = "1X"
    case ThreeG = "3G"
    case FourG = "4G"
  }
  
  enum SignalType: String {
    case None, Low, Medium, High, Full
  }
  
  enum BatteryLevel: String {
    case Unknown, Low, Medium, Full
  }
  
  var networkType = NetworkType.None
  var connected = false {
    willSet(newValue) {
      if !newValue {
        self.reset()
      }
    }
  }
  var connectedString: String {
    return connected ? "Connected" : "Disconnected"
  }
  var signal = SignalType.None
  var charging = false
  var chargingString: String {
    return charging ? "Charging" : "Normal"
  }
  var batteryLevel = BatteryLevel.Unknown
  var uptime = ""
  var ipAddress = ""
  var signalString = ""
  
  var description: String {
    return "Status: { network: \(networkType), connected: \(connected), signal: \(signal), charging: \(charging), batteryLevel: \(batteryLevel), uptime: \(uptime), ipAddress: \(ipAddress), signalString: \(signalString)}"
  }
  
  mutating func reset() {
    signal = SignalType.None
    charging = false
    batteryLevel = BatteryLevel.Unknown
    uptime = ""
    ipAddress = ""
    signalString = ""
  }
}

