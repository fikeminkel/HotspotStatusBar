import Cocoa
import CoreWLAN

class WIFIClient: NSObject {

  var interfaceConfiguration = CWWiFiClient.shared().interface()?.configuration()
  
  var knownSSIDs: [String] {
    guard let networkProfiles = (interfaceConfiguration?.networkProfiles) else {
      return []
    }
    var ssids: [String] = []
    for case let networkProfile as CWNetworkProfile in networkProfiles {
      if let ssid = networkProfile.ssid {
        ssids.append(ssid)
      }
    }
    return ssids
  }
}


