//
//  ContentView.swift
//  egotter_ios
//
//  Created by Teruki Shinohara on 2020/02/17.
//  Copyright © 2020 Teruki Shinohara. All rights reserved.
//

import SwiftUI
import FirebaseAuth

struct ContentView: View {
    @State var text = NSLocalizedString("signInWithTwitter", comment: "")

    var body: some View {
        VStack {
            Image("egotter500x500")
                .resizable()
                .scaledToFit()
                .padding(.top)
                .padding(.bottom)
            Button(action: {
                signInWithTwitter()
            }) {
                Text(text)
            }
            Spacer()
            Button(action: {
                let url = URL(string: "https://egotter.com/terms_of_service?via=ios_dev")!
                UIApplication.shared.open(url)
            }) {
                Text("termsOfService")
                    .foregroundColor(Color.gray)
                    .padding(.bottom)
            }
            Button(action: {
                let url = URL(string: "https://egotter.com/privacy_policy?via=ios_dev")!
                UIApplication.shared.open(url)
            }) {
                Text("privacyPolicy")
                    .foregroundColor(Color.gray)
                    .padding(.bottom)
            }
        }
    }
}

let provider = OAuthProvider(providerID: "twitter.com")

func signInWithTwitter () {
    provider.customParameters = ["lang": "ja"]
    provider.getCredentialWith(nil) { credential, error in
        if let error = error {
            print("Failed to get credential: \(error)")
            return
        }

        if let credential = credential {
            Auth.auth().signIn(with: credential) { authResult, error in
                if let error = error {
                    print("Failed to sign in: \(error)")
                    return
                }

                if let authResult = authResult {
                    let user = User(authResult)
                    saveCredentials(user.uid, user.screenName, user.token, user.secret)
                }
            }
        }
    }
}

func isUserSignedIn () -> Bool {
    Auth.auth().currentUser != nil
}

func saveCredentials (_ uid: String, _ screenName: String, _ token: String, _ secret: String) {
    UserDefaults.standard.set(uid, forKey: "twitter_id")
    UserDefaults.standard.set(screenName, forKey: "twitter_screen_name")
    UserDefaults.standard.set(token, forKey: "twitter_access_token")
    UserDefaults.standard.set(secret, forKey: "twitter_access_secret")

    if isUserSignedIn() {
        sendDeviceTokenToServer()
    }
}

func sendDeviceTokenToServer() {
    let deviceToken = UserDefaults.standard.string(forKey: "apn_device_token")
    if (deviceToken == nil || deviceToken == "") {
        print("sendDeviceTokenToServer() device token not persisted")
        return
    }

    let twitterUid = UserDefaults.standard.string(forKey: "twitter_id")
    let accessToken = UserDefaults.standard.string(forKey: "twitter_access_token")
    let accessSecret = UserDefaults.standard.string(forKey: "twitter_access_secret")
    if (twitterUid == nil || twitterUid == "" || accessToken == nil || accessToken == "" || accessSecret == nil || accessSecret == "") {
        print("sendDeviceTokenToServer() twitter credentials not persisted")
        return
    }

    ApiClient.sendDeviceTokenToServer(twitterUid!, deviceToken!, accessToken!, accessSecret!)
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
           ContentView()
              .previewDevice(PreviewDevice(rawValue: "iPhone SE"))
              .previewDisplayName("iPhone SE")

           ContentView()
              .previewDevice(PreviewDevice(rawValue: "iPhone 11"))
              .previewDisplayName("iPhone 11")
        }
    }
}
