//
//  ViewController.swift
//  Repos
//
//  Created by Sergey on 11/19/18.
//  Copyright © 2018 sblinov.com. All rights reserved.
//

import UIKit

class MainVC: UIViewController {
    
    @IBOutlet weak var tableView: UITableView!{
        didSet {
            tableView.register(RepoTableViewCell.self)
        }
    }
    
    private var activityIndicatorView: UIActivityIndicatorView!
    private var dataSource: GitRepoListDataSource!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = String(format: "User: %@", ConstantsConfig.gitHubUser)
        self.setupTableView()
        self.dataSource = GitRepoListDataSource(tableView: self.tableView, loadingDelegate: self)
        self.dataSource.loadRepositories(ConstantsConfig.gitHubUser)
    }
    
    func setupTableView() -> Void {
        self.activityIndicatorView = UIActivityIndicatorView(style: .gray)
        self.tableView.backgroundView = activityIndicatorView
    }
    
    func stopShowActivity() -> Void {
        if self.activityIndicatorView.isAnimating {
            self.activityIndicatorView.stopAnimating()
        }
    }
    
    func startShowActivity() -> Void {
        self.activityIndicatorView.startAnimating()
    }
}

extension MainVC: GitRepoLoadingDelegate {
    
    func beginLoadItems() {
        self.stopShowActivity()
    }
    
    func endLoadItems(_ error: Error?) {
        self.stopShowActivity()
        guard let error = error else { return }
        var message = ConstantsConfig.errorMessage
        
        if !error.localizedDescription.isEmpty {
            message = error.localizedDescription
        }
        
        let errorPresenter = ErrorPresenter.init(title: ConstantsConfig.error, message: message)
        errorPresenter.present(in: self)
    }
}
