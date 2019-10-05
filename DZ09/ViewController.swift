//
//  ViewController.swift
//  DZ09
//
//  Created by Georgy Khaydenko on 05/10/2019.
//  Copyright © 2019 Georgy Khaydenko. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    var placeHolderMask = "+7 (000) 000-00-00"
    var enteredText = ""
    let numberAttributes = [NSAttributedString.Key.foregroundColor: UIColor.black ]
    let placeHolderAttributes = [ NSAttributedString.Key.foregroundColor: UIColor.lightGray ]
    
    
    @IBOutlet weak var textField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        setupTextField()
    }

    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        view.endEditing(true)
    }
    
    
    func setupTextField() {
        textField.delegate = self
        textField.autocorrectionType = .no
        textField.keyboardType = .numberPad
    }
    
    
    @IBAction func textFieldChanged(_ sender: UITextField) {
        if enteredText.count == 11 {
            textField.text?.removeLast()
            sender.resignFirstResponder()
        } else {
            let userText = correctText(text: enteredText)
            let attributedText = NSMutableAttributedString(string: userText, attributes: numberAttributes)
            attributedText.append(NSAttributedString(string: calculatePlaceholderTextToFill(userText: userText), attributes: placeHolderAttributes))
            self.textField.attributedText = attributedText
            //move cursor to the end of user entered number
            if let newPosition = textField.position(from: textField.beginningOfDocument, offset: userText.count) {
                // set the new position
                textField.selectedTextRange = textField.textRange(from: newPosition, to: newPosition)
            }
        }
    }

    
    func calculatePlaceholderTextToFill(userText: String) -> String {
        var correctedPlaceholder = placeHolderMask
        if userText.count > 0 {
            for _ in 1...userText.count {
                correctedPlaceholder.removeFirst()
            }
        }
        return correctedPlaceholder
    }
    
    
    func correctText(text: String) -> String {
        var correctedString = ""
        let enteredNumber = text.filter { (char) -> Bool in
            let numbers = "0123456789"
            return numbers.contains(char)
        }
        for (index, char) in enteredNumber.enumerated() {
            switch index {
            case 0:
                correctedString.append("+")
                correctedString.append(char)
            case 1:
                correctedString.append(" (")
                correctedString.append(char)
            case 4:
                correctedString.append(") ")
                correctedString.append(char)
            case 7, 9:
                correctedString.append("-")
                correctedString.append(char)
            default:
                correctedString.append(char)
            }
        }
        return correctedString
    }
}



extension ViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
    }

    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        // get the current text, or use an empty string if that failed
        let currentText = textField.text ?? ""

        // attempt to read the range they are trying to change, or exit if we can't
        guard let stringRange = Range(range, in: currentText) else { return false }
        
        if range.length == 0, range.location < 18 {
            enteredText.append(string)
        } else {
            if range.length == 1, range.location != 0 {
                enteredText.removeLast()
            }
        }
        if enteredText == "" {
            textField.text = ""
        }
        
        // add their new text to the existing text
        let updatedText = currentText.replacingCharacters(in: stringRange, with: string)
        
        return updatedText.count <= 19
    }
}
