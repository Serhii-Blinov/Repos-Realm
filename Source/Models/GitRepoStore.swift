//
//  GitRepoStore.swift
//  Repos
//
//  Created by Sergey on 11/13/18.
//  Copyright © 2018 Sergey Blinov. All rights reserved.
//

import Foundation

typealias CompletionHandler<T> = (Result<[T]>) -> Void

class GitRepoStore {
    private var gitRepoService: GitRepoServiceProtocol
    private var storage: RealmStorage
    private var block: (([GitRepo]?) -> Void?)
    
    init(block: @escaping (([GitRepo]?) -> Void), service: GitRepoServiceProtocol, storage: RealmStorage = RealmStorage.shared) {
        self.gitRepoService = service
        self.storage = storage
        self.block = block
    }
    
    func getRepoItems(query: String, completionHandler: @escaping CompletionHandler<GitRepo>)  {
        var collection = [GitRepo]()
        
        let completionOperation = BlockOperation {
            let items = collection.sorted { $0.starsCount > $1.starsCount }
            self.clearItems()
            self.saveItems(items: items)
        }
        
        let pages = Array(1...ConstantsConfig.requstsCount)
            .map { (pageIndex: Int) -> (Page) in return Page(index: pageIndex, perPage: ConstantsConfig.perPage) }
        
        for page in pages {
            let operation = self.gitRepoService.getRepoItems(page: page, query: query, completionHandler: {  result in
                switch result {
                case .success(let items):
                    collection.append(contentsOf: items)
                case .failure(let error):
                    completionHandler(.failure(error))
                    break
                }
            })
            
            completionOperation.addDependency(operation)
        }
        
        OperationQueue.main.addOperation(completionOperation)
    }
    
    func cancel() {
        self.gitRepoService.cancel()
    }
    
    func saveItems(items: [GitRepo]) {
        self.storage.saveGitItems(items)
        self.loadItems(closure: block)
    }
    
    func loadItems(closure: @escaping ([GitRepo]?) -> Void?) {
        self.storage.gitItems(closure: closure)
    }
    
    func clearItems() {
        self.storage.clearItems()
    }
}