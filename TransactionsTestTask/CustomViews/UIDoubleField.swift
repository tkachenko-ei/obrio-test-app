//
//  UIDoubleField.swift
//  TransactionsTestTask
//
//

import UIKit

class UIDoubleField: UIPaddedTextField {
    var value: Double? {
        guard let text else { return nil }
        return Double(text)
    }
    
    override var keyboardType: UIKeyboardType {
        didSet {
            super.keyboardType = .decimalPad
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        configure()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        
        configure()
    }
    
    private func configure() {
        keyboardType = .decimalPad
        delegate = self
    }
}

extension UIDoubleField: UITextFieldDelegate {
    func textField(
        _ textField: UITextField,
        shouldChangeCharactersIn range: NSRange,
        replacementString string: String
    ) -> Bool {
        switch string {
        case "":
            if textField.text == "0." {
                textField.text?.removeAll()
                return false
            } else {
                return true
            }
            
        case ".":
            if textField.text?.contains(string) == true {
                return false
            } else if textField.text?.isEmpty == true {
                textField.text = "0."
                return false
            } else {
                return true
            }
            
        case "0":
            if textField.text?.isEmpty == true {
                textField.text = "0."
                return false
            } else {
                return true
            }
            
        case "1"..."9":
            return true
            
        default:
            return false
        }
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        textField.text = value?.formatted(.number.precision(.fractionLength(0...)))
    }
}
