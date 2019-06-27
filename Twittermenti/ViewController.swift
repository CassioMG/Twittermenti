//
//  ViewController.swift
//  Twittermenti
//
//  Created by Angela Yu on 17/07/2018.
//  Copyright © 2018 London App Brewery. All rights reserved.
//

import UIKit
import SwifteriOS
// TODO: use SVProgressHUD to give user feedback

class ViewController: UIViewController {
    
    // TODO: set your consumerKey and consumerSecret here:
    private let swifter = Swifter(consumerKey: "", consumerSecret: "")
    private let kTweetsCount = 100
    private let kTweetsLanguage = "en"
    
    // Default keyboard animation values (iPhone 8 Plus)
    private var keyboardHeight : CGFloat = 271.0
    private var animationDuration : Double = 0.25
    private var animationCurve : UInt = 7
    private var initialBottomConstraintConstant: CGFloat = 0.0
    
    @IBOutlet weak var backgroundView: UIView!
    @IBOutlet weak var textField: UITextField!
    @IBOutlet weak var sentimentLabel: UILabel!
    @IBOutlet weak var bottomConstraint: NSLayoutConstraint!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(backgroundTapped))
        backgroundView.addGestureRecognizer(tapGesture)
    }

    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        initialBottomConstraintConstant = bottomConstraint.constant
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(keyboardWillShow),
            name: UIResponder.keyboardWillShowNotification,
            object: nil
        )
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(keyboardWillHide),
            name: UIResponder.keyboardWillHideNotification,
            object: nil
        )
    }
    
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        NotificationCenter.default.removeObserver(self)
    }
    
    
    @IBAction func predictPressed(_ sender: Any) {
        fetchTweets()
    }
    
    
    private func fetchTweets () {
        
        if textField.text!.count == 0 {
            return updateUI(with: 0)
        }
        
        swifter.searchTweet(using: textField.text!, lang: kTweetsLanguage, count: kTweetsCount, tweetMode: .extended, success: { (jsonResults, jsonMetada) in
            
            if let classifierInputs = jsonResults.array?.compactMap({ (jsonTweet) -> TwittermentiClassifierInput? in
                    
                    if let full_text = jsonTweet["full_text"].string {
                        return TwittermentiClassifierInput(text: full_text)
                    }
                    return nil
                
            }) {
                self.makePrediction(with: classifierInputs)
            }
            
        }) { (error) in
            print("Error searching for tweets: ", error)
        }
    }
    
    
    private func makePrediction (with classifierInputs: [TwittermentiClassifierInput]) {
        
        let sentimentClassifier = TwittermentiClassifier()
        
        do {
            let classifierOutputs = try sentimentClassifier.predictions(inputs: classifierInputs)
            
            let sentimentLabels = classifierOutputs.map { $0.label }
            
            var sentimentScore = 0
            for label in sentimentLabels {
                switch label {
                case "Pos": sentimentScore += 1
                case "Neg": sentimentScore -= 1
                default: continue
                }
            }
            
            updateUI(with: sentimentScore)
            
        } catch {
            print("Error predicting classifier inputs: ", error)
        }
    }
    
    
    private func updateUI (with sentimentScore: Int) {
        
        print("FINAL SCORE: ", sentimentScore)
        
        switch sentimentScore {
            
        case 20...100 : self.sentimentLabel.text = "😍"
        case 15...19 : self.sentimentLabel.text = "😁"
        case 10...14 : self.sentimentLabel.text = "😀"
        case 4...9 : self.sentimentLabel.text = "🙂"
        case (-9)...(-4) : self.sentimentLabel.text = "😕"
        case (-14)...(-10) : self.sentimentLabel.text = "☹️"
        case (-19)...(-15) : self.sentimentLabel.text = "😡"
        case (-100)...(-20) : self.sentimentLabel.text = "🤮"
        default /* -3...3 */ : self.sentimentLabel.text = "😐"
            
        }
    }
    
    // MARK: - Tap Gesture method
    @objc private func backgroundTapped () {
        textField.endEditing(true)
    }
    
    // MARK: - Keyboard Notifications
    @objc private func keyboardWillShow(_ notification: Notification) {
        
        if let keyboardFrame: NSValue = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue {
            keyboardHeight = keyboardFrame.cgRectValue.height
        }
        
        if let animationDurationNumber: NSNumber = notification.userInfo?[UIResponder.keyboardAnimationDurationUserInfoKey] as? NSNumber {
            animationDuration = animationDurationNumber.doubleValue
        }
        
        if let animationCurveNumber: NSNumber = notification.userInfo?[UIResponder.keyboardAnimationCurveUserInfoKey] as? NSNumber {
            animationCurve = animationCurveNumber.uintValue
        }
        
        UIView.animate(withDuration: animationDuration, delay: 0, options: UIView.AnimationOptions(rawValue: animationCurve), animations: {
            
            self.bottomConstraint.constant = self.keyboardHeight + self.initialBottomConstraintConstant
            self.view.layoutIfNeeded()
            
        }, completion: nil)
    }
    
    @objc private func keyboardWillHide(_ notification: Notification) {
        
        UIView.animate(withDuration: animationDuration, delay: 0, options: UIView.AnimationOptions(rawValue: animationCurve), animations: {
            
            self.bottomConstraint.constant = self.initialBottomConstraintConstant
            self.view.layoutIfNeeded()
            
        }, completion: nil)
        
    }
    
    
}
