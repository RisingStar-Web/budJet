//
//  PinCodeViewController.swift
//  budJet
//
//  Created by neko on 08.10.17.
//  Copyright © 2017 Daniil Alferov. All rights reserved.
//

import UIKit
import SmileLock
import KeychainAccess

enum PinState: Int {
    case checkPin = 0, addPin, retypePin
}

class PinCodeViewController: UIViewController {

    @IBOutlet weak var passwordStackView: UIStackView!
    @IBOutlet weak var titleLabel: UILabel!
    
    //MARK: Property
    var passwordContainerView: PasswordContainerView!
    let kPasswordDigit = 4
    var pinState: PinState = .checkPin
    var intermediatePin = ""
    
    func configureTitle() {
        switch pinState {
        case .addPin:
            titleLabel.text = "New passcode"
        case .retypePin:
            titleLabel.text = "Retype passcode"
        default:
            titleLabel.text = "Enter passcode"
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //create PasswordContainerView
        passwordContainerView = PasswordContainerView.create(in: passwordStackView, digit: kPasswordDigit)
        passwordContainerView.delegate = self
        passwordContainerView.deleteButtonLocalizedTitle = "Cancel"
        
        //customize password UI
        passwordContainerView.tintColor = UIColor(colorWithHexValue: 0x545454)
        passwordContainerView.highlightedColor = UIColor(colorWithHexValue: 0x646464)
        
        configureTitle()
    }
    
}

extension PinCodeViewController: PasswordInputCompleteProtocol {
    func passwordInputComplete(_ passwordContainerView: PasswordContainerView, input: String) {
        switch pinState {
        case .addPin:
            intermediatePin = input
            passwordContainerView.clearInput()
            pinState = .retypePin
        case .retypePin:
            if validateNewPin(input) {
                validateNewPinSuccess()
            } else {
                validateNewPinFail()
            }
        default:
            if validation(input) {
                validationSuccess()
            } else {
                validationFail()
            }
        }
        configureTitle()
    }
    
    func touchAuthenticationComplete(_ passwordContainerView: PasswordContainerView, success: Bool, error: Error?) {
        if success {
            self.validationSuccess()
        } else {
            passwordContainerView.clearInput()
        }
    }
}

private extension PinCodeViewController {
    func validation(_ input: String) -> Bool {
        let keychainStore : Keychain = Keychain(service: Bundle.main.bundleIdentifier!)
        return input == keychainStore["password"]
    }

    func validateNewPin(_ input: String) -> Bool {
        return input == intermediatePin
    }
    
    func validationSuccess() {
        print("*️⃣ success!")
        dismiss(animated: true, completion: nil)
    }
    
    func validationFail() {
        print("*️⃣ failure!")
        passwordContainerView.wrongPassword()
    }
    
    func validateNewPinSuccess() {
        print("*️⃣ success!")
        let keychainStore : Keychain = Keychain(service: Bundle.main.bundleIdentifier!)
        keychainStore["password"] = intermediatePin
        dismiss(animated: true, completion: nil)
    }
    
    func validateNewPinFail() {
        print("*️⃣ failure!")
        passwordContainerView.wrongPassword()
    }
}
