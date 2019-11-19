//
//  ThumbnailProvider.swift
//  VGASimulatorMobileThumbnailExtension
//
//  Created by Pedro José Pereira Vieito on 2/7/17.
//  Copyright © 2017 Pedro José Pereira Vieito. All rights reserved.
//

import QuickLookThumbnailing
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
                
                guard let thumbnailImage = try simulation.frames.next()?.cgImage() else {
                    Logger.log(error: "Error obtaining first VGASimulation frame.")
                    return false
                }
                
                Logger.log(debug: "Drawing frame in CGContext...")
                let boundingBox = CGRect(origin: .zero, size: request.maximumSize)

                let thumbnailSize = CGSize(ratio: thumbnailImage.ratio, boundingBoxSize: boundingBox.size)

                let contextRect = CGRect(size: thumbnailSize, centeredOn: boundingBox)
                context.draw(thumbnailImage, in: contextRect)

                Logger.log(debug: "Returning CGContext...")
                return true
            }
            catch {
                Logger.log(error: error)
                return false
            }
            
            // Return true if the thumbnail was successfully drawn inside this block.
        }), nil)
    }
}
