//
//  TextFileViewController.swift
//  HW_CoreDataFileSystem
//
//  Created by Gena on 12.04.15.
//  Copyright (c) 2015 Gena. All rights reserved.
//

import UIKit

class TextFileViewController: UIViewController {
    
    var file: FileText?

    @IBOutlet weak var textViewBottomConstraint: NSLayoutConstraint!
    @IBOutlet weak var textView: UITextView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.textView.text = self.file?.text
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "keyboardWillShow:", name: UIKeyboardWillShowNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "keyboardWillHide:", name: UIKeyboardWillHideNotification, object: nil)
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        self.file?.text = self.textView.text
        CoreDataManager.sharedInstance.save()
        
        NSNotificationCenter.defaultCenter().removeObserver(self, name: UIKeyboardWillShowNotification, object: nil)
        NSNotificationCenter.defaultCenter().removeObserver(self, name: UIKeyboardWillHideNotification, object: nil)
    }
    
    func keyboardWillShow(notification: NSNotification) {
        let userInfo: NSDictionary = notification.userInfo!
        let keyboardSize = (userInfo[UIKeyboardFrameEndUserInfoKey] as! NSValue).CGRectValue()
        let keyboardHeight: CGFloat = keyboardSize.height
        let animateDuration = userInfo[UIKeyboardAnimationDurationUserInfoKey]!.doubleValue
        self.textViewBottomConstraint.constant = keyboardHeight
        
        UIView.animateWithDuration(animateDuration, animations: { () -> Void in
            self.view.layoutIfNeeded()
        })
    }
    
    func keyboardWillHide(notification: NSNotification) {
        let userInfo: NSDictionary = notification.userInfo!
        let animateDuration = userInfo[UIKeyboardAnimationDurationUserInfoKey]!.doubleValue
        self.textViewBottomConstraint.constant = 0
        
        UIView.animateWithDuration(animateDuration, animations: { () -> Void in
            self.view.layoutIfNeeded()
        })
    }

}
