//
//  Document.swift
//  VGASimulatorMobile
//
//  Created by Pedro José Pereira Vieito on 10/6/17.
//  Copyright © 2017 Pedro José Pereira Vieito. All rights reserved.
//

import UIKit
import FoundationKit
import VGASimulatorKit
import LoggerKit

class VGADocument: UIDocument {
    
    var delegate: VGADocumentDelegate?
    
    var vgaSimulation: VGASimulation?
    var cancelProcessing = false
    
    var processingQueue = DispatchQueue(label: "com.pvieito.VGASimulator.frameProcessing")
    var availableFrames: [CGImage] = []
    
    override func read(from url: URL) throws {
        do {
            let vgaSimulation = try VGASimulation(url: url)
            self.vgaSimulation = vgaSimulation
            
            processingQueue.async {
                
                DispatchQueue.main.async {
                    Logger.log(debug: "Document did start processing...")
                    self.delegate?.documentDidStartProcessing()
                }
                
                for (index, frame) in vgaSimulation.frames.enumerated() {
                    
                    guard !self.cancelProcessing else {
                        break
                    }
                    
                    self.availableFrames.append(frame)
                    
                    DispatchQueue.main.async {
                        Logger.log(debug: "Simulation frame \(index) loaded...")
                        self.delegate?.document(self, didLoad: frame, at: index)
                    }
                }
                
                DispatchQueue.main.async {
                    Logger.log(debug: "Document end processing.")
                    self.delegate?.documentDidEndProcessing()
                }
            }
        }
        catch {
            throw error.cocoaError
        }
    }
    
    override func close(completionHandler: ((Bool) -> Void)? = nil) {
        self.vgaSimulation = nil
        self.cancelProcessing = true
        
        super.close(completionHandler: completionHandler)
    }
}

