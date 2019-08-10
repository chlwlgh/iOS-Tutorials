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
