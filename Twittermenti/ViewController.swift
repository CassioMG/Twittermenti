//
//  ViewController.swift
//  Twittermenti
//
//  Created by Angela Yu on 17/07/2018.
//  Copyright © 2018 London App Brewery. All rights reserved.
//

import UIKit
import SwifteriOS

class ViewController: UIViewController, UITextFieldDelegate {
    
    // TODO: set your consumerKey and consumerSecret here:
    private let swifter = Swifter(consumerKey: "", consumerSecret: "")
    
    private let kTweetsCount = 100
    private let kTweetsLanguage = "en"
    
    @IBOutlet weak var backgroundView: UIView!
    @IBOutlet weak var textField: UITextField!
    @IBOutlet weak var sentimentLabel: UILabel!
    @IBOutlet weak var bottomConstraint: NSLayoutConstraint!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }

    
    @IBAction func predictPressed(_ sender: Any) {
        fetchTweets()
    }
    
    
    private func fetchTweets () {
        
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
    
    
    // MARK: Text Field delegate methods
    func textFieldDidBeginEditing(_ textField: UITextField) {
        UIView.animate(withDuration: 0.3) {
            self.bottomConstraint.constant = 300.0
            self.view.layoutIfNeeded()
        }
    }
    
}
