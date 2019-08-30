//
//  Segue0.swift
//  macStat
//
//  Created by Abraham Tarverdi on 8/30/19.
//  Copyright © 2019 Tarverdi Ent. All rights reserved.
//

import Foundation
import Cocoa

// Creates a Custom Storyboard Segue
class StoryBoardCustomSegue0: NSStoryboardSegue {
    
    override init(identifier: NSStoryboardSegue.Identifier,
                  source sourceController: Any,
                  destination destinationController: Any) {
        var myIdentifier : String
        
        if identifier.isEmpty {
            myIdentifier = ""
        } else {
            myIdentifier = identifier
        }
        
        super.init(identifier: NSStoryboardSegue.Identifier(myIdentifier), source: sourceController, destination: destinationController)
                    
    }
    
    override func perform() {
        
        let sourceViewController = self.sourceController as! NSViewController
        //debugPrint(sourceViewController.parent)
        let destinationViewController = self.destinationController as! NSViewController
        let containerViewController = sourceViewController.parent! as NSViewController
        
        containerViewController.insertChild(destinationViewController, at: 1)
        
        sourceViewController.view.wantsLayer = true
        destinationViewController.view.wantsLayer = true
        
        containerViewController.transition(from: sourceViewController, to: destinationViewController, options: NSViewController.TransitionOptions.crossfade, completionHandler: nil)
        
    }
    
}
