//
//  ErrorPresenter.swift
//  GenericReusable
//
//  Created by Sergey on 11/14/18.
//  Copyright © 2018 sblinov.com. All rights reserved.
//

import UIKit

struct AlertPresenter {
    private let title: String
    private let message: String
    private let okTitle: String
    private let canceltitle: String
    
    init(title: String, message: String, okTitle: String = "OK", canceltitle: String = "CANCEL") {
        self.title = title
        self.message = message
        self.okTitle = okTitle
        self.canceltitle = canceltitle
    }
    
    func present(in viewController: UIViewController,
                 animated: Bool = true,
                 completion: (() -> Void)? = nil,
                 okHandler:(() -> Void)? = nil,
                 cancelHandler:(() -> Void)? = nil) {
        let alertController = UIAlertController(
            title: title,
            message: message,
            preferredStyle: .alert
        )
        
        let okAction = UIAlertAction(
            title: okTitle,
            style: .default) { _ in  okHandler?() }
        
        alertController.addAction(okAction)
        
        if (cancelHandler != nil) {
            let cancelAction = UIAlertAction(
                title: canceltitle,
                style: .default) { _ in cancelHandler?() }
            alertController.addAction(cancelAction)
        }
        
        guard viewController.presentedViewController == nil else { return }
        
        viewController.present(alertController, animated: animated, completion: completion)
    }
}
