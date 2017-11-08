//
//  ThumbnailProvider.swift
//  VGASimulatorMobileThumbnailExtension
//
//  Created by Pedro José Pereira Vieito on 2/7/17.
//  Copyright © 2017 Pedro José Pereira Vieito. All rights reserved.
//

import UIKit
import QuickLook
import CoreGraphicsKit
import LoggerKit
import VGASimulatorKit

class VGAThumbnailProvider: QLThumbnailProvider {
    
    override func provideThumbnail(for request: QLFileThumbnailRequest, _ handler: @escaping (QLThumbnailReply?, Error?) -> Void) {
        
        // There are three ways to provide a thumbnail through a QLThumbnailReply. Only one of them should be used.
        Logger.log(debug: "Starting thumbnail request for \(request.fileURL.path)...")
        
        // Second way: Draw the thumbnail into a context passed to your block, set up with Core Graphics' coordinate system.
        handler(QLThumbnailReply(contextSize: request.maximumSize, drawing: { (context) -> Bool in
            // Draw the thumbnail here.
            do {
                Logger.log(debug: "Creating VGASimulation...")
                let simulation = try VGASimulation(url: request.fileURL)
                
                Logger.log(debug: "Rendering first VGASimulation frame...")
                
                guard let thumbnailFrame = simulation.frames.next() else {
                    Logger.log(error: "Error obtaining first VGASimulation frame.")
                    return false
                }
                
                Logger.log(debug: "Drawing frame in CGContext...")
                let contextRect = CGRect(origin: .zero, size: request.maximumSize.scaled(by: UIScreen.main.scale))
                context.draw(thumbnailFrame, in: contextRect)

                Logger.log(debug: "Returning CGContext...")
                return true
            }
            catch {
                Logger.log(error: error)
                return false
            }
            
            // Return true if the thumbnail was successfully drawn inside this block.
        }), nil)
        
        /*
        // Third way: Set an image file URL.
        handler(QLThumbnailReply(imageFileURL: Bundle.main.url(forResource: "fileThumbnail", withExtension: "jpg")!), nil)
        */
    }
}
