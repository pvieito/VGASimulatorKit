//
//  VGAResolution.swift
//  VGASimulator
//
//  Created by Pedro José Pereira Vieito on 25/5/17.
//  Copyright © 2017 Pedro José Pereira Vieito. All rights reserved.
//

import Foundation

public struct VGAResolution: CustomStringConvertible {
    public let width: Int
    public let height: Int

    public var pixels: Int {
        return self.width * self.height
    }

    public var description: String {
        return "\(self.width)×\(self.height)"
    }
}
