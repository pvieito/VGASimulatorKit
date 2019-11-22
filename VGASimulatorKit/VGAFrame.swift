//
//  VGAFrame.swift
//  VGASimulatorKit
//
//  Created by Pedro José Pereira Vieito on 14/4/18.
//  Copyright © 2018 Pedro José Pereira Vieito. All rights reserved.
//

import Foundation

public struct VGAFrame {
    enum FrameError: LocalizedError {
        case invalidBufferSize
        
        var errorDescription: String? {
            switch self {
            case .invalidBufferSize:
                return "Error creating frame. Resolution, channels and buffer size should match."
            }
        }
    }
    
    static let channels: Int = 4

    public let resolution: VGAResolution
    public internal(set) var pixelBuffer: [UInt8]

    private init(resolution: VGAResolution, pixelBuffer: [UInt8]) throws {
        guard resolution.width * resolution.height * VGAFrame.channels == pixelBuffer.count else {
            throw FrameError.invalidBufferSize
        }
        
        self.resolution = resolution
        self.pixelBuffer = pixelBuffer
    }
    
    init(resolution: VGAResolution) throws {
        let pixelBuffer = [UInt8](repeating: 0xFF, count: resolution.width * resolution.height * VGAFrame.channels)
        try self.init(resolution: resolution, pixelBuffer: pixelBuffer)
    }
}
