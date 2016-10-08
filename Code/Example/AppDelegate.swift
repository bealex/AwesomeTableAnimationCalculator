//
// Created by Alexander Babaev on 17.04.16.
// Copyright (c) 2016 Alexander Babaev, LonelyBytes. All rights reserved.
// Sources: https://github.com/bealex/AwesomeTableAnimationCalculator
// License: MIT https://github.com/bealex/AwesomeTableAnimationCalculator/blob/master/LICENSE
//

import UIKit
import AwesomeTableAnimationCalculator

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    var window: UIWindow?
    var viewController: UIViewController?

    func application(_ application: UIApplication,
            didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey : Any]?) -> Bool {
        window = UIWindow()

        if let window = window {
            viewController = ViewControllerCollection()
//            viewController = ViewControllerTable()

            let navigationController = UINavigationController(rootViewController: viewController!)

            navigationController.view.frame = window.bounds
            window.rootViewController = navigationController

            window.makeKeyAndVisible()
        }

        // just a small test of ObjC code
//        ObjCTest().test()

        return true
    }

    func applicationWillResignActive(_ application: UIApplication) {
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
    }

    func applicationWillTerminate(_ application: UIApplication) {
    }
}
