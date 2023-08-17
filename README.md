# SimpleApiClient

SimpleApiClient is a package that's helpful for defining and sending API HTTP requests.  

## Basic Usage

### Overview of Usage

1. Create an `HttpClient`
2. Create `HttpApiRequest`s
3. Call `send(api:)`/`sendAsync(api:)`/`sendPublisher(api:)`

### Setting up an HttpClient

The `HttpClient` is the core object that you will be interacting with. It is initialized using a baseUrl for your API.
```swift
import SimpleApiClient

let myClient = HttpClient(baseUrl: URL(string: "https://api.hosting.com/")!)

// OR

class MyClient: HttpClient {
  init() {
    super.init(baseUrl: URL(string: "https://api.hosting.com/")!)
  }
}
let myClient = MyClient()
``` 

### Creating an HttpApiRequest

The `HttpApiRequest` protocol represents a definition of your API. It contains things like your endpoint path, methods, parameters, headers, etc.  

```swift
import SimpleApiClient

// Set up our response model.
struct Item: Decodable {
  let id: String
  let title: String
  let description: String
}

// Create our API definition with an initializer and properties.
struct GetItemApi {
  let id: String
  
  init(id: String) {
    self.id = id
  }
}

// Extend our definition with parameters, endpoint, and method.
extension GetItemApi: HttpApiRequest {
  typealias ResponseType = MyResponse
  
  var endpointPath: String {
    "item/\(id)/"
  }
  
  var method: HttpMethod {
    .get
  }
}
```

### Sending an API

```swift

let api = GetItemApi(id: "1234")

// Use closures
let taskHandler = myClient.send(api: apiRequest) { result in
  ...
}

// Use Combine Publisher
let itemPublisher = myClient.sendPublisher(api: api)
  .sink { asyncResult in
    ...
  }

// Use Swift Concurrency (async/await)
let item = try await myClient.sendAsync(api: api)
```

## Advanced Usage

### Custom JSON Decoding

By default `HttpClient` uses a JSONDecoder with the `keyDecodingStrategy` set to `.convertFromSnakeCase`. If your API requires a different decoder setup, we can pass one to our `HttpClient`.

```swift
import SimpleApiClient

let myDecoder = JSONDecoder()
myDecoder.keyDecodingStrategy = .useDefaultKeys
myDecoder.assumesTopLevelDictionary = true

let myClient = HttpClient(
  baseUrl: URL(string: "https://api.hosting.com/")!,
  decoder: myDecoder
)
```

### Client-wide Invalid Status Code Parsing 

Sometimes APIs will return a consistent response body when a 2xx status code is not encountered. In these cases we can pass a `DecodableError` type to our `HttpClient`.

If a `DecodableError` type is not provided, a URLError will be thrown by default.

```swift
import SimpleApiClient

struct GenericApiError: DecodableError {
  let errorCode: Int
  let errorMessage: String
}

let myClient = HttpClient(
  baseUrl: URL(string: "https://api.hosting.com/")!,
  invalidStatusCodeType: GenericApiError.self
)
Task {
  do {
    let item = try await myClient.sendAsync(api: GetItemApi(id: "1234"))
  }
  catch let error as GenericApiError {
    print(error.errorCode, error.errorMessage)
  }
  catch {
    print("Unexpected error encountered")
  }
}
```

### Adapters

TODO
