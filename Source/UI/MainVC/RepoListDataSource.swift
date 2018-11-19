//
//  GitRepoListDataSource.swift
//  Repos
//
//  Created by Sergey on 11/13/18.
//  Copyright © 2018 Sergey Blinov. All rights reserved.
//

import UIKit

protocol GitRepoLoadingDelegate: class {
    func beginLoadItems()
    func endLoadItems(_ error: Error?)
}

class GitRepoListDataSource: NSObject {
    
    private weak var tableView: UITableView?
    private var gitRepoStore: GitRepoStore!
    private var items: [GitRepo] = []
    private weak var loadingDelegate: GitRepoLoadingDelegate?
    
    init(tableView: UITableView, loadingDelegate: GitRepoLoadingDelegate) {
        super.init()
        self.tableView = tableView
        self.tableView?.dataSource = self
        self.tableView?.delegate = nil
        self.loadingDelegate = loadingDelegate
        self.setupGitRepoStore()
    }
    
    func cancelLoad() -> Void {
        self.gitRepoStore.cancel()
    }
    
    func clearItems() -> Void {
        self.items = [GitRepo]()
        self.gitRepoStore.clearItems()
        self.tableView?.reloadData()
    }
    
    func loadRepositories(_ query: String) -> Void {
        self.loadingDelegate?.beginLoadItems()
        self.gitRepoStore.getRepoItems(query: query) { [weak self] result in
            self?.loadingDelegate?.endLoadItems(nil)
            guard let strongSelf = self else { return }
            strongSelf.clearItems()
            switch result {
            case .success(_):
                break
            case .failure(let error):
                strongSelf.loadingDelegate?.endLoadItems(error)
            }
        }
    }
    
    private func setupGitRepoStore() {
        self.gitRepoStore = GitRepoStore(block: { [weak self] items in
            guard let items = items, let strongSlef = self else { return }
            strongSlef.insert(items)
            },service: API.gitRepoServise)
    }
}

extension GitRepoListDataSource: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.items.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: RepoTableViewCell.className) as! RepoTableViewCell
        let item = self.items[indexPath.row]
        let cellModel = GitRepoViewModel(item)
        cell.fillWith(cellModel)
        
        return cell
    }
}

private extension GitRepoListDataSource {
    
    func insert(_ items:[GitRepo]) {
        for object in items {
            self.items.insert(object, at: self.items.count)
            self.insertRow(index: self.items.count - 1)
        }
    }
    
    func insertRow(index: Int) {
        self.tableView?.beginUpdates()
        self.tableView?.insertRows(at: [IndexPath(row: index, section: 0)], with: .automatic)
        self.tableView?.endUpdates()
    }
}
