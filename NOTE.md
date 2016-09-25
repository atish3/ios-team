Note/guide for for teammates. Hope this note helps, for it took me a while to figure these out.

## Installation Guide

1. Make sure your macOS, Xcode, iOS are in the latest version.
2. Clone this repo.
3. Run in the root directory of the repo.

	```
	git submodule init
	git submodule update --remote
	```

4. Hit `Roar/Roar.xcodeproj` to open it in Xcode.
(`MCConnect` and `MCtests` are for unit test)

5. Plug your iPhone to the Mac. Trust!

## Directory Structure
### THE MAIN
* AppDelegate.swift

### View Controller
* RoarNavigationController.swift // controls the first view
* RoarTableViewController.swift
	* RoarTableViewCell.swift
* RoarComposeViewController.swift
* SecondViewController.swift

### Connection Related
* RoarConnectivityController.swift

### Data Related
* RoarMessage.swift
* RoarMessageCore.swift
* RoarMessageCore+CoreDataProperties.swift // manages Core Data and RoarMeesageCore.swift
* Roar.xcdatamodeld

### UI Related
* Assets.xcassets/
* *.storyboard
