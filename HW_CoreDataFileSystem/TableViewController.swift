//
//  TableViewController.swift
//  HW_CoreDataFileSystem
//
//  Created by Gena on 09.04.15.
//  Copyright (c) 2015 Gena. All rights reserved.
//

import UIKit

class TableViewController: UITableViewController, UIAlertViewDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    var folder: FileFolder?
    var selectedImage: UIImage?
    var selectedIndexPath: NSIndexPath?
    var files: [File]?
    
    var addButton: UIBarButtonItem?
    var doneButton: UIBarButtonItem?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.addGestures()
        
        self.tableView.tableFooterView = UIView()
        
        self.addButton = UIBarButtonItem(barButtonSystemItem: .Add, target: self, action: "addButtonPressed:")
        self.doneButton = UIBarButtonItem(title: "Готово", style: UIBarButtonItemStyle.Done, target: self, action: "doneButtonPressed:")
        
        self.navigationItem.rightBarButtonItem = self.addButton
        self.navigationItem.rightBarButtonItem?.enabled = true
        
        if self.folder == nil {
            CoreDataManager.sharedInstance.getRootFolder({ (rootFile) -> () in
                self.folder = rootFile
                self.loadData()
                
            })
        } else {
            self.loadData()
        }
    }
    
    func loadData() {
        self.title = self.folder?.name
        self.files = CoreDataManager.getSortedFilesFromFolder(self.folder!)
        self.tableView.reloadData()
    }
    
    override func viewDidAppear(animated: Bool) {
        self.reloadRowAtIndexPath(self.selectedIndexPath)
    }
    
    func reloadRowAtIndexPath(indexPath: NSIndexPath?) {
        if let indexPath = indexPath {
            self.tableView.beginUpdates()
            self.tableView.reloadRowsAtIndexPaths([indexPath], withRowAnimation: UITableViewRowAnimation.Automatic)
            self.tableView.endUpdates()
        }
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        CoreDataManager.sharedInstance.save()
    }
    
    func addGestures() {
        let lpgs = UILongPressGestureRecognizer(target: self, action: "handleLongPressGestures:")
        lpgs.minimumPressDuration = 1.0
        self.tableView.addGestureRecognizer(lpgs)
    }
    
    func handleLongPressGestures(sender: UILongPressGestureRecognizer) {
        self.tableView.setEditing(true, animated: true)
        self.navigationItem.rightBarButtonItem = self.doneButton
    }
    
    func doneButtonPressed(sender: AnyObject) {
        self.tableView.setEditing(false, animated: true)
        self.navigationItem.rightBarButtonItem = self.addButton
    }
    
    func addButtonPressed(sender: AnyObject) {
        let actionSheet = UIAlertController(title: nil, message: "Добавить", preferredStyle: .ActionSheet)
        
        let createFolderAction = UIAlertAction(title: "Папку", style: .Default) { (alert: UIAlertAction!) -> Void in
            self.showEnterNameAlert(.Folder, action: .Add)
        }
        let createTextFileAction = UIAlertAction(title: "Текстовый файл", style: .Default) { (alert: UIAlertAction!) -> Void in
            self.showEnterNameAlert(.TextFile, action: .Add)
        }
        
        let createImageFileAction = UIAlertAction(title: "Изображение", style: .Default) { (alert: UIAlertAction!) -> Void in
            self.showImagePicker()
        }
        
        let cancelAction = UIAlertAction(title: "Отмена", style: .Cancel) { (alert: UIAlertAction!) -> Void in }
        
        actionSheet.addAction(createFolderAction)
        actionSheet.addAction(createTextFileAction)
        actionSheet.addAction(createImageFileAction)
        actionSheet.addAction(cancelAction)
        self.presentViewController(actionSheet, animated: true, completion: nil)
    }
    
    //MARK: - AlertController
    
    func showEnterNameAlert(type: FileType, action: ActionType, sender: File? = nil) {
        let title: String
        
        switch type {
            case .Folder: title = "Введите название папки"
            case .TextFile: title = "Введите название текстового файла"
            case .ImageFile: title = "Введите название изображения"
        }
        
        let alertController = UIAlertController(title: title, message: "", preferredStyle: .Alert)
        let cancelAction = UIAlertAction(title: "Отмена", style: .Cancel) { (_) -> Void in }
        let addAction = UIAlertAction(title: (action == .Add ? "Добавить" : "Переименовать"), style: .Default) { (_) -> Void in
            let textFileld = alertController.textFields![0] as! UITextField
            let indexPath = NSIndexPath(forRow: self.folder!.files.count, inSection: 0)
            
            switch type {
            case .Folder:
                if action == .Add {
                    let newFolder = FileFolder(name: textFileld.text)
                    CoreDataManager.sharedInstance.addFileToFolder(self.folder!, file: newFolder, completed: { () -> () in
                        self.files?.append(newFolder)
                        self.tableView.insertRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
                    })
                }
                if action == .Rename {
                    let folder = sender as! FileFolder
                    folder.name = textFileld.text
                    CoreDataManager.sharedInstance.save()
                    self.reloadRowAtIndexPath(self.selectedIndexPath)
                }
                

            case .TextFile:
                if action == .Add {
                    let newTextFile = FileText(name: textFileld.text)
                    CoreDataManager.sharedInstance.addFileToFolder(self.folder!, file: newTextFile, completed: { () -> () in
                        self.files?.append(newTextFile)
                        self.tableView.insertRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
                    })
                }
                if action == .Rename {
                    let textFile = sender as! FileText
                    textFile.name = textFileld.text
                    CoreDataManager.sharedInstance.save()
                    self.reloadRowAtIndexPath(self.selectedIndexPath)
                }
                
            case .ImageFile:
                if action == .Add {
                    let newImageFile = FileImage(name: textFileld.text, image: self.selectedImage!)
                    CoreDataManager.sharedInstance.addFileToFolder(self.folder!, file: newImageFile, completed: { () -> () in
                        self.files?.append(newImageFile)
                        self.tableView.insertRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
                    })
                }
                if action == .Rename {
                    let imageFile = sender as! FileImage
                    imageFile.name = textFileld.text
                    CoreDataManager.sharedInstance.save()
                    self.reloadRowAtIndexPath(self.selectedIndexPath)
                }
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
        self.showEnterNameAlert(.ImageFile, action: .Add)
    }
    

    // MARK: - Table view data source

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.files?.count ?? 0
    }

    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("Cell", forIndexPath: indexPath) as! FileCell

        if let files = self.files {
            let file  = files[indexPath.row]
            var total = 0
            let sizeInBytes = CoreDataManager.getSizeOfFile(file, total: &total)
            let size = FormattingHelper.getFormattedSizeFromByteSize(sizeInBytes)
            
            switch file.getFileType()! {
            case .Folder:
                let file = file as! FileFolder
                if (cell.imageView?.image?.isEqual(UIImage(named: "folder_icon")) == nil) {
                    cell.imgView.image = UIImage(named: "folder_icon")
                }
                cell.detail.text = "Файлов: \(file.files.count); Размер: \(size)"
            case .TextFile:
                if (cell.imageView?.image?.isEqual(UIImage(named: "text_file_icon")) == nil) {
                    cell.imgView.image = UIImage(named: "text_file_icon")
                }
                cell.detail.text = "Размер: \(size)"
            case .ImageFile:
                if (cell.imageView?.image?.isEqual(UIImage(named: "photo_file_icon")) == nil) {
                    cell.imgView.image = UIImage(named: "photo_file_icon")
                }
                cell.detail.text = "Размер: \(size)"
            }
            cell.title.text = file.name
        }
        return cell
    }
    
    override func tableView(tableView: UITableView, moveRowAtIndexPath fromIndexPath: NSIndexPath, toIndexPath: NSIndexPath) {
        CoreDataManager.moveFileFromAllFiles(&self.files!, fromIndex: fromIndexPath.row, toIndex: toIndexPath.row)
    }
    
    override func tableView(tableView: UITableView, canMoveRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        return true
    }
    
    override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        return true
    }
    
    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
    }
    
    
    // MARK: - Table view delegate
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        self.selectedIndexPath = indexPath
        let file  = self.files![indexPath.row]
        
        switch file.getFileType()! {
            case .Folder: self.performSegueWithIdentifier("segueToTableView", sender: file)
            case .TextFile: self.performSegueWithIdentifier("segueViewTextFile", sender: file)
            case .ImageFile: self.performSegueWithIdentifier("segueViewImageFile", sender: file)
        }
    }
    
    override func tableView(tableView: UITableView, editActionsForRowAtIndexPath indexPath: NSIndexPath) -> [AnyObject]? {
        let renameRowAction = UITableViewRowAction(style: UITableViewRowActionStyle.Default, title: "Rename") { (action, indexPath) -> Void in
            let file = self.files![indexPath.row]
            self.selectedIndexPath = indexPath
            self.showEnterNameAlert(file.getFileType()!, action: .Rename, sender: file)
        }
        renameRowAction.backgroundColor = UIColor.orangeColor()
        
        let deleteRowAction = UITableViewRowAction(style: UITableViewRowActionStyle.Default, title: "Удалить") { (action, indexPath) -> Void in
            let file = self.files![indexPath.row]
            self.files?.removeAtIndex(indexPath.row)
            
            CoreDataManager.sharedInstance.deleteFile(file, fromFolder: self.folder!, completed: { () -> () in
                tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
            })
        }
        return [deleteRowAction, renameRowAction]
    }


    // MARK: - Navigation

    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "segueToTableView" {
            let destination = segue.destinationViewController as! TableViewController
            let folder = sender as? FileFolder
            destination.folder = sender as? FileFolder
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
