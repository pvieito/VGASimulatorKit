//
//  VGAMode.swift
//  VGASimulator
//
//  Created by Pedro José Pereira Vieito on 25/5/17.
//  Copyright © 2017 Pedro José Pereira Vieito. All rights reserved.
//

import Foundation

public struct VGAMode: CustomStringConvertible {
    public let resolution: VGAResolution
    public let refreshRate: Double

    let backPorchX = 318
    let backPorchY = 38

    public static let vesa1280x1024_60 = VGAMode(width: 1280, height: 1024, refreshRate: 60)

    public var pixelClockFrequency: Double {
        return Double(self.resolution.pixels) * self.refreshRate
    }

    public init(width: Int, height: Int, refreshRate: Double = 60) {
        self.resolution = VGAResolution(width: width, height: height)
        self.refreshRate = refreshRate
    }

    public var description: String {
        return "\(self.resolution)@\(self.refreshRate)"
    }
}
