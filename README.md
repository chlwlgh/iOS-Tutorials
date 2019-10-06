# URLSession Tutorial (iOS 통신 라이브러리)

Swift로 만들어진 HTTP Networking 라이브러리 Alamofire을 소개합니다.

* [URLSession Document Page](https://developer.apple.com/documentation/foundation/urlsession)


## 프로젝트에서 사용하는 것 
* URLSession : 애플에서 기본으로 제공하느 통신 라이브러리
* JSONPlaceholder : JSON 형식의 REST API를 연습해볼 수 있는 홈페이지

## Xcode 설정 (Xcode 11.0 기준)
* Target은 iOS 11 이상을 가정하고 진행합니다.
* 현재 프로젝트는 JSON 형태의 response와 request를 가정하고 있습니다.

## Config 파일 만들기
- 통신을 하는 baseURL 등을 지정하는 별도 파일입니다.
- 대게 static 변수들로 이루어져 있습니다.
- [참고링크](https://github.com/kor45cw/iOS-Tutorials/blob/network/urlsession/Tutorials/Config.swift)

```swift
struct Config {
    static let baseURL = "https://jsonplaceholder.typicode.com"
}
```

## HTTP Method 생성
- URLRequest에서는 Http method를 string 형태로 전달하는 방식을 사용하고 있습니다.
- 하지만 개발의 편리성을 위해 우리는 enum type을 활용하도록 합니다.
- [참고링크](https://github.com/kor45cw/iOS-Tutorials/blob/network/urlsession/Tutorials/HttpMethod.swift)

```swift
enum HttpMethod<Body> {
    case get
    case post(Body)
    case put(Body)
    case patch(Body)
    case delete(Body)
}

extension HttpMethod {
    var method: String {
        switch self {
        case .get:
            return "GET"
        case .post:
            return "POST"
        case .put:
            return "PUT"
        case .patch:
            return "PATCH"
        case .delete:
            return "DELETE"
        }
    }
}
```

## Codable struct 생성
- [Codable](https://developer.apple.com/documentation/swift/codable) protocol은 JSON, plist 등으로 이루어 진 데이터를 편리하게 객체로 변환해주는 protocol 입니다.
	- Decodable과 Encodable로 이루어져 있습니다.
- [참고링크](https://github.com/kor45cw/iOS-Tutorials/blob/network/urlsession/Tutorials/UserData.swift)

```swift
struct UserData: Decodable {
    let userId: Int
    let id: Int
    let title: String
    let body: String
}

struct PostUserData: Codable {
    let userId: String
    let id: Int?
    let title: String
    let body: String
    
    init(id: Int? = nil) {
        self.userId = "1"
        self.title = "Title"
        self.body = "Body"
        self.id = id
    }
    
    func toUserData() -> UserData {
        return UserData(userId: Int(userId) ?? 0, id: id ?? 0, title: title, body: body)
    }
}

struct PatchUserData: Decodable {
    let userId: String
    let id: String
    let title: String
    let body: String
    
    func toUserData() -> UserData {
        return UserData(userId: Int(userId) ?? 0, id: Int(id) ?? 0, title: title, body: body)
    }
}
```

## Request를 관리하는 Resource를 생성
- 별도의 관리 포인트 없이 바로 request를 실행하게 되면, 개별 API 별로 return type을 지정해야하는 문제가 생깁니다.
- 그런 문제를 해결하기 위해서 Encodable, Decodable type을 Generic하게 입력 받는 resource라는 관리포인트를 생성하는 것이 좋습니다.
	- 각 request type에 따른 URLRequest Setting을 하도록 합니다.
- [참고링크](https://github.com/kor45cw/iOS-Tutorials/blob/network/urlsession/Tutorials/Resource.swift)

```swift
struct Resource<T> {
    var urlRequest: URLRequest
    let parse: (Data) -> T?
}

extension Resource where T: Decodable {
	 // 1
    init(url: URL) {
        self.urlRequest = URLRequest(url: url)
        self.parse = { data in
            try? JSONDecoder().decode(T.self, from: data)
        }
    }
    
    // 2
    init(url: String, parameters _parameters: [String: String]) {
        var component = URLComponents(string: url)
        var parameters = [URLQueryItem]()
        for (name, value) in _parameters {
            if name.isEmpty { continue }
            parameters.append(URLQueryItem(name: name, value: value))
        }

        if !parameters.isEmpty {
          component?.queryItems = parameters
        }
        if let componentURL = component?.url {
            self.urlRequest = URLRequest(url: componentURL)
        } else {
            self.urlRequest = URLRequest(url: URL(string: url)!)
        }
        self.parse = { data in
            try? JSONDecoder().decode(T.self, from: data)
        }
    }
    
    // 3
    init<Body: Encodable>(url: URL, method: HttpMethod<Body>) {
        self.urlRequest = URLRequest(url: url)
        self.urlRequest.httpMethod = method.method

        switch method {
        case .post(let body), .delete(let body), .patch(let body), .put(let body):
            self.urlRequest.httpBody = try? JSONEncoder().encode(body)
            self.urlRequest.addValue("application/json", forHTTPHeaderField: "Content-Type")
            self.urlRequest.addValue("application/json", forHTTPHeaderField: "Accept")
        default: break
        }
        self.parse = { data in
            try? JSONDecoder().decode(T.self, from: data)
        }
    }
}

```

### 1. 기본 GET 방식의 request
- 기본 URLRequest는 get 방식을 지원합니다.
- 따라서 맞는 URL을 던져주고, 결과로 나오는 data를 Decodable Type으로 파싱하는 코드만 넣도록 합니다.

### 2. GET 방식 with Parameters, request
- GET 방식에서의 Parameter와 함께 request를 보내는 것은 결국 "https://baseURL.com/?name=value" 형태로 변환하여 url 요청을 하는 것입니다.
- 따라서 Parameter의 입력은 [String: String] dictionary의 형태로 받되, 그 값은 내부에서 URLQueryItem으로 추가하도록 합니다.
- 마지막으로 그 결과로 나온 url을 URLComponent에서 꺼내어 사용합니다.
- 파싱 코드는 동일합니다.

### 3. Body와 함께 전달하는 방식을 사용하는 request
- GET 방식이외의 method는 URLRequest에 별도로 지정을 해주어야합니다.
- 또한 보내는 body값을 Encodable 타입으로 제한하여, data로 변경되도록 JSONEncoder를 사용합니다.
- 이후 Content-Type, Accept 를 application/json으로 설정하여 json data를 받을 수 있도록 도와줍니다.


## URLSession+Extension
- URLSession의 request를 조금 더 쉽게, 그리고 Resource에 맞춰 request를 쏠 수 있도록 하기 위해 load 함수를 별도로 생성합니다.
- 구현은 아래와 같습니다.
- [참고링크](https://github.com/kor45cw/iOS-Tutorials/blob/network/urlsession/Tutorials/URLSession%2BExtension.swift)

```swift
extension URLSession {
    func load<T>(_ resource: Resource<T>, completion: @escaping (T?, Bool) -> Void) {
        dataTask(with: resource.urlRequest) { data, response, _ in
            if let response = response as? HTTPURLResponse,
                (200..<300).contains(response.statusCode) {
                completion(data.flatMap(resource.parse), true)
            } else {
                completion(nil, false)
            }
        }.resume()
    }
}
```



## API service 생성하기
- Config, Codable object가 생성 되었으면, 이제 직접 통신을 시도할 차례입니다.
- [참고링크](https://github.com/kor45cw/iOS-Tutorials/blob/network/urlsession/Tutorials/API.swift)

```swift
class API {
	 // 1
    enum APIError: LocalizedError {
        case urlNotSupport
        case noData
        
        var errorDescription: String? {
            switch self {
            case .urlNotSupport: return "URL NOT Supported"
            case .noData: return "Has No Data"
            }
        }
    }
    
    // 2
    static let shared: API = API()
    
    private lazy var defaultSession = URLSession(configuration: .default)
    
    private init() { }
   
    // 3
    func get1(completionHandler: @escaping (Result<[UserData], APIError>) -> Void) {
        guard let url = URL(string: "\(Config.baseURL)/posts") else {
            completionHandler(.failure(.urlNotSupport))
            return
        }
        let resource = Resource<[UserData]>(url: url)
        defaultSession.load(resource) { userDatas, _ in
            guard let data = userDatas, !data.isEmpty else {
                completionHandler(.failure(.noData))
                return
            }
            completionHandler(.success(data))
        }
    }
    
    func get2(completionHandler: @escaping (Result<[UserData], APIError>) -> Void) {
        let resource = Resource<[UserData]>(url: "\(Config.baseURL)/posts", parameters: ["userId": "1"])
        defaultSession.load(resource) { userDatas, _ in
            guard let data = userDatas, !data.isEmpty else {
                completionHandler(.failure(.noData))
                return
            }
            completionHandler(.success(data))
        }
    }
    
    func post(completionHandler: @escaping (Result<[UserData], APIError>) -> Void) {
        guard let url = URL(string: "\(Config.baseURL)/posts") else {
            completionHandler(.failure(.urlNotSupport))
            return
        }
        
        let userData = PostUserData()
        let resource = Resource<PostUserData>(url: url, method: .post(userData))
        defaultSession.load(resource) { userData, _ in
            guard let data = userData else {
                completionHandler(.failure(.noData))
                return
            }
            completionHandler(.success([data.toUserData()]))
        }
    }
    
    func put(completionHandler: @escaping (Result<[UserData], APIError>) -> Void) {
        guard let url = URL(string: "\(Config.baseURL)/posts/1") else {
            completionHandler(.failure(.urlNotSupport))
            return
        }
        let userData = PostUserData(id: 1)
        let resource = Resource<PostUserData>(url: url, method: .put(userData))
        defaultSession.load(resource) { userData, _ in
            guard let data = userData else {
                completionHandler(.failure(.noData))
                return
            }
            completionHandler(.success([data.toUserData()]))
        }
    }

    func patch(completionHandler: @escaping (Result<[UserData], APIError>) -> Void) {
        guard let url = URL(string: "\(Config.baseURL)/posts/1") else {
            completionHandler(.failure(.urlNotSupport))
            return
        }
        let userData = PostUserData(id: 1)
        let resource = Resource<PostUserData>(url: url, method: .patch(userData))
        defaultSession.load(resource) { userData, _ in
            guard let data = userData else {
                completionHandler(.failure(.noData))
                return
            }
            completionHandler(.success([data.toUserData()]))
        }
    }

    func delete(completionHandler: @escaping (Result<[UserData], APIError>) -> Void) {
        guard let url = URL(string: "\(Config.baseURL)/posts/1") else {
            completionHandler(.failure(.urlNotSupport))
            return
        }
        let userData = PostUserData()
        let resource = Resource<UserData>(url: url, method: .delete(userData))
        defaultSession.load(resource) { userData, response in
            if response {
                completionHandler(.success([UserData(userId: -1, id: -1, title: "DELETE", body: "SUCCESS")]))
            } else {
                completionHandler(.failure(.noData))
            }
        }
    }
}
```

### 1. Custom APIError 생성
- request 요청시에 사용자가 설정한 error 값도 던질수 있게 setting 합니다.

### 2. API 객체 생성
- Singleton 방식으로 API 객체를 생성하여 관리합니다.

### 3. Request Method
- Resource의 사용법은 다음과 같습니다.
- Resource를 생성함과 동시에 parse할 decodable Type에 해당하는 타입을 정해주고, 정해진 init방식에 따라 url, method를 전달해주도록 합니다.
- 이후 load 함수를 통하여 값을 가져옵니다.

### 공통 작업 (completionHandler, DispatchQueue.main.async)
- completionHandler
	- Network는 기본적으로 별도 thread에서 진행이 되기 때문에 응답 시점을 예측 할 수 없습니다.
	- 따라서 completionHandler를 통하여 응답이 왔을 경우에 대한 처리를 하도록 하였습니다.
	- 응답이 오면, completionHandler를 통해 값을 넘겨주고, 그에 따른 처리는 ViewController에서 진행 되게 됩니다.
- DispatchQueue.main.async
	- URLRequest의 경우 값을 가져온 뒤 자동으로 main thread로 돌아오지 않습니다.
	- 따라서 바로 UI 작업을 진행할 경우, 경고가 뜨게 됩니다 (UI 작업은 main에서만 가능)
	- 그러므로 작업이 끝난 뒤에 DispatchQueue.main을 활용하여 main thread에서 작업할 수 있도록 도와줄 필요가 있습니다.

## API 의 사용
- ViewController 등에서 API 호출하는 방식을 알아봅니다.
- [참고링크](https://github.com/kor45cw/iOS-Tutorials/blob/network/urlsession/Tutorials/ViewController.swift)

```swift
@IBAction private func GET1(_ sender: UIButton) {
	API.shared.get1(completionHandler: handler)
}

handler = { [weak self] result in
            guard let self = self else { return }
            switch result {
            case .success(let userDatas):
                guard let userData = userDatas.first else { return }
                self.setInfo(by: userData)
            case .failure(let error):
                print("Error", error.localizedDescription)
                self.setError()
            }
        }
```


## 마무리
* URLSession의 기초적인 사용법을 알아보았습니다.
* 이번 포스팅에서 사용되었던 코드 예제는 [Github - kor45cw/Tutorials, URLSession branch](https://github.com/kor45cw/iOS-Tutorials/tree/network/urlsession/)에서 확인하실수 있습니다.

- Android 통신 라이브러리인 [Retrofit의 예제](https://kor45cw.tistory.com/5) 도 있으니 참고 부탁드립니다.
