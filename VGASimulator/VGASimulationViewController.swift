//
//  ViewController.swift
//  VGASimulator
//
//  Created by Pedro José Pereira Vieito on 6/6/17.
//  Copyright © 2017 Pedro José Pereira Vieito. All rights reserved.
//

import Cocoa
import LoggerKit
import CoreGraphicsKit
import VGASimulatorKit

class VGASimulationViewController: NSViewController {

    @IBOutlet weak var loadingFrameLabel: NSTextField!
    @IBOutlet weak var activityIndicatorView: NSProgressIndicator!
    
    override func viewDidAppear() {
        super.viewDidAppear()

        view.window?.isMovableByWindowBackground = true
        view.window?.titlebarAppearsTransparent = true
    }

    @discardableResult
    override func presentError(_ error: Error) -> Bool {

        Logger.log(error: error)
        if let window = self.view.window {
            self.presentError(error, modalFor: window, delegate: nil, didPresent: nil, contextInfo: nil)
        }
        else {
            return super.presentError(error)
        }

        return false
    }
}

extension VGASimulationViewController: VGADocumentDelegate {
    
    func documentDidStartProcessing() {
        self.loadingFrameLabel.stringValue = "Loading frame 0..."
        
        self.activityIndicatorView.startAnimation(self)
    }
    
    func document(_ document: VGADocument, didLoad frame: CGImage, at index: Int) {
        self.loadingFrameLabel.stringValue = "Loading frame \(index + 1)..."
        
        do {
            let imageFile = try frame.temporaryFile(format: .png)
            NSWorkspace.shared.open(imageFile)
        }
        catch {
            self.presentError(error)
        }
    }
    
    func documentDidEndProcessing() {
        self.activityIndicatorView.stopAnimation(self)
        
        self.view.window?.close()
    }
}
