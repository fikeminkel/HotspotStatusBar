import Cocoa
import Alamofire
import SwiftyJSON

class VerizonHotspotPoller: NSObject, HotspotPoller {
  typealias HotspotStatusUpdateHandler = (HotspotStatus) -> ()

  let indicatorsURL = NSURL(string: "http://192.168.1.1/v1/indicators")!
  let statsURL = NSURL(string: "http://192.168.1.1/v1/statistics")!
  
  let networkTypes = [
    HotspotStatus.NetworkType.None,
    HotspotStatus.NetworkType.OneX,
    HotspotStatus.NetworkType.None,
    HotspotStatus.NetworkType.ThreeG,
    HotspotStatus.NetworkType.FourG
  ]

  // crude mapping of 6 levels to 5
  let signalTypes = [
    HotspotStatus.SignalType.None,
    HotspotStatus.SignalType.Low,
    HotspotStatus.SignalType.Medium,
    HotspotStatus.SignalType.High,
    HotspotStatus.SignalType.High,
    HotspotStatus.SignalType.Full,
  ]

  // crude mapping of 5 levels to 4
  let batteryLevels = [
    HotspotStatus.BatteryLevel.Unknown,
    HotspotStatus.BatteryLevel.Low,
    HotspotStatus.BatteryLevel.Medium,
    HotspotStatus.BatteryLevel.Medium,
    HotspotStatus.BatteryLevel.Full
  ]
  
  var currentStatus = HotspotStatus()
  var timer: NSTimer?
  var updateHandler: HotspotStatusUpdateHandler?
  
  func pollFor(interval: NSTimeInterval) {
    guard timer == nil else {
      return
    }
    timer = NSTimer.scheduledTimerWithTimeInterval(interval, target: self, selector: "checkStatus", userInfo: nil, repeats: true)
    checkStatus()
  }
  
  func stopPolling() {
    guard let timer = timer else {
      return
    }
    print("Stopping Verizon Poller...")
    timer.invalidate()
    self.timer = nil
  }
  
  func checkStatus() {
    checkIndicators()
    checkStatistics()
  }

  func checkIndicators() {
    Alamofire.request(.GET, indicatorsURL).responseJSON { _, _, result in
      if let value = result.value {
        let json = JSON(value)
        self.currentStatus.networkType = self.networkTypes[json["networkType"].intValue]
        self.currentStatus.connected = (self.currentStatus.networkType != HotspotStatus.NetworkType.None)
        self.currentStatus.signal = self.signalTypes[json["signalStrengthMeter"].intValue]
        self.currentStatus.charging = (json["batteryChargingState"].intValue == 1)
        self.currentStatus.batteryLevel = self.batteryLevels[json["batteryMeter"].intValue]
      } else {
        self.currentStatus.connected = false
      }
      if let updateHandler = self.updateHandler {
        updateHandler(self.currentStatus)
      }
    }
  }
  
  func checkStatistics() {
    Alamofire.request(.GET, statsURL).responseJSON { _, _, result in
      guard let value = result.value else {
        return
      }
      let json = JSON(value)
      self.currentStatus.uptime = json["duration"].stringValue
      self.currentStatus.ipAddress = json["IPv4Address"].stringValue
      let txRate = json["TX"]["rate"].stringValue
      let rxRate = json["RX"]["rate"].stringValue
      self.currentStatus.signalString = "TX: \(txRate) RX: \(rxRate)"
      if let updateHandler = self.updateHandler {
        updateHandler(self.currentStatus)
      }
    }
  }
}



