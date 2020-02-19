//
//  ApiClient.swift
//  egotter_ios
//
//  Created by Teruki Shinohara on 2020/02/20.
//  Copyright © 2020 Teruki Shinohara. All rights reserved.
//

import Foundation

struct ApiClient {
    static func sendDeviceTokenToServer(_ twitterUid: String, _ deviceToken: String, _ accessToken: String, _ accessSecret: String) {
        // let url = URL(string: "https://egotter.com/api/v1/users/update_device_token")
        let url = URL(string: "http://192.168.11.14:3000/api/v1/users/update_device_token")

        guard let requestUrl = url else { fatalError() }
        var request = URLRequest(url: requestUrl)

        request.timeoutInterval = 10
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")

        let params: [String:Any] = [
            "uid": twitterUid,
            "access_token": accessToken,
            "access_secret": accessSecret,
            "device_token": deviceToken
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
}
