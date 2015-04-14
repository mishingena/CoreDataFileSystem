//
//  FileCell.swift
//  HW_CoreDataFileSystem
//
//  Created by Gena on 14.04.15.
//  Copyright (c) 2015 Gena. All rights reserved.
//

import UIKit

class FileCell: UITableViewCell {

    @IBOutlet weak var imgView: UIImageView!
    @IBOutlet weak var title: UILabel!
    @IBOutlet weak var detail: UILabel!

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }

}
