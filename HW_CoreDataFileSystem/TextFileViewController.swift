//
//  TextFileViewController.swift
//  HW_CoreDataFileSystem
//
//  Created by Gena on 12.04.15.
//  Copyright (c) 2015 Gena. All rights reserved.
//

import UIKit

class TextFileViewController: UIViewController {
    
    var element: Element?

    @IBOutlet weak var textView: UITextView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.textView.text = self.element?.textFile?.text
    }
    
    override func viewWillDisappear(animated: Bool) {
        CoreDataManager.sharedInstance.save()
    }
    
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
