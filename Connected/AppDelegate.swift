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
import IQKeyboardManagerSwift
import FirebaseAuth
import GoogleMaps
import GooglePlaces
import UserNotifications
import RealmSwift
import FirebaseMessaging

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate
{
    var window: UIWindow?
    
    static var receiverFCMToken: String?
    
    static var legacyServerKey = K.legacyServerKey
    
    let gcmMessageIDKey = "gcm.message_id"

    override init()
    {
        FirebaseApp.configure()
    }
        
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool
    {
        let _ = print(FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!.path)
        // Override point for customization after application launch.
//        IQKeyboardManager.shared.enable = true
        GMSServices.provideAPIKey(K.GoogleMapsAPIKey)
        GMSPlacesClient.provideAPIKey(K.GoogleMapsAPIKey)
        IQKeyboardManager.shared.enableAutoToolbar = false
        
        if Auth.auth().currentUser == nil
        {
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            let vc = storyboard.instantiateViewController(withIdentifier: "InitialNavigationController") as! UINavigationController
            let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene
            windowScene?.windows.first?.rootViewController = vc
            windowScene?.windows.first?.makeKeyAndVisible()
        }
        
        Messaging.messaging().delegate = self
        
        if #available(iOS 10.0, *)
        {
          // For iOS 10 display notification (sent via APNS)
            UNUserNotificationCenter.current().delegate = self as? UNUserNotificationCenterDelegate

          let authOptions: UNAuthorizationOptions = [.alert, .badge, .sound]
          UNUserNotificationCenter.current().requestAuthorization(
            options: authOptions,
            completionHandler: { _, _ in }
          )
        }
        else
        {
          let settings: UIUserNotificationSettings =
            UIUserNotificationSettings(types: [.alert, .badge, .sound], categories: nil)
          application.registerUserNotificationSettings(settings)
        }

        application.registerForRemoteNotifications()

        if UserDefaults.standard.bool(forKey: "darkmode")
        {
            window!.overrideUserInterfaceStyle = .dark
            K.darkmode = true
        }
        else
        {
            window!.overrideUserInterfaceStyle = .light
            K.darkmode = false
        }
        
        if #available(iOS 16, *)
        {
            K.lang = Locale.current.language.languageCode!.identifier == "ko" ? "ko" : "en"
        }
        else
        {
            K.lang = Locale.current.languageCode! == "ko" ? "ko" : "en"
        }
        return true
    }
    
    func applicationDidEnterBackground(_ application: UIApplication)
    {
        let db = Firestore.firestore()
        let uuid = Auth.auth().currentUser?.uid
        Task.init
        {
            try await db.collection("users").document(uuid!).updateData(["isOnline": false])
            try await db.collection("users").document(uuid!).updateData(["talkingTo": ""])
        }
        print("background")
    }
    
    func applicationWillTerminate(_ application: UIApplication)
    {
        let db = Firestore.firestore()
        let uuid = Auth.auth().currentUser?.uid
        Task.init
        {
            try await db.collection("users").document(uuid!).updateData(["isOnline": false])
            try await db.collection("users").document(uuid!).updateData(["talkingTo": ""])
        }
        print("closing")
    }
    
    func applicationDidBecomeActive(_ application: UIApplication)
    {
        IQKeyboardManager.shared.reloadLayoutIfNeeded()
    }
    
    func applicationWillResignActive(_ application: UIApplication)
    {
        IQKeyboardManager.shared.resignFirstResponder()
    }
    
    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable: Any])
    {
          // If you are receiving a notification message while your app is in the background,
          // this callback will not be fired till the user taps on the notification launching the application.
          // TODO: Handle data of notification
          // With swizzling disabled you must let Messaging know about the message, for Analytics
          // Messaging.messaging().appDidReceiveMessage(userInfo)
          // Print message ID.
        if let messageID = userInfo[gcmMessageIDKey]
        {
            print("Message ID: \(messageID)")
        }
        print("didReceiveRemoteNotification: \(userInfo) ")
    }

    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable: Any],
                         fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void)
    {
          // If you are receiving a notification message while your app is in the background,
          // this callback will not be fired till the user taps on the notification launching the application.
          // TODO: Handle data of notification
          // With swizzling disabled you must let Messaging know about the message, for Analytics
          // Messaging.messaging().appDidReceiveMessage(userInfo)
          // Print message ID.
        if let messageID = userInfo[gcmMessageIDKey]
        {
            print("Message ID: \(messageID)")
        }

          // Print full message.
          print(userInfo)

          completionHandler(UIBackgroundFetchResult.newData)
        }
        // [END receive_message]
    func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error)
    {
        print("Unable to register for remote notifications: \(error.localizedDescription)")
    }

        // This function is added here only for debugging purposes, and can be removed if swizzling is enabled.
        // If swizzling is disabled then this function must be implemented so that the APNs token can be paired to
        // the FCM registration token.
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data)
    {
        print("APNs token retrieved: \(deviceToken)")

        // With swizzling disabled you must set the APNs token here.
        Messaging.messaging().apnsToken = deviceToken
    }
}


extension AppDelegate: UNUserNotificationCenterDelegate
{
  // Receive displayed notifications for iOS 10 devices.
  func userNotificationCenter(_ center: UNUserNotificationCenter,
                              willPresent notification: UNNotification) async
    -> UNNotificationPresentationOptions {
    let userInfo = notification.request.content.userInfo

    // With swizzling disabled you must let Messaging know about the message, for Analytics
    // Messaging.messaging().appDidReceiveMessage(userInfo)

    // ...

    // Print full message.
    print(userInfo)

    // Change this to your preferred presentation option
    return [[.alert, .sound]]
  }

  func userNotificationCenter(_ center: UNUserNotificationCenter,
                              didReceive response: UNNotificationResponse) async {
    let userInfo = response.notification.request.content.userInfo

    // ...

    // With swizzling disabled you must let Messaging know about the message, for Analytics
    // Messaging.messaging().appDidReceiveMessage(userInfo)

    // Print full message.
    print(userInfo)
  }
}

extension AppDelegate : MessagingDelegate
{
  // [START refresh_token]
    func messaging(_ messaging: Messaging, didReceiveRegistrationToken fcmToken: String?)
    {
        print("Firebase registration token: \(String(describing: fcmToken))")

        let dataDict:[String: String] = ["token": String(describing: fcmToken)]
        NotificationCenter.default.post(name: Notification.Name("FCMToken"), object: nil, userInfo: dataDict)
        // TODO: If necessary send token to application server.
        // Note: This callback is fired at each app startup and whenever a new token is generated.
    }
}

