//
//  AppData.swift
//  read
//
//  Created by neko on 21.04.17.
//  Copyright © 2017 Daniil Alferov. All rights reserved.
//

import UIKit
import KeychainAccess

class AppData: NSObject {

    static let sharedInstance = AppData()
    
    private override init() {}
/*
    class func isPinCodeOn() -> Bool {
        let keychainStore : Keychain = Keychain(service: Bundle.main.bundleIdentifier!)
        return keychainStore["password"] != nil
    }
    
    class func clearPinCode() {
        let keychainStore : Keychain = Keychain(service: Bundle.main.bundleIdentifier!)
        keychainStore["password"] = nil

    }
  */
    class func isLoggedIn() -> Bool {
        let keychainStore : Keychain = Keychain(service: Bundle.main.bundleIdentifier!)
        return keychainStore["token"] != nil
    }

    class func clearData() {
        let keychainStore = Keychain(service: Bundle.main.bundleIdentifier!)
        keychainStore["token"] = nil
        keychainStore["email"] = nil
        keychainStore["userid"] = nil
        keychainStore["synctime"] = nil
        keychainStore["password"] = nil
        keychainStore["currency"] = nil
        keychainStore["currencySym"] = nil
    }
    
    class func storeSyncTime() {
        syncTime = Int32(Date().timeIntervalSince1970)
    }
    
    class var syncTime : Int32? {
        set(newTime) {
            let keychainStore : Keychain = Keychain(service: Bundle.main.bundleIdentifier!)
            keychainStore["synctime"] = String(newTime!)
        }
        get {
            let keychainStore : Keychain = Keychain(service: Bundle.main.bundleIdentifier!)
            if keychainStore["synctime"] != nil {
                return Int32(keychainStore["synctime"]!)
            }
            return nil
        }
    }
    
    class var token : String {
        set(newToken) {
            let keychainStore : Keychain = Keychain(service: Bundle.main.bundleIdentifier!)
            keychainStore["token"] = newToken
        }
        get {
            let keychainStore : Keychain = Keychain(service: Bundle.main.bundleIdentifier!)
            if keychainStore[string: "token"] != nil {
                return keychainStore[string: "token"]!
            }
            return ""
        }
    }

    class var currencyCode : String {
        set(currency) {
            let keychainStore : Keychain = Keychain(service: Bundle.main.bundleIdentifier!)
            keychainStore["currency"] = currency
        }
        get {
            let keychainStore : Keychain = Keychain(service: Bundle.main.bundleIdentifier!)
            if keychainStore[string: "currency"] != nil {
                return keychainStore[string: "currency"]!
            }
            return Locale.current.currencyCode!
        }
    }

    class var currencySymbol : String {
        set(currency) {
            let keychainStore : Keychain = Keychain(service: Bundle.main.bundleIdentifier!)
            keychainStore["currencySym"] = currency
        }
        get {
            let keychainStore : Keychain = Keychain(service: Bundle.main.bundleIdentifier!)
            if keychainStore[string: "currencySym"] != nil {
                return keychainStore[string: "currencySym"]!
            }
            return Locale.current.currencySymbol!
        }
    }
    
    class var userid : Int {
        set(newUserid) {
            let keychainStore : Keychain = Keychain(service: Bundle.main.bundleIdentifier!)
            keychainStore["user_id"] = String(newUserid)
        }
        get {
            let keychainStore : Keychain = Keychain(service: Bundle.main.bundleIdentifier!)
            if keychainStore[string: "user_id"] != nil {
                return Int(keychainStore[string: "user_id"]!)!
            }
            return 0
        }
    }
    
    class var email : String {
        set(newEmail) {
            let keychainStore : Keychain = Keychain(service: Bundle.main.bundleIdentifier!)
            keychainStore["email"] = newEmail
        }
        get {
            let keychainStore : Keychain = Keychain(service: Bundle.main.bundleIdentifier!)
            if keychainStore[string: "email"] != nil {
                return keychainStore[string: "email"]!
            }
            return ""
        }
    }
}
