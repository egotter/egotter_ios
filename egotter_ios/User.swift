//
//  User.swift
//  egotter_ios
//
//  Created by Teruki Shinohara on 2020/02/20.
//  Copyright © 2020 Teruki Shinohara. All rights reserved.
//

import Foundation
import FirebaseAuth

struct User {
    var uid: String
    var screenName: String
    var token: String
    var secret: String

    init(_ authResult: AuthDataResult) {
        let profile = authResult.additionalUserInfo?.profile
        self.uid = "\(profile?["id"] as! Int)"
        self.screenName = profile?["screen_name"] as! String

        let cred = authResult.credential as! OAuthCredential
        self.token = cred.accessToken!
        self.secret = cred.secret!
    }
}
