import Cocoa
import OHHTTPStubs
import SwiftyJSON

class StubResponse: NSObject {

  var responseData: [String: AnyObject?]
  
  init(responseData: [String: AnyObject?]) {
    self.responseData = responseData;
    // TODO stub the response using this data
  }
}
