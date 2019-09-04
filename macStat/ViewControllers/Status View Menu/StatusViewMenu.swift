//
//  StatusViewMenu.swift
//  macStat
//
//  Created by Abraham Tarverdi on 8/30/19.
//  Copyright © 2019 Tarverdi Ent. All rights reserved.
//
import Cocoa
import Foundation

class StatusViewController: NSViewController {
    

    @IBOutlet weak var mainStatusText: NSTextField!
    @IBOutlet weak var mainStatusIcon: NSImageView!
    
     // Open the status window
    @IBAction func openStatusWindow(_ sender: Any) {
        logger.write("Clicked Open Button")
        let appDelegate = NSApplication.shared.delegate as! AppDelegate
        NSApplication.shared.keyWindow?.close()
        view.window?.close()
        
        appDelegate.popover.close()
        appDelegate.popover.accessibilityActivationPoint()
        view.removeFromSuperview()
        logger.write("User clicked Full Status Window button.")
    }
   

    /*func openNewWindow() {
     var myWindow: NSWindow? = nil
     let storyboard = NSStoryboard(name: "FullAppWindowID",bundle: nil)
     let controller: EditorViewController = storyboard.instantiateController(withIdentifier: "statusWindow") as! ViewController
     myWindow = NSWindow(contentViewController: controller)
     myWindow?.makeKeyAndOrderFront(self)
     let vc = NSWindowController(window: myWindow)
     vc.showWindow(self)
     }*/
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do view setup here.
        //openStatusWindowButton.isEnabled = false
        mainStatusIcon.image = #imageLiteral(resourceName: "warning")
        
    }
    
    override func viewDidAppear() {
        super.viewDidAppear()
        mainStatusIcon.image = #imageLiteral(resourceName: "warning")
        //openStatusWindowButton.isEnabled = true
        if checkState() {
            mainStatusText.stringValue = "GOOD: System in Compliance."
            mainStatusIcon.image = #imageLiteral(resourceName: "good")
        } else {
            mainStatusText.stringValue = "Error: System out of compliance."
            mainStatusIcon.image = #imageLiteral(resourceName: "bad")
        }
        
    }
    
    override func viewDidDisappear() {
        super.viewDidDisappear()
        
    }
    
    func checkState() -> Bool {
        for item in checkObjectsDict {
            //debugPrint(item.value)
            if item.value.success == false {
                return false
            }
        }
        return true
    }
}

extension StatusViewController {
    // MARK: Storyboard instantiation
    static func freshController(controllerName: String) -> StatusViewController {
        //1.
        let storyboard = NSStoryboard(name: NSStoryboard.Name("Main"), bundle: nil)
        //let storyboard = NSStoryboard(name: NSStoryboard.Name(rawValue: "Main"), bundle: nil)
        //2.
        let identifier = NSStoryboard.SceneIdentifier(controllerName)
        //let identifier = NSStoryboard.SceneIdentifier(rawValue: controllerName)
        //3.
        guard let viewcontroller = storyboard.instantiateController(withIdentifier: identifier) as? StatusViewController else {
            fatalError("Why cant i find StatusViewController? - Check Main.storyboard")
        }
        return viewcontroller
    }
}
