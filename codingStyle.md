# Coding Style Guidelines
## General
### Brackets
- Put the initial bracket of a function, loop, or control statement on the same line as the beginning code block. E.g
```
if !didReceiveRequest { //Do this

if !didReceiveRequest 
{ //Don't do this!
```
### Spacing
- Put exactly one empty line between blocks of code that are unrelated but appear in the same scope contiguously. For example:
```
NotificationCenter.default.addObserver(self, selector: #selector(RoarComposeViewController.keyboardWillShow(_:)), name:NSNotification.Name.UIKeyboardWillShow, object: nil);
NotificationCenter.default.addObserver(self, selector: #selector(RoarComposeViewController.keyboardWillHide(_:)), name:NSNotification.Name.UIKeyboardWillHide, object: nil);
    
self.navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.cancel, target: self, action: #selector(RoarComposeViewController.cancelTapped))
self.navigationItem.leftBarButtonItem?.tintColor=UIColor.white
self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Post", style: .done, target: self, action: #selector(RoarComposeViewController.postTapped))
self.navigationItem.rightBarButtonItem?.tintColor=UIColor.white
self.navigationItem.rightBarButtonItem!.isEnabled = false
```
Doing this helps code readability.
- Never put two empty lines next to each other.
- Put exactly one space between a function parameters name and the name of the passed variable.

### Storyboard
- Only use if absolutely necessary. Otherwise, avoid like the plague. Everything done in the storyboard could also have been done through code!

### Github
- Don't push to the master branch! Make pull requests from other branches, and I will review the requests before accepting the new changes. 

## Variable Conventions
### Type Inference
- Avoid type inference at all costs. Instead of `let myServiceType = "MDP-broadcast"`, write `let myServiceType: String = "MDP-broadcast"`. This way, the type of the variable is not inferred by the compiler but explicitly written, making code more understandable and easier to compile.

### Naming
- Use camelCase for all variable names. That is, all variable names should begin with a lower-case letter, and each subsequent word in the name should begin with a capital letter. For example, `newMessagesReceived` is in camelCase.
- Use descriptive names. A programmer should be able to figure out the purpose of a variable just from its name. 
- Prioritize understandability of variable names over conciseness. The variable name `fetchedResultsController` may be long, but it is much better than `frc`. 

### Scope
- Reduce variable scope to the smallest possible scope necessary.
- Absolutely **no global variables or functions**. All variables and functions belong in class declarations.

## Functions 
### Scope
- As said above, **no global variables or functions**, period.

### Naming
- Functions names should be descriptive. A function name should tell a programmer everything that the function does. 
- It is more important for function names to be descriptive than short.
- All functions should have descriptive variable parameters both for the function programmer and the programmers who call the function. For example `func broadcastHashMessageDictionary(toRequester id: MCPeerID, excludingHashes hashArray: [String])` has internal parameter names `id` and `hashArray`, allowing the function's code to be easily understood; it has has external parameter names `toRequester` and `excludingHashes` so that, when called, the function reads like english. 

## Classes
### Naming
- Same as variables and functions. Make the names descriptive! 

### Protocols/Inheritance
- Do not conform to arbitrary protocols.
- Inherit from the most specific class possible in the class hierarchy. 
