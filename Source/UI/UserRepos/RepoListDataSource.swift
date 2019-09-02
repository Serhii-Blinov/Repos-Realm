//
//  GitRepoListDataSource.swift
//  Repos
//
//  Created by Sergey on 11/13/18.
//  Copyright © 2018 Sergey Blinov. All rights reserved.
//

import UIKit
import Realm
import RealmSwift

protocol GitRepoLoadingDelegate: class {
    func beginLoadItems()
    func endLoadItems(_ error: Error?)
}

class GitRepoListDataSource: NSObject {
    
    private weak var tableView: UITableView?
    private var gitRepoStore: GitRepoStore!
    private var items: [GitRepo] = []
    private weak var loadingDelegate: GitRepoLoadingDelegate?
    let realm = try! Realm()
    var notificationToken: NotificationToken? = nil
    
    deinit {
        notificationToken?.invalidate()
    }
    
    init(tableView: UITableView, loadingDelegate: GitRepoLoadingDelegate) {
        super.init()
        self.tableView = tableView
        self.tableView?.dataSource = self
        self.tableView?.delegate = nil
        self.loadingDelegate = loadingDelegate
        self.setupGitRepoStore()
        self.setupObserveItems()
    }
    
    func cancelLoad() -> Void {
        self.gitRepoStore.cancel()
    }
    
    func clearItems() -> Void {
        self.items = [GitRepo]()
        self.gitRepoStore.clearItems()
    }
    
    func loadRepositories(_ query: String) -> Void {
        self.loadingDelegate?.beginLoadItems()
        self.gitRepoStore.getRepoItems(query: query) { [weak self] result in
            self?.loadingDelegate?.endLoadItems(nil)
            guard let strongSelf = self else { return }
            switch result {
            case .success(_):
                break
            case .failure(let error):
                strongSelf.loadingDelegate?.endLoadItems(error)
            }
        }
    }
    
    private func setupGitRepoStore() {
        self.gitRepoStore = GitRepoStore(service: API.gitRepoServise)
    }
    
    func setupObserveItems() {
        let results = realm.objects(GitRepo.self)
        self.items = Array(results)
        
        self.notificationToken = results.observe { [weak self] (changes: RealmCollectionChange) in
            guard let tableView = self?.tableView, let strongSelf = self else { return }
            self?.items = Array(strongSelf.realm.objects(GitRepo.self))
            switch changes {
            case .initial:
                tableView.reloadData()
            case .update(_, let deletions, let insertions, let modifications):
                tableView.beginUpdates()
                tableView.insertRows(at: insertions.map({ IndexPath(row: $0, section: 0) }),
                                     with: .automatic)
                tableView.deleteRows(at: deletions.map({ IndexPath(row: $0, section: 0)}),
                                     with: .automatic)
                tableView.reloadRows(at: modifications.map({ IndexPath(row: $0, section: 0) }),
                                     with: .automatic)
                tableView.endUpdates()
            case .error(let error):
                fatalError("\(error)")
            }
        }
    }
}

extension GitRepoListDataSource: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return realm.objects(GitRepo.self).count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: RepoTableViewCell.className) as! RepoTableViewCell
        let item = self.items[indexPath.row]
        let cellModel = GitRepoViewModel(item)
        cell.fillWith(cellModel)
        
        return cell
    }
}
