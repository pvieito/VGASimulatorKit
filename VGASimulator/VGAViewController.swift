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

class VGAViewController: NSViewController {

    @IBOutlet weak var loadingFrameLabel: NSTextField!
    @IBOutlet weak var progressIndicator: NSProgressIndicator!

    var processingQueue = DispatchQueue(label: "com.pvieito.VGASimulator.frameProcessing")

    var vgaSimulation: VGASimulation? {
        return self.representedObject as? VGASimulation
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func viewDidAppear() {
        super.viewDidAppear()

        view.window?.isMovableByWindowBackground = true
        view.window?.titlebarAppearsTransparent = true
        self.progressIndicator.startAnimation(self)
    }

    override var representedObject: Any? {
        didSet {
            // Update the view, if already loaded.
            self.processingQueue.async {
                if let vgaSimulation = self.vgaSimulation {
                    for (frameCount, frame) in vgaSimulation.frames.enumerated() {

                        DispatchQueue.main.async {
                            Logger.log(info: "Frame \(frameCount) decoded")
                            self.loadingFrameLabel.stringValue = "Loading frame \(frameCount)..."
                        }

                        do {
                            let imageFile = try frame.temporaryFile(format: .png)
                            NSWorkspace.shared.open(imageFile)
                        }
                        catch {
                            self.presentError(error)
                        }
                    }
                }

                DispatchQueue.main.async {
                    self.view.window?.close()
                }
            }
        }
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
