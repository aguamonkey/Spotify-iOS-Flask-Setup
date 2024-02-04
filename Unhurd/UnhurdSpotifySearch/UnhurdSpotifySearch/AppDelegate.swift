//
//  AppDelegate.swift
//  UnhurdSpotifySearch
//
//  Created by Joshua Browne on 02/02/2024.
//

import UIKit

class AppDelegate: UIResponder, UIApplicationDelegate {
    
    var window: UIWindow?
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Create the window
        self.window = UIWindow(frame: UIScreen.main.bounds)
        
        // Set the initial view controller
        let initialViewController = SearchViewController() // Make sure to define this class
        let navigationController = UINavigationController(rootViewController: initialViewController)
        
        self.window?.rootViewController = navigationController
        self.window?.makeKeyAndVisible()
        
        return true
    }
}
