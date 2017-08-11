//
//  AppDelegate.swift
//  RxHNDemo
//
//  Created by humbertog on 2017-08-01.
//  Copyright © 2017 humbertog. All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    var appCoordinator: AppCoordinator!


    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        
        window = UIWindow()
        appCoordinator = AppCoordinator(window: window!)
        appCoordinator.start()
        window?.makeKeyAndVisible()
        
        return true
    }
}

