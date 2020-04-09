//
//  VGAFrame+CGImage.swift
//  VGASimulatorKit
//
//  Created by Pedro José Pereira Vieito on 14/4/18.
//  Copyright © 2018 Pedro José Pereira Vieito. All rights reserved.
//

#if canImport(CoreGraphics) && !NO_COREGRAPHICS
import Foundation
import CoreGraphics
import CoreGraphicsKit

extension VGAFrame {
    private enum CoreGraphicsRenderError: LocalizedError {
        case contextNotAvailable
        
        var errorDescription: String? {
            switch self {
            case .contextNotAvailable:
                return "Error creating Core Graphics context."
            }
        }
    }
    
    private func cgImage() throws -> CGImage {
        var pixelBuffer = self.pixelBuffer
        guard let context = CGContext(
            data: &pixelBuffer,
            width: self.resolution.width,
            height: self.resolution.height,
            bitsPerComponent: 8,
            bytesPerRow: self.resolution.width * VGAFrame.channels,
            space: CGColorSpaceCreateDeviceRGB(),
            bitmapInfo: CGImageAlphaInfo.noneSkipLast.rawValue) else {
                throw CoreGraphicsRenderError.contextNotAvailable
        }
        
        guard let cgImage = context.makeImage() else {
            throw CoreGraphicsRenderError.contextNotAvailable
        }
        
        return cgImage
    }
    
    public func write(to url: URL) throws {
        try self.cgImage().write(to: url, format: .png)
    }
}
#endif
