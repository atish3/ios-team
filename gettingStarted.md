# Getting Started Guide
**Update:** 12/26/2016
**Description:** This is a note/guide for for teammates. Hope this note helps, for it took me a while to figure these out.

## Preparations
* Register your apple account as a developer.

## Installation Guide

1. Make sure your macOS, Xcode, iOS are in the latest version. I mean it. The LATEST. (Keep them updated all the time)
2. Clone this repo.
3. Run in the root directory of the repo.

	```
	git submodule init
	git submodule update --remote
	```

4. Hit `Anonymouse/Anonymouse.xcodeproj` to open it in Xcode.

5. Plug your iPhone to the Mac. Trust!

## Directory Structure
### THE MAIN
* `AppDelegate.swift` 
This class contains the entire app. It manages the methods that relate to app execution, such as handling background execution, and managing application states, such as foreground and background transition. It also contains the tab bar controller, the data controller and the connectivity controller.

### Controllers
* `AnonymouseTabBarController.swift`
The main container class. It manages the tabs at the bottom of the view. It contains instances of navigation controllers that contain view controllers. It applies an orange gradient to the tab bar. 

* `AnonymouseNavigationStyleController.swift`
This class is the default class that inherits from navigation controller. It applies an orange gradient to the nav bar. 

#### View Controllers
* `AnonymouseSettingViewController.swift`
This class contains the settings of the app, such as being able to change the username and toggle the connectivity settings.
* `AnonymouseProfileViewController.swift`
This class manages the user being able to change their username.
* `AnonymouseComposeViewController.swift`
This class contains the compose view, which allows a user to post a new message to the feed.
* `AnonymouseTableViewController.swift`
This class displays the main messages on the feed, filtered and ordered depending on fetch request.
* `AnonymouseDetailViewController.swift`
This class displays a message in detail, and its replies in a table view. 
	
### Connection Related
* `AnonymouseConnectivityController.swift`
This class manages the connection protocols, sending and receiving messages, replies and rating objects to nearby peers.
* `AnonymouseMessageSentCore.swift`
This class represents a message that is sent to a nearby peer.
* `AnonymouseReplySentCore.swift`
This class represents a reply that is sent to a nearby peer. 
* `AnonymouseRatingSentCore.swift`
This class represents a rating object that is sent to a nearby peer.

### Data Related
* `AnonymouseDataController.swift`
This class manages the data protocols, such as saving messages and replies to the disk. 
* `AnonymouseMessageCore.swift`
This class represents a message that is stored to the disk.
* `AnonymouseMessageCore+CoreDataProperties.swift`
Extends the message core class to have `NSManaged` properties.
* `AnonymouseReplyCore+CoreDataClass.swift`
This class represents a reply that is stored to the disk.
* `AnonymouseReplyCore+CoreDataProperties.swift`
Extends the reply core class that is stored to the disk.
* `Anonymouse.xcdatamodeld`
Manages the core data entities and their relationships (message - reply).

### UI Related
* `AnonymosueTableViewCell.swift`
This class represents a single message on the feed, and defines the UI properties of each message.
* `AnonymosueReplyViewCell.swift`
This class represents a single reply to a message, and defines the UI properties of that reply.

## Other Suggestions
* Design the function interface beforehand. This would help collaboration greatly.
* Read the [official documentation](https://developer.apple.com/)! Google and StackOverFlow are also your good friends.
* Write comments for your codes. Remember you are not developing alone. 

## Team Members that Participated Before
* Pascal psturm@umich.edu
* Qinye Li qinyeli@umich.edu
* Yufan Sun yufansun@umich.edu
* Kevin
* Tyler
