//
//  AppDelegate.swift
//  Instagraph
//
//  Created by 魏文洲 on 8/9/2018.
//  Copyright © 2018 Wenzhou Wei. All rights reserved.
//

import UIKit
import Firebase
import PhotoEditorSDK
import MultiPeer

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, MultiPeerDelegate {

    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
      
        FirebaseApp.configure()
        MultiPeer.instance.initialize(serviceType: "instagraph-app")
        MultiPeer.instance.autoConnect()
        MultiPeer.instance.delegate = self
        
        UINavigationBar.appearance().barTintColor = UIColor.white
        UINavigationBar.appearance().tintColor = ColorObject.sharedInstance.purpleMainColor
        UINavigationBar.appearance().titleTextAttributes = [NSAttributedStringKey.foregroundColor :ColorObject.sharedInstance.purpleMainColor]
        UITabBar.appearance().tintColor = ColorObject.sharedInstance.purpleMainColor
        
        self.window = UIWindow(frame: UIScreen.main.bounds)
        self.window!.backgroundColor = UIColor.white
        let mainStoryboard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
        
        // Check if we have logged out
        if Auth.auth().currentUser == nil {
            // Fix previous bug
            UserManager.share.removeUser()
        }
        
        let userLogin = UserManager.share.cachedUser()
        
        if  userLogin != nil {
            // Check preload data before entering the main view
            UserRelationManager.share.initializeFollowingsData { (error) in
                let mainStoryboard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
                let viewController = mainStoryboard.instantiateViewController(withIdentifier: "MainMenuViewController") as! MainMenuViewController
                self.window!.rootViewController  = viewController
                self.window!.makeKeyAndVisible()
            }
        }
        else {
            let viewController = mainStoryboard.instantiateViewController(withIdentifier: "LoginViewController") as! LoginViewController
            let navigationController = UINavigationController(rootViewController: viewController)
            self.window!.rootViewController  = navigationController
            self.window!.makeKeyAndVisible()
        }
        return true
    }
    
    func application(_ application: UIApplication, willFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey : Any]? = nil) -> Bool {
        if let licenseURL = Bundle.main.url(forResource: "ios_license", withExtension: "dms") {
            PESDK.unlockWithLicense(at: licenseURL)
        }
        
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
    
    func multiPeer(didReceiveData data: Data, ofType type: UInt32) {
        let imgData = data.convert() as? Data
        if  imgData != nil {
            let imageUIImage = UIImage(data: imgData!)
            let mainStoryboard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
            let viewController = mainStoryboard.instantiateViewController(withIdentifier: "PopupImageViewController") as! PopupImageViewController
            if let img = imageUIImage {
                viewController.setImage(image:img)
                let vc = self.window?.rootViewController
                vc?.present(viewController, animated: false, completion: nil)
            }
        }
    }
    
    func multiPeer(connectedDevicesChanged devices: [String]) {
        print(devices)
    }


}

