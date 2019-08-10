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
        self.request = AF.request("\(Config.baseURL)/posts", method: .get)
        self.request?.responseDecodable { (response: DataResponse<[UserData]>) in
                switch response.result {
                case .success(let userDatas):
                    completionHandler(.success(userDatas))
                case .failure(let error):
                    completionHandler(.failure(error))
                }
            }
    }
}
