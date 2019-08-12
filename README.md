# Alamofire Tutorial (iOS 통신 라이브러리)

Swift로 만들어진 HTTP Networking 라이브러리 Alamofire을 소개합니다.

* [Alamofire github](https://github.com/Alamofire/Alamofire)


## 프로젝트에서 사용하는 것 
* Alamofire : 통신 라이브러리
* JSONPlaceholder : JSON 형식의 REST API를 연습해볼 수 있는 홈페이지

## Xcode 설정 (Xcode 10.2 기준)
* Target은 iOS 11 이상을 가정하고 진행합니다.
* 현재 프로젝트는 JSON 형태의 response와 request를 가정하고 있습니다.
* 아래의 5.0.0-beta.7은 현재 최신 버전입니다. 더 업그레이드 된 버전이 있다면 홈페이지에서 확인 후 사용하시기 바랍니다.
* [참고링크](https://github.com/kor45cw/iOS-Tutorials/blob/network/alamofire/Podfile)

Alamofire 라이브러리 사용을 위해 Podfile에 다음의 설정을 해주도록 합니다.

```
pod 'Alamofire', '~> 5.0.0-beta.7'
```

이후 terminal 에서 `pod install`을 진행하시면 자동으로 라이브러리가 설치됩니다.

## Config 파일 만들기
- 통신을 하는 baseURL 등을 지정하는 별도 파일입니다.
- 대게 static 변수들로 이루어져 있습니다.
- [참고링크](https://github.com/kor45cw/iOS-Tutorials/blob/network/alamofire/Tutorials/Config.swift)

```swift
struct Config {
    static let baseURL = "https://jsonplaceholder.typicode.com"
}
```

## Codable struct 생성
- [Codable](https://developer.apple.com/documentation/swift/codable) protocol은 JSON, plist 등으로 이루어 진 데이터를 편리하게 객체로 변환해주는 protocol 입니다.
	- Decodable과 Encodable로 이루어져 있습니다.
- [참고링크](https://github.com/kor45cw/iOS-Tutorials/blob/network/alamofire/Tutorials/UserData.swift)

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

## API service 생성하기
- Config, Codable object가 생성 되었으면, 이제 직접 통신을 시도할 차례입니다.
- [참고링크](https://github.com/kor45cw/iOS-Tutorials/blob/network/alamofire/Tutorials/API.swift)

```swift
class API {
	 // 1
    static let shared: API = API()
    
    // 2
    private var request: DataRequest? {
        didSet {
            oldValue?.cancel()
        }
    }
    
    // 3
    private var reachability: NetworkReachabilityManager!

    private init() {
        monitorReachability()
    }
    
    // 3-1
    private func monitorReachability() {
        reachability = NetworkReachabilityManager(host: "www.apple.com")

        reachability.listener = { status in
            print("Reachability Status Changed: \(status)")
        }

        reachability.startListening()
    }
    
    // 4
    func get1(completionHandler: @escaping (Result<[UserData], Error>) -> Void) {
        self.request = AF.request("\(Config.baseURL)/posts")
        self.request?.responseDecodable { (response: DataResponse<[UserData]>) in
                switch response.result {
                case .success(let userDatas):
                    completionHandler(.success(userDatas))
                case .failure(let error):
                    completionHandler(.failure(error))
                }
            }
    }
    
    // 4-1
    func get2(completionHandler: @escaping (Result<[UserData], Error>) -> Void) {
        let parameters: Parameters = ["userId": 1]
        self.request = AF.request("\(Config.baseURL)/posts", method: .get, parameters: parameters, encoding: URLEncoding.default)
        self.request?.responseDecodable { (response: DataResponse<[UserData]>) in
                switch response.result {
                case .success(let userDatas):
                    completionHandler(.success(userDatas))
                case .failure(let error):
                    completionHandler(.failure(error))
                }
            }
    }
    
    // 5
    func post(completionHandler: @escaping (Result<[UserData], Error>) -> Void) {
        let userData = PostUserData()
        self.request = AF.request("\(Config.baseURL)/posts", method: .post, parameters: userData)
        self.request?.responseDecodable { (response: DataResponse<PostUserData>) in
                switch response.result {
                case .success(let userData):
                    completionHandler(.success([userData.toUserData()]))
                case .failure(let error):
                    completionHandler(.failure(error))
                }
            }
    }
    
    // 6
    func put(completionHandler: @escaping (Result<[UserData], Error>) -> Void) {
        let userData = PostUserData(id: 1)
        self.request = AF.request("\(Config.baseURL)/posts/1", method: .put, parameters: userData)
        self.request?.responseDecodable { (response: DataResponse<PostUserData>) in
                switch response.result {
                case .success(let userData):
                    completionHandler(.success([userData.toUserData()]))
                case .failure(let error):
                    completionHandler(.failure(error))
                }
            }
    }
    
    // 7
    func patch(completionHandler: @escaping (Result<[UserData], Error>) -> Void) {
        let userData = PostUserData(id: 1)
        self.request = AF.request("\(Config.baseURL)/posts/1", method: .patch, parameters: userData)
        self.request?.responseDecodable { (response: DataResponse<PatchUserData>) in
                switch response.result {
                case .success(let userData):
                    completionHandler(.success([userData.toUserData()]))
                case .failure(let error):
                    completionHandler(.failure(error))
                }
            }
    }
    
    // 8
    func delete(completionHandler: @escaping (Result<[UserData], Error>) -> Void) {
        self.request = AF.request("\(Config.baseURL)/posts/1", method: .delete)
        self.request?.response { response in
            switch response.result {
            case .success:
                completionHandler(.success([UserData(userId: -1, id: -1, title: "DELETE", body: "SUCCESS")]))
            case .failure(let error):
                completionHandler(.failure(error))
            }
        }
    }
}
```

### 1. API 객체 생성
- Singleton 방식으로 API 객체를 생성하여 관리합니다.

### 2. reqeust 관리
- request가 시도 중에 새로운 request가 생성되면, 현재 진행중인 oldValue의 request를 cancel 하고 새로운 request를 실행하도록 합니다.

### 3. Reachability
- 현재 셀룰러 데이터가 사용가능한지 확인하는 방법 입니다.
- `monitorReachability`를 호출하여 network 상태가 변경될 때 마다 callback을 받아 상태를 알 수 있도록 설정하였습니다.
- 이후 네트워크가 없을 경우에 대한 별도 설정을 용이하게 하기 위함입니다.

### 4. GET Method
- `AF.request`의 default 호출 방식은 GET 입니다. 따라서 별도의 파라미터가 없다면, URL 값만 넘겨도 무방합니다.

### 4-1. GET Method with parameters
- 별도 parameter가 있을 경우, 가급적 URL뒤에 붙이는 형식이 아닌 별도 parameter를 구분하여 추가하는 것을 추천합니다.
- Encoding 방식은 서버에 따라 다르지만 대게 `URLEncoding.default`, `JSONEncoding.deafult`를 사용합니다.

### 5. POST Method
- POST 방식은 신규 데이터를 등록하는 방식입니다.
- POST에 대응 하는 parameter는 Encodable로 구현하여 통신하였습니다.
- Encodable을 따르는 객체의 데이터를 서버에서 원하는 파라미터, 타입을 맞춰 전송하면 됩니다.
- Alamofire에서 기본적으로 Codable을 지원하고 있으니 맞는 인풋을 넘겨주면 됩니다.

### 6. PUT Method
- PUT 방식은 데이터의 전체를 교체할 때 사용하는 방식입니다.
- PUT의 경우 별도 파라미터가 존재하지 않는다면, method만 지정하여 넘기면 됩니다. POST 방식과 기본적으로 동일합니다.

### 7. PATCH Method
- PATCH 방식은 데이터의 일부를 교체할 때 사용하는 방식입니다.
- PATCH의 경우 별도 파라미터가 존재하지 않는다면, method만 지정하여 넘기면 됩니다. POST 방식과 기본적으로 동일합니다.

### 8. DELETE Method
- Delete의 경우 별도 파라미터가 존재하지 않는다면, method만 지정하여 넘기면 됩니다. POST 방식과 기본적으로 동일합니다.

### 공통 작업 (responseDecodable, completionHandler)
- responseDecodable
	- Alamofire에서는 자동으로 Decodable 객체를 response로 설정하면 파싱하여 데이터를 넘겨주도록 되어있습니다.
	- 위의 responseDecodable을 사용하시면 됩니다.
	- 이외에도 responseString, responseData, responseJSON 등이 있으니 알맞게 사용하면 됩니다.
- completionHandler
	- Network는 기본적으로 별도 thread에서 진행이 되기 때문에 응답 시점을 예측 할 수 없습니다.
	- 따라서 completionHandler를 통하여 응답이 왔을 경우에 대한 처리를 하도록 하였습니다.
	- 응답이 오면, completionHandler를 통해 값을 넘겨주고, 그에 따른 처리는 ViewController에서 진행 되게 됩니다.

## API 의 사용
- ViewController 등에서 API 호출하는 방식을 알아봅니다.
- [참고링크](https://github.com/kor45cw/iOS-Tutorials/blob/network/alamofire/Tutorials/ViewController.swift)

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
* Alamofire의 기초적인 사용법을 알아보았습니다.
* 위의 방식 이외에도 다양한 방식으로 통신을 할 수 있으며, [RxSwift](https://github.com/RxSwiftCommunity/RxAlamofire)역시 지원을 합니다.
* 이번 포스팅에서 사용되었던 코드 예제는 [Github - kor45cw/Tutorials, Alamofire branch](https://github.com/kor45cw/iOS-Tutorials/tree/network/alamofire/)에서 확인하실수 있습니다.

- Android 통신 라이브러리인 [Retrofit의 예제](https://kor45cw.tistory.com/5) 도 있으니 참고 부탁드립니다.

질문 및 지적은 댓글로 해주시면 감사하겠습니다.
