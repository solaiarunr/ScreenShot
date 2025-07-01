//
//  AppDelegate.swift
//  Screenshot
//
//  Created by HTS-PRO-2018 on 27/02/25.
//

import UIKit
import Firebase
import FirebaseAuth
@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    var window: UIWindow?
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        self.setInitalVc(Mainvc: ButtonActionViewController())
        if let window = window {
        makeSecure(window: window)
        }
        FirebaseApp.configure()
        return true
    }
    
    func setInitalVc(Mainvc:UIViewController){
           let navigationController = UINavigationController(rootViewController: Mainvc)
           self.window = UIWindow(frame: UIScreen.main.bounds)
           self.window?.rootViewController = navigationController
           self.window?.makeKeyAndVisible()
    }
    
    func makeSecure(window: UIWindow) {
        let field = UITextField()
        let view = UIView(frame: CGRect(x: 0, y: 0, width: field.frame.self.width, height: field.frame.self.height))
        let image = UIImageView(image: UIImage(named: "Whiteimage"))
        image.frame = CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height)
        field.isSecureTextEntry = true
        window.addSubview(field)
        view.addSubview(image)
        window.layer.superlayer?.addSublayer(field.layer)
        field.layer.sublayers?.last!.addSublayer(window.layer)
        field.leftView = view
        field.leftViewMode = .always
    }

    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        Auth.auth().setAPNSToken(deviceToken, type: .unknown)
    }

    func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {
        print("Failed to register for notifications: \(error.localizedDescription)")
    }


}

