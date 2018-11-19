//
//  GetRepoEndpoint.swift
//  Repos
//
//  Created by Sergey on 11/17/18.
//  Copyright © 2018 Sergey Blinov. All rights reserved.
//

import Foundation

enum GitRepoConstants {
    static let sort = "sort"
    static let stars = "stars"
    static let page = "page"
    static let perPage = "per_page"
}

enum GitRepoEndpoint: EndPoint {
    case items(page: Page, query: String)
}

extension GitRepoEndpoint {
    typealias Response = [GitRepo]
    
    var httpMethod: HTTPMethod {
        return .get
    }
    
    var path: String {
        switch self {
        case let .items(_,query):
            return String(format: "/users/%@/repos",query)
        }
    }
    
    var additionalHeaders: [String: String]? {
        return nil
    }
    
    var httpBody: Data? {
        return nil
    }
    
    var queryItems: [URLQueryItem]? {
        switch self {
        case let .items(page,query):
            return queryItems(page, query: query)
        }
    }
    
    func localizedErrorDescription(forStatusCode statusCode: APIError.HttpStatusCode) -> String? {
        return nil
    }
    
    private func queryItems( _ page: Page, query: String) -> [URLQueryItem]? {
        var parameters: [String : String] {
            return [GitRepoConstants.page : String(page.index),
                    GitRepoConstants.perPage : String(page.perPage),
                    GitRepoConstants.sort : GitRepoConstants.stars]
        }
        
        return parameters.map { URLQueryItem(name: $0.key, value: $0.value) }
    }
}
