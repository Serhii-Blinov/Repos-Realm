//
//  RealmStorage.swift
//  Repos
//
//  Created by Sergey Blinov on 11/13/18.
//  Copyright © 2018 Sergey Blinov. All rights reserved.
//

import Foundation
import RealmSwift
import Realm

class RealmStorage {
    static let shared = RealmStorage()
    let realm = try! Realm()
    let serialQueue = DispatchQueue(label: "com.gitItemsQueue")
    
    func saveGitItems(_ items: [GitRepo]) {
        serialQueue.sync {
            do {
                try realm.write { realm.add(items) }
            }catch let error {
                print(error)
            }
        }
    }
    
    func gitItems(closure: @escaping([GitRepo]?) -> Void?) {
        serialQueue.sync {
            closure(Array(realm.objects(GitRepo.self)))
        }
    }
    
    func clearItems() {
        serialQueue.sync {
            do {
                try realm.write {  realm.deleteAll() }
            }catch let error {
                print(error)
            }
        }
    }
}
