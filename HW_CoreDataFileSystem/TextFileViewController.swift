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

    @IBOutlet weak var textView: UITextView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.textView.text = self.file?.text
    }
    
    override func viewWillDisappear(animated: Bool) {
        self.file?.text = self.textView.text
        CoreDataManager.sharedInstance.save()
    }

}
