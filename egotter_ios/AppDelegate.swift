//
//  AppDelegate.swift
//  egotter_ios
//
//  Created by Teruki Shinohara on 2020/02/17.
//  Copyright © 2020 Teruki Shinohara. All rights reserved.
//

import UIKit
import Firebase

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {



    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        FirebaseApp.configure()

        sendDeviceTokenToServer("token") // TODO Remove

        let center = UNUserNotificationCenter.current()
        center.requestAuthorization(options: [.alert, .sound]) { granted, error in
            print("Permission granted: \(granted)")
            guard granted else { return }

            if (granted) {
                DispatchQueue.main.async {
                    UIApplication.shared.registerForRemoteNotifications()
                }
            }
        }

        return true
    }

    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        let tokenParts = deviceToken.map { data -> String in
            return String(format: "%02.2hhx", data)
        }
        let token = tokenParts.joined()
        print("Device Token: \(token)")
        sendDeviceTokenToServer(token)
    }

    func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {
        print("Failed to register for remote notifications: \(error)")
    }

    func sendDeviceTokenToServer(_ token: String) {
        // let url = URL(string: "https://egotter.com/api/v1/users/update_device_token")
        let url = URL(string: "http://192.168.11.2:3000/api/v1/users/update_device_token")

        guard let requestUrl = url else { fatalError() }
        var request = URLRequest(url: requestUrl)

        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")

        let params:[String:Any] = [
            "uid": "12345",
            "access_token": "",
            "access_secret": "",
            "device_token": token
        ]

        do {
            request.httpBody = try JSONSerialization.data(withJSONObject: params)
        } catch {
            print("Failed to serialize data: \(error)")
            return
        }

        let task = URLSession.shared.dataTask(with: request) { (data, response, error) in

            if let error = error {
                print("Failed to send device token: \(error)")
                return
            }

            if let data = data, let dataString = String(data: data, encoding: .utf8) {
                print("Response data string: \(dataString)")

                do {
                    let dic = try JSONSerialization.jsonObject(with: data) as! [String: Any]
                    print("found \(dic["found"] as! Bool)")
                } catch {
                    print("Failed to deserialize response: \(error)")
                    return
                }
            }

        }

        task.resume()
    }

    // MARK: UISceneSession Lifecycle

    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        // Called when a new scene session is being created.
        // Use this method to select a configuration to create the new scene with.
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }

    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
        // Called when the user discards a scene session.
        // If any sessions were discarded while the application was not running, this will be called shortly after application:didFinishLaunchingWithOptions.
        // Use this method to release any resources that were specific to the discarded scenes, as they will not return.
    }


}

