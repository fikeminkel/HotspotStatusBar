import Cocoa
@testable import Alamofire

class StubAlamofireManager: Alamofire.Manager {

  let responseData: [String: AnyObject?]
  
  init(responseData: [String: AnyObject?]) {
    self.responseData = responseData
  }
  
  override func request(method: Alamofire.Method, _ URLString: URLStringConvertible, parameters: [String : AnyObject]? = nil, encoding: Alamofire.ParameterEncoding = .URL, headers: [String : String]? = nil) -> Alamofire.Request {
    return StubAlamofireRequest(responseData: responseData)
  }
}

class StubAlamofireRequest: Alamofire.Request {
  var responseData: [String: AnyObject?]?

  init(responseData: [String: AnyObject?]) {
    super.init(session: NSURLSession.sharedSession(), task: NSURLSessionDownloadTask())
    self.responseData = responseData
  }
  
}