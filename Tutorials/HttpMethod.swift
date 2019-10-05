//
//  HttpMethod.swift
//  Tutorials
//
//  Created by kor45cw on 05/10/2019.
//  Copyright © 2019 kor45cw. All rights reserved.
//

import Foundation

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
