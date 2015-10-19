import Cocoa
import CoreWLAN

class WIFIClient: NSObject {

  var interfaceConfiguration = CWWiFiClient.sharedWiFiClient().interface()?.configuration()
  
  var knownSSIDs: [String] {
    guard let networkProfiles = (interfaceConfiguration?.networkProfiles) else {
      return []
    }
    var ssids: [String] = []
    for networkProfile in networkProfiles {
      if let ssid = networkProfile.ssid() {
        ssids.append(ssid)
      }
    }
    return ssids
  }
}


