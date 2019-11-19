//
//  PreviewViewController.swift
//  VGASimulatorMobileQuickLookExtension
//
//  Created by Pedro José Pereira Vieito on 7/11/17.
//  Copyright © 2017 Pedro José Pereira Vieito. All rights reserved.
//

import UIKit
import QuickLook
import VGASimulatorKit
import VGASimulatorUI
import FoundationKit

class VGAQuickLookViewController: VGASimulationViewController, QLPreviewingController {
    func preparePreviewOfFile(at url: URL, completionHandler handler: @escaping (Error?) -> Void) {
        do {
            try self.loadSimulation(at: url, frameLimit: 1)
            handler(nil)
        }
        catch {
            handler(error.cocoaError)
        }
    }
}
