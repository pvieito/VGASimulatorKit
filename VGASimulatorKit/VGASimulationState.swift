//
//  VGASimulationState.swift
//  VGASimulatorKit
//
//  Created by Pedro José Pereira Vieito on 8/11/17.
//  Copyright © 2017 Pedro José Pereira Vieito. All rights reserved.
//

import Foundation
import VGASimulatorCore

extension VGASimulationState {
    
    init(simulationFile: UnsafeMutablePointer<FILE>) {
        self.init(simulationFile: simulationFile, backPorchXCounter: 0, backPorchYCounter: 0, hCounter: 0, vCounter: 0, frameCounter: 0, lastOutput: VGAOutput(), nextOutput: VGAOutput())
    }
}
