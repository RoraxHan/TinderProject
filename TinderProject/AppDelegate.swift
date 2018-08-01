//
//  AppDelegate.swift
//  TinderProject
//
//  Created by hkg328 on 7/7/18.
//  Copyright © 2018 HC. All rights reserved.
//

import UIKit
import IQKeyboardManagerSwift
import DropDown
import Firebase
import GoogleSignIn
import FBSDKCoreKit
import UserNotifications
import Toaster

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, GIDSignInDelegate, UNUserNotificationCenterDelegate, MessagingDelegate {

    var window: UIWindow?


    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        IQKeyboardManager.sharedManager().enable = true
        DropDown.startListeningToKeyboard()
        
        FirebaseApp.configure()
        
        // google
        GIDSignIn.sharedInstance().clientID = FirebaseApp.app()?.options.clientID
        GIDSignIn.sharedInstance().delegate = self
        
        // facebook
        
        FBSDKApplicationDelegate.sharedInstance().application(application, didFinishLaunchingWithOptions: launchOptions)
        
        return true
    }

    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }
    
    
    @available(iOS 9.0, *)
    func application(_ application: UIApplication, open url: URL, options: [UIApplicationOpenURLOptionsKey : Any])
        -> Bool {
            let handled = FBSDKApplicationDelegate.sharedInstance().application(application, open: url, sourceApplication: options[UIApplicationOpenURLOptionsKey.sourceApplication] as! String, annotation: options[UIApplicationOpenURLOptionsKey.annotation])
            
            GIDSignIn.sharedInstance().handle(url,
                                                 sourceApplication:options[UIApplicationOpenURLOptionsKey.sourceApplication] as? String,
                                                 annotation: [:])
            return handled
    }
    func application(_ application: UIApplication, open url: URL, sourceApplication: String?, annotation: Any) -> Bool {
        
        return GIDSignIn.sharedInstance().handle(url,
                                                 sourceApplication: sourceApplication,
                                                 annotation: annotation)
    }
    
    // google sign in
    
    func sign(_ signIn: GIDSignIn!, didSignInFor user: GIDGoogleUser!, withError error: Error!) {
        if let err = error {
            print("failed to log in using google account", err)
            return
        }
        
        guard let idToken = user.authentication.idToken else { return }
        guard let accessToken = user.authentication.accessToken else { return }
        
        let credentials = GoogleAuthProvider.credential(withIDToken: idToken, accessToken: accessToken)
        AppStatusNoty.showLoading(show: true);
        Auth.auth().signIn(with: credentials, completion: { (user, error) in
            if let err = error {
                AppStatusNoty.showLoading(show: false);
                Toast(text: NSLocalizedString("Failed to sign with google account", comment: "")).show();
                print("faild to login ", err)
                return
            }
            guard let uid = user?.uid else { return }

            User.currentUser.id = uid
            User.currentUser.email = user?.email
            User.currentUser.firstName = SignupData.firstName
            User.currentUser.lastName = SignupData.lastName
            
            let ref = DBProvider.shared.userRef
            let values = [
                "id": uid,
                "email": User.currentUser.email,
                "firstName": user?.displayName,
                "lastName": "",
                "photoUri": user?.photoURL
                ] as [String : Any]
            
            
            API.getCurrentUser(key: uid, completion: { (user) in
                AppStatusNoty.showLoading(show: false)
                if user == nil  {
                    if SignupData.firstName != "" {
                        DBProvider.shared.userRef.child(uid).setValue(values, withCompletionBlock: { (error, ref) in
                        })
                        CommonAction.gotoMainPage()
                    } else {
                        Toast(text: NSLocalizedString("Please signup first", comment: "")).show()
                        CommonAction.signout(isGotoFirstPage: false)
                    }
                    return;
                }
                User.currentUser = user!;
                CommonAction.gotoMainPage()
            })
            
            print("succesufully logged into firebase using google account ", uid)
        })
    }
    
    func sign(_ signIn: GIDSignIn!, didDisconnectWith user: GIDGoogleUser!, withError error: Error!) {
        // Perform some operation when the user disconnects from app
    }
    
    // facebook sign in
  


}

