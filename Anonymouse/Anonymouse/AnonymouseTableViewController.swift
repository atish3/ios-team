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

class AnonymouseTableViewController: UITableViewController, NSFetchedResultsControllerDelegate, UISearchResultsUpdating, UISearchBarDelegate {
    var managedObjectContext: NSManagedObjectContext!
    var detailViewController: AnonymouseDetailViewController!
    var searchController: UISearchController!
    var fetchRequest: NSFetchRequest<AnonymouseMessageCore>
    var searchRequest: NSFetchRequest<AnonymouseMessageCore> = NSFetchRequest<AnonymouseMessageCore>(entityName: "AnonymouseMessageCore")
    
    init(withFetchRequest fetchRequest: NSFetchRequest<AnonymouseMessageCore>) {
        self.fetchRequest = fetchRequest
        self.searchRequest.sortDescriptors = fetchRequest.sortDescriptors
        super.init(style: UITableViewStyle.plain)
    }
    
    required init?(coder aDecoder: NSCoder) {
        self.fetchRequest = NSFetchRequest<AnonymouseMessageCore>(entityName: "AnonymouseMessageCore")
        let sortDescriptor: NSSortDescriptor = NSSortDescriptor(key: "date", ascending: false)
        fetchRequest.sortDescriptors = [sortDescriptor]
        searchRequest.sortDescriptors = [sortDescriptor]
        super.init(coder: aDecoder)
    }
    
    lazy var fetchedResultsController: NSFetchedResultsController<AnonymouseMessageCore> = {
        // Initialize Fetched Results Controller
        let fetchedResultsController: NSFetchedResultsController<AnonymouseMessageCore> = NSFetchedResultsController(fetchRequest: self.fetchRequest, managedObjectContext: self.managedObjectContext, sectionNameKeyPath: nil, cacheName: nil)
        
        // Configure Fetched Results Controller
        fetchedResultsController.delegate = self
        
        return fetchedResultsController
    }()
    
    lazy var searchResultsController: NSFetchedResultsController<AnonymouseMessageCore> = {
        // Initialize Fetched Results Controller
        let searchResultsController: NSFetchedResultsController<AnonymouseMessageCore> = NSFetchedResultsController(fetchRequest: self.searchRequest, managedObjectContext: self.managedObjectContext, sectionNameKeyPath: nil, cacheName: nil)
        
        // Configure Fetched Results Controller
        searchResultsController.delegate = self
        
        return searchResultsController
    }()
    
    //MARK: View Methods
    
    func performDetailTransition(notification: Notification) {
        guard self.view.window != nil else {
            return
        }
    
        guard let dictionary = notification.userInfo as? [String: AnonymouseTableViewCell] else {
            return
        }
        if let selectedCell = dictionary["cell"] {
            detailViewController.cellData = selectedCell.data!
            detailViewController.shouldDisplayReply = true
            self.navigationController!.pushViewController(detailViewController, animated: true)
        }
    }
    
    override func viewDidLoad() {
        unowned let appDelegate: AppDelegate = UIApplication.shared.delegate as! AppDelegate
        self.managedObjectContext = appDelegate.dataController.managedObjectContext
        
        detailViewController = AnonymouseDetailViewController()
        detailViewController.managedObjectContext = self.managedObjectContext
        
        self.tableView.delegate = self
        self.tableView.dataSource = self
        
        tableView.register(AnonymouseTableViewCell.self, forCellReuseIdentifier: "AnonymouseTableViewCell")
        
        NotificationCenter.default.addObserver(self, selector: #selector(AnonymouseTableViewController.performDetailTransition), name: NSNotification.Name("performDetailTransitionFromMessage"), object: nil)
        
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
        
        //Initialize search controller (but not show it in the table view yet)
        searchController = UISearchController(searchResultsController: nil)
        searchController.searchResultsUpdater = self
        searchController.dimsBackgroundDuringPresentation = false
        searchController.definesPresentationContext = true
        definesPresentationContext = true
        tableView.tableHeaderView = nil
        searchController.searchBar.delegate = self

        //Set up the tableView style
        self.tableView.backgroundColor = UIColor.groupTableViewBackground
        self.tableView.cellLayoutMarginsFollowReadableWidth = false
        self.tableView.separatorStyle = UITableViewCellSeparatorStyle.none
        
        self.refreshControl = UIRefreshControl()
        self.refreshControl?.backgroundColor = UIColor.groupTableViewBackground
        self.refreshControl?.tintColor = UIColor.darkGray
        self.refreshControl?.addTarget(self, action: #selector(self.refreshControlDidChangeValue), for: UIControlEvents.valueChanged)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.tableView.reloadData()
    }
    
    //MARK: UIRefreshControl
    func refreshControlDidChangeValue() {
        self.tableView.reloadData()
        self.refreshControl?.endRefreshing()
    }
    
    //MARK: Scroll to show searchBar
    override func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let yPos: CGFloat = scrollView.contentOffset.y
        print(yPos)
        
        self.tableView.contentInset = UIEdgeInsetsMake(0, 0, 0, 0);
        //self.automaticallyAdjustsScrollViewInsets = false
        //tableView.contentInset = UIEdgeInsets.zero;
        print(self)
        
        if (tableView.tableHeaderView == nil && yPos < 0) {
            tableView.tableHeaderView = searchController.searchBar
        }
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
        var frc: NSFetchedResultsController<NSFetchRequestResult>
        
        if searchController.isActive && searchController.searchBar.text != "" {
            frc = searchResultsController as! NSFetchedResultsController<NSFetchRequestResult>
        } else {
            frc = fetchedResultsController as! NSFetchedResultsController<NSFetchRequestResult>
        }
        
        if let sections: [NSFetchedResultsSectionInfo] = frc.sections {
            let sectionInfo: NSFetchedResultsSectionInfo = sections[section]
            return sectionInfo.numberOfObjects
        }
        
        return 0
    }
    
    //This function is part of UITableViewController's built-in classes.
    //In it, we tell the tableView which message to render at each index of the table.
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        var frc: NSFetchedResultsController<NSFetchRequestResult>
        
        if searchController.isActive && searchController.searchBar.text != "" {
            frc = searchResultsController as! NSFetchedResultsController<NSFetchRequestResult>
        } else {
            frc = fetchedResultsController as! NSFetchedResultsController<NSFetchRequestResult>
        }
        
        //Grab the appropriate data from our cellDataArray.
        
        let anonymouseMessageCoreData: AnonymouseMessageCore = frc.object(at: indexPath) as! AnonymouseMessageCore
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
        
        var frc: NSFetchedResultsController<NSFetchRequestResult>
        if searchController.isActive && searchController.searchBar.text != "" {
            frc = searchResultsController as! NSFetchedResultsController<NSFetchRequestResult>
        } else {
            frc = fetchedResultsController as! NSFetchedResultsController<NSFetchRequestResult>
        }
        
        let anonymouseMessageCoreData: AnonymouseMessageCore = frc.object(at: indexPath) as! AnonymouseMessageCore
        
        return AnonymouseTableViewCell.getClippedCellHeight(withMessageText: anonymouseMessageCoreData.text!)
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let selectedCell: AnonymouseTableViewCell = tableView.cellForRow(at: indexPath) as? AnonymouseTableViewCell {
            detailViewController.cellData = selectedCell.data!
            self.navigationController!.pushViewController(detailViewController, animated: true)
        }
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
                if let cell = tableView.cellForRow(at: indexPath) as? AnonymouseTableViewCell {
                    let anonymouseMessageCoreData = fetchedResultsController.object(at: indexPath)
                    cell.data = anonymouseMessageCoreData
                }
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
    
    // MARK: UISearchBarDelegate
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        print("in searchBarCancelButtonClicked")
        

    }
    
    // MARK: UISearchResultsUpdating
    func updateSearchResults(for searchController: UISearchController) {
        filterContentForSearchResult(searchText: searchController.searchBar.text!)
    }
    
    func filterContentForSearchResult(searchText: String, scope: String = "All") {
        let predicate = NSPredicate(format: "text contains[c] %@", searchText)
        searchRequest.predicate = predicate
        do {
            try searchResultsController.performFetch()
        } catch {
            let fetchError: NSError = error as NSError
            print("\(fetchError), \(fetchError.userInfo)")
            
            let applicationName: Any? = Bundle.main.object(forInfoDictionaryKey: "CFBundleDisplayName")
            let message: String = "A serious application error occurred while \(applicationName) tried to read your data. Please contact support for help."
            
            self.showAlertWithTitle("Warning", message: message, cancelButtonTitle: "OK")
        }

        tableView.reloadData()
        
    }
}
