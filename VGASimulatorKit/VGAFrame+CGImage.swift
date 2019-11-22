//
//  VGAFrame+CGImage.swift
//  VGASimulatorKit
//
//  Created by Pedro José Pereira Vieito on 14/4/18.
//  Copyright © 2018 Pedro José Pereira Vieito. All rights reserved.
//

#if canImport(CoreGraphics)
import Foundation
import CoreGraphics

extension VGAFrame {
    public enum RenderError: LocalizedError {
        case contextNotAvailable
        case imageNotAvailable
        
        public var errorDescription: String? {
            switch self {
            case .contextNotAvailable:
                return "Error creating Core Graphics context."
            case .imageNotAvailable:
                return "Error rendering Core Graphics image."
            }
        }
    }
    
    public func cgImage() throws -> CGImage {
        var pixelBuffer = self.pixelBuffer
        guard let context = CGContext(
            data: &pixelBuffer,
            width: self.resolution.width,
            height: self.resolution.height,
            bitsPerComponent: 8,
            bytesPerRow: self.resolution.width * VGAFrame.channels,
            space: CGColorSpaceCreateDeviceRGB(),
            bitmapInfo: CGImageAlphaInfo.noneSkipLast.rawValue) else {
                throw RenderError.contextNotAvailable
        }
        
        guard let cgImage = context.makeImage() else {
            throw RenderError.contextNotAvailable
        }
        
        return cgImage
    }
}
#endif
