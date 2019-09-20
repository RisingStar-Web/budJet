//
//  TodayViewController.swift
//  budjetwidget
//
//  Created by Daniil Alferov on 09/07/2018.
//  Copyright © 2018 Daniil Alferov. All rights reserved.
//

import UIKit
import NotificationCenter
import DateToolsSwift

class TodayViewController: UIViewController, NCWidgetProviding {
        
    @IBOutlet weak var todayLabel: UILabel!
    @IBOutlet weak var thisMonthLabel: UILabel!
    @IBOutlet weak var thisMonthIncomLabel: UILabel!
    @IBOutlet weak var todayExpenseLabel: UILabel!
    @IBOutlet weak var todayIncomeLabel: UILabel!
    @IBOutlet weak var thisMonthExpenseLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        todayLabel.text = NSLocalizedString("Today", comment: "")
        thisMonthLabel.text = Date().monthTitle.capitalizingFirstLetter()
        configureData()
    }

    func configureData() {
        let today = Date()
        var startDate = Date()
        startDate.hour(0)
        startDate.minute(0)
        startDate.second(0)
        
        let todayIncome = CoreDataHelper.getTotalAmount(true, startDate: startDate, endDate: today)
        let todayExpense = CoreDataHelper.getTotalAmount(false, startDate: startDate, endDate: today)
        
        let monthIncome = CoreDataHelper.getTotalAmount(true, startDate: today.firstDayOfMonth, endDate: today)
        let monthExpense = CoreDataHelper.getTotalAmount(false, startDate: today.firstDayOfMonth, endDate: today)
        thisMonthIncomLabel.text = monthIncome == 0.0 ? "--" : String(format: "%.2f", monthIncome)
        thisMonthExpenseLabel.text = monthExpense == 0.0 ? "--" : String(format: "%.2f", monthExpense)
        
        todayIncomeLabel.text = todayIncome == 0.0 ? "--" : String(format: "%.2f", todayIncome)
        todayExpenseLabel.text = todayExpense == 0.0 ? "--" : String(format: "%.2f", todayExpense)
    }
    
    func widgetPerformUpdate(completionHandler: (@escaping (NCUpdateResult) -> Void)) {

        configureData()
        completionHandler(NCUpdateResult.newData)
    }
}

extension String {
    func capitalizingFirstLetter() -> String {
        return prefix(1).uppercased() + dropFirst()
    }
    
    mutating func capitalizeFirstLetter() {
        self = self.capitalizingFirstLetter()
    }
}
