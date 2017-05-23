//
//  Created by Kordian Ledzion on 17.05.2017.
//  Copyright © 2017 Droids on Roids. All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        
        let cameraViewController = storyboard.instantiateViewController(withIdentifier: "middle")
        let storyViewController = storyboard.instantiateViewController(withIdentifier: "right")
        let contactsViewController = storyboard.instantiateViewController(withIdentifier: "left")
        let settingsViewController = storyboard.instantiateViewController(withIdentifier: "top")
        
        let snapContainerViewController = SnapContainerViewController.containerViewWith(contactsViewController, middleViewController: cameraViewController, rightViewController: storyViewController, topViewController: settingsViewController)
        
        window = UIWindow(frame: UIScreen.main.bounds)
        window?.rootViewController = snapContainerViewController
        window?.makeKeyAndVisible()
        
        return true
    }
}

