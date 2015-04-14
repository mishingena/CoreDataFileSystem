//
//  TableViewController.swift
//  HW_CoreDataFileSystem
//
//  Created by Gena on 09.04.15.
//  Copyright (c) 2015 Gena. All rights reserved.
//

import UIKit

class TableViewController: UITableViewController, UIAlertViewDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    var file: File?
    var selectedImage: UIImage?
    var selectedIndexPath: NSIndexPath?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let addButton = UIBarButtonItem(barButtonSystemItem: .Add, target: self, action: "addButtonPressed:")
        
        self.navigationItem.rightBarButtonItem = addButton
        self.navigationItem.rightBarButtonItem?.enabled = true
        
        if self.file == nil {
            CoreDataManager.sharedInstance.getRootFile({ (rootFile) -> () in
                self.file = rootFile
                self.title = self.file?.name
                self.tableView.reloadData()
            })
        } else {
            self.title = self.file?.name
        }
    }
    
    override func viewDidAppear(animated: Bool) {
        if let indexPath = self.selectedIndexPath {
            println("indexPath.row: \(indexPath.row)")
            self.tableView.beginUpdates()
            let array = NSArray(object: indexPath)
            self.tableView.reloadRowsAtIndexPaths(array as [AnyObject], withRowAnimation: UITableViewRowAnimation.Automatic)
            self.tableView.endUpdates()
        }
        self.tableView.reloadData()
    }
    
    func addButtonPressed(sender: AnyObject) {
        let actionSheet = UIAlertController(title: nil, message: "Добавить", preferredStyle: .ActionSheet)
        
        let createFolderAction = UIAlertAction(title: "Папку", style: .Default) { (alert: UIAlertAction!) -> Void in
            self.showEnterNameAlert(.Folder)
        }
        let createTextFileAction = UIAlertAction(title: "Текстовый файл", style: .Default) { (alert: UIAlertAction!) -> Void in
            self.showEnterNameAlert(.TextFile)
        }
        
        let createImageFileAction = UIAlertAction(title: "Изображение", style: .Default) { (alert: UIAlertAction!) -> Void in
            self.showImagePicker()
//            self.showEnterNameAlert(.ImageFile)
            
        }
        
        let cancelAction = UIAlertAction(title: "Отмена", style: .Cancel) { (alert: UIAlertAction!) -> Void in }
        
        actionSheet.addAction(createFolderAction)
        actionSheet.addAction(createTextFileAction)
        actionSheet.addAction(createImageFileAction)
        actionSheet.addAction(cancelAction)
        self.presentViewController(actionSheet, animated: true, completion: nil)
    }
    
    func showEnterNameAlert(type: FileType) {
        let title: String
        
        switch type {
        case .Folder: title = "Введите название папки"
        case .TextFile: title = "Введите название текстового файла"
        case .ImageFile: title = "Введите название изображения"
        }
        
        let alertController = UIAlertController(title: title, message: "", preferredStyle: .Alert)
        let cancelAction = UIAlertAction(title: "Отмена", style: .Cancel) { (_) -> Void in }
        let addAction = UIAlertAction(title: "Добавить", style: .Default) { (_) -> Void in
            let textFileld = alertController.textFields![0] as! UITextField
            
            switch type {
            case .Folder:
                let newFile = File(name: textFileld.text)
                
                CoreDataManager.sharedInstance.addObjectToFile(self.file!, object: newFile, completed: { () -> () in
                    self.tableView.reloadData()
                })

            case .TextFile:
                let newFile = FileText(name: textFileld.text)
                
                CoreDataManager.sharedInstance.addObjectToFile(self.file!, object: newFile, completed: { () -> () in
                    self.tableView.reloadData()
                })
                
            case .ImageFile:
                let newFile = FileImage(name: textFileld.text, image: self.selectedImage!)
                
                CoreDataManager.sharedInstance.addObjectToFile(self.file!, object: newFile, completed: { () -> () in
                    self.tableView.reloadData()
                })

            }
            
        }
        addAction.enabled = false
        
        alertController.addTextFieldWithConfigurationHandler { (textField) -> Void in
            textField.placeholder = "Нажмите чтобы ввести"
            
            NSNotificationCenter.defaultCenter().addObserverForName(UITextFieldTextDidChangeNotification, object: textField, queue: NSOperationQueue.mainQueue(), usingBlock: { (notification) -> Void in
                addAction.enabled = textField.text != ""
            })
        }
        
        alertController.addAction(cancelAction)
        alertController.addAction(addAction)
        
        self.presentViewController(alertController, animated: true) { () -> Void in }
    }
    
    // MARK: - Image picker
    
    func showImagePicker() {
        let picker = UIImagePickerController()
        picker.sourceType = UIImagePickerControllerSourceType.PhotoLibrary
        picker.delegate = self
        self.presentViewController(picker, animated: true, completion: nil)
    }
    
    func imagePickerController(picker: UIImagePickerController, didFinishPickingImage image: UIImage!, editingInfo: [NSObject : AnyObject]!) {
        self.selectedImage = image
        self.dismissViewControllerAnimated(true, completion: nil)
        self.showEnterNameAlert(.ImageFile)
    }
    

    // MARK: - Table view data source

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if let file = self.file {
            return file.files.count
        }
        return 0
    }

    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("Cell", forIndexPath: indexPath) as! FileCell

        if let file = self.file {
            let array = file.files.allObjects as! [File]
            let file = array[indexPath.row]
            if file.isKindOfClass(FileText.self) {
                cell.imgView.image = UIImage(named: "text_file_icon")
                cell.title.text = file.name
            } else if file.isKindOfClass(FileImage.self) {
                cell.imageView?.image = UIImage(named: "photo_file_icon")
                cell.title.text = file.name
            } else if file.isKindOfClass(File.self) {
                cell.imgView.image = UIImage(named: "folder_icon")
                cell.title.text = file.name
                cell.detail.text = "Файлов: \(file.files.count)"
            }
        }
        return cell
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        self.selectedIndexPath = indexPath
        let array = self.file!.files.allObjects as! [File]
        let file = array[indexPath.row]
        
        if file.isKindOfClass(FileText.self) {
            self.performSegueWithIdentifier("segueViewTextFile", sender: file)
        } else
        if file.isKindOfClass(FileImage.self) {
            self.performSegueWithIdentifier("segueViewImageFile", sender: file)
        } else
        if file.isKindOfClass(File.self) {
            self.performSegueWithIdentifier("segueToTableView", sender: file)
        }
    }
    

    /*
    // Override to support conditional editing of the table view.
    override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return NO if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == .Delete {
            // Delete the row from the data source
            tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
        } else if editingStyle == .Insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(tableView: UITableView, moveRowAtIndexPath fromIndexPath: NSIndexPath, toIndexPath: NSIndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(tableView: UITableView, canMoveRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return NO if you do not want the item to be re-orderable.
        return true
    }
    */


    // MARK: - Navigation

    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "segueToTableView" {
            let destination = segue.destinationViewController as! TableViewController
            let file = sender as? File
            destination.file = sender as? File
        }
        if segue.identifier == "segueViewTextFile" {
            let destination = segue.destinationViewController as! TextFileViewController
            destination.file = sender as? FileText
        }
        if segue.identifier == "segueViewImageFile" {
            let destination = segue.destinationViewController as! ImageFileViewController
            destination.file = sender as? FileImage
        }
    }


}
