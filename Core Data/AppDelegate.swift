//
//  AppDelegate.swift
//  Core Data
//
//  Created by Сергей Веретенников on 25/04/2022.
//

import UIKit
import CoreData

@main
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        window = UIWindow(frame: UIScreen.main.bounds)
        window?.makeKeyAndVisible()
        window?.rootViewController = UINavigationController(rootViewController: TaskListViewController())
        return true
    }
    
    
    func applicationWillTerminate(_ application: UIApplication) {
        StorageMenager.shared.saveContext()
    }
}

