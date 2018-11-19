//
//  API.swift
//  Repos
//
//  Created by Sergey on 11/13/18.
//  Copyright © 2018 Sergey Blinov. All rights reserved.
//

import Foundation

enum API {
    static let gitRepoServise = GitRepoService()
    static let gitRepoClient = GitRepoAPIClient()
}
