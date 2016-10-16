//
//  AnonymouseTableViewController.swift
//  Anonymouse
//
//  Created by Pascal Sturmfels on 3/14/16.
//  Copyright © 2016 1AM. All rights reserved.
//
import CryptoSwift
import UIKit
import CoreData

class AnonymouseTableViewController: UITableViewController, NSFetchedResultsControllerDelegate {
    var managedObjectContext: NSManagedObjectContext!

    lazy var fetchedResultsController: NSFetchedResultsController<AnonymouseMessageCore> = {
        // Initialize Fetch Request
        let fetchRequest: NSFetchRequest<AnonymouseMessageCore> = NSFetchRequest<AnonymouseMessageCore>(entityName: "AnonymouseMessageCore")
        
        // Add Sort Descriptors
        let sortDescriptor: NSSortDescriptor = NSSortDescriptor(key: "date", ascending: false)
        fetchRequest.sortDescriptors = [sortDescriptor]
        
        // Initialize Fetched Results Controller
        let fetchedResultsController: NSFetchedResultsController<AnonymouseMessageCore> = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: self.managedObjectContext, sectionNameKeyPath: nil, cacheName: nil)
        
        // Configure Fetched Results Controller
        fetchedResultsController.delegate = self
        
        return fetchedResultsController
    }()
    
    override func viewDidLoad() {
        self.tableView.delegate = self
        self.tableView.dataSource = self
        
        tableView.register(AnonymouseTableViewCell.self, forCellReuseIdentifier: "AnonymouseTableViewCell")
        
        //Reference the appDelegate to recover the managedObjectContext
        unowned let appDelegate: AppDelegate = UIApplication.shared.delegate as! AppDelegate
        self.managedObjectContext = appDelegate.dataController.managedObjectContext
        
        //The following block of code defends against coreData migrations.
        //When the coreData format is changed, the OS needs to migrate the store
        //to avoid crashes.
        let userDefaults: UserDefaults = UserDefaults.standard
        let didDetectIncompatibleStore: Bool = userDefaults.bool(forKey: "didDetectIncompatibleStore")
        
        if didDetectIncompatibleStore {
            // Show Alert
            let applicationName: Any? = Bundle.main.object(forInfoDictionaryKey: "CFBundleDisplayName")
            let message: String = "A serious application error occurred while \(applicationName) tried to read your data. Please contact support for help."
            
            self.showAlertWithTitle("Warning", message: message, cancelButtonTitle: "OK")
        }
        
        //Attempt to recover all the the persisted messages.
        do {
            try self.fetchedResultsController.performFetch()
        } catch {
            let fetchError: NSError = error as NSError
            print("\(fetchError), \(fetchError.userInfo)")
            
            let applicationName: Any? = Bundle.main.object(forInfoDictionaryKey: "CFBundleDisplayName")
            let message: String = "A serious application error occurred while \(applicationName) tried to read your data. Please contact support for help."
            
            self.showAlertWithTitle("Warning", message: message, cancelButtonTitle: "OK")
        }
        
        //Set up the tableView style
        self.tableView.backgroundColor = UIColor.groupTableViewBackground
        self.tableView.cellLayoutMarginsFollowReadableWidth = false
        self.tableView.separatorStyle = UITableViewCellSeparatorStyle.none
        
        self.refreshControl = UIRefreshControl()
        self.refreshControl?.backgroundColor = UIColor.groupTableViewBackground
        self.refreshControl?.tintColor = UIColor.darkGray
        self.refreshControl?.addTarget(self, action: #selector(self.refreshControlDidChangeValue), for: UIControlEvents.valueChanged)
    }
    
    //MARK: UIRefreshControl
    func refreshControlDidChangeValue() {
        self.tableView.reloadData()
        self.refreshControl?.endRefreshing()
    }
    
    //MARK: tableViewControllerDelegate
    override func numberOfSections(in tableView: UITableView) -> Int {
        if let sections: [NSFetchedResultsSectionInfo] = fetchedResultsController.sections {
            return sections.count
        }
        return 0
    }
    
    //This function is part of UITableViewController's built-in classes.
    //It asks for the number of rows in tableView = number of messages = size of cellDataArray.
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if let sections: [NSFetchedResultsSectionInfo] = fetchedResultsController.sections {
            let sectionInfo: NSFetchedResultsSectionInfo = sections[section]
            return sectionInfo.numberOfObjects
        }
        return 0
    }
    
    //This function is part of UITableViewController's built-in classes.
    //In it, we tell the tableView which message to render at each index of the table.
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        //Grab the appropriate data from our cellDataArray.
        
        let anonymouseMessageCoreData: AnonymouseMessageCore = fetchedResultsController.object(at: indexPath)
        let cell: AnonymouseTableViewCell
        
        
        //Create a cell of type MCChatTableViewCell
        let reusableCell: AnyObject = tableView.dequeueReusableCell(withIdentifier: "AnonymouseTableViewCell", for: indexPath)
        cell = reusableCell as! AnonymouseTableViewCell
        
        cell.preservesSuperviewLayoutMargins = false
        cell.layoutMargins = UIEdgeInsets.zero
        
        //Set the cell's width to be the width of the screen.
        cell.frame.size.width = self.tableView.frame.width
        
        //Set the cell's data to be the appropriate data.
        //Notice that in this line, MCChatTableViewCell's property, data, is set.
        //After it is set, the didSet keyword will be called, calling updateCellUI()
        cell.data = anonymouseMessageCoreData
        
        return cell
    }
    
    //This function is part of UITableViewController's built-in classes.
    //In it, we determine the height of each cell in the tableView.
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        //Notice that MCChatCellData already have a property called cellHeight
        //that depends on the size of the message.
        let anonymouseMessageCoreData: AnonymouseMessageCore = fetchedResultsController.object(at: indexPath)
        
        return AnonymouseTableViewCell.getCellHeight(withMessageText: anonymouseMessageCoreData.text!)
    }
    
    // MARK: Fetched Results Controller Delegate Methods
    func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        tableView.beginUpdates()
    }
    
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        tableView.endUpdates()
    }
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
        switch (type) {
        case .insert:
            if let indexPath = newIndexPath {
                tableView.insertRows(at: [indexPath], with: .fade)
            }
        case .delete:
            if let indexPath = indexPath {
                tableView.deleteRows(at: [indexPath], with: .fade)
            }
        case .update:
            if let indexPath = indexPath {
                let cell = tableView.cellForRow(at: indexPath) as! AnonymouseTableViewCell
                let anonymouseMessageCoreData = fetchedResultsController.object(at: indexPath)
                cell.data = anonymouseMessageCoreData
            }
            
            break;
        case .move:
            if let indexPath = indexPath, let newIndexPath = newIndexPath {
                tableView.moveRow(at: indexPath, to: newIndexPath)
            }
        }
    }
    
    func controller(controller: NSFetchedResultsController<AnonymouseMessageCore>, didChangeSection sectionInfo: NSFetchedResultsSectionInfo, atIndex sectionIndex: Int, forChangeType type: NSFetchedResultsChangeType) {
        switch type {
        case .insert:
            tableView.insertSections(NSIndexSet(index: sectionIndex) as IndexSet, with: .fade)
        case .delete:
            tableView.deleteSections(NSIndexSet(index: sectionIndex) as IndexSet, with: .fade)
        case .move:
            break
        case .update:
            break
        }
    }
    
    fileprivate func showAlertWithTitle(_ title: String, message: String, cancelButtonTitle: String) {
        // Initialize Alert Controller
        let alertController: UIAlertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        
        // Configure Alert Controller
        alertController.addAction(UIAlertAction(title: cancelButtonTitle, style: .default, handler: { (_) -> Void in
            let userDefaults: UserDefaults = UserDefaults.standard
            userDefaults.removeObject(forKey: "didDetectIncompatibleStore")
        }))
        
        // Present Alert Controller
        present(alertController, animated: true, completion: nil)
    }
}
