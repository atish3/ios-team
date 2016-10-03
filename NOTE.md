Note/guide for for teammates. Hope this note helps, for it took me a while to figure these out.

## Installation Guide

1. Make sure your macOS, Xcode, iOS are in the latest version.
2. Clone this repo.
3. Run in the root directory of the repo.

	```
	git submodule init
	git submodule update --remote
	```

4. Hit `Anonymouse/Anonymouse.xcodeproj` to open it in Xcode.
(`MCConnect` and `MCtests` are for unit test)

5. Plug your iPhone to the Mac. Trust!

## Directory Structure
### THE MAIN
* AppDelegate.swift

### View Controller
* AnonymouseNavigationController.swift // controls the first view
* AnonymouseTableViewController.swift
	* AnonymouseTableViewCell.swift
* AnonymouseComposeViewController.swift
* SecondViewController.swift

### Connection Related
* AnonymouseConnectivityController.swift

### Data Related
* AnonymouseMessage.swift
* AnonymouseMessageCore.swift
* AnonymouseMessageCore+CoreDataProperties.swift // manages Core Data and AnonymouseMeesageCore.swift
* Anonymouse.xcdatamodeld

### UI Related
* Assets.xcassets/
* *.storyboard
