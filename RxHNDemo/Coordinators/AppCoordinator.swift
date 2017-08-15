//
//  AppCoordinator.swift
//  RxHNDemo
//
//  Created by humbertog on 2017-08-10.
//  Copyright © 2017 humbertog. All rights reserved.
//

import UIKit
import SafariServices

class AppCoordinator: Coordinator {
    let window: UIWindow
    
    init(window: UIWindow) {
        self.window = window
    }
    
    func start() {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        guard let vc = storyboard.instantiateViewController(withIdentifier: "HNList") as? HNListViewController else { fatalError("wrong VC type") }
        
        let viewModel = HNListViewModel(type: .best)
        viewModel.coordinatorDelegate = self
        
        vc.viewModel = viewModel
        
        let navigation = UINavigationController(rootViewController: vc)
        
        window.rootViewController = navigation
    }
}

extension AppCoordinator: HNListCoordinatorViewDelegate {
    func openURL(_ url: URL) {
        let webview = SFSafariViewController(url: url)
        
        window.rootViewController?.presentedViewController?.present(webview, animated: true)
    }
    
    func didSelect(post: HNPost) {
        print(post)
private extension AppCoordinator {
    func showKidsViewController(with post: HNPost) {
        guard let kids = post.kids else { return }
        let viewModel = HNKidViewModel(kids: kids)
        viewModel.coordinatorDelegate = self
        
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        guard let vc = storyboard.instantiateViewController(withIdentifier: "HNComments") as? HNCommentsViewController else {
            fatalError("wrong vc")
        }
        vc.viewModel = viewModel
        
        let nc = window.rootViewController as! UINavigationController
        nc.pushViewController(vc, animated: true)
    }
}
