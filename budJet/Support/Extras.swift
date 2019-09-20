//
//  Extras.swift
//  budJet
//
//  Created by neko on 09.10.17.
//  Copyright © 2017 Daniil Alferov. All rights reserved.
//

import UIKit
import KeychainAccess

class Extras: NSObject {
    
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
    
    class func showInfoAlert(title: String?, message: String, buttonTitle: String, inController: AnyObject) {
        let actionSheetController: UIAlertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        
        let cancelActionButton = UIAlertAction(title: buttonTitle, style: .cancel) { _ in
            print("Cancel")
        }
        actionSheetController.addAction(cancelActionButton)
        
        inController.present(actionSheetController, animated: true, completion: nil)
    }
}

extension UIColor {
    convenience init(colorWithHexValue value: Int, alpha: CGFloat = 1.0) {
        self.init(
            red: CGFloat((value & 0xFF0000) >> 16)/255.0,
            green: CGFloat((value & 0x00FF00) >> 8)/255.0,
            blue: CGFloat(value & 0x0000FF)/255.0,
            alpha: alpha
        )
    }
}

public extension Int {
    /// SwiftRandom extension
    public static func random(_ range: Range<Int>) -> Int {
        #if swift(>=3)
        return random(range.lowerBound, range.upperBound - 1)
        #else
        return random(range.upperBound, range.lowerBound)
        #endif
    }
    
    /// SwiftRandom extension
    public static func random(_ range: ClosedRange<Int>) -> Int {
        return random(range.lowerBound, range.upperBound)
    }
    
    /// SwiftRandom extension
    public static func random(_ lower: Int = 0, _ upper: Int = 100) -> Int {
        return lower + Int(arc4random_uniform(UInt32(upper - lower + 1)))
    }
}

extension Int32 {
    func random() -> Int32 {
        return Int32(arc4random_uniform(UInt32(Int32.max))) + 1
    }
}

public extension Float {
    /// SwiftRandom extension
    public static func random(_ lower: Float = 0, _ upper: Float = 100) -> Float {
        return (Float(arc4random()) / 0xFFFFFFFF) * (upper - lower) + lower
    }
}

extension Date {
    
    public static func randomWithinDaysBeforeToday(_ days: Int) -> Date {
        let today = Date()
        let earliest = today.addingTimeInterval(TimeInterval(-days*24*60*60))
        
        return Date.random(between: earliest, and: today)
    }
    
    /// SwiftRandom extension
    public static func random() -> Date {
        let randomTime = TimeInterval(arc4random_uniform(UInt32.max))
        return Date(timeIntervalSince1970: randomTime)
    }
    
    public static func random(between initial: Date, and final:Date) -> Date {
        let interval = final.timeIntervalSince(initial)
        let randomInterval = TimeInterval(arc4random_uniform(UInt32(interval)))
        return initial.addingTimeInterval(randomInterval)
    }
    
    public static func generateDateRange(from startDate: Date, to endDate: Date) -> [Date] {
        if startDate > endDate { return [] }
        var returnDates: [Date] = []
        var currentDate = startDate
        repeat {
            returnDates.append(currentDate)
            let calendar = Calendar.current
            currentDate = calendar.startOfDay(for: calendar.date(
                byAdding: .day, value: 1, to: currentDate)!)
        } while currentDate <= endDate
        return returnDates
    }
    
    func daySectionIdentifier() -> String? {
        let currentCalendar = Calendar.current
        var sectionIdentifier = ""
        let day = currentCalendar.component(.day, from: self)
        let month = currentCalendar.component(.month, from: self)
        let year = currentCalendar.component(.year, from: self)
        
        sectionIdentifier = "\(year * 10000 + month * 100 + day)"
        
        return sectionIdentifier
    }
}

extension String {
    var latinCharactersOnly: Bool {
        return self.range(of: ".*[^A-Za-z0-9.\\-_].*", options: .regularExpression) == nil
    }
    
    var isValidEmail: Bool {
        
        var returnValue = true
        let emailRegEx = "[A-Z0-9a-z.-_]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,3}"
        
        do {
            let regex = try NSRegularExpression(pattern: emailRegEx)
            let nsString = self as NSString
            let results = regex.matches(in: self, range: NSRange(location: 0, length: nsString.length))
            
            if results.count == 0
            {
                returnValue = false
            }
            
        } catch let error as NSError {
            print("invalid regex: \(error.localizedDescription)")
            returnValue = false
        }
        
        return  returnValue
    }
}

extension Formatter {
    static let withSeparator: NumberFormatter = {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.groupingSeparator = " "
        formatter.decimalSeparator = "."
        formatter.usesGroupingSeparator = true
        formatter.minimumFractionDigits = 2
        formatter.maximumFractionDigits = 2

        return formatter
    }()
    
    static let monthTitle: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "LLLL"
        return formatter
    }()
}

extension Float {
    var formattedWithSeparatorAndCurrency: String {
        let amountString = Formatter.withSeparator.string(for: self) ?? ""
        let currencyCode = Extras.currencyCode
        return amountString + " " + currencyCode
    }

    var formattedWithSeparator: String {
        let amountString = Formatter.withSeparator.string(for: self) ?? ""
        return amountString
    }

}

extension Date {
    var monthTitle: String { return Formatter.monthTitle.string(from: self) }
    
    var lastDayOfMonth: Date
    {
        let calendar = Calendar.current
        var components = calendar.dateComponents([.year, .month, .day, .hour, .minute, .second], from: self)
        let range = calendar.range(of: .day, in: .month, for: self)!
        components.day = range.upperBound - 1
        return calendar.date(from: components)!
    }
    
    var firstDayOfMonth: Date
    {
        let calendar = Calendar.current
        var components = calendar.dateComponents([.year, .month, .day, .hour, .minute, .second], from: self)
        let range = calendar.range(of: .day, in: .month, for: self)!
        components.day = range.lowerBound
        components.hour = 0
        components.minute = 0
        components.second = 0
        return calendar.date(from: components)!
    }
}
