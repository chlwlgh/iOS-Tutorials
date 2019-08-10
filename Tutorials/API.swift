//
//  API.swift
//  Tutorials
//
//  Created by kor45cw on 10/08/2019.
//  Copyright © 2019 kor45cw. All rights reserved.
//

import Alamofire

class API {
    static let shared: API = API()
    
    private var request: DataRequest? {
        didSet {
            oldValue?.cancel()
        }
    }
    private init() { }
    
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
}