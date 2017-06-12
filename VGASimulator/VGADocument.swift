//
//  Document.swift
//  VGASimulator
//
//  Created by Pedro José Pereira Vieito on 6/6/17.
//  Copyright © 2017 Pedro José Pereira Vieito. All rights reserved.
//

import FoundationKit
import LoggerKit
import VGASimulatorKit

#if os(macOS)
    import Cocoa
    typealias UIDocument = NSDocument
#else
    import UIKit
#endif

class VGADocument: UIDocument {

    public weak var delegate: VGADocumentDelegate?
    
    var vgaSimulation: VGASimulation?
    var cancelProcessing = false
    var processingQueue = DispatchQueue(label: "com.pvieito.VGASimulator.frameProcessing")
    var availableFrames: [CGImage] = []
    
    private func openVGADocument(at url: URL) throws {
        do {
            self.cancelProcessing = false
            
            let vgaSimulation = try VGASimulation(url: url)
            self.vgaSimulation = vgaSimulation
            
            processingQueue.async {
                
                Logger.log(debug: "Document did start processing...")
                DispatchQueue.main.async {
                    self.delegate?.documentDidStartProcessing()
                }
                
                for (index, frame) in vgaSimulation.frames.enumerated() {
                    
                    guard !self.cancelProcessing else {
                        Logger.log(debug: "Simulation was cancelled.")
                        return
                    }
                    
                    self.availableFrames.append(frame)
                    
                    Logger.log(debug: "Simulation frame \(index) loaded...")
                    DispatchQueue.main.async {
                        self.delegate?.document(self, didLoad: frame, at: index)
                    }
                }
                
                Logger.log(debug: "Document end processing.")
                DispatchQueue.main.async {
                    self.delegate?.documentDidEndProcessing()
                }
            }
        }
        catch {
            throw error.cocoaError
        }
    }
    
    private func closeVGADocument() {
        self.vgaSimulation = nil
        self.cancelProcessing = true
    }
}

#if os(iOS)
    extension VGADocument {
        
        override func read(from url: URL) throws {
            try self.openVGADocument(at: url)
        }
        
        override func close(completionHandler: ((Bool) -> Void)? = nil) {
            self.closeVGADocument()
            super.close(completionHandler: completionHandler)
        }
    }
#endif

#if os(macOS)
    extension VGADocument {
        
        override func read(from url: URL, ofType typeName: String) throws {
            try self.openVGADocument(at: url)
        }
        
        override func close() {
            self.closeVGADocument()
            super.close()
        }
        
        override func makeWindowControllers() {
            // Returns the Storyboard that contains your Document window.
            let storyboard = NSStoryboard(name: NSStoryboard.Name("Main"), bundle: nil)
            let windowController = storyboard.instantiateController(withIdentifier: NSStoryboard.SceneIdentifier("VGADocumentWindowController")) as! NSWindowController
            self.addWindowController(windowController)
            
            let documentViewController = windowController.contentViewController as? VGADocumentViewController
            documentViewController?.representedObject = vgaSimulation
            self.delegate = documentViewController
        }
    }
#endif

