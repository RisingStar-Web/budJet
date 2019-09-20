//
//  AmountTextField.swift
//  budJet
//
//  Created by neko on 03.10.17.
//  Copyright © 2017 Daniil Alferov. All rights reserved.
//

import UIKit

class AmountTextField: UITextField, UITextFieldDelegate, AmountKeyboardViewControllerDelegate {
    
    func didAddIntegerNumber(_ number: String) {
        //print(number)
        //text = number + ".00"
    }
    
    func didAddDecimalNumber(_ number: String, position: Int) {
        //if position == 0 { text = number + "0" }
    }

    func didTapNumber(_ number: String) {
       // print(number + " tapped")
    }
    
    func didTapOperation(_ operation: Operation) {
        //print(operation)
//        text = "500.50"
//        text = ""
    }
    
    func didTapDot() {
        //print("dot tapped")
    }
    
    var amountInputViewController: AmountKeyboardViewController?

    override func canPerformAction(_ action: Selector, withSender sender: Any?) -> Bool {
        return false
    }
    
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)!
        delegate = self
        configure()
    }
    
    required override init(frame: CGRect) {
        super.init(frame: frame)
        delegate = self
        configure()
        self.becomeFirstResponder()
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        //print(textField.text!)
        return true
    }
    func configure() {
        amountInputViewController = AmountKeyboardViewController()
        amountInputViewController?.delegate = self
    }
  
    override var inputViewController: UIInputViewController? {
        return amountInputViewController
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        //print("lost focus")
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        //print("focused")
    }
    
}
