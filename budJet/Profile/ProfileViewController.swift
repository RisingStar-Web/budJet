//
//  ProfileViewController.swift
//  budJet
//
//  Created by neko on 07.10.17.
//  Copyright © 2017 Daniil Alferov. All rights reserved.
//

import UIKit
import SkyFloatingLabelTextField

class ProfileViewController: UIViewController {

    @IBOutlet weak var pinSwitch: UISwitch!
    @IBOutlet weak var pinCodeLabel: UILabel!
    
    @IBOutlet weak var currencyCodeLabel: UILabel!
    @IBOutlet weak var currencyTitleLabel: UILabel!
    @IBOutlet weak var currencySubtitleLabel: UILabel!
    
    @IBOutlet weak var headerLabel: UILabel!
    
    @IBAction func backAction(_ sender: Any?) {
        dismiss(animated: true, completion: nil)
    }

    @IBAction func pinSwitchAction(_ sender: UISwitch) {
    /*
        if sender.isOn {
            showPinCodeView()
        } else {
            AppData.clearPinCode()
        }
    */
    }
    /*
    func showPinCodeView() {
        let pinCodeViewController = storyboard?.instantiateViewController(withIdentifier: "PinCodeView") as! PinCodeViewController
        pinCodeViewController.pinState = .addPin
        pinCodeViewController.modalPresentationStyle = .overCurrentContext
        present(pinCodeViewController, animated: true, completion: nil)
    }
*/
    override func viewWillAppear(_ animated: Bool) {
        super .viewWillAppear(animated)
        currencyCodeLabel.text = AppData.currencyCode
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //pinSwitch.isOn = AppData.isPinCodeOn()
        currencyTitleLabel.text = NSLocalizedString("Currency", comment: "")
        currencySubtitleLabel.text = NSLocalizedString("Select your currency", comment: "")
        pinCodeLabel.text = NSLocalizedString("Pin-code", comment: "")
        headerLabel.text = NSLocalizedString("Settings", comment: "")
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}
