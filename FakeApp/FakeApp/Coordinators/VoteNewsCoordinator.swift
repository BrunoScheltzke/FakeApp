//
//  VoteNewsCoordinator.swift
//  FakeApp
//
//  Created by Bruno Scheltzke on 28/09/18.
//  Copyright © 2018 Bruno Scheltzke. All rights reserved.
//

import UIKit

class VoteNewsCoordinator: Coordinator {
    var rootViewController: UIViewController
    
    init() {
        rootViewController = VoteViewController()
    }
    
    @discardableResult func start(popped: (() -> Void)? = nil) -> UIViewController {
        let voteViewModel = VoteNewsViewModel()
        
        voteViewModel.pop = {
            popped?()
        }
        
        return rootViewController
    }
}
