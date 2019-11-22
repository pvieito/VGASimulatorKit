//
//  VGAOuput.swift
//  VGASimulatorKit
//
//  Created by Pedro José Pereira Vieito on 8/11/17.
//  Copyright © 2017 Pedro José Pereira Vieito. All rights reserved.
//

import Foundation
import VGASimulatorCore

extension VGAOutput {
    init() {
        self.init(hSync: false, vSync: false, red: 0, green: 0, blue: 0)
    }
}
