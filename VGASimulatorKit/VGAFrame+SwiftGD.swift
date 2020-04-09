//
//  VGAFrame+CGImage.swift
//  VGASimulatorKit
//
//  Created by Pedro José Pereira Vieito on 10/04/2020.
//  Copyright © 2020 Pedro José Pereira Vieito. All rights reserved.
//

#if !(canImport(CoreGraphics) && !NO_COREGRAPHICS) && canImport(SwiftGD) && !NO_SWIFTGD
import Foundation
import SwiftGD

extension VGAFrame {
    private enum SwiftGDRenderError: LocalizedError {
        case imageSaveError(URL)
        case imageRenderError
        
        var errorDescription: String? {
            switch self {
            case .imageSaveError(let url):
                return "Error saving SwiftGD image at “\(url.path)”."
            case .imageRenderError:
                return "Error rendering SwiftGD image."
            }
        }
    }
    
    private func gdImage() throws -> SwiftGD.Image {
        guard let image = Image(width: self.resolution.width, height: self.resolution.height) else {
            throw SwiftGDRenderError.imageRenderError
        }

        for x in 0..<self.resolution.width {
            for y in 0..<self.resolution.height {
                let point = Point(x: x, y: y)
                let bufferOffset = (self.resolution.width * y + x) * 4
                let color = Color(
                    red: Double(self.pixelBuffer[bufferOffset]) / Double(UInt8.max),
                    green: Double(self.pixelBuffer[bufferOffset + 1]) / Double(UInt8.max),
                    blue: Double(self.pixelBuffer[bufferOffset + 2]) / Double(UInt8.max),
                    alpha: Double(self.pixelBuffer[bufferOffset + 3]) / Double(UInt8.max))
                image.set(pixel: point, to: color)
            }
        }
        
        return image
    }
    
    public func write(to url: URL) throws {
        guard try self.gdImage().write(to: url, allowOverwrite: true) else {
            throw SwiftGDRenderError.imageSaveError(url)
        }
    }
}
#endif
