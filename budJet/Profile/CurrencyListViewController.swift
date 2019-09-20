//
//  CurrencyListViewController.swift
//  budJet
//
//  Created by neko on 08.10.17.
//  Copyright © 2017 Daniil Alferov. All rights reserved.
//

import UIKit

class CurrencyListViewController: UIViewController {
    
    var currencies:[Currency] = Currency().loadEveryCountryWithCurrency()
    var selectedCurrency: Currency?
    
    @IBAction func backAction(_ sender: Any?) {
        navigationController?.popViewController(animated: true)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        for currency in currencies {
            if currency.currencyCode == AppData.currencyCode {
                selectedCurrency = currency
                break
            }
        }
        currencies = currencies.filter { $0.countryCode != selectedCurrency?.countryCode }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}

extension CurrencyListViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        selectedCurrency = currencies[indexPath.row]
        AppData.currencyCode = (selectedCurrency?.currencyCode)!
        AppData.currencySymbol = (selectedCurrency?.currencySymbol)!
        backAction(nil)
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        if section == 1 {
            return CGFloat.leastNormalMagnitude
        } else {
            return 20.0
        }
    }
}

extension CurrencyListViewController: UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return 1
        }
        return currencies.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "CurrencyCellIdentifier", for: indexPath) as! CurrencyTableViewCell
        if indexPath.section == 0 {
            cell.currencyLabel.text = selectedCurrency!.currencyCode
            cell.countryLabel.text = selectedCurrency!.countryName
        } else {
            cell.currencyLabel.text = currencies[indexPath.row].currencyCode
            cell.countryLabel.text = currencies[indexPath.row].countryName
        }
        
        return cell
    }
}
