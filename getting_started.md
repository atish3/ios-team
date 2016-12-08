# Getting Started Guide
**Update:** 12/8/2016  
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
* `AppDelegate.swift` // This is where the whole app starts

### View Controller
* `AnonymouseTabBarController.swift` // This is where all the other view controllers located. There is a bit of UI settings here too.
* `ViewControllers`
	* `AnonymouseSettingViewController.swift`
	* `AnonymouseProfileViewController.swift`
	* `AnonymouseComposeViewController.swift`
	* `AnonymouseTableViewController.swift` // This is a class that displays a bunch of AnonymouseTableViewCells.swift
	* `AnonymouseDetailViewController.swift`
	
### Connection Related
* `Model/Connection/`
	* `AnonymouseConnectivityController.swift`

### Data Related
* `Model/Data/`
	* `AnonymouseDataController.swift`
	* `Anonymouse+CoreDataProperties.swift`
	* `AnonymouseMessageCore.swift`
	* `Anonymouse.xcdatamodeld`

### UI Related
* `AnonymouseNavigationStyleController.swift`
* `AnonymosueTableViewCell.swift`
* `AnonymosueReplyViewCell.swift`
* `Assets.xcassets/`
* `LaunchScreen.storyboard`

**Note that we are writing codes for all UI instead of using storyboard up till now.**


## Other Suggestions
* Design the function interface beforehand. This would help collaboration greatly.
* Read the [official documentation](https://developer.apple.com/)! Google and StackOverFlow are also your good friends.
* Write comments for your codes. Remember you are not developing alone. 

## Team Members that Participated Before
* Pascal
* Qinye Li qinyeli@umich.edu
* Yufan Sun yufansun@umich.edu
* Kevin
* Tyler
