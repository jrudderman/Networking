# Networking

iOS networking library written in Swift

## Instructions

1. Follow these [instructions on how to add a Git repository to your Xcode project][1].

2. Usage

    Globally, e.g., at the top of `AppDelegate.swift`, do:

        let api = API(baseURL: NSURL(string: "https://api.example.com"))

    To make a GET request:

        let request = api.request("GET", "/users")

    To make a form POST request:

        let fields = ["name": "Matt", "email": "matt@example.com"]
        let request = api.request("POST", "/users", fields)

    If certain API paths require an access token, set it:

        api.accessToken = "fb2e77d.47a0479900504cb3ab4a1f626d174d2d"

    Then, to make an authorized request, which includes your access token:

        let request = api.request("GET", "/me", auth: true)

    Then, to send any of the requests above, use `NSURLSession`:

        let dataTask = NSURLSession.sharedSession().dataTaskWithRequest(request) { data, response, error in
            // Handle response
        }

    Or, for help parsing a JSON response, use `API`:

        let dataTask = API.dataTaskWithRequest(request) { JSONObject, statusCode, error in
            // Handle response
        }

    To make and send a multipart (file-upload) request:

        let fields = ["name": "Matt", "email": "matt@example.com"]
        let JPEGData = UIImageJPEGRepresentation(UIImage(named: "Matt"), 0.9)
        let request = api.request("POST", "/users", fields, JPEGData)
        let dataTask = NSURLSession.sharedSession().uploadTaskWithRequest(request, fromData: request.HTTPBody!) { data, response, error in
            // Handle response
        }

    Use `Net` instead of `api` for making one-off requests to resources with different base URLs.

    See the [Acani Chats iPhone Client][2] for example usage.

    See [`Networking.swift`][3] for other handy functions not mentioned here.

Released under the [Unlicense][4].


[1]: https://github.com/acani/Libraries
[2]: https://github.com/acani/Chats-iPhone-Client
[3]: https://github.com/acani/Networking/blob/master/Networking.swift
[4]: http://unlicense.org
