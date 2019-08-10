//
//  UserData.swift
//  Tutorials
//
//  Created by kor45cw on 10/08/2019.
//  Copyright © 2019 kor45cw. All rights reserved.
//

import Foundation

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
