//
//  GitRepo.swift
//  Repos
//
//  Created by Sergey on 11/13/18.
//  Copyright © 2018 Sergey Blinov. All rights reserved.
//

import UIKit
import RealmSwift
import Realm

class GitRepo: Object, Codable {
    @objc dynamic var identifier: Int64 = 0
    @objc dynamic var name: String?
    @objc dynamic var devLanguage: String?
    @objc dynamic var url: String?
    @objc dynamic var starsCount: Int64 = 0
    
    enum CodingKeys: String, CodingKey {
        case identifier = "id"
        case name = "full_name"
        case devLanguage = "language"
        case url = "html_url"
        case starsCount = "stargazers_count"
    }
    
    override class func primaryKey() -> String? {
        return "identifier"
    }
    
    convenience init(identifier: Int64, name: String?, devLanguage: String?, url: String?, starsCount: Int64) {
        self.init()
        self.identifier = identifier
        self.name = name
        self.devLanguage = devLanguage
        self.url = url
        self.starsCount = starsCount
    }
    
    required convenience init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        let name = try? values.decode(String.self, forKey: .name)
        let devLanguage =  try? values.decode(String.self, forKey: .devLanguage)
        let url = try? values.decode(String.self, forKey: .url)
        let starsCount = try values.decode(Int64.self, forKey: .starsCount)
        let identifier = try values.decode(Int64.self, forKey: .identifier)
        self.init(identifier:identifier, name: name, devLanguage: devLanguage, url: url, starsCount: starsCount)
    }

    required init() {
        super.init()
    }
    
    required init(value: Any, schema: RLMSchema) {
        super.init(value: value, schema: schema)
    }
    
    required init(realm: RLMRealm, schema: RLMObjectSchema) {
        super.init(realm: realm, schema: schema)
    }
}
