//
//  AmountKeyboardViewController.swift
//  budJet
//
//  Created by neko on 02.10.17.
//  Copyright © 2017 Daniil Alferov. All rights reserved.
//

import UIKit
import SnapKit

enum Operation {
    case Addition
    case Multiplication
    case Subtraction
    case Division
    case None
}

protocol AmountKeyboardViewControllerDelegate: class {
    func didTapNumber(_ number: String)
    func didAddIntegerNumber(_ number: String)
    func didAddDecimalNumber(_ number: String, position: Int)
    func didTapOperation(_ operation: Operation)
    func didTapDot()
}

class AmountKeyboardViewController: UIInputViewController {

    weak var delegate: AmountKeyboardViewControllerDelegate?
    
    var keyboardView: AmountKeyboardView?
    
    var amountString = "0.0"
    
    var nextOperation = Operation.None
    
    @objc func didTapNumber(_ sender: UIButton) {
        
        let number = sender.titleLabel?.text
        
        if let string = textDocumentProxy.documentContextBeforeInput, let _ = string.index(of: ".") {
            let parts : [String?] = amountString.components(separatedBy: ".")
            
            if parts.count == 1 {
                amountString = parts[0]! + "." + number!
                textDocumentProxy.insertText(number!)
                delegate?.didAddDecimalNumber(amountString, position: 0)
            } else {
                let decimal = parts[1]!
                if decimal.count < 2 {
                    amountString = String(Double(amountString)! + Double(number!)!)
                    
                    let newDecimal = decimal + number!
                    amountString = parts[0]! + "." + newDecimal
                    textDocumentProxy.insertText(number!)
                    delegate?.didAddDecimalNumber(amountString, position: 1)
                }
            }
        } else {
            if amountString.count < 7 {
                let amountInt = Int(amountString)
                amountString = ((amountInt == 0 ? "" : String(amountInt ?? 0)) + number!) + ".0"
                textDocumentProxy.insertText(number!)
                delegate?.didAddIntegerNumber(amountString)
            }
        }
        delegate?.didTapNumber(number!)
    }
    
    @objc func didTapDot(_ sender: UIButton) {
        let proxy = textDocumentProxy as UITextDocumentProxy
        
        if let input = proxy.documentContextBeforeInput {
            if !input.contains(".") {
                proxy.insertText(".")
            }
        }
        delegate?.didTapDot()
    }
    
    @objc func didTapBackspace(_ sender: UIButton) {
        if let string = textDocumentProxy.documentContextBeforeInput {
            if let dotIndex = string.index(of: ".") {
                let oneToEndIndex = string.index(string.endIndex, offsetBy: -2)
                if dotIndex == oneToEndIndex {
                    textDocumentProxy.deleteBackward()
                    var truncated = string
                    truncated.remove(at: truncated.index(before: truncated.endIndex))
                    amountString = truncated
                }
            }
            textDocumentProxy.deleteBackward()
            var truncated = string
            truncated.remove(at: truncated.index(before: truncated.endIndex))
            amountString = truncated
        }
    }
    
    @objc func didTapOperation(_ sender: UIButton) {

        if let op = sender.titleLabel?.text {
            switch op {
            case "+":
                nextOperation = Operation.Addition
            case "-":
                nextOperation = Operation.Subtraction
            case "*":
                nextOperation = Operation.Multiplication
            case "/":
                nextOperation = Operation.Division
            default:
                nextOperation = Operation.None
            }
        }
        delegate?.didTapOperation(nextOperation)
    }

    // MARK: initializers
    init() {
        super.init(nibName: nil, bundle: nil)
        configure()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        configure()
    }
    
    func configure() {
        let screenSize: CGRect = UIScreen.main.bounds
        
        inputView?.frame = CGRect(x: 0.0, y: 0.0, width: screenSize.width, height: 216.0)
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        keyboardView = UINib(nibName: "NumericKeyboardView", bundle: nil).instantiate(withOwner: nil, options: nil)[0] as? AmountKeyboardView
        
        view.addSubview(keyboardView!)
        keyboardView?.snp.updateConstraints { make in
            make.top.equalTo(view)
            make.leading.equalTo(view)
            make.trailing.equalTo(view)
            make.bottom.equalTo(view)
        }
        configureButtonActions()
    }

    override func updateViewConstraints() {
        super.updateViewConstraints()

    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()

    }
    
    func configureButtonActions() {
        keyboardView?.dotKey.addTarget(self, action: #selector(didTapDot(_:)), for: .touchUpInside)

        keyboardView?.backspaceKey.addTarget(self, action: #selector(didTapBackspace(_:)), for: .touchUpInside)

        //        for operationButton in (keyboardView?.operationKeys)! {
//            operationButton.addTarget(self, action: #selector(didTapOperation(_:)), for: .touchUpInside)
//        }
        for numberButton in (keyboardView?.numberKeys)! {
            numberButton.addTarget(self, action: #selector(didTapNumber(_:)), for: .touchUpInside)
        }
    }
    
    override func textWillChange(_ textInput: UITextInput?) {

    }
    
    override func textDidChange(_ textInput: UITextInput?) {

    }

}

class AmountKeyboardView: UIView {
    @IBOutlet weak var dotKey: UIButton!
    @IBOutlet weak var backspaceKey: UIButton!
    @IBOutlet var operationKeys: [UIButton]!
    @IBOutlet var numberKeys: [UIButton]!

    
}
