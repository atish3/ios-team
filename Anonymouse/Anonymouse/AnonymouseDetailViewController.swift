//
//  AnonymouseDetailViewController.swift
//  Anonymouse
//
//  Created by Pascal Sturmfels on 10/16/16.
//  Copyright © 2016 1AM. All rights reserved.
//

import UIKit
import CoreData

///A subclass of `UIViewController` that displays a single message in detail, along with its replies.
class AnonymouseDetailViewController: UIViewController, UITextViewDelegate, UITableViewDelegate, UITableViewDataSource, NSFetchedResultsControllerDelegate {
    ///The data of the main message displayed in detail
    var cellData: AnonymouseMessageCore! {
        didSet {
            ///A fetch request to fetch the replies of the main message
            self.fetchRequest = NSFetchRequest<AnonymouseReplyCore>(entityName: "AnonymouseReplyCore")
            let parentPredicate: NSPredicate = NSPredicate(format: "parentMessage == %@", cellData)
            self.fetchRequest.predicate = parentPredicate
            let sortDescriptor: NSSortDescriptor = NSSortDescriptor(key: "date", ascending: true)
            fetchRequest.sortDescriptors = [sortDescriptor]
            
            self.fetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: self.managedObjectContext, sectionNameKeyPath: nil, cacheName: nil)
            self.fetchedResultsController.delegate = self
            
            do {
                try self.fetchedResultsController.performFetch()
            } catch {
                let fetchError: NSError = error as NSError
                print("\(fetchError), \(fetchError.userInfo)")
                
                let applicationName: Any? = Bundle.main.object(forInfoDictionaryKey: "CFBundleDisplayName")
                let message: String = "A serious application error occurred while \(String(describing: applicationName)) tried to read your data. Please contact support for help."
                
                self.showAlertWithTitle("Warning", message: message, cancelButtonTitle: "OK")
            }
        }
    }
    
    ///A `textView` in which the user inputs a reply to the main message.
    var replyTextView: UITextView!
    ///The container view for everything related to the `replyTextView`.
    var replyView: UIView!
    ///The button that sends the reply to the main message when tapped.
    var replyButton: UIButton!
    ///The placeholder label that appears when the `replyTextView` is empty.
    //var replyLabel: UILabel!
    ///The `tableView` used to display the replies to the main message.
    var tableView: UITableView!
    /**`true` if this view was pushed by a reply button tapped event, `false`
     if this view was pushed by a cell tapped event.
    */
    var shouldDisplayReply: Bool = false
    
    ///The `NSManagedObjectContext` that the replies are stored in.
    var managedObjectContext: NSManagedObjectContext!
    ///The `NSFetchedRequest` that finds the replies to the main message.
    var fetchRequest: NSFetchRequest<AnonymouseReplyCore>!
    
    ///The `NSFetchedResultsController` that fetches the replies using the `fetchRequest`.
    var fetchedResultsController: NSFetchedResultsController<AnonymouseReplyCore>!
    
    ///The maximum number of characters that can be in a reply, minus one (don't ask lol)
    let maxCharacters: Int = 301
    ///The label that displays how many characters the user has left in their composed reply.
    var charactersLeftLabel: UILabel!
    
    ///A weak reference to the `dataController` that allows a user to post a reply to the persistent store.
    weak var dataController: AnonymouseDataController!
    ///A weak reference to the `connectivityController` that allows a user to send a reply to nearby peers.
    weak var connectivityController: AnonymouseConnectivityController!
    
    ///Displays the `replyView`, which allows the user to edit and send replies.
    @objc func displayReply() {
        guard let mainUser: String = cellData.user else {
            return
        }
        guard !replyTextView.isFirstResponder else {
            let shakeAnimation: CABasicAnimation = CABasicAnimation(keyPath: "position")
            shakeAnimation.duration = 0.05
            shakeAnimation.repeatCount = 3
            shakeAnimation.autoreverses = true
            shakeAnimation.fromValue = NSValue(cgPoint: CGPoint(x: self.replyTextView.center.x, y: self.replyTextView.center.y - 5))
            shakeAnimation.toValue = NSValue(cgPoint: CGPoint(x: self.replyTextView.center.x, y: self.replyTextView.center.y + 5))
            self.replyTextView.layer.add(shakeAnimation, forKey: "position")
            return
        }
        
        shouldDisplayReply = false
        //self.replyLabel.isHidden = true
        self.replyTextView.text = "@\(mainUser): "
        self.replyTextView.becomeFirstResponder()
    }
    
    //MARK: Override properties
    override var canBecomeFirstResponder: Bool {
        get {
            return true
        }
    }
    
    ///The `inputAccessoryView` is the thing that sits above the keyboard; in this case, the `replyView`.
    override var inputAccessoryView: UIView? {
        get {
            return replyView
        }
    }
    
    //MARK: View Methods
    override func viewDidLoad() {
        guard let mainUser: String = cellData.user else {
            return
        }
        
        unowned let appDelegate: AppDelegate = UIApplication.shared.delegate as! AppDelegate
        dataController = appDelegate.dataController
        connectivityController = appDelegate.connectivityController
        
        let userDefaults: UserDefaults = UserDefaults.standard
        let didDetectIncompatibleStore: Bool = userDefaults.bool(forKey: "didDetectIncompatibleStore")
        
        if didDetectIncompatibleStore {
            // Show Alert
            let applicationName: Any? = Bundle.main.object(forInfoDictionaryKey: "CFBundleDisplayName")
            let message: String = "A serious application error occurred while \(String(describing: applicationName)) tried to read your data. Please contact support for help."
            
            self.showAlertWithTitle("Warning", message: message, cancelButtonTitle: "OK")
        }
        
        let replyHeight: CGFloat = 50.0
        var tableViewFrame: CGRect = self.view.frame
        tableViewFrame.size.height -= replyHeight + 60.0
        
        self.view.backgroundColor = UIColor.groupTableViewBackground
        tableView = UITableView(frame: tableViewFrame, style: UITableViewStyle.grouped)
        tableView.delegate = self
        tableView.dataSource = self
        tableView.cellLayoutMarginsFollowReadableWidth = false
        tableView.separatorStyle = UITableViewCellSeparatorStyle.none
        tableView.allowsSelection = false
        tableView.contentInset = UIEdgeInsetsMake(-36, 0, 0, 0)
        tableView.sectionFooterHeight = 0.0
        tableView.sectionHeaderHeight = 5.0
        
        tableView.register(AnonymouseTableViewCell.self, forCellReuseIdentifier: "AnonymouseTableViewCell")
        tableView.register(AnonymouseReplyViewCell.self, forCellReuseIdentifier: "AnonymouseReplyViewCell")
        
        self.view.addSubview(tableView)
        
        replyButton = UIButton(frame: CGRect(x: 0.0, y: 0.0, width: 40.0, height: 40.0))
        replyButton.setImage(UIImage(named: "sendFilled"), for: UIControlState.normal)
        replyButton.alpha = 0.5
        replyButton.addTarget(self, action: #selector(AnonymouseDetailViewController.replyTapped), for: UIControlEvents.touchUpInside)
        replyButton.addTarget(self, action: #selector(AnonymouseDetailViewController.replySelected), for: UIControlEvents.touchDown)
        replyButton.addTarget(self, action: #selector(AnonymouseDetailViewController.replyReleased), for: UIControlEvents.touchCancel)
        replyButton.addTarget(self, action: #selector(AnonymouseDetailViewController.replyReleased), for: UIControlEvents.touchDragExit)
        replyButton.frame.origin.x = self.view.frame.width - replyButton.frame.width - 10
        replyButton.frame.origin.y = replyHeight * 0.5 - replyButton.frame.height * 0.5
        replyButton.isHidden = true
        
        let replyTextWidth: CGFloat = replyButton.frame.origin.x - 20.0
        
        let replyFrame: CGRect = CGRect(x: 10.0, y: (replyHeight - 34.5) * 0.5, width: replyTextWidth, height: 34.5)
        replyTextView = UITextView(frame: replyFrame)
        replyTextView.isScrollEnabled = false
        replyTextView.delegate = self
        replyTextView.text = "@\(mainUser): "
        replyTextView.font = UIFont(name: "Helvetica", size: 16.0)!
        replyTextView.backgroundColor = UIColor.white
        replyTextView.contentSize = replyTextView.frame.size
        
        replyView = UIView(frame: CGRect(x: 0.0, y: self.view.frame.height, width: self.view.frame.width, height: replyHeight))
        replyView.backgroundColor = UIColor.white
        replyView.layer.shadowOffset = CGSize(width: -1, height: 1)
        replyView.layer.shadowOpacity = 0.4
        replyView.autoresizingMask = UIViewAutoresizing.flexibleHeight
        
        charactersLeftLabel = UILabel()
        charactersLeftLabel.font = replyTextView.font
        charactersLeftLabel.textColor = UIColor.lightGray
        charactersLeftLabel.text = "\(maxCharacters - 1)"
        charactersLeftLabel.sizeToFit()
        charactersLeftLabel.frame.origin = replyButton.frame.origin
        charactersLeftLabel.frame.origin.y = replyView.frame.height
        
        ///A piece of UI that makes the `replyView` look better.
        let grayTopBar: UIView = UIView()
        grayTopBar.frame.size.width = self.view.frame.width
        grayTopBar.frame.size.height = 1.0
        grayTopBar.frame.origin = CGPoint.zero
        grayTopBar.backgroundColor = UIColor(white: 0.6, alpha: 1.0)
        
        replyView.addSubview(replyButton)
        replyView.addSubview(replyTextView)
        replyView.addSubview(grayTopBar)
        replyView.addSubview(charactersLeftLabel)
        
        NotificationCenter.default.addObserver(self, selector: #selector(AnonymouseDetailViewController.keyboardWillShow(_:)), name:NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(AnonymouseDetailViewController.keyboardWillHide(_:)), name:NSNotification.Name.UIKeyboardWillHide, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(AnonymouseDetailViewController.displayReply), name: NSNotification.Name("replyTextViewBecomeFirstResponder"), object: nil)
        
        let tapGestureRecognizer: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(AnonymouseDetailViewController.tappedOutsideOfEdit))
        self.view.addGestureRecognizer(tapGestureRecognizer)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        guard let text = cellData.text else {
            return
        }
        
        self.title = text
        tableView.reloadData()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if shouldDisplayReply {
            displayReply()
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        resetInputAccessoryView()
        if let parentNavigationController = self.navigationController as? AnonymouseNavigationStyleController {
            if let tableVC = parentNavigationController.viewControllers[0] as? AnonymouseTableViewController {
                tableVC.tableView.reloadData()
                return
            }
        }
    }
    
    ///Clears the `replyView` of the currently-edited message text, and dismisses it.
    func resetInputAccessoryView() {
        guard let mainUser: String = cellData.user else {
            return
        }
        replyButton.isHidden = true
        replyTextView.text = "@\(mainUser): "
        //replyLabel.isHidden = false
        replyButton.isHidden = true
        let bestSize: CGSize = replyTextView.sizeThatFits(replyTextView.frame.size)
        let bestHeight: CGFloat = bestSize.height
        let currentHeight: CGFloat = replyTextView.frame.height
        if bestHeight != currentHeight {
            let difference: CGFloat = bestHeight - currentHeight
            guard abs(difference) < 80 else {
                return
            }
            
            replyTextView.frame.size.height = bestHeight
            replyView.frame.size.height += difference
            replyView.frame.origin.y -= difference
        }
        charactersLeftLabel.frame.origin.y = replyView.frame.height
        replyButton.alpha = 0.5
        dismissKeyboard()
    }
    
    //MARK: Button Methods
    ///Called when the reply button is tapped; sends the reply to nearby peers and saves it to the persisten store.
    @objc func replyTapped() {
        var replyText: String = replyTextView.text
        replyText = replyText.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
        let userPreferences: UserDefaults = UserDefaults.standard
        let username: String = userPreferences.string(forKey: "username")!
        let privKey: String = userPreferences.string(forKey: "privateKey")!
        let pubKey: String = userPreferences.string(forKey: "publicKey")!
        if(privKey.sha1() == pubKey) {
            self.dataController.addReply(withText: replyText, date: Date(), user: username, toMessage: cellData, pubKey: pubKey)
            if self.connectivityController.sessionObject.connectedPeers.count > 0 {
                self.connectivityController.send(individualReply: AnonymouseReplySentCore(text: replyText, date: Date(), user: username, parentText: cellData.text!, pubKey: pubKey))
            }
        }
        
        resetInputAccessoryView()
    }
    
    ///Called when the reply button is selected.
    @objc func replySelected() {
        replyButton.alpha = 1.0
    }
    
    ///Called when the reply button is released.
    @objc func replyReleased() {
        replyButton.alpha = 0.5
    }
    
    ///Called when the user taps outside of the editing window/keyboard; dismissed the keyboard and `replyView`.
    @objc func tappedOutsideOfEdit() {
        guard let mainUser: String = cellData.user else {
            return
        }
        
        if replyTextView.text.isEmpty || replyTextView.text == "@\(mainUser): " {
            self.resetInputAccessoryView()
            return
        }
        
        let title: String = "Discard Comment?"
        let alertController: UIAlertController = UIAlertController(title: title, message: nil, preferredStyle: .alert)
        
        
        // Configure Alert Controller
        alertController.addAction(UIAlertAction(title: "Keep Writing", style: .default, handler: nil))
        alertController.addAction(UIAlertAction(title: "Discard", style: .destructive, handler: { (_) in
            self.resetInputAccessoryView()
        }))
        
        let alertWindow = UIWindow(frame: UIScreen.main.bounds)
        alertWindow.rootViewController = UIViewController()
        alertWindow.windowLevel = 10000001
        alertWindow.isHidden = false
        // Present Alert Controller
        alertWindow.rootViewController!.present(alertController, animated: true, completion: nil)
    }
    
    //MARK: TextView Methods
    ///Dismisses the keyboard
    func dismissKeyboard() {
        replyTextView.resignFirstResponder()
    }
    
    func textViewDidChange(_ textView: UITextView) {
        let testString: String = textView.text!.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
        replyButton.isHidden = testString.isEmpty
      //  replyLabel.isHidden = !textView.text.isEmpty
        let numLines: Int = Int(textView.contentSize.height/textView.font!.lineHeight)
        
        if numLines >= 4 {
            textView.isScrollEnabled = true
        } else {
            textView.isScrollEnabled = false
            let bestSize: CGSize = textView.sizeThatFits(textView.frame.size)
            let bestHeight: CGFloat = bestSize.height
            let currentHeight: CGFloat = textView.frame.height
            if bestHeight != currentHeight {
                let difference: CGFloat = bestHeight - currentHeight
                guard abs(difference) < 80 else {
                    return
                }
                
                textView.frame.size.height = bestHeight
                replyView.frame.size.height += difference
                replyView.frame.origin.y -= difference
                
                let newNumLines: Int = Int(textView.contentSize.height/textView.font!.lineHeight)
                if newNumLines >= 2 {
                    self.charactersLeftLabel.frame.origin.y = replyView.frame.height - charactersLeftLabel.frame.height - 5
                } else {
                    self.charactersLeftLabel.frame.origin.y = replyView.frame.height
                }
            }
        }
    }
    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        let nsString: NSString = textView.text! as NSString
        let numCharacters: Int = nsString.replacingCharacters(in: range, with: text).characters.count
        let remainingCharacters: Int = maxCharacters - numCharacters
        
        if remainingCharacters < 40 {
            charactersLeftLabel.textColor = UIColor.red
            charactersLeftLabel.alpha = 0.7
        } else {
            charactersLeftLabel.textColor = UIColor.lightGray
            charactersLeftLabel.alpha = 1.0
        }
        
        if remainingCharacters < 1 {
            return false
        }
        
        charactersLeftLabel.text = "\(remainingCharacters - 1)"
        return true
    }
    
    //MARK: TableViewDelegate Methods
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return 1
        } else {
            let sections: [NSFetchedResultsSectionInfo] = fetchedResultsController.sections!
            let sectionInfo: NSFetchedResultsSectionInfo = sections[0]
            return sectionInfo.numberOfObjects
        }
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section == 0 {
            if indexPath.row == 0 {
                let cell: AnonymouseTableViewCell = tableView.dequeueReusableCell(withIdentifier: "AnonymouseTableViewCell", for: indexPath) as! AnonymouseTableViewCell
                cell.preservesSuperviewLayoutMargins = false
                cell.layoutMargins = UIEdgeInsets.zero
                cell.frame.size.width = self.tableView.frame.width
                cell.createMessageLabel(withNumberOfLines: 0)
                
                cell.isInTable = false
                cell.data = cellData
                return cell
            }
        } else if indexPath.section == 1 {
            let section: Int = 0
            let updatedIndexPath: IndexPath = IndexPath(row: indexPath.row, section: section)
            
            let replyData: AnonymouseReplyCore = fetchedResultsController.object(at: updatedIndexPath)
            let cell: AnonymouseReplyViewCell = tableView.dequeueReusableCell(withIdentifier: "AnonymouseReplyViewCell", for: indexPath) as! AnonymouseReplyViewCell
            cell.preservesSuperviewLayoutMargins = false
            cell.layoutMargins = UIEdgeInsets.zero
            cell.frame.size.width = self.tableView.frame.width - 20
            cell.createMessageLabel(withNumberOfLines: 0)
            cell.isInTable = false
            cell.reply = replyData
            
            return cell
        }
        return AnonymouseTableViewCell()
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.section == 0 {
            if indexPath.row == 0 {
                if let text = cellData.text {
                    return AnonymouseTableViewCell.getCellHeight(withMessageText: text)
                }
            }
        } else {
            let section: Int = 0
            let updatedIndexPath: IndexPath = IndexPath(row: indexPath.row, section: section)
            let anonymouseReplyCoreData: AnonymouseReplyCore = fetchedResultsController.object(at: updatedIndexPath)
            return AnonymouseTableViewCell.getCellHeight(withMessageText: anonymouseReplyCoreData.text!)
        }
        
        return 0.0
    }
    
    //MARK: Keyboard Methods
    @objc func keyboardWillShow(_ notification: Notification) {
        var info = (notification as NSNotification).userInfo!
        let keyboardFrame: CGRect = (info[UIKeyboardFrameEndUserInfoKey] as! NSValue).cgRectValue
        if keyboardFrame.height > 100 {
            tableView.frame.size.height -= keyboardFrame.height - 50.0
        }
    }
    
    @objc func keyboardWillHide(_ notification: Notification) {
        var info = (notification as NSNotification).userInfo!
        let keyboardFrame: CGRect = (info[UIKeyboardFrameEndUserInfoKey] as! NSValue).cgRectValue
        if keyboardFrame.height > 100 {
            tableView.frame.size.height += keyboardFrame.height - 50.0
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
                let section: Int = 1
                let row: Int = indexPath.row
                let updatedIndexPath: IndexPath = IndexPath(row: row, section: section)
                tableView.insertRows(at: [updatedIndexPath], with: .fade)
            }
        case .delete:
            if let indexPath = indexPath {
                let section: Int = 1
                let row: Int = indexPath.row
                let updatedIndexPath: IndexPath = IndexPath(row: row, section: section)
                tableView.deleteRows(at: [updatedIndexPath], with: .fade)
            }
        case .update:
            if let indexPath = indexPath {
                let section: Int = 1
                let row: Int = indexPath.row
                let updatedIndexPath: IndexPath = IndexPath(row: row, section: section)
                if let cell = tableView.cellForRow(at: updatedIndexPath) as? AnonymouseReplyViewCell {
                    let anonymouseReplyCoreData = fetchedResultsController.object(at: indexPath)
                    cell.reply = anonymouseReplyCoreData
                }
            }
            
            break;
        case .move:
            if let indexPath = indexPath, let newIndexPath = newIndexPath {
                let section: Int = 1
                let updatedIndexPath: IndexPath = IndexPath(row: indexPath.row, section: section)
                let newUpdatedIndexPath: IndexPath = IndexPath(row: newIndexPath.row, section: section)
                tableView.moveRow(at: updatedIndexPath, to: newUpdatedIndexPath)
            }
        }
    }
    
    func controller(controller: NSFetchedResultsController<AnonymouseReplyCore>, didChangeSection sectionInfo: NSFetchedResultsSectionInfo, atIndex sectionIndex: Int, forChangeType type: NSFetchedResultsChangeType) {
        fatalError("Section info should never change")
        //        switch type {
        //        case .insert:
        //            tableView.insertSections(NSIndexSet(index: sectionIndex) as IndexSet, with: .fade)
        //        case .delete:
        //            tableView.deleteSections(NSIndexSet(index: sectionIndex) as IndexSet, with: .fade)
        //        case .move:
        //            break
        //        case .update:
        //            break
        //        }
    }
    
    
    //MARK: Helpers
    /**
    Displays an alert with the given `title`, `message`, and `cancelButtonTitle`.
     
     - Parameters:
        - title: The title of the alert.
        - message: The message body of the alert.
        - cancelButtonTitle: The title of the cancel button.
     */
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
