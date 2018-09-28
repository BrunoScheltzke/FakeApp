//
//  AppCoordinator.swift
//  FakeApp
//
//  Created by Bruno Scheltzke on 28/09/18.
//  Copyright © 2018 Bruno Scheltzke. All rights reserved.
//

import UIKit

protocol Coordinator {
    var rootViewController: UIViewController { get set }
    @discardableResult func start(popped: (() -> Void)?) -> UIViewController
}

protocol TabBarCoordinator {
    var tabBarController: UITabBarController { get set }
    @discardableResult func start(popped: (() -> Void)?) -> UITabBarController
}

class AppCoordinator: TabBarCoordinator {
    let window: UIWindow?
    var tabBarController: UITabBarController = UITabBarController()
    
    init(window: UIWindow?) {
        self.window = window
    }
    
    @discardableResult func start(popped: (() -> Void)? = nil) -> UITabBarController {
        guard let window = window else { return tabBarController }
        
        let voteCoordinator = VoteNewsCoordinator()
        let voteVc = voteCoordinator.start()
        
        tabBarController.setViewControllers([voteVc], animated: true)
        
        window.rootViewController = tabBarController
        window.makeKeyAndVisible()
        
        return tabBarController
    }
}
