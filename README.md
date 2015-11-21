# Networking

A simple iOS networking library written in Swift

## Instructions

1. Follow these [instructions on how to add a Git repository to your Xcode project][1].

2. Usage

    Globally, e.g., at the top of `AppDelegate.swift`, do:

        let api = API(baseURL: NSURL(string: "https://api.example.com"))

    To make a simple GET request:

        let request = NSURLRequest(URL: api.URLWithPath("/users"))

    To make a form POST request:

        let fields = ["name": "Matt", "email": "matt@example.com"]
        var request = api.formRequest("POST", "/users", fields)

    Then, to send either of the requests above, use `NSURLSession`:

        let dataTask = NSURLSession.sharedSession().dataTaskWithRequest(request, completionHandler: { (data, response, error) in
            // Handle response
        }

    To make and send a multipart request:

        let boundary = Web.multipartBoundary()
        let request = Web.multipartRequest("POST", "/users", boundary)
        let fields = ["name": "Matt", "email": "matt@example.com"]
        let data = api.multipartData(boundary, fields, UIImageJPEGRepresentation(UIImage(named: "Matt"), 0.9))
        let dataTask = NSURLSession.sharedSession().uploadTaskWithRequest(request, fromData: data, completionHandler: { (data, response, error) in
            // Handle response
        }

    Use `Web` instead of `api` for making one-off requests to resources with different base URLs.

Released under the [Unlicense][2].


[1]: https://github.com/acani/Libraries
[2]: http://unlicense.org
