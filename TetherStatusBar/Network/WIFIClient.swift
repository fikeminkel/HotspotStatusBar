import Cocoa
import CoreWLAN

class WIFIClient: NSObject {

  var knownSSIDs: [String] {
    guard let networkProfiles = (CWWiFiClient.sharedWiFiClient().interface()?.configuration()?.networkProfiles) else {
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
