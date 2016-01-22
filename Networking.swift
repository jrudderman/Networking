import UIKit

struct API {
    let baseURL: NSURL
    var accessToken: String?

    init(baseURL: NSURL) {
        self.baseURL = baseURL
    }

    func URLWithPath(path: String) -> NSURL {
        return NSURL(string: path, relativeToURL: baseURL)!
    }

    func request(HTTPMethod: String, _ path: String, _ fields: Dictionary<String, String>? = nil, _ JPEGData: NSData? = nil, auth: Bool = false) -> NSMutableURLRequest {
        let request = Net.request(HTTPMethod, URLWithPath(path), fields, JPEGData)
        if auth { authorizeRequest(request) }
        return request
    }

    static func dataTaskWithRequest(request: NSURLRequest, _ completionHandler: (AnyObject?, Int?, NSError?) -> Void) -> NSURLSessionDataTask {
        return NSURLSession.sharedSession().dataTaskWithRequest(request) { (data, response, error) in
            let JSONObject: AnyObject? = data != nil ? try? NSJSONSerialization.JSONObjectWithData(data!, options: NSJSONReadingOptions(rawValue: 0)) : nil
            let statusCode = (response as! NSHTTPURLResponse?)?.statusCode
            completionHandler(JSONObject, statusCode, error)
        }
    }

    private func authorizeRequest(request: NSMutableURLRequest) {
        request.setValue("Bearer "+accessToken!, forHTTPHeaderField: "Authorization")
    }
}

struct Net {
    static func request(HTTPMethod: String, _ URL: NSURL, _ fields: Dictionary<String, String>? = nil, _ JPEGData: NSData? = nil) -> NSMutableURLRequest {
        let request = NSMutableURLRequest(URL: URL)
        request.HTTPMethod = HTTPMethod

        if JPEGData == nil {
            if fields != nil {
                request.addValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
                request.HTTPBody = formHTTPBodyFromFields(fields!)
            }
        } else {
            let boundary = multipartBoundary()
            request.addValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")
            request.HTTPBody = multipartBodyData(boundary, fields, JPEGData!)
        }

        return request
    }

    // Convert ["name1": "value1", "name2": "value2"] to "name1=value1&name2=value2".
    // NOTE: Like curl, let front-end developers URL encode names & values.
    private static func formHTTPBodyFromFields(fields: Dictionary<String, String>) -> NSData? {
        var bodyArray = [String]()
        for (name, value) in fields {
            bodyArray.append("\(name)=\(value)")
        }
        return bodyArray.joinWithSeparator("&").dataUsingEncoding(NSUTF8StringEncoding)
    }

    private static func multipartBoundary() -> String {
        return "-----AcaniFormBoundary" + String.randomStringWithLength(16)
    }

    private static func multipartBodyData(boundary: String, _ fields: Dictionary<String, String>? = nil, _ JPEGData: NSData) -> NSData {
        var bodyString = ""
        let hh = "--", rn = "\r\n"

        func contentDisposition(name: String) -> String {
            return "Content-Disposition: form-data; name=\"\(name)\""
        }

        // Add fields
        if fields != nil {
            for (name, value) in fields! {
                bodyString += hh + boundary + rn
                bodyString += contentDisposition(name) + rn + rn
                bodyString += value + rn
            }
        }

        // Add JPEG data
        bodyString += hh + boundary + rn
        bodyString += contentDisposition("jpeg") + rn
        bodyString += "Content-Type: image/jpeg" + rn + rn
        let bodyData = NSMutableData(data: bodyString.dataUsingEncoding(NSUTF8StringEncoding)!)
        bodyData.appendData(JPEGData)

        // Complete
        bodyString = rn + hh + boundary + hh + rn
        bodyData.appendData(bodyString.dataUsingEncoding(NSUTF8StringEncoding)!)

        return bodyData
    }
}

extension String {
    static func randomStringWithLength(length: Int) -> String {
        let alphabet = "-_1234567890abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ" // 64 characters
        return String((0..<length).map { _ -> Character in
            return alphabet[alphabet.startIndex.advancedBy(Int(arc4random_uniform(64)))]  // <^ connected
        })
    }

    // Percent encode all characters except alphanumerics, "*", "-", ".", and "_". Replace " " with "+".
    // http://www.w3.org/TR/html5/forms.html#application/x-www-form-urlencoded-encoding-algorithm
    func stringByAddingFormURLEncoding() -> String {
        let characterSet = NSMutableCharacterSet.alphanumericCharacterSet()
        characterSet.addCharactersInString("*-._ ")
        return stringByAddingPercentEncodingWithAllowedCharacters(characterSet)!.stringByReplacingOccurrencesOfString(" ", withString: "+")
    }
}

extension UIViewController {
    func alertError(dictionary: Dictionary<String, String>?, error: NSError?, handler: ((UIAlertAction) -> Void)?) {
        let alert = UIAlertController(dictionary: dictionary, error: error, handler: handler)
        presentViewController(alert, animated: true, completion: nil)
    }
}

extension UIAlertController {
    convenience init(dictionary: Dictionary<String, String>?, error: NSError?, handler: ((UIAlertAction) -> Void)?) {
        let title = dictionary?["title"] ?? ""
        let message = dictionary?["message"] ?? (error != nil ? error!.localizedDescription : "Could not connect to server.")
        self.init(title: title, message: message, preferredStyle: .Alert)
        self.addAction(UIAlertAction(title: "OK", style: .Cancel, handler: handler))
    }
}
