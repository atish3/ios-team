//
//  AnonymouseDetailViewController.swift
//  Anonymouse
//
//  Created by Pascal Sturmfels on 10/16/16.
//  Copyright © 2016 1AM. All rights reserved.
//

import UIKit

class AnonymouseDetailViewController: UIViewController, UITextViewDelegate, UITableViewDelegate, UITableViewDataSource {
    var cellData: AnonymouseMessageCore!
    var replyTextView: UITextView!
    var replyView: UIView!
    var replyButton: UIButton!
    var replyLabel: UILabel!
    var tableView: UITableView!
    var shouldDisplayReply: Bool = false
    
    let maxCharacters: Int = 301
    var charactersLeftLabel: UILabel!
    
    func displayReply() {
        guard let mainUser = cellData.user else {
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
        self.replyLabel.isHidden = true
        self.replyTextView.text = "@\(mainUser): "
        self.replyTextView.becomeFirstResponder()
    }
    
    //MARK: Override properties
    override var canBecomeFirstResponder: Bool {
        get {
            return true
        }
    }
    
    override var inputAccessoryView: UIView? {
        get {
            return replyView
        }
    }
    
    //MARK: View Methods
    override func viewDidLoad() {
        
        self.view.backgroundColor = UIColor.groupTableViewBackground
        tableView = UITableView(frame: self.view.frame, style: UITableViewStyle.grouped)
        tableView.delegate = self
        tableView.dataSource = self
        tableView.cellLayoutMarginsFollowReadableWidth = false
        tableView.separatorStyle = UITableViewCellSeparatorStyle.none
        tableView.allowsSelection = false
        tableView.contentInset = UIEdgeInsetsMake(-36, 0, 0, 0)
        
        tableView.register(AnonymouseTableViewCell.self, forCellReuseIdentifier: "StaticMessage")
        
        self.view.addSubview(tableView)
        
        let replyHeight: CGFloat = 50.0
        
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
        replyTextView.text = ""
        replyTextView.font = UIFont(name: "Helvetica", size: 16.0)!
        replyTextView.backgroundColor = UIColor.white
        replyTextView.contentSize = replyTextView.frame.size
        
        replyLabel = UILabel()
        replyLabel.font = replyTextView.font
        replyLabel.text = "Add a reply..."
        replyLabel.textColor = UIColor.lightGray
        replyLabel.sizeToFit()
        replyLabel.frame.origin.x = 10
        replyLabel.frame.origin.y = 8
        replyTextView.addSubview(replyLabel)
        
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
        
        let tapGestureRecognizer: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(AnonymouseDetailViewController.dismissKeyboard))
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
        dismissKeyboard()
        replyTextView.text = ""
        self.replyLabel.isHidden = false
        self.replyButton.isHidden = true
        if let parentNavigationController = self.navigationController as? AnonymouseNavigationStyleController {
            if let tableVC = parentNavigationController.viewControllers[0] as? AnonymouseTableViewController {
                tableVC.tableView.reloadData()
                return
            }
        }
    }
    //MARK: Button Methods
    func replyTapped() {
        replyButton.alpha = 0.5
        replyButton.isHidden = true
        replyTextView.text = ""
        self.replyLabel.isHidden = false
        dismissKeyboard()
    }
    
    func replySelected() {
        replyButton.alpha = 1.0
    }
    
    func replyReleased() {
        replyButton.alpha = 0.5
    }
    
    //MARK: TextView Methods
    func dismissKeyboard() {
        replyTextView.resignFirstResponder()
    }
    
    func textViewDidChange(_ textView: UITextView) {
        let testString: String = textView.text!.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
        replyButton.isHidden = testString.isEmpty
        replyLabel.isHidden = !textView.text.isEmpty
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
        return 1 //Needs to be number of replies
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section == 0 {
            if indexPath.row == 0 {
                let cell: AnonymouseTableViewCell = tableView.dequeueReusableCell(withIdentifier: "StaticMessage", for: indexPath) as! AnonymouseTableViewCell
                cell.preservesSuperviewLayoutMargins = false
                cell.layoutMargins = UIEdgeInsets.zero
                cell.frame.size.width = self.tableView.frame.width
                cell.createMessageLabel(withNumberOfLines: 0)
                
                cell.isInTable = false
                cell.data = cellData
                return cell
            }
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
        }
        return 0.0
    }
    
    //MARK: Keyboard Methods
    func keyboardWillShow(_ notification: Notification) {
        //        var info = (notification as NSNotification).userInfo!
        //        let keyboardFrame: CGRect = (info[UIKeyboardFrameEndUserInfoKey] as! NSValue).cgRectValue
    }
    
    func keyboardWillHide(_ notification: Notification) {
        
    }
}
