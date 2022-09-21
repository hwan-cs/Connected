//
//  AppDelegate.swift
//  Connected
//
//  Created by Jung Hwan Park on 2022/09/09.
//

import UIKit
import FirebaseCore
import AuthenticationServices
import Firebase
import FirebaseDynamicLinks

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate
{
    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool
    {
        // Override point for customization after application launch.
        FirebaseApp.configure()
        return true
    }
}

