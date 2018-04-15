//
//  VGAMode.swift
//  VGASimulator
//
//  Created by Pedro José Pereira Vieito on 25/5/17.
//  Copyright © 2017 Pedro José Pereira Vieito. All rights reserved.
//

import Foundation

public struct VGAMode: CustomStringConvertible {
    public static let vesa1280x1024_60 = VGAMode(width: 1280, height: 1024, backPorchX: 318, backPorchY: 38, refreshRate: 60)
    public static let vesa640x480_60 = VGAMode(width: 640, height: 480, backPorchX: 48, backPorchY: 33, refreshRate: 60)

    public let resolution: VGAResolution
    public let refreshRate: Double

    let backPorchX: Int
    let backPorchY: Int

    public var pixelClockFrequency: Double {
        return Double(self.resolution.pixels) * self.refreshRate
    }
    
    public init(resolution: VGAResolution, backPorchX: Int, backPorchY: Int, refreshRate: Double = 60) {
        self.resolution = resolution
        self.backPorchX = backPorchX
        self.backPorchY = backPorchY
        self.refreshRate = refreshRate
    }

    public init(width: Int, height: Int, backPorchX: Int, backPorchY: Int, refreshRate: Double = 60) {
        let resolution = VGAResolution(width: width, height: height)
        self.init(resolution: resolution, backPorchX: backPorchX, backPorchY: backPorchY, refreshRate: refreshRate)
    }

    public var description: String {
        return "\(self.resolution)@\(self.refreshRate)"
    }
}
