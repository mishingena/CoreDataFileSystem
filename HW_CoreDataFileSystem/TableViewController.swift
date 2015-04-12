//
//  TableViewController.swift
//  HW_CoreDataFileSystem
//
//  Created by Gena on 09.04.15.
//  Copyright (c) 2015 Gena. All rights reserved.
//

import UIKit

class TableViewController: UITableViewController, UIAlertViewDelegate {
    
    var folder: Folder?
    //вот такие костыли приходится делать из-за типизации объектов
    var elements: [Element]?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let addButton = UIBarButtonItem(barButtonSystemItem: .Add, target: self, action: "addButtonPressed:")
        
        self.navigationItem.rightBarButtonItem = addButton
        
        if self.folder == nil {
            CoreDataManager.sharedInstance.getRootFolder { (rootFolder) -> () in
                self.folder = rootFolder
                println(self.folder?.name)
                self.title = self.folder?.name
            }
        }
    }
    
    override func viewDidAppear(animated: Bool) {
        self.loadData()
    }
    
    func loadData() {
        if let folder = self.folder {
            CoreDataManager.sharedInstance.getElementsFromFolder(self.folder!, completion: { (elements) -> () in
                self.elements = elements
                self.tableView.reloadData()
            })
        }
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
            self.showEnterNameAlert(.ImageFile)
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
//            self.addElement(textFileld.text, type: type)
//            self.addFolder(textFileld.text)
            var newElement = Element(type: type, name: textFileld.text)
//            newElement.folder?.name = textFileld.text
//            CoreDataManager.sharedInstance.addElement(self.folder!, element: newElement)
            CoreDataManager.sharedInstance.addElement(self.folder!, element: newElement, finished: { () -> () in
                self.elements?.append(newElement)
                self.tableView.reloadData()
            })
            
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
    
//    func addElement(name: String, type: FileType) {
//        self.folder?.folders = NSSet()
//        self.folder?.folders.setByAddingObject(Element(type: type))
//        var element = Element(type: type)
//        
//        switch type {
//        case .Folder: element.folder!.name = name
//        case .ImageFile: element.imageFile!.name = name
//        case .TextFile: element.textFile!.name = name
//        }
//        
//    }
    
//    func addFolder(name: String) {
//        var newElement = Element(type: .Folder)
//        newElement.folder?.name = name
//        
//        var newFolder = Folder()
//        newFolder.name = name
//        
//        var folders = NSMutableSet(set: self.folder!.folders)
//        folders.addObject(newFolder)
//        self.folder?.folders = folders
//        
//        CoreDataManager.sharedInstance.save()
//        self.loadData()
//    }

    // MARK: - Table view data source

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if let elemets = self.elements {
            return elements!.count
        }
        return 0
    }

    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("Cell", forIndexPath: indexPath) as! UITableViewCell
        
        if let element = self.elements?[indexPath.row] {
            var name = "no name"
            switch element.fileType! {
            case .Folder: name = element.folder!.name
            case .TextFile: name = element.textFile!.name
            case .ImageFile: name = element.imageFile!.name
            }
            cell.textLabel?.text = name
        }

        return cell
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        if let element = self.elements?[indexPath.row] {
            switch element.fileType! {
            case .TextFile: self.performSegueWithIdentifier("segueViewTextFile", sender: element)
            default: break
            }
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
        if segue.identifier == "segueViewTextFile" {
            let destination = segue.destinationViewController as! TextFileViewController
//            let element = sender as! Element
//            if let textFile = element.textFile {
//                if textFile.text != "" {
                    destination.element = sender as? Element
//                }
//            }
            
//            if element.textFile?.text != nil {
//                destination.text = element.textFile?.text
//            }
//            if let text = element.textFile?.name {
//                destination.text = element.textFile?.name
//            }
//            destination.text = element.textFile?.text
        }
    }


}
