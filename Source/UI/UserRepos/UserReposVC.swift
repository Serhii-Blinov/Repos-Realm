//
//  ViewController.swift
//  Repos
//
//  Created by Sergey on 11/19/18.
//  Copyright © 2018 sblinov.com. All rights reserved.
//

import UIKit

class UserReposVC: UIViewController {
    
    @IBOutlet var changeUserNameButton: UIButton!
    @IBOutlet var tableView: UITableView!{
        didSet {
            tableView.register(RepoTableViewCell.self)
        }
    }
    
    private var activityIndicatorView: UIActivityIndicatorView!
    private var dataSource: GitRepoListDataSource!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = String(format: "User: %@", ConstantsConfig.gitHubUser)
        self.setupUI()
        self.dataSource = GitRepoListDataSource(tableView: self.tableView, loadingDelegate: self)
        self.dataSource.loadRepositories(ConstantsConfig.gitHubUser)
    }
    
    func setupUI() {
        self.activityIndicatorView = UIActivityIndicatorView(style: .gray)
        self.tableView.backgroundView = activityIndicatorView
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(customView: self.changeUserNameButton)
    }
    
    func stopShowActivity() {
        if self.activityIndicatorView.isAnimating {
            self.activityIndicatorView.stopAnimating()
        }
    }
    
    func startShowActivity()  {
        self.activityIndicatorView.startAnimating()
    }
}

extension UserReposVC: GitRepoLoadingDelegate {
    
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
        
        let errorPresenter = AlertPresenter(title: ConstantsConfig.error, message: message)
        errorPresenter.present(in: self)
    }
}
