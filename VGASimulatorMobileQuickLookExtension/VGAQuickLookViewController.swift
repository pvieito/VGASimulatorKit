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
    
    /*
     * Implement this method if you support previewing files.
     * Add the supported content types to the QLSupportedContentTypes array in the Info.plist of the extension.
     */
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
