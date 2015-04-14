//
//  ImageFileViewController.swift
//  HW_CoreDataFileSystem
//
//  Created by Gena on 12.04.15.
//  Copyright (c) 2015 Gena. All rights reserved.
//

import UIKit

class ImageFileViewController: UIViewController {

    var file: FileImage?
    @IBOutlet var imageView: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.imageView.image = self.file?.image
    }
}
